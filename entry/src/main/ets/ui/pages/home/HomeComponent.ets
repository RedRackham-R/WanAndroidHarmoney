import { BannerItemLayout } from '../../layout/BannerItemLayout';
import { ArticleItemLayout } from '../../layout/ArticleItemLayout';
import { PageState, PageStateWeight } from '../../weight/PageStateWeight';
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh';
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController';
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator';
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel';
import { CollectEvent, LoginRegistEvent, UncollectEvent } from '../../../event/WanEvents';
import { IArticle } from '../../../net/wanAPI/response/IArticle';
import homeViewModel from '../../../viewmodel/HomeViewModel';
import { AnyListDataSource } from '../../../data_source/AnyListDataSource';
import { RouterDelegate } from '../../../router/RouterDelegate';
import globalVM_Collect from '../../../global/viewmodel/GlobalCollectViewModel';
import { extUIShowToast } from '../../../ext/UIExt';
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel';
import { Wanthemes } from '../../../theme/WanThemes';
import { IBanner } from '../../../net/wanAPI/response/IBanner';


@Component
export struct HomeComponent {
  private TAG: string = 'HomeComponent'
  @State private pageState: PageState = PageState.LOADING
  @Prop @Watch('onTapBackToTop') tapBackTop: number = 0
  @State title: string = 'WanAndroid'
  //datas为两种参数:Array<IBanner>以及IArticle，根据业务判断
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  @State controller: PullToRefreshController = new PullToRefreshController()
  @State private configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  onScroll: (yOffset: number) => void

  aboutToAppear() {
    this.configurator.setRefreshBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)


    //更换主题event
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (_event) => {
      this.theme = globalVM_Setting.getTheme()
      this.configurator.setRefreshBackgroundColor(this.theme.REFRESH_BG_COLOR)
      this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)
    })

    //登录event
    globalVM_User.subscribeLoginEvent(this.TAG, (event) => {
      let realEvent = event.data as LoginRegistEvent
      if (realEvent.isSuccess) {
        this.handleUserLogin(true)
      }
    })

    //注册登出event
    globalVM_User.subscribLoginOutEvent(this.TAG, (_event) => {
      this.handleUserLogin(false)
    })

    //注册收藏文章event
    globalVM_Collect.subscribeCollectEvent(this.TAG, (event) => {
      let realEvent = event.data as CollectEvent
      this.handleCollect(realEvent)
    })

    //注册取消收藏文章event
    //注册收藏文章event
    globalVM_Collect.subscribeUncollectEvent(this.TAG, (event) => {
      let realEvent = event.data as UncollectEvent
      this.handleUncollect(realEvent)
    })

    this.loadDataAsync(true)
    //从本地登录
    globalVM_User.loginFromLocal()

  }

  aboutToDisappear() {
    globalVM_User.unSubscribeLoginOutEvent(this.TAG)
    globalVM_User.unSubscribeLoginEvent(this.TAG)
    globalVM_Collect.unSubscribeCollectEvent(this.TAG)
    globalVM_Collect.unSubscribeUncollectEvent(this.TAG)
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)
  }

  private handleCollect(event: CollectEvent) {
    if (event.isSuccess) {
      extUIShowToast("已收藏")
      this.dataSource.getAllData().forEach((item: IArticle, index: number) => {
        if (item.id === event.id) {
          item.extIsCollecting = false
          item.collect = true
          this.dataSource.notifyDataChange(index)
          return
        }
      })
    } else {
      for (let index = 0; index < this.dataSource.getAllData().length; index++)
        this.dataSource.getAllData().forEach((item: IArticle, index: number) => {
          if (item.id === event.id) {
            item.extIsCollecting = false
            item.collect = false
            this.dataSource.notifyDataChange(index)
            return
          }
        })
      extUIShowToast("收藏失败：" + event.errMsg)
    }
  }

  private handleUncollect(event: UncollectEvent) {
    if (event.isSuccess) {
      extUIShowToast("取消收藏")
      this.dataSource.getAllData().forEach((item: IArticle, index: number) => {
        if (item.id === event.id) {
          item.extIsCollecting = false
          item.collect = false
          this.dataSource.notifyDataChange(index)
          return
        }
      })
    } else {
      for (let index = 0; index < this.dataSource.getAllData().length; index++)
        this.dataSource.getAllData().forEach((item: IArticle, index: number) => {
          if (item.id === event.id) {
            item.extIsCollecting = false
            item.collect = true
            this.dataSource.notifyDataChange(index)
            return
          }
        })
      extUIShowToast("取消收藏失败：" + event.errMsg)
    }
  }

  /**
   * 处理登录事件 收藏状态更新
   */
  private handleUserLogin(isLogin: boolean) {
    this.dataSource.getAllData().forEach((item, index) => {
      if (!Array.isArray(item)) {
        if (isLogin) { //登录
          if (globalVM_User.getLoginInfo().collectIds.includes((item as IArticle).id)) {
            (item as IArticle).collect = true
            this.dataSource.notifyDataChange(index)
          }
        } else { //登出
          (item as IArticle).collect = false
          this.dataSource.notifyDataChange(index)
        }
      }
    })
  }

  build() {
    PageStateWeight({
      pageState: this.pageState,
      onRetryCallback: () => {
        this.pageState = PageState.LOADING
        this.loadDataAsync(true)
      },
      contentLayout: () => {
        this.contentLayout()
      },
    })
  }

  onTapBackToTop() {
    this.controller.refresh()
  }

  @Builder
  private contentLayout() {
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $dataSource,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      controller: this.controller,
      refreshConfigurator: this.configurator,
      customList: () => {
        this.ListLayout()
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
  private ListLayout() {
    List({ space: 0, initialIndex: 0, scroller: this.controller.getScroller() }) {
      LazyForEach(this.dataSource, (item: any, index: number) => {
        ListItem() {
          if (Array.isArray(item)) {
            BannerItemLayout({
              banners: item,
              onItemClick: (bannerItem: IBanner) => {
                RouterDelegate.toWebPage(bannerItem.url)
              }
            })
          } else {
            ArticleItemLayout({
              article: item,
              theme: this.theme,
              onCollect: (isCollect: boolean, article: IArticle) => {
                if (globalVM_User.hasLogged()) {
                  article.extIsCollecting = true
                  this.dataSource.notifyDataChange(index)
                  if (isCollect) {
                    globalVM_Collect.collect(article.id)
                  } else {
                    globalVM_Collect.uncolect(article.id)
                  }
                } else {
                  RouterDelegate.toLoginPage(true)
                }
              }
            })
          }
        }
      }, (item, index) => JSON.stringify(item) + index) //TODO 坑：这里需要实现LazyForEach的keyGenerator，配置每一个item的key值才能根据index操作DataSource更新（如notifyDataChange）
    }
    .onScroll((_xOffset: number, _yOffset: number) => {
      this.onScroll(this.controller.getScroller().currentOffset().yOffset)
    })
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.None)
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
      const result = await homeViewModel.loadDataAsync(isRefresh)
      if (isRefresh && this.dataSource.totalCount() === 0) {
        if (result.over && result.datas.length === 0) {
          this.pageState = PageState.EMPTY
        } else {
          this.pageState = PageState.SUCCESS
        }
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
}

