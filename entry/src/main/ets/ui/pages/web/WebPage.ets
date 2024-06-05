import webview from '@ohos.web.webview'
import HashMap from '@ohos.util.HashMap'
import { CollectUrlEvent, UncollectEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Collect from '../../../global/viewmodel/GlobalCollectViewModel'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { ICollectedUrl } from '../../../net/wanAPI/response/ICollectedUrl'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import webViewModel from '../../../viewmodel/WebViewModel'
import { CollectUrlDialog } from '../../dialog/CollectUrlDialog'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'


enum CollectType {
  COLLECTED,
  UNCOLLECT,
  LOADING,
}

@Entry
@Component
export struct WebPage {
  private readonly TAG = 'WebPage'
  private controller: WebviewController = new webview.WebviewController()
  private link: string | null = RouterDelegate.getParams()['link']
  @State private title: string = '加载中...'
  @State private loadingProgress: number = 0
  @State private showLoadingProgress: boolean = true
  //收藏状态 0 未收藏   1 已收藏   2 正在收藏
  @State private collectType: CollectType = CollectType.UNCOLLECT
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  private isFristLoad = true
  private collectedUrlMap: HashMap<number, ICollectedUrl> = new HashMap<number, ICollectedUrl>()
  private unCollectUrl: ICollectedUrl = null
  private collectUrlDialogController: CustomDialogController = new CustomDialogController({
    builder: CollectUrlDialog({
      editingTitle: this.title,
      editingLink: this.link,
      onComfrim: (title: string, link: string) => {
        globalVM_Collect.collectUrl(title, link)
        this.collectType = CollectType.LOADING
        this.collectUrlDialogController.close()
      },
      onCancel: () => {
        this.collectUrlDialogController.close()
      }
    }),
    // 点击遮障层退出时的回调
    cancel: () => {

    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })
  private unCollectUrlDialogController: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: '是否取消收藏 \n \n《' + this.unCollectUrl.name + '》 \n \n ' + this.unCollectUrl.link,
      onComfrim: () => {
        globalVM_Collect.uncollectUrl(this.unCollectUrl.id)
        this.collectType = CollectType.LOADING
        this.unCollectUrlDialogController.close()
      },
      onCancel: () => {
        this.unCollectUrlDialogController.close()
      }
    }),
    // 点击遮障层退出时的回调
    cancel: () => {

    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  aboutToAppear() {

    globalVM_Collect.subscribeCollectUrlEvent(this.TAG, (event) => {
      const realEvent = event.data as CollectUrlEvent
      if (realEvent.isSuccess) {
        this.collectedUrlMap.set(realEvent.id, {
          desc: realEvent.desc,
          icon: realEvent.icon,
          id: realEvent.id,
          link: realEvent.link,
          name: realEvent.name,
          order: realEvent.order,
          userId: realEvent.userId,
          visible: realEvent.visible,
          extIsCollecting: false
        })
        extUIShowToast('已收藏')
      } else {
        extUIShowToast("收藏失败")
      }
      this.checkCollectedUrl(realEvent.link)
    })

    globalVM_Collect.subscribeUnCollectUrlEvent(this.TAG, (event) => {
      const realEvent = event.data as UncollectEvent
      if (realEvent.isSuccess) {
        if (this.collectedUrlMap.hasKey(realEvent.id)) {
          const target = this.collectedUrlMap.get(realEvent.id) as ICollectedUrl
          this.collectedUrlMap.remove(realEvent.id)
        }
        extUIShowToast("取消收藏")
      } else {
        extUIShowToast("取消收藏失败")
      }
      this.checkCollectedUrl(this.link)
    })
  }

  aboutToDisappear() {
    globalVM_Collect.unSubscribeCollectUrlEvent(this.TAG)
    globalVM_Collect.unSubscribeUnCollectUrlEvent(this.TAG)
    this.collectUrlDialogController = null
    this.unCollectUrlDialogController = null
  }

  build() {

    Flex({ direction: FlexDirection.Column }) {
      ActionBarWeight({
        title: this.title,
        showBackButton: true,
        rightRowElement: this.rightRowLayout.bind(this), //这里需要绑定本页面，不然rightRowLayout中的this是ActionBarWeight的this，造成undefined
        onBackPress: () => {
          RouterDelegate.back()
        },
      })
      Stack() {
        Web({ src: this.link, controller: this.controller })
          .mixedMode(MixedMode.All)
          .backgroundColor(this.theme.BG_COLOR)
          .width("100%")
          .height("100%")
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .fileAccess(true)
          .imageAccess(true)
          .onlineImageAccess(true)
          .zoomAccess(true)
          .overviewModeAccess(true)
          .databaseAccess(true)
          .geolocationAccess(true)
          .multiWindowAccess(true)
          .mediaPlayGestureAccess(true)
          .blockNetwork(false)
          .pinchSmooth(true)
          .onPageBegin((event) => { //网页开始加载时触发该回调，且只在主frame触发，iframe或者frameset的内容加载时不会触发此回调。
            this.showLoadingProgress = true
            this.link = event.url
            this.checkCollectedUrl(event.url)
            if (this.isFristLoad) {
              if (globalVM_User.hasLogged()) {
                this.fetchCollectedUrlList()
              }
              this.isFristLoad = false
            }


          })
          .onPageEnd((event) => { //网页加载完成时触发该回调，且只在主frame触发。
            this.showLoadingProgress = false

          })
          .onProgressChange((event) => { //网页加载进度变化时触发该回调。
            this.loadingProgress = event.newProgress

          })
          .onTitleReceive((event) => { //网页document标题更改时触发该回调。
            this.title = event.title

          })

        if (this.showLoadingProgress) {
          Progress({ value: 0, total: 100, type: ProgressType.Linear })
            .color(Color.Green)
            .value(this.loadingProgress)
            .width('100%')
        }
      }.width('100%').layoutWeight(1).alignContent(Alignment.Top)

    }
    .backgroundColor('#F1F3F5')
    .width('100%')
    .height('100%')
  }

  @Builder
  private rightRowLayout() {
    if (this.collectType === CollectType.UNCOLLECT) { //未收藏
      Image($r('app.media.ic_uncollect_url'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 8,
        })
        .onClick(() => {
          this.onCollectAction(true)
        })
    } else if (this.collectType === CollectType.COLLECTED) { //已收藏
      Image($r('app.media.ic_collected_url'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 8,
        })
        .onClick(() => {
          this.onCollectAction(false)
        })
    } else { //正在收藏
      LoadingProgress()
        .color(this.theme.PROGRESS_COLOR)
        .width(30)
        .height(30)
        .margin({
          right: 8,
        })
    }

  }

  private onCollectAction(isCollect: boolean) {
    if (globalVM_User.hasLogged()) {
      if (isCollect) {
        this.collectUrlDialogController.open()
      } else {
        const keys = Array.from(this.collectedUrlMap.keys())
        keys.forEach((key: number) => {
          if (this.collectedUrlMap.get(key) !== null &&
            this.collectedUrlMap.get(key) !== undefined &&
            this.collectedUrlMap.get(key).link === this.link
          ) {
            this.unCollectUrl = this.collectedUrlMap.get(key)
            this.unCollectUrlDialogController.open()
            return
          }
        })
      }
    } else {
      RouterDelegate.toLoginPage(true)
    }
  }

  private checkCollectedUrl(url: string): boolean {

    const keys: Array<number> = Array.from(this.collectedUrlMap.keys())
    let hasLink: boolean = false
    keys.forEach((key: number) => {
      if (this.collectedUrlMap.get(key) !== null &&
        this.collectedUrlMap.get(key) !== undefined &&
        this.collectedUrlMap.get(key).link === url
      ) {
        hasLink = true
        return
      }
    })
    if (hasLink) {
      this.collectType = CollectType.COLLECTED
    } else {
      this.collectType = CollectType.UNCOLLECT
    }
    return hasLink
  }

  private async fetchCollectedUrlList() {
    try {
      const list = await webViewModel.loadUrlListAsync()
      list.forEach((item: ICollectedUrl) => {
        this.collectedUrlMap.set(item.id, item)
      })

      this.checkCollectedUrl(this.link)
    } catch (err) {
      extUIShowToast('获取收藏URL列表失败：' + err)
    }
  }

  /**
   * 转场动画 从右边弹出
   */
  pageTransition() {

    // 定义页面进入时的效果，从右侧滑入，时长为1200ms，页面栈发生push操作时该效果才生效
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Right)
    // 定义页面进入时的效果，从左侧滑入，时长为1200ms，页面栈发生pop操作时该效果才生效
    PageTransitionEnter({ type: RouteType.Pop, duration: 300 })
      .translate({
        x: -100,
        y: 0,
      })


    // 定义页面退出时的效果，向左侧滑出，时长为1000ms，页面栈发生push操作时该效果才生效
    PageTransitionExit({ type: RouteType.Push, duration: 300 })
      .translate({
        x: -100,
        y: 0,
      })

    // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Right)
  }
}


