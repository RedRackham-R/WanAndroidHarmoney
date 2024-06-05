import router from '@ohos.router'
import { extUIShowToast } from '../ext/UIExt'
import globalVM_User from '../global/viewmodel/GlobalUserViewModel'
import { IArticle } from '../net/wanAPI/response/IArticle'


export class PagesConstant {
  public static SPLASH_PAGE: string = 'ui/pages/SplashPage'
  public static MAIN_PAGE: string = 'ui/pages/main/MainPage'
  public static LOGIN_PAGE: string = 'ui/pages/login/LoginPage'
  public static COIN_PAGE: string = 'ui/pages/coin/CoinPage'
  public static RANK_PAGE: string = 'ui/pages/rank/RankPage'
  public static SEARCH_PAGE: string = 'ui/pages/search/SearchPage'
  public static COLLECT_PAGE: string = 'ui/pages/collect/CollectPage'
  public static SHARE_LIST_PAGE: string = 'ui/pages/share/ShareListPage'
  public static SHARE_ARTICLE_PAGE: string = 'ui/pages/share/ShareArticlePage'
  public static SETTING_PAGE: string = 'ui/pages/setting/SettingPage'
  public static AVATAR_PAGE: string = 'ui/pages/avatar/AvatarPage'
  public static WEB_PAGE: string = 'ui/pages/web/WebPage'
}

export class RouterDelegate {
  public static toWebPage(link: string) {

    RouterDelegate.push(
      PagesConstant.WEB_PAGE,
      {
        'link': link,
      }
    )
  }


  public static toAvatarPage() {
    RouterDelegate.push(PagesConstant.AVATAR_PAGE)
  }


  public static toSettingPage() {
    RouterDelegate.push(PagesConstant.SETTING_PAGE)
  }

  public static toShareArticlePage(id: number | null = null, title: string | null = null, link: string | null = null) {
    RouterDelegate.pushWithLogin(
      PagesConstant.SHARE_ARTICLE_PAGE,
      {
        'id': id,
        'title': title,
        'link': link,
      }
    )
  }

  public static toShareListPage() {
    RouterDelegate.pushWithLogin(
      PagesConstant.SHARE_LIST_PAGE,
      {
        refresh: false
      })
  }

  public static toCollectPage() {
    RouterDelegate.pushWithLogin(PagesConstant.COLLECT_PAGE)
  }

  public static toSearchPage() {
    RouterDelegate.push(PagesConstant.SEARCH_PAGE)
  }

  public static toRankPage() {
    RouterDelegate.pushWithLogin(PagesConstant.RANK_PAGE)
  }

  public static toCoinPage() {
    RouterDelegate.pushWithLogin(PagesConstant.COIN_PAGE)
  }


  public static toMainPage() {
    RouterDelegate.replace(PagesConstant.MAIN_PAGE)
  }


  public static toLoginPage(showTips: boolean = true) {
    RouterDelegate.push(PagesConstant.LOGIN_PAGE, null, () => {
      if (showTips) {
        extUIShowToast('请先登录')
      }
    })
  }


  private static pushWithLogin(url: string, params: object = null, showTips: boolean = true,) {
    if (!globalVM_User.hasLogged()) {
      RouterDelegate.toLoginPage(showTips)
    } else {
      RouterDelegate.push(url, params)
    }
  }


  public static replace(url: string, params: object = null, sucess: () => void = null, fail: (error) => void = null) {
    router.replaceUrl(
      { url: url, params: params },
      router.RouterMode.Standard)
      .then(sucess)
      .catch(fail)
  }

  public static push(
    url: string,
    params: object | null = null,
    success: () => void = null,
    fail: (error) => void = null) {
    router.pushUrl(
      { url: url, params: params },
      router.RouterMode.Standard
    ).then(success)
      .catch(fail)
  }


  public static back(url: string = null, params: object = null) {
    router.back({ url: url, params: params })
  }

  public static getParams(): object | null {
    return router.getParams()
  }
}