#!/usr/bin/env python3
import json
import os
import subprocess
import threading
import time
from pathlib import Path

import periph_battery as battery

BLUETOOTH_PREFIX = "bluez_output."
HEADSET_PREFIX = "alsa_output.usb-C-Media_Electronics_Inc_MCHOSE_X9_0123456789AB"
SPEAKERS = "alsa_output.pci-0000_07_00.6.analog-stereo"

HEADSET_INTERVAL = 3
PERIPHERAL_INTERVAL = 60
AUDIO_INTERVAL = 1
OFFLINE_CONFIRMATIONS = 2

STATE_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "periph.json"

state = {name: battery.result("unknown") for name in ("headset", "mouse", "keyboard")}
headset_on = None


def update(name, reading):
    if reading["level"] is None and reading["status"] in ("offline", "busy"):
        reading["level"] = state[name]["level"]
    state[name] = reading


def watch_headset():
    global headset_on
    misses = 0
    while True:
        reading = battery.read_headset()
        if reading["online"]:
            misses = 0
            headset_on = True
        elif reading["status"] in ("offline", "absent"):
            misses += 1
            if misses >= OFFLINE_CONFIRMATIONS:
                headset_on = False
        # A single timeout must not flip the widget or the audio output.
        if reading["status"] != "error" and (reading["online"] or headset_on is False):
            update("headset", reading)
        time.sleep(HEADSET_INTERVAL)


def watch_device(name, reader):
    while True:
        update(name, reader())
        time.sleep(PERIPHERAL_INTERVAL)


def pactl(*args):
    try:
        return subprocess.run(["pactl", *args], capture_output=True, text=True, timeout=5, check=True).stdout
    except (OSError, subprocess.SubprocessError):
        return None


def list_sinks():
    output = pactl("list", "short", "sinks") or ""
    return [line.split("\t")[1] for line in output.splitlines() if "\t" in line]


def choose_sink(sinks, headset_state):
    bluetooth = next((s for s in sinks if s.startswith(BLUETOOTH_PREFIX)), None)
    if bluetooth:
        return bluetooth
    if headset_state is None:
        return None
    if headset_state:
        headset = next((s for s in sinks if s.startswith(HEADSET_PREFIX)), None)
        if headset:
            return headset
    return SPEAKERS if SPEAKERS in sinks else None


def write_state(text):
    temporary = STATE_FILE.with_suffix(".tmp")
    temporary.write_text(text)
    temporary.replace(STATE_FILE)


def main():
    jobs = [
        (watch_headset, ()),
        (watch_device, ("mouse", battery.read_mouse)),
        (watch_device, ("keyboard", battery.read_keyboard)),
    ]
    for target, args in jobs:
        threading.Thread(target=target, args=args, daemon=True).start()

    last_target = None
    last_text = None
    while True:
        target = choose_sink(list_sinks(), headset_on)
        # Switch only when the priority winner changes, so a manual choice is kept.
        if target and target != last_target:
            if pactl("set-default-sink", target) is not None:
                print(f"default sink: {target}", flush=True)
                last_target = target
        else:
            last_target = target

        default = (pactl("get-default-sink") or "").strip()
        text = json.dumps({**state, "sink": default})
        if text != last_text:
            write_state(text)
            last_text = text
        time.sleep(AUDIO_INTERVAL)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
