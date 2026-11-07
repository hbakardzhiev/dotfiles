import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root

  moduleName: "alice.disk-health"
  ipcTarget: "alice.disk-health"
  // Own the single IpcHandler this target permits so `refresh` can ride
  // along with the open/close/toggle methods.
  manageIpc: false

  // Last good scan, replaced wholesale: a failed refresh never blanks the bar.
  property var snapshot: ({ ok: true, time: 0, drives: [], worst: "none" })
  property int selectedIndex: 0
  property string checkedLabel: ""
  property color themeGreen: "#63702c"
  property color themeOrange: "#d0772b"
  // Fixed vivid green for the row dots: maximum visibility by design,
  // intentionally not taken from the theme.
  property color dotGreen: "#22c55e"

  readonly property var drives: snapshot.drives
  readonly property string worst: snapshot.worst
  readonly property bool hasData: drives.length > 0
  readonly property bool scanning: !hasData && snapshot.time === 0

  // The helper lives next to this file. Entry points are resolved by the
  // registry as file:// URLs, so this gives us a plain filesystem path.
  readonly property string helperPath: {
    var url = Qt.resolvedUrl("disk-health").toString()
    if (url.indexOf("file://") === 0) return decodeURIComponent(url.slice(7))
    return Quickshell.env("HOME") + "/.config/omarchy/plugins/alice.disk-health/disk-health"
  }

  readonly property string tooltipText: {
    if (!hasData) return ""
    var lines = []
    for (var i = 0; i < drives.length; i++) lines.push(Model.driveLine(drives[i]))
    return lines.join("\n")
  }

  // Neutral when everything is healthy — colour only shows up as a signal.
  readonly property color stateColor: {
    if (worst === "fail") return Color.urgent
    if (worst === "warn") return themeOrange
    if (worst === "ok") return barForeground
    return Color.muted
  }

  function statusColor(state) {
    if (state === "fail") return Color.urgent
    if (state === "warn") return themeOrange
    if (state === "ok") return themeGreen
    return Color.muted
  }

  function refresh(mode) {
    if (helperProc.running) return
    helperProc.command = [helperPath, mode || "full"]
    helperProc.running = true
  }

  function applyResult(raw) {
    var next = Model.parse(raw)
    if (!next.ok) return
    selectedIndex = Model.clampIndex(selectedIndex, next.drives.length)
    snapshot = next
    checkedLabel = Model.ago(next.time, Math.floor(Date.now() / 1000))
  }

  function moveSelection(delta) {
    selectedIndex = Model.clampIndex(selectedIndex + delta, drives.length)
  }

  Component.onCompleted: refresh("fast")

  onOpenedChanged: {
    if (opened) {
      selectedIndex = 0
      refresh("full")
    }
  }

  // Background cadence stays cheap: a cached read at startup (~70 ms), a full
  // re-scan every ten minutes (~200 ms, mostly udisks' own SMART read), and a
  // faster one while the panel is on screen.
  Timer { interval: 600000; running: true; repeat: true; onTriggered: root.refresh("full") }
  Timer { interval: 60000; running: root.opened; repeat: true; onTriggered: root.refresh("full") }

  IpcHandler {
    target: "alice.disk-health"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): void { root.refresh("full") }
  }

  Process {
    id: helperProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyResult(text)
    }
  }

  // The Color singleton only forwards foreground/background/accent/urgent
  // from the theme; ok/warn hues come straight out of the active colors.toml.
  FileView {
    path: Color.currentThemePath + "/colors.toml"
    watchChanges: true
    printErrors: false
    onLoaded: {
      root.themeGreen = Model.tomlColor(text(), "green", "#63702c")
      root.themeOrange = Model.tomlColor(text(), "orange", "#d0772b")
    }
    onFileChanged: reload()
    onLoadFailed: {
      root.themeGreen = "#63702c"
      root.themeOrange = "#d0772b"
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰋊"
    foreground: root.stateColor
    tooltipText: root.tooltipText
    onPressed: root.toggle()
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) { root.moveSelection(dy !== 0 ? dy : dx) }
      onActivateRequested: root.refresh("full")
      onReturnRequested: root.refresh("full")
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) { if (t === "r" || t === "R") root.refresh("full") }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero: glyph · title/status · state pill ----------
        Item {
          id: hero
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, statusPill.implicitHeight)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            text: "󰋊"
            color: root.stateColor
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 200 } }
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: statusPill.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: "DISK HEALTH"
              color: root.barForeground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: root.scanning ? "SCANNING DISKS…" : Model.statusLabel(root.worst)
              color: root.stateColor
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight

              Behavior on color { ColorAnimation { duration: 200 } }
            }
          }

          StatusPill {
            id: statusPill
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            label: root.scanning ? "…" : Model.pillLabel(root.worst)
            tint: root.scanning ? root.stateColor : root.statusColor(root.worst)
          }
        }

        PanelSeparator { foreground: root.barForeground }

        // ---------- Drives ----------
        Column {
          width: parent.width
          spacing: Style.space(12)
          visible: root.hasData

          Repeater {
            model: root.drives

            DriveRow {
              required property var modelData
              required property int index
              width: parent.width
              drive: modelData
              rowIndex: index
            }
          }
        }

        Text {
          visible: !root.hasData
          width: parent.width
          textFormat: Text.PlainText
          text: root.scanning ? "Scanning disks…" : "No drives found"
          color: root.barForeground
          opacity: 0.6
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
          horizontalAlignment: Text.AlignHCenter
        }

        PanelSeparator { foreground: root.barForeground }

        // ---------- Footer ----------
        Row {
          id: footer
          width: parent.width
          spacing: Style.space(10)

          FooterText { text: "R · RE-SCAN" }

          Item {
            width: Math.max(0, footer.width - footer.children[0].implicitWidth
              - footer.children[2].implicitWidth - footer.spacing * 2)
            height: 1
          }

          FooterText { text: root.checkedLabel ? "CHECKED " + root.checkedLabel.toUpperCase() : "" }
        }
      }
    }
  }

  component StatusPill: Rectangle {
    id: pill

    property string label: ""
    property color tint: Color.foreground

    radius: height / 2
    color: Qt.rgba(tint.r, tint.g, tint.b, 0.14)
    implicitWidth: pillLabel.implicitWidth + Style.space(18)
    implicitHeight: pillLabel.implicitHeight + Style.space(8)

    Text {
      id: pillLabel
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: pill.label
      color: pill.tint
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 1
    }
  }

  component FooterText: Text {
    textFormat: Text.PlainText
    color: root.barForeground
    opacity: 0.5
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.caption
    font.letterSpacing: 1
  }

  component DriveRow: Item {
    id: row

    property var drive: ({})
    property int rowIndex: 0

    readonly property string driveState: Model.statusOf(drive)
    readonly property color stateColor: driveState === "ok" ? root.dotGreen : root.statusColor(driveState)
    readonly property bool selected: root.drives.length > 1 && rowIndex === root.selectedIndex

    width: parent ? parent.width : 0
    implicitHeight: rowColumn.implicitHeight

    Rectangle {
      anchors.fill: row
      anchors.leftMargin: -Style.space(6)
      anchors.rightMargin: -Style.space(6)
      radius: Style.space(4)
      visible: row.selected
      color: Qt.rgba(root.barForeground.r, root.barForeground.g, root.barForeground.b, 0.07)
    }

    Column {
      id: rowColumn
      width: parent.width
      spacing: Style.space(4)

      Item {
        id: titleRow
        width: parent.width
        implicitHeight: modelLabel.implicitHeight

        Rectangle {
          id: dot
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          width: Style.space(11)
          height: width
          radius: width / 2
          color: row.stateColor

          Behavior on color { ColorAnimation { duration: 200 } }
        }

        Text {
          id: modelLabel
          anchors.left: dot.right
          anchors.leftMargin: Style.space(10)
          anchors.right: sizeLabel.left
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: row.drive.model || "Drive"
          color: root.barForeground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          id: sizeLabel
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: Model.formatSize(row.drive.size)
          color: root.barForeground
          opacity: 0.55
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
      }

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: Model.detailLine(row.drive)
        color: root.barForeground
        opacity: 0.55
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
      }
    }
  }
}
