import { TabItem } from '../../../pojo/TabItem'
import MainViewModel from '../../../viewmodel/MainViewModel'
import { MineComponent, } from '../mine/MineComponent'
import { HomeComponent, } from '../home/HomeComponent'
import { RouterDelegate } from '../../../router/RouterDelegate'

import display from '@ohos.display';
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { Wanthemes } from '../../../theme/WanThemes'
import { ThemeChangeEvent } from '../../../event/WanEvents'
import { extUtilsPrintLog } from '../../../ext/UtilsExt'

@Entry
@Component
struct MainPage {
  private readonly TAG: string = 'MainPage'
  @State checkedIndex: number = 0
  private tabController: TabsController = new TabsController()
  @State private tapToTop: number = 0
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  @State private isShowBackToTop: boolean = false
  @State private searchBtnPositionY: number = 0
  private readonly searchBtnSize :number = 58

  //配置沉浸式状态栏 当前API9无法使用
  // // 获取UIAbility上下文
  // context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  //
  // async setSystemBar() {
  //   // 获取当前应用窗口
  //   let windowClass: window.Window = await window.getLastWindow(this.context)
  //   // 将状态栏和导航栏的背景色设置为跟应用窗口相同的颜色
  //   await windowClass.setWindowSystemBarProperties({
  //     navigationBarColor: "#00FF00",
  //     statusBarColor: "#00FF00",
  //     navigationBarContentColor: "#00FF00",
  //     statusBarContentColor: "#00FF00"
  //   })
  // }
  // aboutToAppear() {
  //   this.setSystemBar()
  // }

  aboutToAppear() {
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (event) => {
      const realEvent = event.data as ThemeChangeEvent
      this.theme = globalVM_Setting.getTheme()
    })
  }

  aboutToDisappear() {
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)
  }

  build() {
    Stack() {
      Tabs({
        index: this.checkedIndex,
        barPosition: BarPosition.End,
        controller: this.tabController,
      }) {
        TabContent() {
          HomeComponent({
            tapBackTop: this.tapToTop,
            onScroll: (yOffset: number) => {
              if (yOffset > 1000) {
                if (!this.isShowBackToTop) {
                  this.isShowBackToTop = true
                }
              } else {
                if (this.isShowBackToTop) {
                  this.isShowBackToTop = false
                }
              }
            }
          })
        }
        .tabBar(this.homeTabItemLayout(MainViewModel.tabTitles[0]))


        TabContent() {
          MineComponent()
        }
        .tabBar(this.userTabItemLayout(MainViewModel.tabTitles[1]))
      }
      .scrollable(false)
      .onChange((index: number) => {
        //只有在homePage页面并且再次点击才能回到顶部
        if (index === 0 && (this.checkedIndex === index)) {
          this.tapToTop++
        }
        this.checkedIndex = index
      })

      Button() {
        Image(this.theme.ICON_SEARCH_ARTICLE_RES as Resource)
          .width(52)
          .height(52)
          .objectFit(ImageFit.Auto)
      }
      .width(this.searchBtnSize)
      .height(this.searchBtnSize)
      .borderRadius(90)
      .position({ x: px2vp(display.getDefaultDisplaySync().width / 2) + 24, y: this.searchBtnPositionY })
      .markAnchor({ x: '100%', y: '100%' })
      .backgroundColor(this.theme.SEARCH_ARTICLE_BUTTON_BG)
      .onClick(() => {
        RouterDelegate.toSearchPage()
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.BG_COLOR)
  }

  @Builder
  homeTabItemLayout(item: TabItem) {
    Column() {
      Image(this.checkedIndex === item.index ? (this.isShowBackToTop ? this.theme.ICON_HOME_CHECKED_BACK_TO_TOP_RES as Resource : this.theme.ICON_HOME_CHECKED_RES as Resource) : (this.isShowBackToTop ? this.theme.ICON_HOME_UNCHECKED_BACK_TO_TOP_RES as Resource : this.theme.ICON_HOME_UNCHECKED_RES as Resource))
        .height(24)
        .width(24)
      Text(item.title)
        .margin({
          top: 4
        })
        .fontColor(this.checkedIndex == item.index ? this.theme.TEXT_COLOR : this.theme.TEXT_SEC_COLOR)
        .fontSize(12)
    }
    .height('100%')
    .width('100%')
    .border({
      width: {
        top: 2
      },
      color: {
        top: this.theme.BG_SEC_COLOR
      }
    })
    //这里获取控件高度，重新对搜索按钮Y轴布局
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.searchBtnPositionY = px2vp(display.getDefaultDisplaySync().height) - (newValue.height as number) -46
    })
    .backgroundColor(this.theme.BG_COLOR)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 创建底部导航item组件
   * @param item
   */
  @Builder
  userTabItemLayout(item: TabItem) {
    Column() {
      Image(this.checkedIndex === item.index ? this.theme.ICON_USER_CHECKED_RES as Resource : this.theme.ICON_USER_UNCHECKED_RES as Resource)
        .height(24)
        .width(24)
      Text(item.title)
        .margin({
          top: 4
        })
        .fontColor(this.checkedIndex == item.index ? this.theme.TEXT_COLOR : this.theme.TEXT_SEC_COLOR)
        .fontSize(12)
    }
    .height('100%')
    .width('100%')
    .border({
      width: {
        top: 2
      },
      color: {
        top: this.theme.BG_SEC_COLOR
      }
    })
    .backgroundColor(this.theme.BG_COLOR)
    .justifyContent(FlexAlign.Center)
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


