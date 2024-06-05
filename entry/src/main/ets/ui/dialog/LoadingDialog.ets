/**
 * loading 弹窗
 */
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@CustomDialog
export struct LogdingDialog {
  controller?: CustomDialogController
  @Link text: string
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  build() {
    Column() {
      LoadingProgress()
        .color(this.theme.TEXT_PROGRESS_COLOR)
        .width(160)
        .height(160)
      Text(this.text)
        .fontSize(20)
        .fontColor(this.theme.PROGRESS_COLOR)
        .margin({
          top: 20,
          bottom: 40,
        })

    }
    .align(Alignment.Center)
    .width('100%')
    .backgroundColor(this.theme.DIALOG_BG)
  }
}
