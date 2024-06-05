import { extUIShowKeybroad } from '../../ext/UIExt'
import globalVM_Setting from '../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../theme/WanThemes'

@Component
export struct ActionBarSearchWeight {
  onBackPress: () => void
  onSearchPress: (words: string) => void
  onInputChange: (currentWords: string) => void
  private controller: TextInputController = new TextInputController()
  @Link words: string
  @Link searchHint: string
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  build() {
    RelativeContainer() {
      TextInput({ text: this.words, placeholder: this.searchHint, controller: this.controller })
        .placeholderColor($r('app.color.grey100'))
        .placeholderFont({ size: 14, weight: 320 })
        .caretColor($r('app.color.red900'))
        .width(20)
        .height(50)
        .margin({
          top: 12,
          bottom: 12
        })
        .fontSize(16)
        .fontColor(Color.White)
        .onChange((value: string) => {
          this.words = value
          this.onInputChange(value)
        })
        .backgroundColor($r('app.color.white24'))
        .defaultFocus(true)
        .focusable(true)
        .key('search_textInput')
        .onFocus(() => {
          extUIShowKeybroad("ActionBarSearchWeight_search_textInput")
        })
        .alignRules({
          left: { anchor: "back_btn", align: HorizontalAlign.End },
          top: { anchor: "__container__", align: VerticalAlign.Top },
          right: { anchor: "search_btn", align: HorizontalAlign.Start },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        })
        .id("ActionBarSearchWeight_search_textInput")

      Image($r('app.media.ic_back'))
        .width(32)
        .height(22)
        .objectFit(ImageFit.Contain)
        .onClick(this.onBackPress)
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .margin({
          left: 12,
          top: 24,
          right: 12,
          bottom: 24,
        })
        .onClick(this.onBackPress)
        .id("back_btn")

      Image($r('app.media.ic_search'))
        .width(28)
        .height(28)
        .objectFit(ImageFit.Auto)
        .onClick(this.onBackPress)
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          right: { anchor: "__container__", align: HorizontalAlign.End },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .margin({
          left: 12,
          top: 24,
          right: 12,
          bottom: 24,
        })
        .onClick(() => {
          this.onSearchPress(this.words)
        })
        .id("search_btn")
    }

    .backgroundColor(this.theme.PRIMARY_COLOR)
    .width('100%')
    .height(70)

  }
}