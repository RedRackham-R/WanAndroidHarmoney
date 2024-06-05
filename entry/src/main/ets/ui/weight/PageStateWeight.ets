import { ThemeChangeEvent } from '../../event/WanEvents'
import { extUtilsGenerateRadomUUID } from '../../ext/UtilsExt'
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@Component
export struct PageStateWeight {
  private readonly TAG = "PageStateWeight_" + extUtilsGenerateRadomUUID()
  @Prop pageState: PageState
  @BuilderParam contentLayout: () => void
  @BuilderParam emptyLayout: () => void = () => {
    this.defEmptyLayout()
  }
  onRetryCallback: () => void
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  aboutToAppear() {
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (event => {
      const realEvent = event.data as ThemeChangeEvent
      this.theme = globalVM_Setting.getTheme()
    }))
  }

  aboutToDisappear() {
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)
  }

  build() {
    this.judgePageStateLayout()
  }

  @Builder
  private judgePageStateLayout() {
    if (this.pageState === PageState.LOADING) {
      this.loadingLayout()
    } else if (this.pageState === PageState.FAIL) {
      this.failLayout()
    } else if (this.pageState === PageState.EMPTY) {
      this.emptyLayout()
    } else {
      this.contentLayout()
    }
  }

  @Builder
  private loadingLayout() {
    Column() {
      LoadingProgress()
        .color(this.theme.TEXT_PROGRESS_COLOR)
        .width(160)
        .height(160)

      Text('正在加载...')
        .fontColor(this.theme.TEXT_PROGRESS_COLOR)
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }

  @Builder
  private failLayout() {
    Column() {
      Image($r('app.media.ic_error1'))
        .height(160)
        .width(280)
        .objectFit(ImageFit.Auto)
      Text('请求失败，点击重试。')
        .fontColor(this.theme.TEXT_SEC_COLOR)
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onClick(this.onRetryCallback)
  }

  @Builder
  private defEmptyLayout() {
    Column() {
      Image($r('app.media.pic_no_data'))
        .height(180)
        .width(180)
        .objectFit(ImageFit.Auto)
      Text('暂 无 数 据')
        .fontColor(this.theme.TEXT_SEC_COLOR)
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onClick(this.onRetryCallback)
  }
}


export enum PageState {
  LOADING,
  SUCCESS,
  FAIL,
  EMPTY,
}
