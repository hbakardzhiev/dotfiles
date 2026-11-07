#!/usr/bin/env python3
"""S.M.A.R.T. data for every drive, read through udisks2 (no privileges needed).

Prints one JSON document on stdout:

    {"time": 1790459000, "drives": [{"model": "...", ...}, ...]}

Modes:
    full  (default)  refresh udisks' SMART cache, then read everything
    fast             read udisks' cached properties only (~15 ms)
    waybar           one Waybar JSON object (text/class/tooltip) for the bar
    details          full scan, then a notify-send summary on click
    notify           full scan, then toast when a drive is degraded
                     (warn/fail); silent when healthy.
                     `--force=warn|fail` overrides the verdict for testing.

Health verdicts (status/statusReason/worst) are computed here so the bar
and the notifier always agree.
"""

import json
import subprocess
import sys
import time

# Verdict thresholds — keep in sync with nothing: this IS the source.
# Ported 1:1 from the original Model.js rules (order matters: first match wins).
TEMP_WARN = 60
TEMP_FAIL = 75
LIFE_WARN = 10
USED_WARN = 90

STATUS_RANK = {"fail": 3, "warn": 2, "ok": 1, "none": 0}

SVC = "org.freedesktop.UDisks2"
OM_PATH = "/org/freedesktop/UDisks2"
IF_OM = "org.freedesktop.DBus.ObjectManager"
IF_DRIVE = "org.freedesktop.UDisks2.Drive"
IF_ATA = "org.freedesktop.UDisks2.Drive.Ata"
IF_NVME = "org.freedesktop.UDisks2.NVMe.Controller"

# ATA SMART attributes worth surfacing, keyed by attribute id.
ATA_ATTRS = {
    5: "reallocated",
    9: "powerOnHours",
    12: "powerCycles",
    177: "wear",
    194: "temp",
    197: "pending",
    198: "uncorrectable",
    199: "crcErrors",
    232: "endurance",
}


def buscall(path, iface, method, *args):
    cmd = ["busctl", "--json=short", "call", SVC, path, iface, method, *args]
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or ("busctl %s failed" % method))
    return json.loads(proc.stdout).get("data", [])


def managed_objects():
    data = buscall(OM_PATH, IF_OM, "GetManagedObjects")
    return data[0] if data else {}


def field(props, key, default=None):
    value = props.get(key)
    if isinstance(value, dict) and "data" in value:
        return value["data"]
    return default


def smart_iface_of(ifaces):
    if IF_ATA in ifaces:
        return IF_ATA
    if IF_NVME in ifaces:
        return IF_NVME
    return None


def refresh_cache(objs):
    """Ask udisks to re-read SMART data. Failures just leave stale values."""
    for path, ifaces in objs.items():
        iface = smart_iface_of(ifaces)
        if iface is None:
            continue
        try:
            buscall(path, iface, "SmartUpdate", "a{sv}", "0")
        except Exception:
            pass


def unwrap(value):
    """busctl --json keeps variants wrapped as {"type": ..., "data": ...}."""
    if isinstance(value, dict) and "data" in value and set(value) <= {"type", "data"}:
        return value["data"]
    return value


def smart_attributes(path, iface):
    """ATA: list of attribute tuples. NVMe: flat {name: value} dict."""
    data = buscall(path, iface, "SmartGetAttributes", "a{sv}", "0")
    payload = data[0] if data else None
    if isinstance(payload, list):
        out = {}
        for row in payload:
            key = ATA_ATTRS.get(row[0])
            if key:
                out[key] = {"raw": row[6], "failed": row[7]}
        return out
    if isinstance(payload, dict):
        return {key: unwrap(value) for key, value in payload.items()}
    return {}


def as_int(value, default=None):
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return default
    return int(value)


