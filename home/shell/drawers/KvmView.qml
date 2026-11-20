import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.theme

Item {
    id: root

    implicitWidth: 320
    implicitHeight: 240

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "HyprKVM"
            color: Tokens.ink
            font.pixelSize: 18
            font.bold: true
        }

        Text {
            text: "State: " + Kvm.state
            color: Kvm.active ? Tokens.signal : Tokens.dim
            font.pixelSize: 13
        }

        Text {
            text: "Machine: " + Kvm.machine
            color: Tokens.dim
            font.pixelSize: 12
            visible: Kvm.machine !== ""
        }

        Text {
            text: "Peers: " + Kvm.connectedCount + "/" + Kvm.peers.length
            color: Tokens.dim
            font.pixelSize: 12
        }

        Repeater {
            model: Kvm.peers
            delegate: Row {
                spacing: 8
                Text {
                    text: modelData.name + " (" + modelData.direction + ")"
                    color: modelData.connected ? Tokens.ink : Tokens.dim
                    font.pixelSize: 12
                }
                Text {
                    text: modelData.connected ? "●" : "○"
                    color: modelData.connected ? Tokens.signal : Tokens.muted
                    font.pixelSize: 12
                }
            }
        }

        Row {
            spacing: 8
            visible: Kvm.active

            Rectangle {
                width: 80; height: 28; radius: 4
                color: Tokens.raised
                Text {
                    anchors.centerIn: parent
                    text: "Return"
                    color: Tokens.ink
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Kvm.returnControl()
                }
            }

            Rectangle {
                width: 80; height: 28; radius: 4
                color: Tokens.raised
                Text {
                    anchors.centerIn: parent
                    text: "Release"
                    color: Tokens.ink
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Kvm.release()
                }
            }
        }
    }
}
