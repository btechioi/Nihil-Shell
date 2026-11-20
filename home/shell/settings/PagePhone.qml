import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme
import qs.config
import qs.services
import qs.components

Flickable {
    id: page

    readonly property bool wanted: Machine.get("deck.enable", false)

    contentHeight: column.implicitHeight + 24
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Component.onCompleted: Deck.refresh()
    Component.onDestruction: Deck.cancel()

    ColumnLayout {
        id: column
        width: page.width
        spacing: 14

        Heading {
            title: Lang.cfgPhone
        }

        Setting {
            title: Lang.deckUse
            sub: page.wanted && !Deck.enabled ? Lang.deckApply : ""

            Toggle {
                on: page.wanted
                onToggled: Machine.set("deck.enable", !on)
            }
        }

        Alert {
            Layout.fillWidth: true
            visible: Deck.enabled && Deck.loaded && !Deck.running
            text: Lang.deckDown
        }

        Setting {
            visible: Deck.enabled && Deck.running
            title: Lang.deckWatchTitle

            KeyButton {
                text: Lang.deckWatchInstall
                onClicked: Quickshell.execDetached([Config.cmd.terminal, "--hold", "--title", Lang.deckWatchTitle, Config.cmd.watch])
            }
        }

        Setting {
            visible: Deck.enabled && Deck.running
            title: Lang.deckPairTitle

            Column {
                spacing: 14

                KeyButton {
                    visible: !Deck.pairing
                    accent: true
                    text: Lang.deckPair
                    onClicked: Deck.pair()
                }

                Alert {
                    visible: Deck.pairFailed && !Deck.pairing
                    text: Lang.deckPairFailed
                }

                QrCode {
                    visible: Deck.pairing
                    rows: Deck.rows
                }

                KeyButton {
                    visible: Deck.pairing
                    text: Lang.cfgCancel
                    onClicked: Deck.cancel()
                }
            }
        }

        Label {
            visible: Deck.enabled && Deck.running
            Layout.topMargin: 8
            text: Deck.devices.length > 0 ? Lang.deckPhones : Lang.deckNone
        }

        Repeater {
            model: Deck.enabled && Deck.running ? Deck.devices : []

            Item {
                id: phone

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 44

                Surface {
                    anchors.fill: parent
                    radius: 10
                    color: area.hovered ? Tokens.surface : "transparent"
                }

                HoverHandler {
                    id: area
                }

                Txt {
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x - seen.width - forget.width - 48
                    text: phone.modelData.name
                }

                Label {
                    id: seen
                    anchors.right: forget.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: Dates.moment(phone.modelData.seen ?? 0)
                    font.pixelSize: 12
                }

                KeyButton {
                    id: forget
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: Lang.deckForget
                    onClicked: Deck.forget(phone.modelData.id)
                }
            }
        }

        Heading {
            title: "HyprKVM"
            Layout.topMargin: 8
        }

        Label {
            text: "State: " + Kvm.state + (Kvm.machine ? " (" + Kvm.machine + ")" : "")
            font.pixelSize: 12
        }

        Label {
            text: Kvm.peers.length > 0 ? (Kvm.connectedCount + "/" + Kvm.peers.length + " peers connected") : "No peers found"
            font.pixelSize: 12
        }

        Repeater {
            model: Kvm.peers

            Item {
                id: kvmPeer

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 36

                Surface {
                    anchors.fill: parent
                    radius: 8
                    color: kvmPeer.modelData.connected ? Tokens.surface : "transparent"
                }

                Txt {
                    x: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: kvmPeer.modelData.name + " (" + kvmPeer.modelData.direction + ") — " + kvmPeer.modelData.address
                    color: kvmPeer.modelData.connected ? Tokens.ink : Tokens.dim
                    font.pixelSize: 12
                    width: parent.width - 120
                    elide: Text.ElideRight
                }

                Txt {
                    anchors.right: removeBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: kvmPeer.modelData.connected ? "●" : "○"
                    color: kvmPeer.modelData.connected ? Tokens.signal : Tokens.muted
                    font.pixelSize: 14
                }

                KeyButton {
                    id: removeBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Remove"
                    onClicked: {
                        Quickshell.execDetached([Config.cmd.hyprkvmCtl, "remove-peer", kvmPeer.modelData.name]);
                        Quickshell.execDetached(["sh", "-c", "pkill -f 'hyprkvm daemon'; sleep 1; hyprkvm daemon &"]);
                        Kvm.check();
                    }
                }
            }
        }

        Heading {
            title: "Add peer"
            Layout.topMargin: 8
        }

        property string peerDir: "left"

        RowLayout {
            spacing: 6
            Repeater {
                model: ["left", "right", "up", "down"]
                delegate: KeyButton {
                    required property string modelData
                    text: modelData
                    accent: column.peerDir === modelData
                    onClicked: column.peerDir = modelData
                }
            }
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Field {
                id: peerNameField
                placeholder: "Name"
                implicitWidth: 120
            }

            Field {
                id: peerAddrField
                placeholder: "Address (host:port)"
                Layout.fillWidth: true
            }

            KeyButton {
                text: "Add"
                accent: true
                onClicked: {
                    if (peerNameField.text === "" || peerAddrField.text === "") return;
                    Quickshell.execDetached([Config.cmd.hyprkvmCtl, "add-peer", peerNameField.text, column.peerDir, peerAddrField.text]);
                    Quickshell.execDetached(["sh", "-c", "pkill -f 'hyprkvm daemon'; sleep 1; hyprkvm daemon &"]);
                    peerNameField.clear();
                    peerAddrField.clear();
                    Kvm.check();
                }
            }
        }

        RowLayout {
            spacing: 8
            visible: Kvm.active

            KeyButton {
                text: "Return control"
                onClicked: Kvm.returnControl()
            }

            KeyButton {
                text: "Release"
                onClicked: Kvm.release()
            }
        }

    }
}
