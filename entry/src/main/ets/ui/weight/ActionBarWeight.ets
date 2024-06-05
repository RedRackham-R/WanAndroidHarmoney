import display from '@ohos.display'
import { extUtilsGenerateRadomUUID } from '../../ext/UtilsExt'
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@Component
export struct ActionBarWeight {
  private readonly TAG = 'ActionBarWeight_' + extUtilsGenerateRadomUUID()
  @BuilderParam rightRowElement: (() => void) = () => {
  }
  @Link title: string
  showBackButton: boolean = true
  onBackPress?: (() => void) = null
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  private leftLayoutArea: Area | null = null
  private rightLayoutArea: Area | null = null
  @State private titleMargin: number = 0
  private isFristLoad = true

  aboutToAppear() {
    //主题
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (_event) => {
      this.theme = globalVM_Setting.getTheme()
    })
  }

  aboutToDisappear() {
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)
  }

  build() {
    RelativeContainer() {
      Text(this.title)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
        .fontSize(18)
        .width('100%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .margin({
          left: this.titleMargin,
          right: this.titleMargin,
        })
        .alignRules({
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End },
        })
        .id("title_text")

      if (this.showBackButton) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height('100%')
          .objectFit(ImageFit.Contain)
          .onClick(this.onBackPress)
          .onAreaChange((_oldValue: Area, newValue: Area) => {
            this.leftLayoutArea = newValue
            this.judgeLeftRightLayoutPadding()
          })
          .alignRules({
            left: { anchor: "__container__", align: HorizontalAlign.Start },
          })
          .margin({
            left: 16
          })
          .id("back_btn")

      }

      Stack() {
        this.rightRowElement()
      }
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.rightLayoutArea = newValue
        this.judgeLeftRightLayoutPadding()
      })
      .height('100%')
      .alignRules({
        right: { anchor: "__container__", align: HorizontalAlign.End },
      })
      .id("container_right_row")

    }
    .align(Alignment.Center)
    .backgroundColor(this.theme.PRIMARY_COLOR)
    .width('100%')
    .height(70)
  }

  private judgeLeftRightLayoutPadding() {
    if (this.isFristLoad && this.leftLayoutArea !== null && this.rightLayoutArea !== null) {
      this.isFristLoad = false
      const leftMargin: number = (this.leftLayoutArea.width as number) + (this.leftLayoutArea.position.x as number)
      const rightMargin: number = px2vp(display.getDefaultDisplaySync()
        .width) - (this.rightLayoutArea.position.x as number)
      if (leftMargin > rightMargin) {
        this.titleMargin = leftMargin
      } else {
        this.titleMargin = rightMargin
      }
    }
  }
}