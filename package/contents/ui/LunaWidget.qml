/*

    Copyright 2016 Bill Binder <dxtwjb@gmail.com>
      Updated the Luna QML plasmoid from Plasma 4 to Plasma 5.
    Copyright (C) 2011, 2012, 2013 Glad Deschrijver <glad.deschrijver@gmail.com>

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

import QtQuick 2.7
import QtQuick.Layouts 1.2 as QtLayouts
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.plasmoid 2.0

import "../code/phases.js" as Phases
import "../code/lunacalc.js" as LunaCalc

Item {
    id: lunaWidget
    anchors.centerIn: parent

    focus: true // needs to be focused, otherwise the key events aren't caught

    property int dateFormat: 0
    property var dateFormatQt: 0
    property string dateFormatString: "hh"

    QtLayouts.Layout.minimumWidth: labelButtonColumn.width
    QtLayouts.Layout.minimumHeight: labelButtonColumn.height

    Component.onCompleted: {
        setDateFormat();
        showTodayPhases();
    }

    onDateFormatChanged: setDateFormat()

    onDateFormatStringChanged: setDateFormat()

    Keys.onUpPressed: showPreviousPhases()
    Keys.onLeftPressed: showPreviousPhases()
    Keys.onRightPressed: showNextPhases()
    Keys.onDownPressed: showNextPhases()

    Keys.onPressed: {
        if (event.key == Qt.Key_Home)
            showTodayPhases();
        else if (event.key == Qt.Key_PageUp)
            showPreviousPhases();
        else if (event.key == Qt.Key_PageDown)
            showNextPhases();
    }

    function setDateFormat() {
        if (dateFormat == 0)
            lunaWidget.dateFormatQt = Qt.TextDate;
        else if (dateFormat == 1)
            lunaWidget.dateFormatQt = Qt.DefaultLocaleShortDate;
        else if (dateFormat == 2)
            lunaWidget.dateFormatQt = Qt.DefaultLocaleLongDate;
        else if (dateFormat == 3)
            lunaWidget.dateFormatQt = Qt.ISODate;
        else {
            lunaWidget.dateFormatQt = dateFormatString;
        }
        showPhases(LunaCalc.reloadPhases());
    }

    function showPhases(phases) {
        lastNewText.text = Qt.formatDateTime(phases[0], lunaWidget.dateFormatQt);
        firstQuarterText.text = Qt.formatDateTime(phases[1], lunaWidget.dateFormatQt);
        fullMoonText.text = Qt.formatDateTime(phases[2], lunaWidget.dateFormatQt);
        thirdQuarterText.text = Qt.formatDateTime(phases[3], lunaWidget.dateFormatQt);
        nextNewText.text = Qt.formatDateTime(phases[4], lunaWidget.dateFormatQt);
        lunaWidget.focus = true;
    }

    function showTodayPhases() {
        showPhases(LunaCalc.getTodayPhases());
    }

    function showPreviousPhases() {
        showPhases(LunaCalc.getPreviousPhases());
    }

    function showNextPhases() {
        showPhases(LunaCalc.getNextPhases());
    }

    Column {
        id: labelButtonColumn

        anchors.centerIn: parent

        spacing: 10

        Grid {
            id: labelArea
            columns: 2
            padding: 10
            flow: Grid.LeftToRight
            PC3.Label {
                id: lastNewLabel
                text: i18n("Last new:") + "  "
            }
            PC3.Label {
                id: lastNewText
            }
            PC3.Label {
                id: firstQuarterLabel
                text: i18n("First quarter:") + "  "
            }
            PC3.Label {
                id: firstQuarterText
            }
            PC3.Label {
                id: fullMoonLabel
                text: i18n("Full moon:") + "  "
            }
            PC3.Label {
                id: fullMoonText
            }
            PC3.Label {
                id: thirdQuarterLabel
                text: i18n("Third quarter:") + "  "
            }
            PC3.Label {
                id: thirdQuarterText
            }
            PC3.Label {
                id: nextNewLabel
                text: i18n("Next new:") + "  "
            }
            PC3.Label {
                id: nextNewText
            }
        }
        Row {
            id: buttonRow
            anchors.horizontalCenter: parent.horizontalCenter
            PC3.ToolButton {
                id: previousButton
                icon.name: "go-previous"
                onClicked: showPreviousPhases();
            }
            PC3.ToolButton {
                id: todayButton
                icon.name: "go-jump-today"
                onClicked: showTodayPhases();
            }
            PC3.ToolButton {
                id: nextButton
                icon.name: "go-next"
                onClicked: showNextPhases();
            }
        }
    }
}
