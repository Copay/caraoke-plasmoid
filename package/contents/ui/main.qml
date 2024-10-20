/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} Sinofine <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root
    property var d
    property var lastRequestTerm
    property int refresh: plasmoid.configuration.refreshRate
    readonly property string apiServerAddress: plasmoid.configuration.apiServerAddress || "https://krcparse.sinofine.me"
    readonly property double currentTimeCache: (mpris2Model.currentPlayer?.position) / 1000 ?? 0
    property double oldtimecache
    property double currentTime
    Behavior on currentTime {
        NumberAnimation {
            duration: refresh
        }
    }
    Timer {
        id: seekTimer
        interval: refresh
        repeat: true
        running: true
        onTriggered: {
            mpris2Model.currentPlayer?.updatePosition();
        }
    }
    Timer {
        id: changeLyricSelectionTimer
        repeat: false
        onTriggered: {
            // console.log(`done, interval: ${interval}`)
            mpris2Model.currentPlayer?.updatePosition();
        }
    }
    readonly property bool isPlaying: mpris2Model.currentPlayer?.playbackStatus === Mpris.PlaybackStatus.Playing
    /* readonly property var currentMetaData: mpris2Model.currentPlayer?.Metadata ?? undefined */
    property int currentItem: 0
    readonly property var currentTimeRange: d[currentItem] ? [d[currentItem].start, d[currentItem].end] : [0, 0]
    readonly property var currentTimeList: d[currentItem] ? d[currentItem].nodes.reduce((init, curr) => (init.push(curr.start, curr.end), init), []) : []
    readonly property var currentLyricStr: d[currentItem] ? d[currentItem].nodes.map(a => a.content) : []
    onCurrentTimeCacheChanged: {
        if (!isPlaying)
            return;
        if (!d || !d.length)
            currentItem = 0;
        else
            for (let i = 0; i < d.length; i++) {
                if (d[i].start <= currentTime && d[i].end > currentTime)
                    currentItem = i;
            }
        currentTime = currentTimeCache + refresh || 0;
        oldtimecache = currentTimeCache || 0;
    }
    readonly property string musicName: track + " " + artist
    property bool lastRequest: false
    readonly property double duration: mpris2Model.currentPlayer?.length / 1000 ?? 0
    onMusicNameChanged: {
        if(!(new RegExp(plasmoid.configuration.playerFilter)).test(mpris2Model.currentPlayer?.objectName)) return;
        Qt.callLater(updateLyric);
    }

    readonly property string track: mpris2Model.currentPlayer?.track ?? ""
    readonly property string artist: mpris2Model.currentPlayer?.artist ?? ""
    property bool noPlayer: mpris2Model.length < 1

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    function retrievePosition() {
        mpris2Model.currentPlayer?.updatePosition();
    }
    function request(url) {
        return new Promise((resolve, reject) => {
            let xhr = new XMLHttpRequest();
            xhr.onreadystatechange = () => {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status !== 200)
                        reject();
                    else
                        resolve(xhr.responseText);
                }
            };
            xhr.open('GET', url, true);
            xhr.send();
        });
    }
    signal lyricUpdated
    function updateLyric() {
        let currentMusicName = musicName.trim();
        if(lastRequestTerm == currentMusicName) return;
        if (!currentMusicName || !currentMusicName.length) return; // Do not proceed null name.
        console.log("meow loading lyrics for [" + currentMusicName + "] with API server [" + apiServerAddress + "]...");
        d = [];
        let proc = a => {
            let res = JSON.parse(a);
            if (res.body !== null)
                return res.body;
            else
                return [];
        };
        Promise.all([request(apiServerAddress + "/163/" + encodeURIComponent(currentMusicName) + "?body=1").then(proc), request(apiServerAddress + "/kugou/" + encodeURIComponent(currentMusicName) + "?body=1").then(proc), request(apiServerAddress + "/qq/" + encodeURIComponent(currentMusicName) + "?body=1").then(proc),]).then(arr => {
            if(currentMusicName !== musicName) return; // Encountered the wrong music.
            let res = arr.filter(s => s.length);
            d = res.length ? (() => {
                    if (res[0][0].start > 0)
                        res[0].unshift({
                            nodes: [
                                {
                                    start: 0,
                                    end: res[0][0].start,
                                    content: currentMusicName
                                }
                            ],
                            start: 0,
                            end: res[0][0].start
                        });
                    
                    return res[0];
                })() : [];
            currentItem = 0;
            if(d.length &&d.length>0)lyricUpdated();
            console.log("Music Queried. ")
        });
    }

    Component.onCompleted: {
        d = [];
    }

    fullRepresentation: FullRepresentation {
    }
    compactRepresentation: CompactRepresentation {
    }
}
