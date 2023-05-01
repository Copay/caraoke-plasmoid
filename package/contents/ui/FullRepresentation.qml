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
        Layout.preferredWidth: plasmoid.configuration.dwidth * PlasmaCore.Units.devicePixelRatio
        clip: true

        id: lyricPanel
        
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 0
            property var slideAnimation
            Repeater {
                id: lyricNode
                model: currentLyricStr
                TextWithTime {
                    id: twi
                    texts: modelData
                    fontSize: plasmoid.configuration.dfontSize
                    fontWeight: plasmoid.configuration.dfontWeight
                    fontFamily: plasmoid.configuration.dfont.family
                }
            }
            function setclip(){
                row.anchors.centerIn=undefined
                slideAnimation = slidani.createObject(this, {
                   duration: currentTimeRange[1] ? (currentTimeRange[1] - currentTimeRange[0]) : 0,
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
            SequentialAnimation {
                id: seq
            }
        }
        Component.onCompleted: {
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
                onStopped: ()=>{
                    this.destroy()
                }
            }
        }
        function updateAnim() {
            let tmp = seq.animations
            if(!currentLyricStr.length)return
            let anim = []
            for(let a = 0; a< currentLyricStr.length;a++){
                anim.push(numani.createObject(lyricPanel,{target:lyricNode.itemAt(a), duration: currentTimeList[2*a+1]-currentTimeList[2*a]}))
            }
            seq.animations = anim
            controller.progress=0
            controller.reload()
            for(let i = 0; i< tmp.length; i++)
                tmp[i].destroy()
            
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
                controller.progress = currentTimeRange[1] ? (currentTime - currentTimeRange[0]) / (currentTimeRange[1] - currentTimeRange[0]):0
            }
        }
    }