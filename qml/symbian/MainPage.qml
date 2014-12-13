<<<<<<< HEAD
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.star.widgets 1.0
import "../utility"
import "../utility/metro"
import "../utility/newsListPage"
import "../js/api.js" as Api

MyPage{
    id: root

    property bool isQuit: false
    //判断此次点击后退键是否应该退出
    signal refreshNewsList
    //发射信号刷新当前新闻列表
    property bool isBusy: false
    //记录是否正在忙碌，例如正在获取新闻分类

    function getNewsCategorysFinished(error, data){
        isBusy = false
        //取消忙碌状态

        //当获取新闻种类结束后调用此函数
        if(error){//如果网络请求出错
            command.showBanner(qsTr("Failed to load the news categorys, will try again."))
            return
        }

        data = JSON.parse(data)
        if(data.error==0){
            for(var i in data.categorys){
                metroView.addItem(data.titles[i], data.categorys[i])
            }
        }else{
            command.showBanner(data.error)
        }
    }

    function updateAllNewsCategorys(){//重新加载所有分类的新闻
        if(isBusy)//如果正在忙就返回
            return

        isBusy = true
        //取消忙碌状态

        metroView.clearPage()
        //先清除所有分类
        metroView.addItem(qsTr("all news"))
        //先增加全部新闻的页
        utility.httpGet(getNewsCategorysFinished, Api.newsCategorysUrl)
        //去获取新闻分类
    }

    tools: ToolBarSwitch{
        id: toolBarSwitch
        toolBarComponent: compoentToolBarLayout
    }

    Component{
        id: compoentToolBarLayout

        CustomToolBarLayout{
            invertedTheme: command.invertedTheme

            ToolButton{
                iconSource: "toolbar-back"
                platformInverted: command.invertedTheme
                onClicked: {
                    if(isQuit){
                        Qt.quit()
                    }else{
                        isQuit = true
                        command.showBanner(qsTr("Press again to exit"))
                        timerQuit.start()
                    }
                }
            }
            ToolButton{
                iconSource: command.getIconSource("skin", command.invertedTheme)
                onClicked: {
                    command.invertedTheme=!command.invertedTheme
                }
            }
            ToolButton{
                iconSource: "toolbar-search"
                platformInverted: command.invertedTheme
                onClicked: {
                    toolBarSwitch.toolBarComponent = compoentCommentToolBar
                    //搜索新闻
                }
            }

            ToolButton{
                iconSource: "toolbar-menu"
                platformInverted: command.invertedTheme
                onClicked: {
                    mainMenu.open()
                }
            }
        }
    }

    Component{
        id: compoentCommentToolBar

        TextAreaToolBar{
            property string oldText: ""

            invertedTheme: command.invertedTheme
            rightButtonIconSource: "toolbar-search"

            onLeftButtonClick: {
                textArea.closeSoftwareInputPanel()
                metroView.pageInteractive = true
                toolBarSwitch.toolBarComponent = compoentToolBarLayout
                if(metroView.getTitle(metroView.currentPageIndex)==qsTr("Searched result")){
                    metroView.removePage(metroView.currentPageIndex)
                    metroView.activation(0)
                }
            }
            onRightButtonClick: {
                if(oldText == textAreaContent||textAreaContent=="")
                    return//如果搜索内容没有变化或者为空则不搜索

                oldText = textAreaContent
                if(metroView.getTitle(metroView.currentPageIndex)==qsTr("Searched result")){
                    metroView.setProperty(metroView.currentPageIndex,
                                          "newsUrl",
                                          Api.getNewsUrlByCategory("", textAreaContent))
                    refreshNewsList()//刷新新闻
                }else{
                    metroView.addItem(qsTr("Searched result"), "", textAreaContent)
                    metroView.activation(metroView.pageCount-1)
                    metroView.pageInteractive = false
                    textArea.closeSoftwareInputPanel()
                }
            }
        }
    }

    HeaderView{
        id: headerView

        invertedTheme: command.invertedTheme
        height: screen.currentOrientation===Screen.Portrait?
                     privateStyle.tabBarHeightPortrait:privateStyle.tabBarHeightLandscape
    }

    Timer{
        //当第一次点击后退键时启动定时器，如果在定时器被触发时用户还未按下第二次后退键则将isQuit置为false
        id: timerQuit
        interval: 2000
        onTriggered: {
            isQuit = false
        }
    }

    MetroView{
        id: metroView
        anchors.fill: parent
        titleBarHeight: headerView.height
        titleSpacing: 25
        titleMaxFontSize: command.style.metroTitleFontPointSize

        function addItem(title, category, keyword, order){
            var obj = {
                "articles": null,//所有大海报的数据
                "covers": null,//所有新闻的数据
                "listContentY": 0,//新闻列表的y值
                "enableAnimation": true,//是否允许列表动画
                "dataOrder": true,//是否按日期排序（否则是按人气）
                "newsUrl": Api.getNewsUrlByCategory(category, keyword, order),
                //新闻列表的获取地址
                "imagePosterUrl": keyword?"":Api.getPosterUrlByCategory(category)
                //大海报的获取地址
            }
            addPage(title, obj)
        }

        delegate: NewsListPage{
            id: newsList

            width: metroView.width
            height: metroView.height-metroView.titleBarHeight

            Connections{
                target: root
                onRefreshNewsList:{
                    newsList.updateList()
                    //如果收到刷新列表的信号就重新获取新闻列表
                }
            }
        }

        Component.onCompleted: {
            updateAllNewsCategorys()
            //加载所有分类的信息
        }
    }
    Connections{
        target: command
        onGetNews:{
            //如果某新闻标题被点击（需要阅读此新闻）
            pageStack.push(Qt.resolvedUrl("NewsContentPage.qml"),
                           {newsId: newsId, newsTitle: title})
        }
    }

    // define the menu
     Menu {
         id: mainMenu
         // define the items in the menu and corresponding actions
         platformInverted: command.invertedTheme
         content: MenuLayout {
             MenuItem {
                 text: qsTr("Personal Center")
                 platformInverted: command.invertedTheme
             }
             MenuItem {
                 text: qsTr("Refresh All News Categorys")
                 platformInverted: command.invertedTheme

                 onClicked: {
                     updateAllNewsCategorys()
                     //更新所有分类的新闻
                 }
             }
             MenuItem {
                 text: qsTr("Settings")
                 platformInverted: command.invertedTheme
             }
             MenuItem {
                 text: qsTr("About")
                 platformInverted: command.invertedTheme
                 onClicked: {
                     pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                 }
             }
         }
     }
}
=======
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.stars.widgets 1.0
import "../utility"
import "../utility/metro"
import "../utility/newsListPage"
import "../js/api.js" as Api

