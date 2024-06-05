/**
 * 编辑、删除 文章弹窗
 */
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@CustomDialog
export struct EditArticlePromptDialog {
  controller?: CustomDialogController
  title: string
  message: string
  onClose: () => void = () => {
  }
  onEdit: () => void = () => {
  }
  onDelete: () => void = () => {
  }
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  build() {
    Column() {
      Stack() {
        Text(this.title).width('100%').textAlign(TextAlign.Center).fontColor(this.theme.TEXT_COLOR)
        Image($r('app.media.ic_close_cycle_grey')).width(24).height(24).objectFit(ImageFit.Auto).onClick(this.onClose)
      }
      .alignContent(Alignment.Start)
      .width('100%')
      .padding({
        top: 12,
        left: 12,
        right: 12,
      })

      Text(this.message)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({
          top: 32
        })
        .fontColor(this.theme.TEXT_COLOR)

      Divider()
        .margin({
          top: 32
        })
        .color(Color.Grey)

      Row() {
        Image($r('app.media.ic_edit')).width(24).height(24).objectFit(ImageFit.Auto)
        Text('编辑').fontColor(Color.White).margin({ left: 8 })
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.cyan600'))
      .width('100%')
      .height(48)
      .onClick(this.onEdit)

      Divider()

      Row() {
        Image($r('app.media.ic_delete')).width(24).height(24).objectFit(ImageFit.Auto)
        Text('删除').fontColor(Color.White).margin({ left: 8 })
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.red600'))
      .width('100%')
      .height(48)
      .onClick(this.onDelete)
    }
    .backgroundColor(this.theme.DIALOG_BG)

  }
}
