import { UserInfoUpdateEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { IRankInfo } from '../../../net/wanAPI/response/IRankInfo'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import { PageState, PageStateWeight } from '../../weight/PageStateWeight'
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh'
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator'
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController'
import rankViewModel from '../../../viewmodel/RankViewModel'

@Entry
@Component
export struct RankPage {
  private TAG = 'RankPage'
  @State title: string = '积分排行（我的排名:正在获取...）'
  @State private datas: Array<IRankInfo> = new Array<IRankInfo>()
  @State controller: PullToRefreshController = new PullToRefreshController()
  private configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State private pageState: PageState = PageState.LOADING
  private theme = globalVM_Setting.getTheme()

  aboutToAppear() {
    //注册userInfo监听
    globalVM_User.subscribeUserInfoUpdateEvent(this.TAG, (eventData => {
      let realEvent = eventData.data as UserInfoUpdateEvent
      if (!realEvent.isUpdating) {
        if (globalVM_User.getUserInfo() !== null) {
          this.title = '积分排行（我的排名:' + globalVM_User.getUserInfo().coinInfo.rank + '）'
        } else {
          this.title = '积分排行（我的排名:获取失败，重新进入页面再次获取）'
        }
      }
    }))

    //获取积分排行数据
    if (globalVM_User.getUserInfo() === null) {
      this.title = '积分排行（我的排名:正在获取...）'
      globalVM_User.getUserInfo()
    } else {
      this.title = '积分排行（我的排名:' + globalVM_User.getUserInfo().coinInfo.rank + '）'
    }

    //配置刷新UI
    this.configurator.setRefreshBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.loadDataAsync(true)

  }

  aboutToDisappear() {
    globalVM_User.unSubscribeUserInfoUpdateEvent(this.TAG)
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      ActionBarWeight({
        title: this.title,
        onBackPress: () => {
          RouterDelegate.back()
        }
      })
      this.contentLayout()
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .width('100%')
    .height('100%')
  }

  @Builder
  private refreshLayout() {
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $datas,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      controller: this.controller,
      refreshConfigurator: this.configurator,
      customList: () => {
        this.listLayout()
      },
      // 可选项，下拉刷新回调
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataAsync(true, resolve, reject)
        })
      },
      // 可选项，上拉加载更多回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataAsync(false, resolve, reject)
        })
      },
      customLoad: null,
      customRefresh: null,
    })
  }

  @Builder
  private contentLayout() {
    PageStateWeight({
      pageState: this.pageState,
      onRetryCallback: () => {
        this.pageState = PageState.LOADING
        this.loadDataAsync(true)
      },
      contentLayout: () => {
        this.refreshLayout()
      },
    })
      .layoutWeight(1) //不设置宽高，直接配置权重自动填充
  }

  @Builder
  private listLayout() {
    Stack() {
      List({ space: 0, initialIndex: 0, scroller: this.controller.getScroller() }) {
        ForEach(this.datas, (item: any, index: number) => {
          ListItem() {
            this.rankInfoItemLayout(item, index)
          }
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)

    }
    .alignContent(Alignment.BottomEnd)
    .width('100%')
    .height('100%')
  }

  @Builder
  private rankInfoItemLayout(item: IRankInfo, index: number) {
    Row() {
      if (item.userId === globalVM_User.getLoginInfo().id) {
        Image($r("app.media.ic_arrow_right_indigo500"))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Auto)
      }
      if (index === 0) {
        Image($r('app.media.ic_rank_1')).width(28).height(28).objectFit(ImageFit.Auto)
        Text(item.username)
          .fontSize(18 - index)
          .fontColor(this.theme.TEXT_COLOR)
          .margin({
            left: 8
          })
        Blank()
        Text(item.coinCount + "")
          .fontSize(18 - index)
          .fontColor($r('app.color.amber500'))
      } else if (index === 1) {
        Image($r('app.media.ic_rank_2')).width(28).height(28).objectFit(ImageFit.Auto)
        Text(item.username)
          .fontSize(18 - index)
          .fontColor(this.theme.TEXT_COLOR)
          .margin({
            left: 8
          })
        Blank()
        Text(item.coinCount + "")
          .fontSize(18 - index)
          .fontColor($r('app.color.bluegrey500'))
      } else if (index === 2) {
        Image($r('app.media.ic_rank_3')).width(28).height(28).objectFit(ImageFit.Auto)
        Text(item.username)
          .fontSize(18 - index)
          .fontColor(this.theme.TEXT_COLOR)
          .margin({
            left: 8
          })
        Blank()
        Text(item.coinCount + "")
          .fontSize(18 - index)
          .fontColor($r('app.color.orange500'))
      } else {
        Text(item.rank).fontColor(this.theme.TEXT_COLOR)
          .margin({
            left: 10
          })
        Text(item.username)
          .fontSize(14)
          .fontColor(this.theme.TEXT_COLOR)
          .margin({
            left: 8
          })
        Blank()
        Text(item.coinCount + "")
          .fontSize(14)
          .fontColor(this.theme.TEXT_SEC_COLOR)
      }
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme.BG_COLOR)
    .height(36)
    .width('100%')
    .padding({
      left: 8,
      right: 8,
      top: 4,
      bottom: 4,
    })

  }

  private async loadDataAsync(
    isRefresh: boolean,
    resolve?: (value: string | PromiseLike<string>) => void,
    _reject?: (reason?: any) => void) {

    if (isRefresh && this.datas.length === 0) {
      this.pageState = PageState.LOADING
    }
    try {
      const result = await rankViewModel.loadDataAsync(isRefresh)

      if (isRefresh && this.datas.length === 0) {
        this.pageState = PageState.SUCCESS
      }
      if (isRefresh) {
        this.datas = result.datas
        if (resolve !== null && resolve !== undefined) {
          resolve('刷新完成')
        }
      } else {
        this.datas = [...this.datas, ...result.datas]
        if (resolve !== null && resolve !== undefined) {
          resolve('加载完成')
        }
      }
    } catch (err) {
      extUIShowToast("数据加载失败：" + err)
      if (isRefresh) {
        if (this.datas.length === 0) {
          this.pageState = PageState.FAIL
        }
        if (resolve !== null && resolve !== undefined) {
          resolve('刷新失败')
        }
      } else {
        if (resolve !== null && resolve !== undefined) {
          resolve('加载失败')
        }
      }
    }

  }

  /**
   * 转场动画 从右边弹出
   */
  pageTransition() {
    // 定义页面进入时的效果，从右侧滑入，时长为1200ms，页面栈发生push操作时该效果才生效
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Right)

    // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Right)
  }
}