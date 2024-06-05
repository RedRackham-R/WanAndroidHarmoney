import { AnyListDataSource } from '../../../data_source/AnyListDataSource'
import { CollectEvent, UncollectEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Collect from '../../../global/viewmodel/GlobalCollectViewModel'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { IArticle } from '../../../net/wanAPI/response/IArticle'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { ArticleItemLayout } from '../../layout/ArticleItemLayout'
import { PageState, PageStateWeight } from '../../weight/PageStateWeight'
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh'
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator'
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController'
import searchListViewModel from '../../../viewmodel/SearchListViewModel'

@Component
export struct SearchListComponent {
  private TAG: string = 'SearchListComponent'
  @Link searchWords: string
  @Prop @Watch('onTapSearch') tapSearch: number = 0
  @State pageState: PageState = PageState.LOADING
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  @State controller: PullToRefreshController = new PullToRefreshController()
  private configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  aboutToAppear() {
    this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.configurator.setHasRefresh(false)

    //注册收藏文章event
    globalVM_Collect.subscribeCollectEvent(this.TAG, (event) => {
      let realEvent = event.data as CollectEvent
      this.handleCollect(realEvent)
    })

    //注册取消收藏文章event
    globalVM_Collect.subscribeUncollectEvent(this.TAG, (event) => {
      let realEvent = event.data as UncollectEvent
      this.handleUncollect(realEvent)
    })
    this.pageState = PageState.LOADING
    this.loadDataAsync(true)
  }

  aboutToDisappear() {
    globalVM_Collect.unSubscribeCollectEvent(this.TAG)
    globalVM_Collect.unSubscribeUncollectEvent(this.TAG)

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
      .width('100%')
      .height('100%')
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
      }, (item, index) => JSON.stringify(item) + index) //TODO 坑：这里需要实现LazyForEach的keyGenerator，配置每一个item的key值才能根据index操作DataSource更新（如notifyDataChange）
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.None)
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

  onTapSearch() {
    this.pageState = PageState.LOADING
    this.loadDataAsync(true)
  }

  private async loadDataAsync(
    isRefresh: boolean,
    resolve?: (value: string | PromiseLike<string>) => void,
    _reject?: (reason?: any) => void) {

    try {
      const result = await searchListViewModel.searchAsync(isRefresh, this.searchWords)
      //处理搜索不到的情况
      if (isRefresh && result.datas.length === 0) {
        if (this.pageState !== PageState.EMPTY) {
          this.pageState = PageState.EMPTY
        }
        if (resolve !== null && resolve !== undefined) {
          resolve('')
        }
        return
      }
      if (isRefresh) {
        this.dataSource.removeAll()
      }

      result.datas.forEach((item: IArticle) => {
        this.dataSource.addData(item)
      })
      if (this.pageState !== PageState.SUCCESS) {
        this.pageState = PageState.SUCCESS
      }
      if (result.over) {
        if (resolve !== null && resolve !== undefined) {
          resolve('已经到底了')
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
}