#include "ncommand.h"
#include <QDateTime>

NCommand::NCommand(QObject *parent) :
    QObject(parent)
{
    m_invertedTheme = true;

#ifdef HARMATTAN_BOOSTER
    m_style["metroTitleFontPointSize"] = 22;
    //Metro界面上方大标题的最大字体大小
    m_style["newsListFontPointSize"] = 14;
    //新闻列表中新闻标题的字体大小
    m_style["newsInfosFontPointSize"] = 10;
    //新闻列表中新闻来源和发表时间等新闻信息的字体大小
    m_style["flipchartsTitleFontPointSize"] = 10;
    //大海报上新闻标题的字体大小
#else
    m_style["metroTitleFontPointSize"] = 11;
    //Metro界面上方大标题的最大字体大小
    m_style["newsListFontPointSize"] = 7;
    //新闻列表中新闻标题的字体大小
    m_style["newsInfosFontPointSize"] = 5;
    //新闻列表中新闻来源和发表时间等新闻信息的字体大小
    m_style["flipchartsTitleFontPointSize"] = 5;
    //大海报上新闻标题的字体大小
#endif
}

NCommand::SystemType NCommand::systemTye() const
{
#ifdef HARMATTAN_BOOSTER
    return Harmattan;
#else
    return Symbian;
#endif
}

bool NCommand::invertedTheme() const
{
    return m_invertedTheme;
}

QVariantMap NCommand::style() const
{
    return m_style;
}

void NCommand::setInvertedTheme(bool arg)
{
    if (m_invertedTheme != arg) {
        m_invertedTheme = arg;
        emit invertedThemeChanged(arg);
    }
}

QString NCommand::fromTime_t(uint seconds) const
{
    return QDateTime::fromTime_t(seconds).toString(Qt::SystemLocaleDate);
}

QString NCommand::textToHtml(const QString &text, int width, bool invertedTheme) const
{
#ifdef HARMATTAN_BOOSTER
    if(invertedTheme)
        return "<html><style>*{padding:0;margin:0;}body{color:#000;background-attachment:fixed;background-image: url(qrc:/images/meegoBackground.png);width:"+QString::number(width)+"px }</style><body>"+text+"</body></html>";

    else
        return "<html><style>*{padding:0;margin:0;}body{color:#ccc;background-color:#000000;width:"+QString::number(width)+"px }</style><body>"+text+"</body></html>";
#else
    QString background_color = (invertedTheme?"#F1F1F1":"#000000");
    QString color = (invertedTheme?"#000":"#ccc");
    return "<html><style>*{padding:0;margin:0;}body{color:"+color+";background-color:"+background_color+";width:"+QString::number(width)+"px}</style><body>"+text+"</body></html>";
#endif
}
