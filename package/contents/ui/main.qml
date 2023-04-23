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
    property double currentTimeCache
    property double currentTime: (mpris2Source.currentData && mpris2Source.currentData.Position)/1000 || 0
    property var currentMetaData: mpris2Source.currentData ? mpris2Source.currentData.Metadata : undefined
    property int currentItem
    onCurrentTimeChanged: {
        if(!d) currentItem = 0
        else for(let i = 0; i<d.length;i++){
            if(d[i].start<=currentTime && d[i].end>currentTime) currentItem = i
        }
    }
    property string musicName: track + " " + artist
    property bool lastRequest: false
    property double duration: currentMetaData ? currentMetaData["mpris:length"]/1000 || 0 : 0
    onMusicNameChanged: {
        if(!lastRequest) singleShot.createObject(this, {
            action: ()=>{
                updateLyric()
                lastRequest=false
            }, 
            interval:16}
        )
        lastRequest = true
        
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
            xhr.onload = ()=>{
                if(xhr.status !== 200) reject()
                else resolve(xhr.responseText)
            };
            xhr.open('GET', url, true);
            xhr.send();
        })
        
    }
    function updateLyric(){
        console.log("meow loading lyrics for ["+ musicName +"]...")
        request("https://krcparse.sinofine.me/qq/"+encodeURIComponent(musicName)+"?body=1").then(a=>{
            let res = JSON.parse(a)
            if(res.body!==null) d=res.body
            else d=[]
        })
    }

    // Component {
    //     id: interpolation
    //     NumberAnimation {
    //         property: "currentTime"
    //         from: currentTimeCache
    //         to: currentTimeCache+166
    //         duration: 166
    //         target: root
    //     }
    // }

	Timer {
		interval: 16
		running: true
		repeat: true
		onTriggered: {
			retrievePosition();
            // currentTimeCache = currentTime
            // interpolation.createObject(this, {
            //         onStopped: ()=>{
            //             slideAnimation.destroy()
            //         }
            // }).start()
		}
	}
    
    Component.onCompleted: {
        mpris2Source.serviceForSource("@multiplex").enableGlobalShortcuts()
        updateMprisSourcesModel()
    }
    onStateChanged: {
        if (state != "") {
            plasmoid.status = PlasmaCore.Types.ActiveStatus
        } else {
            updatePlasmoidStatusTimer.restart()
        }
    }

    component TextWithTime: Item{
        property string texts
        property var t
        width: mask.width
        height: mask.height
        Text {
            id: mask
            text: texts
            font.pointSize: 30
        }
        Rectangle {
            id: bg
            anchors.top: mask.top
            anchors.bottom: mask.bottom
            anchors.left: mask.left
            anchors.right: mask.right
            color: PlasmaCore.Theme.textColor
            Rectangle {
                id: left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width*t
                color: "red"//PlasmaCore.Theme.highlightedTextColor
            }
            visible: false
        }
        
        OpacityMask {
            anchors.fill: bg
            source: bg
            maskSource: mask
        }
    }
    Component {
        id: numani
        NumberAnimation {
            property: "t"
            from: 0
            to: 1
        }
    }
    Component {
        id: singleShot
        Timer {
            property var action
            running: true
            onTriggered: {
                if (action) action() // To check, whether it is a function, would be better.
                this.destroy()
            }
        }
    }

    property var d: []
    Plasmoid.fullRepresentation: Item {
        //Layout.minimumWidth: row.implicitWidth
        Layout.minimumHeight: row.implicitHeight
        Layout.preferredWidth: 640 * PlasmaCore.Units.devicePixelRatio
        clip: true

        id: lyricPanel
        
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 0
            property var slideAnimation
            Repeater {
                id: lyricNode
                model: d[currentItem]?d[currentItem].nodes:[]
                TextWithTime {
                    id: twi
                    texts: modelData.content
                }
            }
            function setclip(){
                row.anchors.centerIn=undefined
                //anchors.left = lyricPanel.left
                slideAnimation = slidani.createObject(this, {
                    duration: d[currentItem] ? parseInt(d[currentItem].end - d[currentItem].start):0,
                    onStopped: ()=>{
                        slideAnimation.destroy()
                    }
                })
                slideAnimation.start()
            }
            function setnoclip(){
                if(slideAnimation)slideAnimation.complete()
                row.anchors.centerIn=parent
            }
        }
        
        AnimationController {
            id: controller
            progress: d[currentItem] ? (currentTime - d[currentItem].start) / (d[currentItem].end - d[currentItem].start):0
            SequentialAnimation {
                id: seq
            }
        }
        Component.onCompleted: {
            root.currentItem=0
            updateAnim()
        }
        Component {
            id: numani
            NumberAnimation {
                property: "t"
                from: 0
                to: 1
            }
        }
        Component {
            id: slidani
            NumberAnimation {
                from: 0
                to: lyricPanel.width - row.width
                target: row
                property: "x"
                easing.type: Easing.InOutCubic
            }
        }
        function updateAnim() {
            if(!d[currentItem])return
            let n = d[currentItem].nodes
            let anim = []
            for(let a = 0; a< n.length;a++){
                anim.push(numani.createObject(lyricPanel,{target:lyricNode.itemAt(a), duration: n[a].end-n[a].start}))
            }
            seq.animations = anim
            controller.progress=0
            controller.reload()
            
            singleShot.createObject(this, {
                action: ()=>{
                    if (lyricPanel.width < row.width) {
                        row.setclip()
                    }else {
                        row.setnoclip()
                    }
                }, 
                interval:16}
            )
        }
        Connections {
            target: root
            function onCurrentItemChanged() {
                lyricPanel.updateAnim()
            }
            function onCurrentTimeChanged() {
                controller.progress = d[currentItem] ? (currentTime - d[currentItem].start) / (d[currentItem].end - d[currentItem].start):0
            }
        }
    }
}