/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} Sinofine <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasma5support 2.0 as P5Support
import QtGraphicalEffects 1.0

Item {
    id: root
    property var d: []
    //property bool trans: false
    property int refresh: plasmoid.configuration.refreshRate
    readonly property double currentTimeCache: (mpris2Source.currentData && mpris2Source.currentData.Position)/1000 || 0
    property double currentTime
    Behavior on currentTime {
        NumberAnimation {duration: refresh}
    }
    readonly property bool isPlaying: mpris2Source.currentData ? mpris2Source.currentData.PlaybackStatus === "Playing" : false
    readonly property var currentMetaData: mpris2Source.currentData ? mpris2Source.currentData.Metadata : undefined
    property int currentItem: 0
    readonly property var currentTimeRange: d[currentItem] ? [d[currentItem].start,d[currentItem].end] : [0,0]
    readonly property var currentTimeList: d[currentItem] ? d[currentItem].nodes.reduce((init,curr)=>(init.push(curr.start,curr.end),init),[]): []
    readonly property var currentLyricStr: d[currentItem] ? d[currentItem].nodes.map(a=>a.content): []
    onCurrentTimeCacheChanged: {
        if(!isPlaying) return;
        if(!d.length) currentItem = 0
        else for(let i = 0; i<d.length;i++){
            if(d[i].start<=currentTime && d[i].end>currentTime) currentItem = i
        }
        currentTime = currentTimeCache + refresh
    }
    readonly property string musicName: track + " " + artist
    property bool lastRequest: false
    readonly property double duration: currentMetaData ? currentMetaData["mpris:length"]/1000 || 0 : 0
    onMusicNameChanged: {
        Qt.callLater(updateLyric)
    }
    
    property string track: {
        if(!currentMetaData) return ""
        let title = currentMetaData["xesam:title"]
        if(title) return title
        let url = currentMetaData["xesam:url"] ? currentMetaData["xesam:url"].toString() : ""
        if(!url) return ""
        let lastpos = url.lastIndexOf("/")
        if(lastpos<0) return ""
        let part = url.substring(lastpos+1)
        return decodeURIComponent(part)
    }
    property string artist: {
        if (!currentMetaData) return ""
        let artist = currentMetaData["xesam:artist"]
        if(!artist || artist.length===0) artist = currentMetaData["xesam:albumArtist"] || [""]
        return artist.join(", ")
    }
    property bool noPlayer: mpris2Source.sources.length <=1
    property var mprisSourcesModel: []

    P5Support.DataSource {
        id: mpris2Source

        readonly property string multiplexSource: "@multiplex"
        property string current: multiplexSource

        readonly property var currentData: data[current]

        engine: "mpris2"
        connectedSources: sources

        onSourceAdded: source => {
            updateMprisSourcesModel()
        }

        onSourceRemoved: source => {
            // if player is closed, reset to multiplex source
            if (source === current) {
                current = multiplexSource
            }
            updateMprisSourcesModel()
        }
    }
    function updateMprisSourcesModel () {
        var model = [{
            'text': i18n("Choose player automatically"),
            'icon': 'emblem-favorite',
            'source': mpris2Source.multiplexSource
        }]

        var proxyPIDs = [];  // for things like plasma-browser-integration
        var sources = mpris2Source.sources
        for (var i = 0, length = sources.length; i < length; ++i) {
            var source = sources[i]
            if (source === mpris2Source.multiplexSource) {
                continue
            }

            const playerData = mpris2Source.data[source];
            // source data is removed before its name is removed from the list
            if (!playerData) {
                continue;
            }

            model.push({
                'text': playerData["Identity"],
                'icon': playerData["Desktop Icon Name"] || playerData["DesktopEntry"] || "emblem-music-symbolic",
                'source': source
            });


            if ("kde:pid" in playerData["Metadata"]) {
                var proxyPID = playerData["Metadata"]["kde:pid"];
                if (!proxyPIDs.includes(proxyPID)) {
                    proxyPIDs.push(proxyPID);
                }
            }
        }

        // prefer proxy controls like plasma-browser-integration over browser built-in controls
        model = model.filter( item => {
            if (mpris2Source.data[item["source"]] && "InstancePid" in mpris2Source.data[item["source"]]) {
                return !(proxyPIDs.includes(mpris2Source.data[item["source"]]["InstancePid"]));
            }
            return true;
        });

        root.mprisSourcesModel = model;
    }
    function retrievePosition() {
        var service = mpris2Source.serviceForSource(mpris2Source.current);
        var operation = service.operationDescription("GetPosition");
        service.startOperationCall(operation);
    }
    function request(url) {
        return new Promise((resolve,reject)=>{
            let xhr = new XMLHttpRequest();
            xhr.onreadystatechange = ()=> {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if(xhr.status !== 200) reject()
                    else resolve(xhr.responseText)
                }
            };
            xhr.open('GET', url, true);
            xhr.send();
        })
    }
    function updateLyric(){
        console.log("meow loading lyrics for ["+ musicName +"]...")
        d = []
        let proc = a=>{
            let res = JSON.parse(a)
            if(res.body!==null) return res.body
            else return []
        }
        Promise.all([
            request("https://krcparse.sinofine.me/163/"+encodeURIComponent(musicName)+"?body=1").then(proc),
            request("https://krcparse.sinofine.me/kugou/"+encodeURIComponent(musicName)+"?body=1").then(proc),
            request("https://krcparse.sinofine.me/qq/"+encodeURIComponent(musicName)+"?body=1").then(proc),
        ]).then(arr=>{
            let res = arr.filter(s=>s.length)
            d = res.length?(()=>{
                if(res[0][0].start>0) res[0].unshift({nodes:[{start: 0, end: res[0][0].start, content:musicName}], start: 0, end: res[0][0].start})
                return res[0]
                })():[]
            currentItem = 0
        })
    }


	Timer {
		interval: refresh
		running: true
		repeat: true
		onTriggered: {
			retrievePosition();
		}
	}
    function action_transparent(){
        trans = !trans
    }
    Component.onCompleted: {
        //mpris2Source.serviceForSource("@multiplex").enableGlobalShortcuts()
        //Plasmoid.setAction("transparent","toggle desktop widght transparent")
        updateMprisSourcesModel()
    }
    onStateChanged: {
        if (state != "") {
            plasmoid.status = PlasmaCore.Types.ActiveStatus
        } else {
            updatePlasmoidStatusTimer.restart()
        }
    }

    Plasmoid.fullRepresentation: FullRepresentation {}
    Plasmoid.compactRepresentation: CompactRepresentation {}
}