import { ICoinListInfo } from '../../net/wanAPI/response/ICoinListInfo'
import { Wanthemes } from '../../theme/WanThemes'


@Component
export struct CoinListItemLayout {
  item: ICoinListInfo
  theme: Wanthemes.IWanTheme

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Text(this.item.reason)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('30%')
        .height('100%')
        .fontColor(Color.Orange)

      Column() {
        Text(this.item.desc.split(',')[1])
          .fontColor(this.theme.TEXT_COLOR)
          .fontSize(16)

        Text(this.item.desc.split(',')[0].substring(0, 16))
          .margin({
            top: 8
          })
          .fontColor(this.theme.TEXT_SEC_COLOR)
          .fontSize(14)
      }
      .align(Alignment.Center)
      .justifyContent(FlexAlign.Center)
      .width('70%')
      .height('100%')

      Text('+' + this.item.coinCount)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('20%')
        .height('100%')
        .fontColor(this.theme.TEXT_SEC_COLOR)
    }
    .width('100%')
    .height(58)
    .backgroundColor(this.theme.BG_COLOR)
  }
}