import { AnyListDataSource } from '../../../data_source/AnyListDataSource'
import { CollectEvent, UncollectEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Collect from '../../../global/viewmodel/GlobalCollectViewModel'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { IArticle } from '../../../net/wanAPI/response/IArticle'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'
import { EditArticlePromptDialog } from '../../dialog/EditArticlePromptDialog'
import { LogdingDialog } from '../../dialog/LoadingDialog'
import { ArticleItemLayout } from '../../layout/ArticleItemLayout'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import { PageState, PageStateWeight } from '../../weight/PageStateWeight'
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh'
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator'
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController'
import shareViewModel from '../../../viewmodel/ShareViewModel'

@Entry
@Component
export struct ShareListPage {
  private TAG: string = 'ShareListPage'
  @State private pageState: PageState = PageState.LOADING
  @State controller: PullToRefreshController = new PullToRefreshController()
  private configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  @State
  private title: string = '我的分享（长按文章编辑）'
  private editItemIndex: number = -1
  @State private loadingMsg: string = '删除中...'
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  //loading弹窗
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LogdingDialog({
      text: this.loadingMsg
    }),
    // 点击遮障层退出时的回调
    cancel: () => {
    },
    //是否允许点击遮障层退出
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })
  private deleteComfrimDialogController: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: '是否删除文章 \n \n《' + (this.dataSource.getData(this.editItemIndex) as IArticle).title + '》',
      onComfrim: () => {
        this.deleteComfrimDialogController.close()
        this.loadingDialogController.open()
        const id = (this.dataSource.getData(this.editItemIndex) as IArticle).id
        this.deleteSharedArticleAsync(id)
      },
      onCancel: () => {
        this.deleteComfrimDialogController.close()
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
  //弹窗
  private editComfrimDialogController: CustomDialogController = new CustomDialogController({
    builder: EditArticlePromptDialog({
      title: '修改文章',
      message: '《' + (this.dataSource.getData(this.editItemIndex) as IArticle).title + '》',
      onEdit: () => {
        const article = this.dataSource.getData(this.editItemIndex) as IArticle
        RouterDelegate.toShareArticlePage(article.id, article.title, article.link)
      },
      onDelete: () => {
        this.editComfrimDialogController.close()
        this.deleteComfrimDialogController.open()
      },
      onClose: () => {
        this.editComfrimDialogController.close()
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
    this.configurator.setRefreshBackgroundColor(this.theme.REFRESH_BG_COLOR)
    this.configurator.setLoadBackgroundColor(this.theme.REFRESH_BG_COLOR)

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
  }

  aboutToDisappear() {
    globalVM_Collect.unSubscribeCollectEvent(this.TAG)
    globalVM_Collect.unSubscribeUncollectEvent(this.TAG)
    this.editComfrimDialogController = null
    this.deleteComfrimDialogController = null
    this.loadingDialogController = null
  }

  onPageShow() {
    const refresh: boolean = RouterDelegate.getParams()['refresh']
    if (refresh) {
      this.loadDataAsync(true)
    }
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
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .width('100%')
    .height('100%')
  }

  @Builder
  private rightRowLayout() {
    Row() {
      Image($r('app.media.ic_add'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 24,
        })
        .onClick(() => {
          RouterDelegate.toShareArticlePage()
        })
    }
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
    List({ space: 0, initialIndex: 0, scroller: this.controller.getScroller() }) {
      LazyForEach(this.dataSource, (item: any, index: number) => {
        ListItem() {
          ArticleItemLayout({
            article: item,
            theme: this.theme,
            onItemClick: (item: IArticle) => {
              extUIShowToast("点击事件：" + item.title)
            },
            onItemLongClick: (_item: IArticle, _event: GestureEvent) => {
              this.editItemIndex = index
              this.editComfrimDialogController.open()
            },
            onCollect: (isCollect: boolean, item: IArticle) => {
              item.extIsCollecting = true
              this.dataSource.notifyDataChange(index)
              if (isCollect) {
                globalVM_Collect.collect(item.id)
              } else {
                globalVM_Collect.uncolect(item.id)
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

  private async deleteSharedArticleAsync(id: number) {
    try {
      const result = await shareViewModel.deleteSharedArticleAsync(id)
      let deletedIndex: number = -1
      for (let index = 0; index < this.dataSource.totalCount() - 1; index++) {
        if (result.id === this.dataSource.getData(index).id) {
          deletedIndex = index
          break
        }
      }
      if (deletedIndex !== -1) {
        this.dataSource.remove(deletedIndex)
      }
      if (this.dataSource.totalCount() === 0) {
        this.pageState = PageState.EMPTY
      }
      extUIShowToast("删除成功")
    } catch (err) {
      extUIShowToast("删除文章失败：" + err)
    }
    this.loadingDialogController.close()
  }

  private async loadDataAsync(
    isRefresh: boolean,
    resolve?: (value: string | PromiseLike<string>) => void,
    _reject?: (reason?: any) => void) {

    if (isRefresh && this.dataSource.totalCount() === 0) {
      this.pageState = PageState.LOADING
    }
    try {
      const result = await shareViewModel.fetchSharedArticleListAsync(isRefresh)
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