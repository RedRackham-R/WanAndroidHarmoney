/**
 * loading 弹窗
 */
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@CustomDialog
export struct ComfrimDialog {
  controller?: CustomDialogController
  message: string
  onComfrim: () => void
  onCancel: () => void
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  build() {
    Column() {
      Text(this.message)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({
          top: 32
        })
        .fontColor(this.theme.TEXT_COLOR)
      Divider()
        .margin({
          top: 16
        })
        .height(1)
        .opacity(0.6)
        .color(Color.Gray)

      Row() {
        Text('取消')
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .fontColor(this.theme.TEXT_SEC_COLOR)
          .onClick(() => {
            this.onCancel()
          })
        Divider()
          .vertical(true)
          .width(1)
          .color(Color.Gray)
          .opacity(0.6)
          .margin({
            top:12,
            bottom:12
          })
        Text('确认')
          .width("50%")
          .height('100%')
          .textAlign(TextAlign.Center)
          .fontColor(this.theme.TEXT_COLOR)
          .onClick(() => {
            this.onComfrim()
          })
      }
      .width('100%')
      .height(58)
      .justifyContent(FlexAlign.Center)
    }
    .backgroundColor(this.theme.DIALOG_BG)


  }
}