def describe(path, ifaces, attrs):
    drive = ifaces.get(IF_DRIVE, {})
    ata = ifaces.get(IF_ATA)
    nvme = ifaces.get(IF_NVME)
    iface = IF_ATA if ata else (IF_NVME if nvme else None)
    smart = iface is not None

    size = as_int(field(drive, "Size", 0), 0)
    if size <= 0:
        return None  # empty card reader / unplugged media: nothing to report

    if nvme:
        bus = "nvme"
    elif ata:
        bus = field(drive, "ConnectionBus", "") or "sata"
    else:
        bus = field(drive, "ConnectionBus", "") or "unknown"

    info = {
        "path": path,
        "model": field(drive, "Model", "") or "Unknown drive",
        "serial": field(drive, "Serial", ""),
        "size": size,
        "bus": bus,
        "removable": bool(field(drive, "Removable", False)),
        "smart": smart,
        "updated": 0,
        "smartSupported": None,
        "smartEnabled": None,
        "smartFailing": False,
        "tempC": None,
        "powerOnHours": None,
        "powerCycles": None,
        "attrsFailing": 0,
        "attrsFailedPast": 0,
        "badSectors": 0,
        "criticalWarning": [],
        "lifePct": None,
        "percentUsed": None,
        "availSpare": None,
        "spareThreshold": None,
        "mediaErrors": None,
        "reallocated": None,
        "pending": None,
        "uncorrectable": None,
    }
    if not smart:
        return info

    if ata:
        info["updated"] = as_int(field(ata, "SmartUpdated", 0), 0)
        info["smartSupported"] = bool(field(ata, "SmartSupported", False))
        info["smartEnabled"] = bool(field(ata, "SmartEnabled", False))
        info["smartFailing"] = bool(field(ata, "SmartFailing", False))
        info["attrsFailing"] = as_int(field(ata, "SmartNumAttributesFailing", 0), 0)
        info["attrsFailedPast"] = as_int(field(ata, "SmartNumAttributesFailedInThePast", 0), 0)
        info["badSectors"] = as_int(field(ata, "SmartNumBadSectors", 0), 0)
        seconds = as_int(field(ata, "SmartPowerOnSeconds", 0), 0)
        if seconds:
            info["powerOnHours"] = round(seconds / 3600)
        kelvin = field(ata, "SmartTemperature")
        if isinstance(kelvin, (int, float)):
            info["tempC"] = round(kelvin - 273.15, 1)

        info["reallocated"] = attrs.get("reallocated", {}).get("raw")
        info["pending"] = attrs.get("pending", {}).get("raw")
        info["uncorrectable"] = attrs.get("uncorrectable", {}).get("raw")
        if info["powerCycles"] is None:
            info["powerCycles"] = attrs.get("powerCycles", {}).get("raw")
        if info["tempC"] is None and "temp" in attrs:
            # Attribute 194 is milli-Kelvin on this drive (307150 -> 307.15 K).
            info["tempC"] = round(attrs["temp"]["raw"] / 1000.0 - 273.15, 1)
        if info["powerOnHours"] is None and "powerOnHours" in attrs:
            info["powerOnHours"] = round(attrs["powerOnHours"]["raw"] / 1000.0 / 3600)
        if "endurance" in attrs:
            info["lifePct"] = as_int(attrs["endurance"].get("raw"))
    else:
        info["updated"] = as_int(field(nvme, "SmartUpdated", 0), 0)
        info["smartSupported"] = True
        info["smartEnabled"] = True
        info["smartFailing"] = bool(field(nvme, "SmartCriticalWarning", []) or [])
        info["criticalWarning"] = list(field(nvme, "SmartCriticalWarning", []) or [])
        hours = as_int(field(nvme, "SmartPowerOnHours", 0), 0)
        if hours:
            info["powerOnHours"] = hours
        kelvin = field(nvme, "SmartTemperature")
        if isinstance(kelvin, (int, float)):
            info["tempC"] = round(kelvin - 273.15, 1)

        info["percentUsed"] = as_int(attrs.get("percent_used"))
        info["availSpare"] = as_int(attrs.get("avail_spare"))
        info["spareThreshold"] = as_int(attrs.get("spare_thresh"))
        info["mediaErrors"] = as_int(attrs.get("media_errors"))
        info["powerCycles"] = as_int(attrs.get("power_cycles"))
        if info["percentUsed"] is not None:
            info["lifePct"] = max(0, 100 - info["percentUsed"])
        sensors = attrs.get("temp_sensors")
        if info["tempC"] is None and isinstance(sensors, list) and sensors:
            first = as_int(sensors[0])
            if first:
                info["tempC"] = round(first - 273.15, 1)

    return info


def status_of(d):
    """Verdict + reason for one drive. First matching rule wins (same order
    the panel's original Model.js rules used)."""
    if not d.get("smart"):
        return "none", "no S.M.A.R.T. data"
    if d.get("smartFailing"):
        return "fail", "S.M.A.R.T. reports the drive failing"
    if d.get("criticalWarning"):
        return "fail", "NVMe critical warning: " + ", ".join(str(x) for x in d["criticalWarning"])
    if (d.get("attrsFailing") or 0) > 0:
        return "fail", "%d failing attribute(s)" % d["attrsFailing"]
    spare, threshold = d.get("availSpare"), d.get("spareThreshold")
    if spare is not None and threshold is not None and spare <= threshold:
        return "fail", "spare capacity %d%% (threshold %d%%)" % (spare, threshold)
    temp = d.get("tempC")
    if temp is not None and temp >= TEMP_FAIL:
        return "fail", "temperature %d°C" % round(temp)
    if temp is not None and temp >= TEMP_WARN:
        return "warn", "temperature %d°C" % round(temp)

    if (d.get("badSectors") or 0) > 0:
        return "warn", "%d bad sector(s)" % d["badSectors"]
    if (d.get("attrsFailedPast") or 0) > 0:
        return "warn", "%d previously failed attribute(s)" % d["attrsFailedPast"]
    if (d.get("reallocated") or 0) > 0:
        return "warn", "%d reallocated sector(s)" % d["reallocated"]
    if (d.get("pending") or 0) > 0:
        return "warn", "%d pending sector(s)" % d["pending"]
    if (d.get("uncorrectable") or 0) > 0:
        return "warn", "%d uncorrectable sector(s)" % d["uncorrectable"]
    if (d.get("mediaErrors") or 0) > 0:
        return "warn", "%d media error(s)" % d["mediaErrors"]
    percent = d.get("percentUsed")
    if percent is not None and percent >= USED_WARN:
        return "warn", "%d%% used" % percent
    life = d.get("lifePct")
    if life is not None and life <= LIFE_WARN:
        return "warn", "life at %d%%" % life
    return "ok", ""


