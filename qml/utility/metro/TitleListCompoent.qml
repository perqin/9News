// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Text{
    id: root
    property int fontSize: 9

    text: title
    anchors.verticalCenter: parent.verticalCenter
    opacity: 1-Math.abs(currentPageIndex-index)/10

    color: {
        if(currentPageIndex==index){
            return command.invertedTheme?"black":"white"
        }else{
            return command.invertedTheme?"#666":"#ddd"
        }
    }

    font{
        bold: currentPageIndex == index
        pointSize: {
            var deviations = Math.abs(currentPageIndex-index)
            if(deviations<4)
                return fontSize - deviations*2
            else
                return 3
        }
    }
}