MyPage{
    id: root

    property bool isQuit: false
    //判断此次点击后退键是否应该退出
    signal refreshNewsList
    //发射信号刷新当前新闻列表

    function getNewsCategorysFinished(error, data){
        //当获取新闻种类结束后调用此函数
        if(error)//如果网络请求出错
            return

        data = JSON.parse(data)
        if(data.error==0){
            for(var i in data.categorys){
                metroView.addItem(data.titles[i], data.categorys[i])
            }
        }
    }

    tools: ToolBarSwitch{
        id: toolBarSwitch
        toolBarComponent: compoentToolBarLayout
    }

    Component{
        id: compoentToolBarLayout

        CustomToolBarLayout{
            invertedTheme: command.invertedTheme

            ToolButton{
                iconSource: "toolbar-back"
                platformInverted: command.invertedTheme
                onClicked: {
                    if(isQuit){
                        Qt.quit()
                    }else{
                        isQuit = true
                        main.showBanner(qsTr("Press again to exit"))
                        timerQuit.start()
                    }
                }
            }
            ToolButton{
                iconSource: command.getIconSource("skin", command.invertedTheme)
                onClicked: {
                    command.invertedTheme=!command.invertedTheme
                }
            }
            ToolButton{
                iconSource: "toolbar-search"
                platformInverted: command.invertedTheme
                onClicked: {
                    toolBarSwitch.toolBarComponent = compoentCommentToolBar
                    //搜索新闻
                }
            }

            ToolButton{
                iconSource: "toolbar-menu"
                platformInverted: command.invertedTheme
                onClicked: {
                    mainMenu.open()
                }
            }
        }
    }

    Component{
        id: compoentCommentToolBar

        CommentToolBar{
            invertedTheme: command.invertedTheme

            onLeftButtonClick: {
                textArea.closeSoftwareInputPanel()
                metroView.pageInteractive = true
                toolBarSwitch.toolBarComponent = compoentToolBarLayout
                if(metroView.getTitle(metroView.pageCount-1)==qsTr("Searched result")){
                    metroView.removePage(metroView.pageCount-1)
                    metroView.activation(0)
                }
            }
            onRightButtonClick: {
                if(metroView.getTitle(metroView.pageCount-1)==qsTr("Searched result")){
                    metroView.removePage(metroView.pageCount-1)
                }
                if(textAreaContent!=""){
                    metroView.addItem(qsTr("Searched result"), "", textAreaContent)
                    metroView.activation(metroView.pageCount-1)
                    metroView.pageInteractive = false
                    textArea.closeSoftwareInputPanel()
                }
            }
        }
    }

    HeaderView{
        id: headerView

        invertedTheme: command.invertedTheme
        height: screen.currentOrientation===Screen.Portrait?
                     privateStyle.tabBarHeightPortrait:privateStyle.tabBarHeightLandscape
    }

    Timer{
        //当第一次点击后退键时启动定时器，如果在定时器被触发时用户还未按下第二次后退键则将isQuit置为false
        id: timerQuit
        interval: 2000
        onTriggered: {
            isQuit = false
        }
    }

    MetroView{
        id: metroView
        anchors.fill: parent
        titleBarHeight: headerView.height
        titleSpacing: 25

        function addItem(title, category, keyword, order){
            var obj = {
                "articles": null,
                "covers": null,
                "listContentY": 0,
                "enableAnimation": true,
                "newsUrl": Api.getNewsUrlByCategory(category, keyword, order),
                "imagePosterUrl": keyword?"":Api.getPosterUrlByCategory(category)
            }
            addPage(title, obj)
        }

        delegate: NewsListPage{
            id: newsList

            width: metroView.width
            height: metroView.height-metroView.titleBarHeight

            Connections{
                target: root
                onRefreshNewsList:{
                    newsList.updateList()
                    //如果收到刷新列表的信号就重新获取新闻列表
                }
            }
        }

        Component.onCompleted: {
            metroView.addItem(qsTr("all news"))
            //先去获取全部新闻
            utility.httpGet(getNewsCategorysFinished, Api.newsCategorysUrl)
            //去获取新闻分类
        }
    }
    Connections{
        target: command
        onGetNews:{
            //如果某新闻标题被点击（需要阅读此新闻）
            pageStack.push(Qt.resolvedUrl("NewsContentPage.qml"),
                           {newsId: newsId, newsTitle: title})
        }
    }

    // define the menu
     Menu {
         id: mainMenu
         // define the items in the menu and corresponding actions
         platformInverted: command.invertedTheme
         content: MenuLayout {
             MenuItem {
                 text: qsTr("Personal Center")
                 platformInverted: command.invertedTheme
             }
             MenuItem {
                 text: qsTr("Settings")
                 platformInverted: command.invertedTheme
             }
             MenuItem {
                 text: qsTr("About")
                 platformInverted: command.invertedTheme
             }
         }
     }
}
>>>>>>> 5eadeb2e4c633312e53c5ed6b7be596665fabe33
