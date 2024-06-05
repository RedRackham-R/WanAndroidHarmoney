import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import { CollectedArticleListComponent } from './CollectedArticleListComponent'
import { CollectedUrlListComponent } from './CollectedUrlListComponent'

@Entry
@Component
export struct CollectPage {
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  @State title: string = "我的收藏"
  private theme = globalVM_Setting.getTheme()

  build() {
    Flex({ direction: FlexDirection.Column }) {
      ActionBarWeight({
        title: this.title,
        showBackButton: true,
        onBackPress: () => {
          RouterDelegate.back()
        },
      })
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        TabContent() {
          CollectedArticleListComponent()
        }
        .tabBar(this.TabBuilder(0, '文章'))

        TabContent() {
          CollectedUrlListComponent()
        }
        .tabBar(this.TabBuilder(1, '网址'))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(56)
      .animationDuration(100)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .scrollable(true)
      .width('100%')
      .layoutWeight(1)
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.theme.TEXT_ON_PRIMARY_COLOR : this.theme.TEXT_ON_PRIMARY_SEC_COLOR)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .color(Color.White)
        .margin({
          left: 8,
          right: 8,
        })
        .opacity(this.currentIndex === index ? 1 : 0)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.PRIMARY_COLOR)
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