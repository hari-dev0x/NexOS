import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#000000"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string selectedUser: userModel.lastUser != "" ? userModel.lastUser : (userModel.count > 0 ? userModel.get(0).name : "")

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "#76a9fa"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            passwordInput.text = ""
            errorMessage.color = "#f87171"
            errorMessage.text = textConstants.loginFailed
            passwordInput.focus = true
        }
        function onInformationMessage(message) {
            errorMessage.color = "#76a9fa"
            errorMessage.text = message
        }
    }

    // Top Header: Realtime Clock & Date
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 16

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: clockTime
                anchors.right: parent.right
                color: "#FFFFFF"
                font.pixelSize: 28
                font.weight: Font.DemiBold
                font.family: "Noto Sans"
                text: Qt.formatTime(new Date(), "h:mm AP")
            }

            Text {
                id: clockDate
                anchors.right: parent.right
                color: "#8B949E"
                font.pixelSize: 13
                font.family: "Noto Sans"
                text: Qt.formatDate(new Date(), "dddd, MMMM d")
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockTime.text = Qt.formatTime(new Date(), "h:mm AP")
                clockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
            }
        }
    }

    // Central Login Surface
    Item {
        id: loginContainer
        width: 380
        height: 480
        anchors.centerIn: parent

        // Glass Card Backdrop
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "#080c14"
            border.color: "#2E76A9FA"
            border.width: 1
            opacity: 0.95
        }

        Column {
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 20

            // NexOS Monolithic Glyph
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64
                height: 64
                source: "nexos-logo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // User Identity Section
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                // User Avatar
                Rectangle {
                    width: 76
                    height: 76
                    radius: 38
                    color: "#161b22"
                    border.color: "#76a9fa"
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.selectedUser != "" ? ("file:///var/lib/AccountsService/icons/" + root.selectedUser) : "/usr/share/sddm/faces/root.face.icon"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        onStatusChanged: {
                            if (status == Image.Error) {
                                source = "/usr/share/sddm/faces/root.face.icon"
                            }
                        }
                    }
                }

                // Display Name
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.selectedUser
                    color: "#FFFFFF"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    font.family: "Noto Sans"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NexOS Desktop"
                    color: "#76a9fa"
                    font.pixelSize: 12
                    font.letterSpacing: 1.5
                    font.capitalization: Font.AllUppercase
                }
            }

            // Password Field Pill
            Rectangle {
                width: parent.width
                height: 46
                radius: 12
                color: passwordInput.activeFocus ? "#14FFFFFF" : "#0AFFFFFF"
                border.color: passwordInput.activeFocus ? "#76a9fa" : "#26FFFFFF"
                border.width: passwordInput.activeFocus ? 1.5 : 1

                TextInput {
                    id: passwordInput
                    anchors.left: parent.left
                    anchors.right: submitBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    anchors.rightMargin: 8
                    echoMode: TextInput.Password
                    font.pixelSize: 15
                    color: "#FFFFFF"
                    selectionColor: "#76a9fa"
                    focus: true

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Enter Password"
                        color: "#6e7681"
                        font.pixelSize: 14
                        visible: !passwordInput.text && !passwordInput.activeFocus
                    }

                    Keys.onReturnPressed: {
                        if (passwordInput.text != "") {
                            sddm.login(root.selectedUser, passwordInput.text, root.sessionIndex)
                        }
                    }
                }

                Rectangle {
                    id: submitBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 6
                    width: 34
                    height: 34
                    radius: 8
                    color: submitMouse.pressed ? "#588ee6" : (submitMouse.containsMouse ? "#76a9fa" : "#3376A9FA")

                    Text {
                        anchors.centerIn: parent
                        text: "➔"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: submitMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (passwordInput.text != "") {
                                sddm.login(root.selectedUser, passwordInput.text, root.sessionIndex)
                            }
                        }
                    }
                }
            }

            // Error / Prompt message
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: "#f87171"
                font.pixelSize: 12
                font.family: "Noto Sans"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    // Bottom Bar: Session Selector & Power Controls
    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 32
        spacing: 12

        ComboBox {
            id: sessionCombo
            width: 200
            height: 34
            model: sessionModel
            index: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
            font.pixelSize: 12
            font.family: "Noto Sans"
            arrowIcon: Qt.resolvedUrl("angle-down.png")
            color: "#161b22"
            borderColor: "#30363d"
            textColor: "#c9d1d9"
            focusColor: "#76a9fa"
            hoverColor: "#21262d"
            menuColor: "#0D1117"
            onIndexChanged: {
                root.sessionIndex = index
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 12

        // Suspend Button
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: pwr1Mouse.containsMouse ? "#1FFFFFFF" : "#0DFFFFFF"
            border.color: "#1FFFFFFF"

            Text {
                anchors.centerIn: parent
                text: "⏾"
                color: "#c9d1d9"
                font.pixelSize: 15
            }

            MouseArea {
                id: pwr1Mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend()
            }
        }

        // Reboot Button
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: pwr2Mouse.containsMouse ? "#1FFFFFFF" : "#0DFFFFFF"
            border.color: "#1FFFFFFF"

            Text {
                anchors.centerIn: parent
                text: "↻"
                color: "#c9d1d9"
                font.pixelSize: 17
            }

            MouseArea {
                id: pwr2Mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }

        // Power Off Button
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: pwr3Mouse.containsMouse ? "#40EF4444" : "#0DFFFFFF"
            border.color: pwr3Mouse.containsMouse ? "#ef4444" : "#1FFFFFFF"

            Text {
                anchors.centerIn: parent
                text: "⏻"
                color: pwr3Mouse.containsMouse ? "#fca5a5" : "#c9d1d9"
                font.pixelSize: 15
            }

            MouseArea {
                id: pwr3Mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus()
    }
}
