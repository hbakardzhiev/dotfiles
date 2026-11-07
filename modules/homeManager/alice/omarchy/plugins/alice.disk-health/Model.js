// View model for the disk-health panel: labels and formatting over the
// helper's JSON. Pure functions only — no Qt objects — so this module stays a
// plain script library. Verdicts (status/statusReason/worst) are computed by
// the disk-health helper so the panel and its boot notifier always agree.

var STATUS_WORDS = { ok: "OK", warn: "WARN", fail: "FAIL", none: "NO SMART" }
var STATUS_LABELS = {
  ok: "ALL DRIVES HEALTHY",
  warn: "ATTENTION NEEDED",
  fail: "FAILURE DETECTED",
  none: "NO SMART DATA"
}
var PILL_LABELS = { ok: "HEALTHY", warn: "ATTENTION", fail: "FAILING", none: "UNKNOWN" }

function parse(text) {
  var raw
  try {
    raw = JSON.parse(String(text || ""))
  } catch (e) {
    return { ok: false, time: 0, drives: [], worst: "none" }
  }
  if (!raw || raw.error) return { ok: false, time: 0, drives: [], worst: "none" }
  var drives = Array.isArray(raw.drives) ? raw.drives : []
  var time = typeof raw.time === "number" ? raw.time : 0
  var rank = { fail: 3, warn: 2, ok: 1, none: 0 }
  var worst = rank[raw.worst] ? raw.worst : worstOf(drives)
  return { ok: true, time: time, drives: drives, worst: worst }
}

function statusOf(drive) {
  return drive && drive.status ? drive.status : "none"
}

function worstOf(drives) {
  var rank = { fail: 3, warn: 2, ok: 1, none: 0 }
  var worst = "none"
  for (var i = 0; i < drives.length; i++) {
    var state = statusOf(drives[i])
    if (rank[state] > rank[worst]) worst = state
  }
  return worst
}

function clampIndex(index, length) {
  if (length <= 0) return 0
  return Math.max(0, Math.min(length - 1, index))
}

function hasTemp(drive) {
  return drive && drive.tempC !== null && drive.tempC !== undefined
}

function formatSize(bytes) {
  var n = Number(bytes)
  if (!isFinite(n) || n <= 0) return ""
  if (n >= 1e12) return trimNum(n / 1e12) + " TB"
  if (n >= 1e9) return trimNum(n / 1e9) + " GB"
  if (n >= 1e6) return Math.round(n / 1e6) + " MB"
  return Math.round(n / 1e3) + " KB"
}

function trimNum(n) {
  return String(n >= 100 ? Math.round(n) : Math.round(n * 10) / 10)
}

function formatTemp(celsius) {
  if (celsius === null || celsius === undefined) return "—"
  return Math.round(celsius) + "°C"
}

function formatYears(hours) {
  var n = Number(hours) || 0
  if (n <= 0) return ""
  var years = n / 8766 // 365.25 days
  if (years < 0.05) return Math.max(1, Math.round(n / 24)) + " d"
  return trimNum(years) + " y"
}

function ago(timestamp, now) {
  if (!timestamp) return ""
  var seconds = Math.max(0, (now || 0) - timestamp)
  if (seconds < 60) return "just now"
  if (seconds < 3600) return Math.floor(seconds / 60) + "m ago"
  if (seconds < 86400) return Math.floor(seconds / 3600) + "h ago"
  return Math.floor(seconds / 86400) + "d ago"
}

function statusWord(state) { return STATUS_WORDS[state] || STATUS_WORDS.none }
function statusLabel(state) { return STATUS_LABELS[state] || STATUS_LABELS.none }
function pillLabel(state) { return PILL_LABELS[state] || PILL_LABELS.none }

function driveLine(drive) {
  var line = (drive.model || "Drive") + " · " + statusWord(statusOf(drive))
  if (hasTemp(drive)) line += " · " + formatTemp(drive.tempC)
  return line
}

function detailLine(drive) {
  if (!drive.smart) return String(drive.bus || "").toUpperCase() + " · no S.M.A.R.T."
  var parts = [String(drive.bus || "").toUpperCase()]
  if (hasTemp(drive)) parts.push(formatTemp(drive.tempC))
  if (drive.powerOnHours) parts.push(formatYears(drive.powerOnHours) + " on")
  if (drive.lifePct !== null && drive.lifePct !== undefined) parts.push("life " + drive.lifePct + "%")
  return parts.join(" · ")
}

function tomlColor(raw, key, fallback) {
  var match = String(raw || "").match(new RegExp("^\\s*" + key + "\\s*=\\s*[\"']?(#[0-9A-Fa-f]{6})", "m"))
  return match ? match[1] : fallback
}