def collect(refresh):
    """One full read of every drive, each tagged with its verdict."""
    objs = managed_objects()
    paths = [p for p, i in objs.items() if IF_DRIVE in i]
    if refresh:
        refresh_cache(objs)
        objs = managed_objects()

    drives = []
    for path in paths:
        ifaces = objs.get(path, {})
        if IF_DRIVE not in ifaces:
            continue
        iface = smart_iface_of(ifaces)
        try:
            attrs = smart_attributes(path, iface) if iface else {}
        except Exception:
            attrs = {}
        info = describe(path, ifaces, attrs)
        if info:
            info["status"], info["statusReason"] = status_of(info)
            drives.append(info)

    drives.sort(key=lambda d: -d["size"])
    worst = "none"
    for d in drives:
        if STATUS_RANK[d["status"]] > STATUS_RANK[worst]:
            worst = d["status"]
    return {"time": int(time.time()), "drives": drives, "worst": worst}


def notify(argv):
    """Boot/login alert: toast when the verdict is not green. Never fails and
    never toasts on a scan error — silence beats a false alarm."""
    force = None
    for arg in argv:
        if arg.startswith("--force="):
            force = arg.split("=", 1)[1]

    payload = None
    for _ in range(3):
        try:
            payload = collect(refresh=True)
            break
        except Exception:
            time.sleep(2)
    if payload is None:
        return

    worst = force if force in STATUS_RANK else payload["worst"]
    if worst not in ("warn", "fail"):
        return

    degraded = [d for d in payload["drives"] if d.get("status") in ("warn", "fail")]
    headline = "Disk health: " + ("FAILURE DETECTED" if worst == "fail" else "ATTENTION NEEDED")
    body = "\n".join(
        "%s — %s" % (d.get("model") or "Drive", d.get("statusReason") or d["status"])
        for d in degraded
    )
    if not body:
        body = "A drive's S.M.A.R.T. health is not green."

    subprocess.run([
        "notify-send",
        "-a", "Disk health",
        "-u", "critical" if worst == "fail" else "normal",
        headline, body,
    ], capture_output=True)


def bar():
    """One Waybar JSON object. Missing or unreadable S.M.A.R.T. data is not an
    error here: the widget just shows the grey state."""
    try:
        payload = collect(refresh=True)
    except Exception as exc:
        print(json.dumps({
            "text": "󰋊 ?",
            "class": "none",
            "tooltip": "SMART read failed: %s" % exc,
        }))
        return

    drives = payload["drives"]
    worst = payload["worst"]
    lines = []
    for d in drives:
        bits = [d.get("model") or "Drive"]
        if d.get("lifePct") is not None:
            bits.append("%s%% life" % d["lifePct"])
        elif d.get("percentUsed") is not None:
            bits.append("%s%% used" % d["percentUsed"])
        if d.get("tempC") is not None:
            bits.append("%s°C" % d["tempC"])
        if d.get("statusReason"):
            bits.append(d["statusReason"])
        else:
            bits.append(d["status"])
        lines.append(" — ".join([bits[0], ", ".join(bits[1:])]))

    if not lines:
        lines = ["No SMART-capable drives found"]

    text = {"warn": "󰋊 !", "fail": "󰋊 !!"}.get(worst, "󰋊")
    print(json.dumps({"text": text, "class": worst, "tooltip": "\n".join(lines)}))


def details():
    """Click action: full scan, then a notification with every drive."""
    try:
        payload = collect(refresh=True)
    except Exception as exc:
        subprocess.run([
            "notify-send", "-a", "Disk health", "-u", "normal",
            "Disk health", "SMART read failed: %s" % exc,
        ], capture_output=True)
        return

    drives = payload["drives"]
    if not drives:
        subprocess.run([
            "notify-send", "-a", "Disk health", "Disk health",
            "No SMART-capable drives found",
        ], capture_output=True)
        return

    worst = payload["worst"]
    body = "\n".join(
        "%s — %s%s" % (
            d.get("model") or "Drive",
            d.get("statusReason") or d["status"],
            (" (%s°C)" % d["tempC"]) if d.get("tempC") is not None else "",
        )
        for d in drives
    )
    subprocess.run([
        "notify-send", "-a", "Disk health",
        "-u", "critical" if worst == "fail" else "normal",
        "Disk health: %s" % worst.upper(), body,
    ], capture_output=True)


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "full"
    if mode == "notify":
        notify(sys.argv[2:])
        return
    if mode == "waybar":
        bar()
        return
    if mode == "details":
        details()
        return
    json.dump(collect(refresh=mode != "fast"), sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # never break the bar: report an empty result
        json.dump({"time": int(time.time()), "drives": [], "worst": "none", "error": str(exc)}, sys.stdout)
        sys.stdout.write("\n")
        sys.exit(1)
