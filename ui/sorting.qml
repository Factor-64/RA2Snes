import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0

Item {
	Flow {
		id: sortingSettingsFlow
		spacing: 6
		Layout.fillWidth: true
		Layout.leftMargin: 20
		Layout.bottomMargin: 10
		Layout.rightMargin: 20
		Layout.topMargin: 10

		RowLayout {
			id: sortingTextRow
			spacing: 6
			Layout.fillWidth: true
			Text{
				text: qsTr("Sort:")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: normal
				text: qsTr("Normal")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaNormal
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByNormal()
					}
					onEntered: normal.state = "hovered"
					onExited: normal.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: normal
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: normal
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: normal
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: points
				text: qsTr("Points")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaPoints
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByPoints()
					}
					onEntered: points.state = "hovered"
					onExited: points.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: points
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: points
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: points
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: title
				text: qsTr("Title")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaTitleSort
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByTitle()
					}
					onEntered: title.state = "hovered"
					onExited: title.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: title
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: title
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: title
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: type
				text: qsTr("Type")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaType
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByType()
					}
					onEntered: type.state = "hovered"
					onExited: type.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: type
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: type
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: type
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: time
				text: qsTr("Latest")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaTime
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByTime()
					}
					onEntered: time.state = "hovered"
					onExited: time.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: time
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: time
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: time
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: primed
				text: qsTr("Primed")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaPrime
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByPrimed()
					}
					onEntered: primed.state = "hovered"
					onExited: primed.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: primed
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: primed
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: primed
							property: "color"
							duration: 200
						}
					}
				]
			}
			Text{
				text: "-"
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.basicTextColor
				Layout.fillWidth: true
			}
			Text{
				id: progress
				text: qsTr("Progress")
				font.family: "Verdana"
				font.pixelSize: 13
				color: themeLoader.item.linkColor
				Layout.fillWidth: true
				MouseArea {
					id: mouseAreaProgress
					anchors.fill: parent
					hoverEnabled: true
					onClicked: {
						sortedAchievementModel.sortByPercent()
					}
					onEntered: progress.state = "hovered"
					onExited: progress.state = ""
				}

				states: [
					State {
						name: "hovered"
						PropertyChanges {
							target: progress
							color: themeLoader.item.selectedLink
						}
					}
				]

				transitions: [
					Transition {
						from: ""
						to: "hovered"
						ColorAnimation {
							target: progress
							property: "color"
							duration: 200
						}
					},
					Transition {
						from: "hovered"
						to: ""
						ColorAnimation {
							target: progress
							property: "color"
							duration: 200
						}
					}
				]
			}
		}

		Item {
			id: dynamicSpacer
			height: 1
		}

		Binding {
			target: dynamicSpacer
			property: "width"
			value: Math.max(0,sortingSettingsFlow.width - sortingTextRow.width - sortingCheckBoxes.width - (sortingSettingsFlow.spacing * 3))
		}

		RowLayout {
			id: sortingCheckBoxes
			Layout.alignment: Qt.AlignRight
			Layout.fillWidth: true
			spacing: 14

			Row {
				spacing: 4
				Layout.fillWidth: true
				CheckBox {
					id: missableCheckBox
					width: 14
					height: 14

					indicator: Rectangle {
						width: 14
						height: 14
						radius: 2
						color: missableCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor
						border.color: missableCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedBorderColor

						Text {
							anchors.centerIn: parent
							text: missableCheckBox.checked ? "\u2713" : ""
							color: themeLoader.item.checkBoxUnCheckedColor
							font.pixelSize: 12
						}
					}

					onCheckedChanged: {
						if (missableCheckBox.checked) {
							sortedAchievementModel.showOnlyMissable();
						} else {
							sortedAchievementModel.clearMissableFilter();
						}
					}
				}
				Text {
					text: qsTr("Only show missables")
					font.family: "Verdana"
					font.pixelSize: 13
					color: themeLoader.item.basicTextColor
					verticalAlignment: Text.AlignVCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							missableCheckBox.checked = !missableCheckBox.checked
						}
					}
				}
			}
			Row {
				spacing: 4
				Layout.fillWidth: true

				CheckBox {
					id: hideCheckBox
					width: 14
					height: 14

					indicator: Rectangle {
						width: 14
						height: 14
						radius: 2
						color: hideCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor
						border.color: hideCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedBorderColor

						Text {
							anchors.centerIn: parent
							text: hideCheckBox.checked ? "\u2713" : ""
							color: themeLoader.item.checkBoxUnCheckedColor
							font.pixelSize: 12
						}
					}

					onCheckedChanged: {
						if (hideCheckBox.checked) {
							sortedAchievementModel.hideUnlocked();
						} else {
							sortedAchievementModel.clearUnlockedFilter();
						}
					}
				}
				Text {
					text: qsTr("Hide unlocked achievements")
					font.family: "Verdana"
					font.pixelSize: 13
					color: themeLoader.item.basicTextColor
					verticalAlignment: Text.AlignVCenter
					MouseArea {
						anchors.fill: parent
						onClicked: {
							hideCheckBox.checked = !hideCheckBox.checked
						}
					}
				}
			}
		}
	}
}
