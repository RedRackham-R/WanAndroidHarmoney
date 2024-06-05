import { extUIHideKeybroad, extUIShowKeybroad } from '../../../ext/UIExt'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_WanDB from '../../../global/viewmodel/GlobalWanDBViewModel'
import { IHotKey } from '../../../net/wanAPI/response/IHotKey'
import { Wanthemes } from '../../../theme/WanThemes'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'

@Component
export struct SearchHistoryComponent {
  onTagPress: (word: string) => void
  @Link hotKeys: Array<IHotKey>
  @State hotKeysColors: ResourceColor[] = [
    Color.Red,
    $r('app.color.blue500'),
    $r('app.color.green500'),
    $r('app.color.brown500'),
    $r('app.color.orange500'),
    $r('app.color.teal500'),
    $r('app.color.purple500'),
    $r('app.color.cyan500'),
    $r('app.color.grey500'),
  ]
  @State historyKeys: Array<string> = new Array()
  private scroller: Scroller = new Scroller()
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  //弹窗
  private comfrimDialogController: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: '确认删除搜索记录吗？',
      onComfrim: () => {
        this.historyKeys = []
        globalVM_WanDB.deleteAllSearchKeywordsHistory()
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
    extUIShowKeybroad("ActionBarSearchWeight_search_textInput")
    this.loadHistoryKeywords()
  }

  aboutToDisappear() {
    this.comfrimDialogController = null
  }

  build() {
    Column() {
      if (this.hotKeys.length > 0) {
        this.hotKeywordsLayout()
      }

      if (this.historyKeys.length > 0) {
        this.historyKeywordsLayout()
      }
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
    .align(Alignment.TopStart)
  }

  /**
   * 热词布局
   */
  @Builder
  hotKeywordsLayout() {
    Column() {
      Text('大家都在搜：')
        .fontColor(this.theme.PROGRESS_COLOR)

      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(this.hotKeys, (item: IHotKey, index: number) => {
          Text(item.name)
            .fontColor(this.hotKeysColors[index % 9])
            .margin(8)
            .onClick(() => {
              extUIHideKeybroad()
              this.onTagPress(item.name.trim())
            })
        })
      }
      .width("100%")
      .margin({
        top: 12
      })
    }
    .margin({
      top: 24,
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  historyKeywordsLayout() {
    Column() {
      Row() {
        Text('历史搜索：')
          .fontColor(this.theme.PROGRESS_COLOR)
        Blank()
        Image($r('app.media.ic_clear_history'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Auto)
          .onClick(() => {
            extUIHideKeybroad()
            this.comfrimDialogController.open()
          })
          .margin({
            right: 8
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Scroll(this.scroller) {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.historyKeys, (item: string) => {
            Text(item)
              .fontColor(this.theme.TEXT_SEC_COLOR)
              .margin(8)
              .onClick(() => {
                extUIHideKeybroad()
                this.onTagPress(item)
              })
          })
        }
        .width("100%")
        .margin({
          top: 12
        })
      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBar(BarState.Off) // 滚动条常驻显示

    }
    .margin({
      top: 24,
    })
    .alignItems(HorizontalAlign.Start)
  }

  private async loadHistoryKeywords() {
    try {
      let keywords: Array<string> = await globalVM_WanDB.fetchSearchKeywords()
      this.historyKeys = keywords.reverse()
    } catch (err) {
    }
  }
}