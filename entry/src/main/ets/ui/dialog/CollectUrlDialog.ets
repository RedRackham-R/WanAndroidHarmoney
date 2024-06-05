/**
 * 编辑、删除 文章弹窗
 */
import { extUIShowToast } from '../../ext/UIExt'
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@CustomDialog
export struct CollectUrlDialog {
  controller?: CustomDialogController
  onComfrim: (title: string, link: string) => void
  onCancel: () => void

  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  @State private editingTitle: string = ''
  @State private editingLink: string = ''
  private titleController = new TextInputController()
  private linkController = new TextInputController()
  //title和link输入框边框选中颜色
  @State private titleBorderColor: string = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
  @State private linkBorderColor: string = this.theme.TEXTINPUT_UNFOCUS_COLOR as string

  onPageShow() {

    this.titleController.caretPosition(0)
  }

  build() {
    Column() {
      Text('收 藏 网 址')
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor(this.theme.TEXT_COLOR)
        .fontSize(18)

      Text('标 题')
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontColor(this.theme.TEXT_COLOR)
        .margin({
          top: 24,
        })

      TextInput({
        text: this.editingTitle,
        placeholder: '标 题',
        controller: this.titleController
      })
        .placeholderColor(this.theme.TEXTINPUT_PLACEHOLDER_COLOR)
        .placeholderFont({ size: 14, weight: 320 })
        .caretColor(this.theme.TEXTINPUT_CREATE_COLOR)
        .width('100%')
        .height(48)
        .margin({
          top: 16
        })
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
        .onChange((value: string) => {
          if (this.editingTitle !== value) {
            this.editingTitle = value
          }
        })
        .onFocus(() => {
          this.titleBorderColor = this.theme.TEXTINPUT_FOCUS_COLOR as string
          this.linkBorderColor = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
        })
        .border({
          width: 1,
          color: this.titleBorderColor
        })
        .backgroundColor(this.theme.TEXTINPUT_BG_COLOR)
      // .defaultFocus(true)
      // .focusable(true)

      Text('链 接')
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontColor(this.theme.TEXT_COLOR)
        .margin({
          top: 24,
        })
      TextInput({
        text: this.editingLink,
        placeholder: '链 接（如：https://www.wanandroid.com）',
        controller: this.linkController
      })
        .placeholderColor(this.theme.TEXTINPUT_PLACEHOLDER_COLOR)
        .placeholderFont({ size: 14, weight: 320 })
        .caretColor(this.theme.TEXTINPUT_CREATE_COLOR)
        .width('100%')
        .height(58)
        .textAlign(TextAlign.Start)
        .margin({
          top: 16
        })
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
        .onChange((value: string) => {
          if (this.editingLink !== value) {
            this.editingLink = value
          }
        })
        .enabled(false)
        .onFocus(() => {
          this.titleBorderColor = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
          this.linkBorderColor = this.theme.TEXTINPUT_FOCUS_COLOR as string

        })
        .border({
          width: 1,
          color: this.linkBorderColor
        })
        .backgroundColor(this.theme.TEXTINPUT_BG_COLOR)

      Row() {
        Text('取消')
          .width('50%')
          .height(68)
          .textAlign(TextAlign.Center)
          .fontColor(this.theme.TEXT_SEC_COLOR)
          .onClick(() => {
            this.onCancel()
          })
        Divider()
          .vertical(true)
          .height(24)
          .width(2)
          .color(Color.Gray)
          .opacity(0.6)
          .margin({ left: 6, right: 6 })
        Text('确认')
          .width("50%")
          .height(68)
          .textAlign(TextAlign.Center)
          .fontColor(this.theme.TEXT_COLOR)
          .onClick(() => {
            if (this.editingTitle.length === 0 || this.editingLink.length === 0) {
              extUIShowToast('标题和链接不能为空！')
              return
            }
            this.onComfrim(this.editingTitle, this.editingLink)
          })
      }
      .width('100%')
      .margin({
        top: 24
      })
    }

    .backgroundColor(this.theme.DIALOG_BG)
    .padding({
      top: 16,
      left: 16,
      right: 16,
    })

  }
}
