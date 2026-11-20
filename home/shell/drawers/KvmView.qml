import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.theme
import qs.components

Item {
    id: root

    implicitWidth: 320
    implicitHeight: 280

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Txt {
            text: "HyprKVM"
            font.pixelSize: 16
            font.bold: true
            color: Tokens.ink
        }

        RowLayout {
            spacing: 8
            Txt {
                text: "State:"
                color: Tokens.dim
                font.pixelSize: 12
            }
            Txt {
                text: Kvm.state
                color: Kvm.active ? Tokens.signal : Tokens.ink
                font.pixelSize: 12
                font.bold: true
            }
        }

        Txt {
            text: "Machine: " + Kvm.machine
            color: Tokens.dim
            font.pixelSize: 12
            visible: Kvm.machine !== ""
        }

        Txt {
            text: "Peers: " + Kvm.connectedCount + "/" + Kvm.peers.length
            color: Tokens.dim
            font.pixelSize: 12
        }

        Repeater {
            model: Kvm.peers

            delegate: Surface {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 36
                radius: 8
                color: modelData.connected ? Tokens.surface : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Txt {
                        text: modelData.name + " (" + modelData.direction + ")"
                        color: modelData.connected ? Tokens.ink : Tokens.dim
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Txt {
                        text: modelData.connected ? "●" : "○"
                        color: modelData.connected ? Tokens.signal : Tokens.muted
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            spacing: 8
            visible: Kvm.active

            KeyButton {
                text: "Return"
                onClicked: Kvm.returnControl()
            }

            KeyButton {
                text: "Release"
                onClicked: Kvm.release()
            }
        }
    }
}
