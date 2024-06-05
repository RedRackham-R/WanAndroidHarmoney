/**
 * 积分规则说明
 */
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'

@CustomDialog
export struct RuleDescribeDialog {
  controller?: CustomDialogController
  content: Resource

  build() {
    Column() {
      Scroll() {
        Text(this.content)
          .fontSize(16)
          .fontColor(globalVM_Setting.getTheme().TEXT_SEC_COLOR)
      }
      .scrollBar(BarState.Off)
      .margin(16)
    }
    .height(380)
    .borderRadius({
      topLeft: 20,
      topRight: 20,
    })
    .backgroundColor(globalVM_Setting.getTheme().BG_SEC_COLOR)
  }
}
