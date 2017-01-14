#ifdef Q_OS_BLACKBERRY
#include <bb/cascades/Application>
#include <Qt/qdeclarativedebug.h>
#include "blackberry/applicationui.h"
using namespace bb::cascades;
#else
#include <QtGui/QApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDebug>
#include <QSettings>
#include <QWebSettings>
#include "qmlapplicationviewer.h"
#include "selectfilesdialog.h"
#include "ncommand.h"
#include "myimage.h"
#include "mysvgview.h"
#include "utility.h"
#include "myhttprequest.h"
#include "monitormouseevent.h"
#include "selectfilesdialog.h"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef Q_OS_BLACKBERRY
    Application app(argc, argv);

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    new ApplicationUI(&app);

    // Enter the application main event loop.
    return Application::exec();
#else
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    app->setApplicationName ("9News");
    app->setOrganizationName ("zccrs");
    app->setApplicationVersion ("0.0.1");

#if defined(Q_WS_SIMULATOR)
    //模拟器下设置网络代理，测试用
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    qmlRegisterType<SelectFilesDialog>("com.zccrs.widgets", 1, 0, "FilesDialog");
    qmlRegisterType<MaskImage>("com.zccrs.widgets", 1, 0, "MaskImage");
    qmlRegisterType<MySvgView>("com.zccrs.widgets", 1, 0, "MySvgView");
    qmlRegisterType<NCommand>("com.news.utility", 1, 0, "NCommand");
    qmlRegisterType<MonitorMouseEvent>("com.zccrs.utility", 1, 0, "MonitorMouseEvent");
    //qmlRegisterType<QWebViewItem>("com.yeatse.widgets", 1, 0, "WebView");

    QWebSettings::globalSettings ()->setAttribute (QWebSettings::LocalContentCanAccessRemoteUrls,true);
    QmlApplicationViewer viewer;
    //viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

    QSettings *settings = new QSettings;
    Utility *utility = Utility::createUtilityClass();
    utility->initUtility(settings, viewer.engine());

    viewer.engine()->rootContext()->setContextProperty("fileDialog", new SelectFilesDialog());
    viewer.engine()->rootContext()->setContextProperty("command", new NCommand());
    //QNetworkRequest *httpRequest = utility->getHttpRequest()->getNetworkRequest();
    //httpRequest->setHeader(QNetworkRequest::ContentTypeHeader, "text/html,application/xhtml+xml");
    //httpRequest->setRawHeader("Accept-Encoding", "gzip");

#ifdef HARMATTAN_BOOSTER      //Meego
    viewer.setMainQmlFile(QLatin1String("qml/meego/main.qml"));
#elif defined(Q_OS_S60V5)     //Symbian^1
    viewer.setMainQmlFile(QLatin1String("qml/symbian1/main.qml"));
#elif defined(Q_WS_SIMULATOR) //Simulator
    viewer.setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#else                         //Symbian^3
    viewer.setMainQmlFile(QLatin1String("qml/symbian/main.qml"));
#endif
    viewer.showExpanded();

    return app->exec();
#endif
}
