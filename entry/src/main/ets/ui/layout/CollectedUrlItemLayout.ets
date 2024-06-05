import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { ICollectedUrl } from '../../net/wanAPI/response/ICollectedUrl'
import { Wanthemes } from '../../theme/WanThemes'


/**
 * article和banner布局
 */
@Component
export struct CollectedUrlItemLayout {
  index: number
  item: ICollectedUrl
  onDelete: (index: number, collectedUrl: ICollectedUrl) => void
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  onItemClick: (link: string) => void

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Text(this.item.name)
          .fontColor(this.theme.TEXT_COLOR)
          .fontSize(18)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Text(this.item.link).fontSize(12).fontColor(Color.Green)
      }
      .height('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Column() {
        if (this.item.extIsCollecting) {
          LoadingProgress()
            .color(this.theme.PROGRESS_COLOR)
            .width(30)
            .height(30)
            .margin({
              right: 8,
              left: 8,
            })
        } else {
          Image($r('app.media.ic_collected_url'))
            .width(26)
            .height(26)
            .objectFit(ImageFit.Auto)
            .margin({
              right: 8,
              left: 8,
            })
            .onClick(() => {
              this.onDelete(this.index, this.item)
            })
        }
      }
      .justifyContent(FlexAlign.Center)
      .height('100%')
    }
    .padding({
      top: 8,
      bottom: 8,
      left: 4,
      right: 4,
    })
    .align(Alignment.Center)
    .backgroundColor(this.theme.BG_COLOR)
    .width('100%')
    .height(86)
    .onClick(() => {
      this.onItemClick(this.item.link)
    })
  }
}

