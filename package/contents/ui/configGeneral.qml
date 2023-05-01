/**
    Copyright 2016 Bill Binder <dxtwjb@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15 as QtLayouts
import QtQuick.Dialogs 1.3 as QtDialogs

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.plasma5support 2.0 as P5Support


Item {
    id: generalPage

    property alias cfg_latitudeAuto: latitudeAuto.checked  // 0=Equator, +90=North Pole, -90=South Pole
    property alias cfg_latitude: latitude.value  // 0=Equator, +90=North Pole, -90=South Pole
    property alias cfg_transparentShadow: transparentShadow.checked  // boolean
    property alias cfg_showBackground: showBackground.checked  // boolean
    property alias cfg_dateFormat: dateFormat.currentIndex // code: 0= 1= 2=...
    property alias cfg_dateFormatString: dateFormatString.text
    property alias cfg_diskColour: diskColour.color

    property int cfg_lunarIndex: 0        // index into imageChoices
    property string cfg_lunarImage: ''    // filename (from imageChoices)
    property int cfg_lunarImageTweak: 0   // rotation angle adjustment for the image (from imageChoices)

    property alias cfg_showGrid: showGrid.checked
    property alias cfg_showTycho: showTycho.checked
    property alias cfg_showCopernicus: showCopernicus.checked

    onCfg_lunarIndexChanged: {
        cfg_lunarImage = imageChoices.get(cfg_lunarIndex).filename
        cfg_lunarImageTweak = imageChoices.get(cfg_lunarIndex).tweak
        if (cfg_lunarImage == '') {
            cfg_transparentShadow = false  //transparentShadow does not work with diskColour
        }
    }

    onCfg_latitudeAutoChanged: {
        if (cfg_latitudeAuto) {
            cfg_latitude = geoSource.data.location.latitude
        }
    }

    ImageChoices {
        id: imageChoices
    }

    P5Support.DataSource {
        id: geoSource
        engine: "geolocation"
        connectedSources: ["location"]
        interval: 3600 * 1000

        onNewData:{
            lbl_place.text = i18n(geoSource.data.location.country)
        }
    }

    QtDialogs.ColorDialog {
        id: colorDialog
        title: i18n("Pick a colour for the moon")
        visible: false

        onAccepted: {
            diskColour.color = colorDialog.color
        }
    }

    QtLayouts.GridLayout {
        columns: 2
        rowSpacing: 15

        QQC2.Label {
            text: i18n("Preview")
        }
        QtLayouts.RowLayout {
            spacing: 20

            PC3.ToolButton {
                id: previousButton
                icon.name: "go-previous"
                enabled: cfg_lunarIndex > 0
                onClicked: {
                    cfg_lunarIndex -= 1
                }
            }

            LunaIcon {
              id: lunaPreview
              width: 200
              height: 200
              latitude: cfg_latitude
              showShadow: false
              transparentShadow: false
              lunarImage: cfg_lunarImage
              lunarImageTweak: cfg_lunarImageTweak
              diskColour: cfg_diskColour
              showGrid: cfg_showGrid
              showTycho: cfg_showTycho
              showCopernicus: cfg_showCopernicus
            }

            PC3.ToolButton {
                id: nextButton
                icon.name: "go-next"
                enabled: cfg_lunarIndex < imageChoices.count-1
                onClicked: {
                    cfg_lunarIndex += 1
                }
            }

            QtLayouts.ColumnLayout {
                spacing: 20

                QQC2.CheckBox {
                    id: showGrid
                    text: i18n("Show grid")
                }

                QQC2.CheckBox {
                    id: showTycho
                    text: i18n("Tycho")
                }

                QQC2.CheckBox {
                    id: showCopernicus
                    text: i18n("Copernicus")
                }

            }
        }

        QQC2.Label {
            text: i18n("Disk Colour")
            visible: cfg_lunarImage === ""
        }
        Rectangle {
            id: diskColour
            width: 50
            height: 50
            color: '#808040'
            border.color: '#000000'
            radius: height/2
            visible: cfg_lunarImage === ""

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorDialog.color = diskColour.color
                    colorDialog.visible = true
                }
            }
        }

        QQC2.Label {
            text: i18n("Latitude")
        }
        QtLayouts.RowLayout {
            spacing: 20

            QQC2.Label {
                id: lbl_latitude
                text: Math.abs(latitude.value) + "º " + (latitude.value < 0 ? "S" : "N")
                QtLayouts.Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }

            QQC2.Slider {
                id: latitude
                QtLayouts.Layout.fillWidth: true
                from: -90.0
                to: 90.0
                stepSize: 5.0
                enabled: !cfg_latitudeAuto
            }
        }
        QQC2.Label {
            text: i18n("")
        }
        QtLayouts.RowLayout {
            spacing: 20
            QQC2.CheckBox {
                id: latitudeAuto
                text: i18n("Use current latitude")
            }
            QQC2.Label {
                id: lbl_place
                QtLayouts.Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }

        QQC2.Label {
            text: i18n("Date Format")
        }
        QQC2.ComboBox {
            id: dateFormat
            QtLayouts.Layout.fillWidth: true
            textRole: "key"
            model: ListModel {
                dynamicRoles: true
                Component.onCompleted: {
                append({ key: i18n("Text date"), value: 0 })
                append({ key: i18n("Short date"), value: 1 })
                append({ key: i18n("Long date"), value: 2 })
                append({ key: i18n("ISO date"), value: 3 })
                append({ key: i18n("Custom"), value: 4 })
                }
            }
        }

        QQC2.Label {
            text: i18n("Date Format String")
            visible: dateFormat.currentIndex == 4
        }
        QQC2.TextField {
            id: dateFormatString
            maximumLength: 24
            visible: dateFormat.currentIndex == 4
        }
        QQC2.Label {
            text: i18n("Background")
        }
        QQC2.CheckBox {
            id: showBackground
            text: i18n("Show background")
        }
        QQC2.Label {
            text: ""
        }
        QQC2.CheckBox {
            id: transparentShadow
            text: i18n("Transparent shadow")
            enabled: cfg_lunarImage != ""
        }
    }
}
