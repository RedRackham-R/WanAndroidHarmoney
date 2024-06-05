export namespace Wanthemes {

  export declare type THEME = Resource | string | Color | ResourceStr

  /**
   * 基础主题接口，定义所有主题需要实现的属性。
   */
  export interface IWanTheme {
    /** 主颜色 */
    PRIMARY_COLOR: THEME
    /** 次要颜色 */
    SEC_COLOR: THEME
    /** 背景颜色 */
    BG_COLOR: THEME
    /** 次要背景色*/
    BG_SEC_COLOR: THEME
    /** 文本颜色 */
    TEXT_COLOR: THEME
    /** 文本次要颜色*/
    TEXT_SEC_COLOR: THEME
    /** 主题颜色上的文字颜色*/
    TEXT_ON_PRIMARY_COLOR: THEME
    /** 主题颜色上的文字次要颜色*/
    TEXT_ON_PRIMARY_SEC_COLOR: THEME
    /** progres 文本颜色*/
    TEXT_PROGRESS_COLOR: THEME
    /** 刷新组件背景色*/
    REFRESH_BG_COLOR: THEME
    /** progress的颜色*/
    PROGRESS_COLOR: THEME
    /** dialog背景8*/
    DIALOG_BG: THEME
    /** textInput 获取聚焦颜色*/
    TEXTINPUT_FOCUS_COLOR: THEME
    /** textInput 取消焦点颜色*/
    TEXTINPUT_UNFOCUS_COLOR: THEME
    /** textInput 背景*/
    TEXTINPUT_BG_COLOR: THEME
    /** textInput 光标颜色*/
    TEXTINPUT_CREATE_COLOR: THEME
    /** textInput提示文本颜色*/
    TEXTINPUT_PLACEHOLDER_COLOR: THEME
    /** 主页icon*/
    ICON_HOME_CHECKED_RES: THEME
    ICON_HOME_UNCHECKED_RES: THEME
    ICON_HOME_CHECKED_BACK_TO_TOP_RES: THEME
    ICON_HOME_UNCHECKED_BACK_TO_TOP_RES: THEME
    /** 用户icon*/
    ICON_USER_CHECKED_RES: THEME
    ICON_USER_UNCHECKED_RES: THEME
    /** github 图标*/
    ICON_GITHUB_LOGO_RES: THEME
    /** wanandroid 图标*/
    ICON_WANANDROID_LOGO_RES: THEME
    /** 搜索文章图标*/
    ICON_SEARCH_ARTICLE_RES: THEME
    SEARCH_ARTICLE_BUTTON_BG: THEME
  }

  /**
   * 获取主题
   * @param themeNum 0 light, 1 dark
   * @returns
   */
  export function getWanTheme(themeNum: number): IWanTheme {
    if (themeNum = 0) {
      return new LightWanTheme()
    } else {
      return new DarkWanTheme()
    }
  }


  export class LightWanTheme implements IWanTheme {
    PRIMARY_COLOR: THEME = '#3f51b5'
    SEC_COLOR: THEME = '#5c6bc0'
    BG_COLOR: THEME = '#FEFEFE'
    BG_SEC_COLOR: THEME = '#F1F3F5'
    TEXT_COLOR: THEME = '#000000'
    TEXT_SEC_COLOR: THEME = '#555555'
    TEXT_ON_PRIMARY_COLOR: THEME = '#FFFFFF'
    TEXT_ON_PRIMARY_SEC_COLOR: THEME = '#888888'
    TEXT_PROGRESS_COLOR: THEME = '#3f51b5'
    REFRESH_BG_COLOR: THEME = '#FAFAFA'
    PROGRESS_COLOR: THEME = "#3f51b5"
    DIALOG_BG: THEME = this.BG_COLOR
    TEXTINPUT_FOCUS_COLOR: THEME = '#3f51b5'
    TEXTINPUT_UNFOCUS_COLOR: THEME = '#F1F3F5'
    TEXTINPUT_BG_COLOR: THEME = '#3DFFFFFF'
    TEXTINPUT_CREATE_COLOR: THEME = this.PRIMARY_COLOR
    TEXTINPUT_PLACEHOLDER_COLOR: THEME = '#555555'
    /** 主页icon*/
    ICON_HOME_CHECKED_RES: THEME = $r('app.media.ic_checked_home')
    ICON_HOME_UNCHECKED_RES: THEME = $r('app.media.ic_unchecked_home')
    ICON_HOME_CHECKED_BACK_TO_TOP_RES: THEME = $r('app.media.ic_checked_back_to_top')
    ICON_HOME_UNCHECKED_BACK_TO_TOP_RES: THEME = $r('app.media.ic_unchecked_back_to_top')
    /** 用户icon*/
    ICON_USER_CHECKED_RES: THEME = $r('app.media.ic_checked_user')
    ICON_USER_UNCHECKED_RES: THEME = $r('app.media.ic_unchecked_user')
    ICON_GITHUB_LOGO_RES: THEME = $r('app.media.pic_github_logo')
    ICON_WANANDROID_LOGO_RES: THEME = $r('app.media.pic_wanandroid_logo')
    ICON_SEARCH_ARTICLE_RES: THEME = $r('app.media.pic_search_article')
    /** 搜索文章按钮背景色*/
    SEARCH_ARTICLE_BUTTON_BG: THEME = '#FFFFFF'
  }


  /**
   * 深色主题实现
   */
  export class DarkWanTheme implements IWanTheme {
    PRIMARY_COLOR: THEME = '#000000'
    SEC_COLOR: THEME = '#1e1e1e'
    BG_COLOR: THEME = '#121212'
    BG_SEC_COLOR: THEME = '#1e1e1e'
    TEXT_COLOR: THEME = '#FFFFFF'
    TEXT_SEC_COLOR: THEME = '#BBBBBB'
    TEXT_ON_PRIMARY_COLOR: THEME = '#FFFFFF'
    TEXT_ON_PRIMARY_SEC_COLOR: THEME = '#CCCCCC'
    TEXT_PROGRESS_COLOR: THEME = '#FFFFFF'
    REFRESH_BG_COLOR: THEME = '#2C2C2C'
    PROGRESS_COLOR: THEME = "#FAFAFA"
    DIALOG_BG: THEME = '#2C2C2C'
    TEXTINPUT_FOCUS_COLOR: THEME = '#FFFFFF'
    TEXTINPUT_UNFOCUS_COLOR: THEME = '#2C2C2C'
    TEXTINPUT_BG_COLOR: THEME = '#3DFFFFFF'
    TEXTINPUT_CREATE_COLOR: THEME = '#FEFEFE'
    TEXTINPUT_PLACEHOLDER_COLOR: THEME = '#BBBBBB'
    /** 主页icon*/
    ICON_HOME_CHECKED_RES: THEME = $r('app.media.ic_checked_home_dark')
    ICON_HOME_UNCHECKED_RES: THEME = $r('app.media.ic_unchecked_home')
    ICON_HOME_CHECKED_BACK_TO_TOP_RES: THEME = $r('app.media.ic_checked_back_to_top_dark')
    ICON_HOME_UNCHECKED_BACK_TO_TOP_RES: THEME = $r('app.media.ic_unchecked_back_to_top')
    /** 用户icon*/
    ICON_USER_CHECKED_RES: THEME = $r('app.media.ic_checked_user_dark')
    ICON_USER_UNCHECKED_RES: THEME = $r('app.media.ic_unchecked_user')
    ICON_GITHUB_LOGO_RES: THEME = $r('app.media.pic_github_logo_dark')
    ICON_WANANDROID_LOGO_RES: THEME = $r('app.media.pic_wanandroid_logo_dark')
    ICON_SEARCH_ARTICLE_RES: THEME = $r('app.media.pic_search_article_dark')
    SEARCH_ARTICLE_BUTTON_BG: THEME = '#121212'
  }


  export const LightTheme: Wanthemes.LightWanTheme = new Wanthemes.LightWanTheme()


  export const DarkTheme: Wanthemes.DarkWanTheme = new Wanthemes.DarkWanTheme()
}

















