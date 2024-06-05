import { extUIHideKeybroad, extUIShowToast } from '../../../ext/UIExt'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_WanDB from '../../../global/viewmodel/GlobalWanDBViewModel'
import { IHotKey } from '../../../net/wanAPI/response/IHotKey'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'
import { ActionBarSearchWeight } from '../../weight/ActionBarSearchWeight'
import searchViewModel from '../../../viewmodel/SearchViewModel'
import { SearchHistoryComponent } from './SearchHistoryComponent'
import { SearchListComponent } from './SearchListComponent'

enum PageType {
  HISTORY,
  LIST,
}

@Entry
@Component
export struct SearchPage {
  @State private pageType: PageType = PageType.HISTORY
  @State private hotKeys: Array<IHotKey> = new Array()
  @State private searchHint: string = '使用空格分隔多个关键字'
  @State private tapSearch: number = 0
  @State private words: string = ''
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()

  aboutToAppear() {
    this.fetchHotKeyAsync()
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      ActionBarSearchWeight({
        words: this.words,
        searchHint: this.searchHint,
        onBackPress: () => {
          if (this.pageType === PageType.LIST) {
            this.words = ''
            this.pageType = PageType.HISTORY
          } else {
            RouterDelegate.back()
          }
        },
        onSearchPress: (words: string) => {
          if (words.length === 0) {
            if (this.hotKeys.length > 0) {
              this.words = this.hotKeys[0].name
            }
          } else {
            this.words = words
          }
          extUIHideKeybroad()
          if (this.pageType === PageType.HISTORY) {
            this.pageType = PageType.LIST
          } else {
            this.tapSearch++
          }
          globalVM_WanDB.addSearchKeywords(this.words)

        },
        onInputChange: (currentWords: string) => {
          if (currentWords.length === 0 && this.pageType !== PageType.HISTORY) {
            this.pageType = PageType.HISTORY
          }
        }
      })
      if (this.pageType == PageType.HISTORY) {
        SearchHistoryComponent({
          onTagPress: (word: string) => {
            this.words = word
            globalVM_WanDB.addSearchKeywords(this.words)
            this.pageType = PageType.LIST
          },
          hotKeys: this.hotKeys
        }).layoutWeight(1)
      } else {
        SearchListComponent({
          tapSearch: this.tapSearch,
          searchWords: this.words
        }).layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.BG_SEC_COLOR)
  }

  private async fetchHotKeyAsync() {
    try {
      const result = await searchViewModel.fetchHotKeyAsync()
      this.hotKeys = result.datas
      if (this.hotKeys.length > 0) {
        this.searchHint = this.hotKeys[0].name + " ( 使用空格分隔多个关键字 )"
      }
    } catch (err) {
      extUIShowToast("热词更新失败：" + err)
    }
  }

  /**
   * 转场动画 从右边弹出
   */
  pageTransition() {
    // 定义页面进入时的效果，从右侧滑入，时长为1200ms，页面栈发生push操作时该效果才生效
    PageTransitionEnter({ type: RouteType.Push, duration: 300 })
      .slide(SlideEffect.Right)
    // 定义页面进入时的效果，从左侧滑入，时长为1200ms，页面栈发生pop操作时该效果才生效
    PageTransitionEnter({ type: RouteType.Pop, duration: 300 })
      .translate({
        x: -100,
        y: 0,
      })
    // 定义页面退出时的效果，向左侧滑出，时长为1000ms，页面栈发生push操作时该效果才生效
    PageTransitionExit({ type: RouteType.Push, duration: 300 })
      .translate({
        x: -100,
        y: 0,
      })
    // 定义页面退出时的效果，向右侧滑出，时长为1000ms，页面栈发生pop操作时该效果才生效
    PageTransitionExit({ type: RouteType.Pop, duration: 300 })
      .slide(SlideEffect.Right)
  }
}