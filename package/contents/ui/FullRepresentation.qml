import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtGraphicalEffects 1.0

PlasmaExtras.Representation {
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
                    fontWeight: Font.Bold
                    fontFamily: "Noto Serif CJK SC"
                }
            }
            function setclip(){
                row.anchors.centerIn=undefined
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