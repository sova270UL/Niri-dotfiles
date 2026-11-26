#!/usr/bin/env python3
import argparse
import json
import os
import select
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HEADSET_ID = ("0x3837", "0x6045")
MOUSE_ID = (0x1D57, 0xFA60)
KEYBOARD_ID = (0x3554, 0xFA09)
KEYBOARD_CHANNEL = bytes([0x06, 0x02, 0xFF, 0x09, 0x02, 0xA1, 0x01, 0x85, 0x13])
DEBUG = False


def log(source, message):
    if DEBUG:
        print(f"{time.strftime('%T')} {source}: {message}", file=sys.stderr, flush=True)


def result(status, level=None):
    return {"online": status in ("discharging", "charging", "full"), "level": level, "status": status}


def hid_nodes(vid, pid):
    nodes = []
    for entry in sorted(Path("/sys/class/hidraw").glob("hidraw*")):
        try:
            uevent = (entry / "device/uevent").read_text()
            fields = dict(line.split("=", 1) for line in uevent.splitlines() if "=" in line)
            _, found_vid, found_pid = (int(x, 16) for x in fields["HID_ID"].split(":"))
            if (found_vid, found_pid) == (vid, pid):
                descriptor = (entry / "device/report_descriptor").read_bytes()
                nodes.append((f"/dev/{entry.name}", descriptor))
        except (OSError, KeyError, ValueError):
            continue
    return nodes


def read_headset():
    try:
        output = subprocess.run(
            ["headsetcontrol", "-b", "-o", "json"], capture_output=True, text=True, timeout=10
        ).stdout
        devices = json.loads(output)["devices"]
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError, KeyError):
        return result("error")

    for device in devices:
        if (device.get("id_vendor"), device.get("id_product")) != HEADSET_ID:
            continue
        battery = device.get("battery", {})
        status = {"BATTERY_AVAILABLE": "discharging", "BATTERY_CHARGING": "charging"}.get(battery.get("status"))
        return result(status, battery["level"]) if status else result("offline")
    return result("absent")


def decode_mouse(frame):
    if len(frame) != 5 or frame[:2] != b"\x03\x55" or frame[2] not in (0x40, 0x41):
        return None
    status = {1: "discharging", 2: "full", 3: "charging"}.get(frame[3])
    if status is None or frame[4] > 100:
        return None
    return result(status, frame[4])


def read_mouse(timeout=5.0):
    nodes = hid_nodes(*MOUSE_ID)
    if not nodes:
        return result("absent")

    fds = []
    for path, _ in nodes:
        try:
            fds.append(os.open(path, os.O_RDONLY | os.O_NONBLOCK))
        except OSError:
            pass
    if not fds:
        return result("no_access")

    readings = []
    deadline = time.monotonic() + timeout
    try:
        while len(readings) < 2 and (left := deadline - time.monotonic()) > 0:
            for fd in select.select(fds, [], [], left)[0]:
                frame = os.read(fd, 64)
                if frame[:2] == b"\x03\x55":
                    log("mouse", frame.hex(" "))
                reading = decode_mouse(frame)
                if reading:
                    readings.append(reading)
    except OSError:
        return result("error")
    finally:
        for fd in fds:
            os.close(fd)
    # The first frame after opening may falsely report 100 %, so it is never used alone.
    return readings[-1] if len(readings) >= 2 else result("offline")


def keyboard_request():
    packet = bytearray(20)
    packet[:3] = 0x13, 0x4A, 0x01
    packet[19] = sum(packet[:19]) & 0xFF
    return bytes(packet)


def decode_keyboard(frame):
    if len(frame) < 20 or frame[0] != 0x13 or frame[1] & 0x7F != 0x4A or frame[2] & 0x80:
        return None
    if sum(frame[:19]) & 0xFF != frame[19]:
        return None
    if frame[6] == 0x10:
        return result("charging")
    if frame[6] == 0x01 and 1 <= frame[5] <= 100:
        return result("discharging", frame[5])
    return None


def keys_held(report):
    if len(report) == 8:
        return bool(report[0] or any(report[2:7]))
    if report[:1] == b"\x04":
        return any(report[1:])
    return None


def wait_keys_released(fds, quiet=0.4, limit=3.0):
    held = {}
    start = last_key = time.monotonic()
    while (now := time.monotonic()) - start < limit:
        for fd in select.select(fds, [], [], 0.05)[0]:
            report = os.read(fd, 64)
            state = keys_held(report)
            if state is None:
                log("keyboard", f"other report: {report.hex(' ')}")
            else:
                log("keyboard", f"key report, length {len(report)}, held={state}")
                held[fd] = state
                last_key = time.monotonic()
        if not any(held.values()) and time.monotonic() - last_key >= quiet:
            return True
    return False


def read_keyboard():
    nodes = hid_nodes(*KEYBOARD_ID)
    channel = next((path for path, desc in nodes if KEYBOARD_CHANNEL in desc), None)
    if channel is None:
        return result("absent")

    fds = {}
    try:
        for path, _ in nodes:
            mode = os.O_RDWR if path == channel else os.O_RDONLY
            fds[path] = os.open(path, mode | os.O_NONBLOCK)

        status = "busy"
        for _ in range(3):
            if not wait_keys_released(list(fds.values())):
                continue
            status = "offline"
            fd = fds[channel]
            os.write(fd, keyboard_request())
            deadline = time.monotonic() + 0.5
            while (left := deadline - time.monotonic()) > 0:
                if select.select([fd], [], [], left)[0]:
                    frame = os.read(fd, 64)
                    log("keyboard", f"reply: {frame.hex(' ')}")
                    reading = decode_keyboard(frame)
                    if reading:
                        return reading
        return result(status)
    except PermissionError:
        return result("no_access")
    except OSError:
        return result("error")
    finally:
        for fd in fds.values():
            os.close(fd)


def read_all():
    readers = {"headset": read_headset, "mouse": read_mouse, "keyboard": read_keyboard}
    with ThreadPoolExecutor(max_workers=len(readers)) as pool:
        jobs = {name: pool.submit(reader) for name, reader in readers.items()}
        return {name: job.result() for name, job in jobs.items()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--watch", type=float, metavar="SECONDS")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()
    global DEBUG
    DEBUG = args.debug

    last_levels = {}
    while True:
        data = read_all()
        for name, device in data.items():
            if device["level"] is not None:
                last_levels[name] = device["level"]
            elif device["status"] in ("offline", "busy"):
                device["level"] = last_levels.get(name)
        print(json.dumps(data), flush=True)
        if args.watch is None:
            break
        time.sleep(args.watch)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
