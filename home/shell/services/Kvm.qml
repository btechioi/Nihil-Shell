pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string state: "unknown"
    property string machine: ""
    property var peers: []
    property int connectedCount: 0
    property real checkedAt: 0

    readonly property bool active: state !== "Local" && state !== "unknown" && state !== "" && state !== "offline"

    function check(): void {
        if (statusProc.running || peersProc.running)
            return;
        statusProc.running = true;
        peersProc.running = true;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.check()
    }

    Process {
        id: statusProc
        command: [Config.cmd.hyprkvmCtl, "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.state = j.state ?? "unknown";
                    root.machine = j.machine_name ?? "";
                    root.checkedAt = Date.now();
                } catch (e) {
                    root.state = "offline";
                }
            }
        }
    }

    Process {
        id: peersProc
        command: [Config.cmd.hyprkvmCtl, "peers", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.peers = j ?? [];
                    root.connectedCount = root.peers.filter(p => p.connected).length;
                } catch (e) {
                    root.peers = [];
                    root.connectedCount = 0;
                }
            }
        }
    }

    function switchTo(name: string): void {
        Quickshell.execDetached([Config.cmd.hyprkvmCtl, "switch", name]);
    }

    function returnControl(): void {
        Quickshell.execDetached([Config.cmd.hyprkvmCtl, "return"]);
    }

    function release(): void {
        Quickshell.execDetached([Config.cmd.hyprkvmCtl, "release"]);
    }
}
