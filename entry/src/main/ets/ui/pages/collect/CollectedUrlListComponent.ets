import { AnyListDataSource } from '../../../data_source/AnyListDataSource'
import { CollectUrlEvent, UncollectEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'
import globalVM_Collect from '../../../global/viewmodel/GlobalCollectViewModel'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { ICollectedUrl } from '../../../net/wanAPI/response/ICollectedUrl'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'
import { CollectedUrlItemLayout } from '../../layout/CollectedUrlItemLayout'
import { PageState, PageStateWeight } from '../../weight/PageStateWeight'
import { PullToRefresh } from '../../weight/pullToRefresh/PullToRefresh'
import { PullToRefreshConfigurator } from '../../weight/pullToRefresh/PullToRefreshConfigurator'
import { PullToRefreshController } from '../../weight/pullToRefresh/PullToRefreshController'
import collectedListViewModel from '../../../viewmodel/CollectedListViewModel'

@Component
export struct CollectedUrlListComponent {
  private TAG: string = 'CollectedUrlListComponent'
  @State private pageState: PageState = PageState.LOADING
  @State controller: PullToRefreshController = new PullToRefreshController()
  private configurator: PullToRefreshConfigurator = new PullToRefreshConfigurator()
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  private deleteIndex: number = -1
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  //弹窗
  private comfrimDialogController: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: '是否取消收藏 \n \n《' + (this.dataSource.getData(this.deleteIndex) as ICollectedUrl).name + '》',
      onComfrim: () => {
        const item = (this.dataSource.getData(this.deleteIndex) as ICollectedUrl)
        item.extIsCollecting = true
        this.dataSource.notifyDataChange(this.deleteIndex)
        globalVM_Collect.uncollectUrl(item.id)
        this.comfrimDialogController.close()
      },
      onCancel: () => {
        this.comfrimDialogController.close()
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
    this.configurator.setHasLoadMore(false)


    globalVM_Collect.subscribeCollectUrlEvent(this.TAG, (event) => {
      const realEvent = event.data as CollectUrlEvent
      this.dataSource.addData({
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
      if (this.pageState !== PageState.SUCCESS) {
        this.pageState = PageState.SUCCESS
      }
    })

    globalVM_Collect.subscribeUnCollectUrlEvent(this.TAG, (event) => {
      let realEvent = event.data as UncollectEvent
      this.handleUncollectUrl(realEvent)
    })


    this.loadDataAsync()
  }

  aboutToDisappear() {
    this.comfrimDialogController = null
    globalVM_Collect.unSubscribeCollectUrlEvent(this.TAG)
    globalVM_Collect.unSubscribeUnCollectUrlEvent(this.TAG)

  }

  build() {
    PageStateWeight({
      pageState: this.pageState,
      onRetryCallback: () => {
        this.pageState = PageState.LOADING
        this.loadDataAsync()
      },
      contentLayout: () => {
        this.contentLayout()
      },
    })
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
          this.loadDataAsync(resolve, reject)
        })
      },

      customLoad: null,
      customRefresh: null,
    })
  }

  @Builder
  private listLayout() {
    List({ space: 0, initialIndex: 0, scroller: this.controller.getScroller() }) {
      LazyForEach(this.dataSource, (item: ICollectedUrl, index: number) => {
        ListItem() {
          CollectedUrlItemLayout({
            index: index,
            item: item,
            onDelete: (index: number, _item: ICollectedUrl) => {
              this.deleteIndex = index
              this.comfrimDialogController.open()
            },
            onItemClick: (link: string) => {
              RouterDelegate.toWebPage(link)
            }
          })
        }
      }, (item, index) => JSON.stringify(item) + index) //TODO 坑：这里需要实现LazyForEach的keyGenerator，配置每一个item的key值才能根据index操作DataSource更新（如notifyDataChange）
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.None)
  }

  private handleUncollectUrl(event: UncollectEvent) {
    if (event.isSuccess) {
      let targetIndex = -1
      for (let i = 0; i < this.dataSource.getAllData().length; i++) {
        const item: ICollectedUrl = this.dataSource.getData(i)
        if (item.id === event.id) {
          targetIndex = i
          break
        }
      }
      if (targetIndex !== -1) {
        this.dataSource.remove(targetIndex)
      }

      if (this.dataSource.totalCount() === 0) {
        this.pageState = PageState.EMPTY
      }
    } else {
      for (let i = 0; i < this.dataSource.getAllData().length; i++) {
        const item: ICollectedUrl = this.dataSource.getData(i)
        if (item.id === event.id) {
          item.extIsCollecting = false
          this.dataSource.notifyDataAdd(i)
          break
        }
      }
      extUIShowToast(event.errMsg)
    }
  }

  private async loadDataAsync(
    resolve?: (value: string | PromiseLike<string>) => void,
    _reject?: (reason?: any) => void
  ) {
    try {
      const result = await collectedListViewModel.loadUrlListAsync()
      //处理搜索不到的情况
      if (result.datas.length === 0) {
        if (this.pageState !== PageState.EMPTY) {
          this.pageState = PageState.EMPTY
        }
        if (resolve !== null && resolve !== undefined) {
          resolve('')
        }
        return
      }
      this.dataSource.removeAll()
      result.datas.forEach((item: ICollectedUrl) => {
        this.dataSource.addData(item)
      })
      if (this.pageState !== PageState.SUCCESS) {
        this.pageState = PageState.SUCCESS
      }
      if (resolve !== null && resolve !== undefined) {
        resolve('加载成功')
      }

    } catch (err) {
      extUIShowToast("数据加载失败：" + err)
      if (this.dataSource.totalCount() === 0) {
        this.pageState = PageState.FAIL
      }
      if (resolve !== null && resolve !== undefined) {
        resolve('加载失败')
      }
    }
  }
}