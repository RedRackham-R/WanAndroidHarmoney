import { Wanthemes } from '../../theme/WanThemes'

@Component
export struct OptionTitleLayout {
  title: string
  @Link theme: Wanthemes.IWanTheme

  build() {
    Row() {
      Text(this.title).fontColor(this.theme.TEXT_COLOR).fontSize(22)
    }.width('100%').margin({
      top: 36,
    })
  }
}