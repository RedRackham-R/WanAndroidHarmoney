import Curves from '@ohos.curves'
import { AnyListDataSource } from '../../../data_source/AnyListDataSource'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { ICoinListInfo } from '../../../net/wanAPI/response/ICoinListInfo'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { RuleDescribeDialog } from '../../dialog/RuleDescribeDialog'
import { CoinListItemLayout } from '../../layout/CoinListItemLayout'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import { PageState, PageStateWeight } from '../../weight/PageStateWeight'
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh'
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator'
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController'
import coinViewModel from '../../../viewmodel/CoinViewModel'


/**
 * 我的积分
 */
@Entry
@Component
export struct CoinPage {
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  @State coinNum: number = 0
  @State private pageState: PageState = PageState.LOADING
  private intervalId: number = null
  @State controller: PullToRefreshController = new PullToRefreshController()
  configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State title: string = '我的积分'
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  //弹窗
  private coinRuleDialogController: CustomDialogController = new CustomDialogController({
    builder: RuleDescribeDialog({
      content: $r('app.string.coin_rule_description')
    }),
    // 点击遮障层退出时的回调
    cancel: () => {
      this.coinRuleDialogController.close()
    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: true
  })

  aboutToAppear() {
    //增加积分增长效果
    var progress: number = 0
    let curve = Curves.initCurve(Curve.EaseOut)
    this.intervalId = setInterval(() => {
      let interpolate = curve.interpolate(progress)
      //向下取整
      this.coinNum = Math.floor(interpolate * globalVM_User.getLoginInfo().coinCount)
      progress += 0.04
      if (progress > 1) {
        //结束
        this.coinNum = globalVM_User.getLoginInfo().coinCount
        clearInterval(this.intervalId)
      }
    }, 38)


    //配置刷新UI
    this.configurator.setRefreshBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)

    this.loadDataAsync(true)
  }

  aboutToDisappear() {
    clearInterval(this.intervalId)
    this.coinRuleDialogController = null // 将dialogController置空
  }

  build() {
    Flex({ direction: FlexDirection.Column,  }) {
      ActionBarWeight({
        title: this.title,
        showBackButton: true,
        rightRowElement: this.rightRowLayout.bind(this), //这里需要绑定本页面，不然rightRowLayout中的this是ActionBarWeight的this，造成undefined
        onBackPress: () => {
          RouterDelegate.back()
        },
      })
      Text(this.coinNum + "")
        .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
        .fontSize(52)
        .textAlign(TextAlign.Center)
        .height('100%')
        .width('100%')
        .height(170)
        .backgroundColor(this.theme.PRIMARY_COLOR)

      this.contentLayout()
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .width('100%')
    .height('100%')
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
  private refreshLayout() {
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $dataSource,
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
  private listLayout() {
    Stack() {
      List({ space: 0, initialIndex: 0, scroller: this.controller.getScroller() }) {
        LazyForEach(this.dataSource, (item: ICoinListInfo) => {
          ListItem() {
            CoinListItemLayout({
              item: item,
              theme: this.theme
            })
          }
        }, (item, index) => JSON.stringify(item) + index) //TODO 坑：这里需要实现LazyForEach的keyGenerator，配置每一个item的key值才能根据index操作DataSource更新（如notifyDataChange）
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
  private headLayout() {
    Flex({
      direction: FlexDirection.Column
    }) {
      ActionBarWeight({
        title: this.title,
        showBackButton: true,
        rightRowElement: this.rightRowLayout.bind(this), //这里需要绑定本页面，不然rightRowLayout中的this是ActionBarWeight的this，造成undefined
        onBackPress: () => {
          RouterDelegate.back()
        },
      })
      Text(this.coinNum + "")
        .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
        .fontSize(52)
        .textAlign(TextAlign.Center)
        .height('100%')
        .width('100%')
        .height(240)
        .backgroundColor(this.theme.PRIMARY_COLOR)
    }
    .width('100%')
    .height(240)
    .backgroundColor(this.theme.PRIMARY_COLOR)
  }

  @Builder
  private rightRowLayout() {
    Row() {
      Image($r('app.media.ic_introduce'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 24,
        })
        .onClick(() => {
          this.coinRuleDialogController.open()
        })

      Image($r('app.media.ic_rank'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 24,
        })
        .onClick(() => {
          RouterDelegate.toRankPage()
        })

    }
  }

  private async loadDataAsync(
    isRefresh: boolean,
    resolve?: (value: string | PromiseLike<string>) => void,
    _reject?: (reason?: any) => void
  ) {
    if (isRefresh && this.dataSource.totalCount() === 0) {
      this.pageState = PageState.LOADING
    }

    try {
      const result = await coinViewModel.loadDataAsync(isRefresh)
      if (isRefresh && this.dataSource.totalCount() === 0) {
        this.pageState = PageState.SUCCESS
      }
      if (isRefresh) {
        this.dataSource.removeAll(true)
      }
      result.datas.forEach((item) => {
        this.dataSource.addData(item)
      })
      if (isRefresh) {
        if (resolve !== null && resolve !== undefined) {
          resolve('刷新完成')
        }
      } else {
        if (resolve !== null && resolve !== undefined) {
          resolve('加载完成')
        }
      }
    } catch (err) {
      extUIShowToast("数据加载失败：" + err)
      if (isRefresh) {
        if (this.dataSource.totalCount() === 0) {
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