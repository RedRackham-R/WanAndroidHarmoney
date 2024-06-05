/**
 * 可以单向控制item的dsrc以及subDesck
 */
import { Wanthemes } from '../../theme/WanThemes'

@Component
export struct OptionItemLinkLayout {
  @Link desc: string
  @Link subDesc: string
  onItemClick: () => void = () => {
  }
  @BuilderParam itemRightLayout: () => void = () => {
  }
  @Link theme: Wanthemes.IWanTheme

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Text(this.desc).fontColor(this.theme.TEXT_COLOR).fontSize(16)
        Text(this.subDesc).fontColor(this.theme.TEXT_SEC_COLOR).fontSize(12).margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick(this.onItemClick)

      this.itemRightLayout()

    }.width('100%').align(Alignment.Center).margin({ left: 6, top: 28, })
  }
}