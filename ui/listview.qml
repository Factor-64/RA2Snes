import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0
import QtQuick.Effects

ListView {
	implicitHeight: contentHeight
	layoutDirection: Qt.Vertical
	interactive: false
	model: sortedAchievementModel
	clip: true
	delegate: Rectangle {
		height: {
			var h = descriptionText.implicitHeight + 28;
			if(achievementProgressColumn.visible)
				h += achievementProgressColumn.implicitHeight;
			else
				h += unlockedTime.implicitHeight;
			return Math.max(72, h);
		}
		id: achievement
		Component.onCompleted: {
			if (parent !== null)
			{
			   anchors.left = parent.left
			   anchors.right = parent.right
			   anchors.leftMargin = 20
			   anchors.rightMargin = 20
			}
		}
		color: index % 2 == 0 ? themeLoader.item.mainWindowLightAccentColor : themeLoader.item.mainWindowBackgroundColor
		opacity: 1
		z: 1

		Row {
			id: achievementInfoRow
			spacing: 10
			anchors.leftMargin: 8
			anchors.rightMargin: 8
			anchors.topMargin: 4
			anchors.bottomMargin: 4
			anchors.fill: parent

			Image {
				id: badge
				source: model.unlocked ? model.badgeUrl : model.badgeLockedUrl
				width: 64
				height: 64
				Layout.alignment: Qt.AlignVCenter
				cache: true
				asynchronous: true
			}

			ColumnLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
				spacing: 0
				Row {
					spacing: 8
					Text {
						id: titleText
						text: model.title
						color: themeLoader.item.linkColor
						font.family: "Verdana"
						font.pixelSize: 13
						Layout.fillWidth: true
						wrapMode: Text.WordWrap
						MouseArea {
							id: mouseArea
							anchors.fill: parent
							hoverEnabled: true
							onClicked: {
								Qt.openUrlExternally(model.achievementLink)
							}
							onEntered: titleText.state = "hovered"
							onExited: titleText.state = ""
						}

						states: [
							State {
								name: "hovered"
								PropertyChanges {
									target: titleText
									color: themeLoader.item.selectedLink
								}
							}
						]

						transitions: [
							Transition {
								from: ""
								to: "hovered"
								ColorAnimation {
									target: titleText
									property: "color"
									duration: 200
								}
							},
							Transition {
								from: "hovered"
								to: ""
								ColorAnimation {
									target: titleText
									property: "color"
									duration: 200
								}
							}
						]
					}
					Text {
						text: "(" + model.points + ")"
						font.family: "Verdana"
						font.pixelSize: 13
						color: themeLoader.item.basicTextColor
						Layout.fillWidth: true
					}
				}
				Text {
					id: descriptionText
					text: model.description
					font.family: "Verdana"
					font.pixelSize: 13
					color: themeLoader.item.basicTextColor
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
					Layout.preferredWidth: achievement.width - 120
				}
			}
		}
		Text {
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 10
			anchors.leftMargin: badge.width + 20
			id: unlockedTime
			color: themeLoader.item.timeStampColor
			text: {
				if(model.timeUnlockedString !== "")
					"Unlocked " + model.timeUnlockedString
				else ""
			}
			font.family: "Verdana"
			font.pixelSize: 10
		}
		Column {
			id: achievementProgressColumn
			anchors.bottom:  parent.bottom
			anchors.right: parent.right
			anchors.bottomMargin: 10
			anchors.rightMargin: 42
			visible: model.target > 0
			Text {
				id: achievementProgressText
				anchors.right: parent.right
				text: model.value + "/" + model.target + " (" + percent + "%)"
				color: {
					if(model.value > 0)
						themeLoader.item.progressBarColor
					else index % 2 == 0 ? themeLoader.item.mainWindowBackgroundColor : themeLoader.item.mainWindowLightAccentColor
				}
				font.pixelSize: 10
				font.bold: true
			}
			ProgressBar {
				id: achievementProgressBar
				width: 198
				height: 6
				value: model.percent / 100
				anchors.leftMargin: 1
				z: 2
				Item {
					z: 1
					width: achievementProgressBar.width + 2
					height: achievementProgressBar.height
					anchors.left: parent.left
					anchors.leftMargin: -1
					Rectangle {
						width: parent.width
						height: parent.height
						radius: 6
						color: index % 2 == 0 ? themeLoader.item.mainWindowBackgroundColor : themeLoader.item.mainWindowLightAccentColor
						anchors.bottom: parent.bottom
					}
				}
				Item {
					z: 2
					width: (achievementProgressBar.width + 2) * achievementProgressBar.value
					height: achievementProgressBar.height
					anchors.left: parent.left
					anchors.leftMargin: -1
					Rectangle {
						id: roundedBar2
						width: parent.width
						height: parent.height
						radius: 6
						color: themeLoader.item.progressBarColor
						anchors.bottom: parent.bottom
					}
				}
			}
		}
		Rectangle {
			id: primedRectangle
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.topMargin: 4
			anchors.rightMargin: 4
			width: 28
			height: 28
			radius: 50
			border.width: 1
			border.color: themeLoader.item.popoutBorderColor
			color: themeLoader.item.popoutBackgroundColor
			visible: model.primed
			z: 2

			Text {
				z: 3
				id: primedText
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 20
				font.bold: true
				font.family: "Verdana"
				font.pixelSize: 10
				text: "Primed"
				color: themeLoader.item.popoutTextColor
				visible: false
				opacity: 0.0

				Behavior on opacity {
					NumberAnimation {
						duration: 250
					}
				}

				Behavior on anchors.leftMargin {
					NumberAnimation {
						duration: 250
					}
				}
			}

			Image {
				z: 4
				id: svgPrimed
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.rightMargin: 5
				width: 18
				height: 18
				source: "./images/primed"
				layer.enabled: true
				layer.effect: MultiEffect {
					colorization: 1.0
					colorizationColor: themeLoader.item.primedIconColor
				}
				asynchronous: true
			}

			MouseArea {
				anchors.fill: parent
				onEntered: primedRectangle.state = "hovered"
				onExited: primedRectangle.state = ""
				hoverEnabled: true
			}

			states: [
				State {
					name: "hovered"
					PropertyChanges {
						target: primedRectangle
						width: primedText.width + 38
					}
					PropertyChanges {
						target: primedText
						visible: true
						anchors.leftMargin: 10
						opacity: 1.0
					}
					PropertyChanges {
						target: svgPrimed
					}
				}
			]

			transitions: [
				Transition {
					from: ""
					to: "hovered"
					PropertyAnimation {
						target: typeRectangle
						property: "width"
						duration: 50
					}
				},
				Transition {
					from: "hovered"
					to: ""
					PropertyAnimation {
						target: typeRectangle
						property: "width"
						duration: 200
					}
				}
			]
		}

		Rectangle {
			id: typeRectangle
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 4
			anchors.rightMargin: 4
			width: 28
			height: 28
			radius: 50
			border.width: 1
			border.color: themeLoader.item.popoutBorderColor
			color: themeLoader.item.popoutBackgroundColor
			visible: model.type !== ""
			z: 2

			Text {
				z: 3
				id: typeText
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 20
				font.bold: true
				font.family: "Verdana"
				font.pixelSize: 10
				text: {
					if(model.type === "win_condition")
						"Win Condition"
					else if(model.type === "missable")
						"Missable"
					else if(model.type === "progression")
						"Progression"
					else ""
				}
				color: themeLoader.item.popoutTextColor
				visible: false
				opacity: 0.0

				Behavior on opacity {
					NumberAnimation {
						duration: 250
					}
				}

				Behavior on anchors.leftMargin {
					NumberAnimation {
						duration: 250
					}
				}
			}

			Image {
				property color type: "#ffffff"
				z: 4
				id: svgImage
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.rightMargin: 5
				width: 18
				height: 18
				source: {
					if(model.type === "win_condition")
					{
						svgImage.type = themeLoader.item.winConditionIconColor;
						"./images/win_condition.svg";
					}
					else if(model.type === "missable")
					{
						svgImage.type = themeLoader.item.missableIconColor;
						"./images/missable.svg";
					}
					else if(model.type === "progression")
					{
						svgImage.type = themeLoader.item.progressionIconColor;
						"./images/progression.svg";
					}
					else ""
				}
				layer.enabled: true
				layer.effect: MultiEffect {
					colorization: 1.0
					colorizationColor: svgImage.type
				}
				asynchronous: true
			}

			MouseArea {
				anchors.fill: parent
				onEntered: typeRectangle.state = "hovered"
				onExited: typeRectangle.state = ""
				hoverEnabled: true
			}

			states: [
				State {
					name: "hovered"
					PropertyChanges {
						target: typeRectangle
						width: typeText.width + 38
					}
					PropertyChanges {
						target: typeText
						visible: true
						anchors.leftMargin: 10
						opacity: 1.0
					}
					PropertyChanges {
						target: svgImage
					}
				}
			]

			transitions: [
				Transition {
					from: ""
					to: "hovered"
					PropertyAnimation {
						target: typeRectangle
						property: "width"
						duration: 50
					}
				},
				Transition {
					from: "hovered"
					to: ""
					PropertyAnimation {
						target: typeRectangle
						property: "width"
						duration: 200
					}
				}
			]
		}
	}
}
