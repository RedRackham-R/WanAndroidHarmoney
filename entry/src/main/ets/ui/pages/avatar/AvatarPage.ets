import { AnyListDataSource } from '../../../data_source/AnyListDataSource'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { ActionBarWeight } from '../../weight/ActionBarWeight'

interface AvatarItem {
  selected: boolean
  avatarRes: Resource
}

@Entry
@Component
export struct AvatarPage {
  private avatars: AvatarItem[] = [
    { selected: false, avatarRes: $r('app.media.avatar1') },
    { selected: false, avatarRes: $r('app.media.avatar2') },
    { selected: false, avatarRes: $r('app.media.avatar3') },
    { selected: false, avatarRes: $r('app.media.avatar4') },
    { selected: false, avatarRes: $r('app.media.avatar5') },
    { selected: false, avatarRes: $r('app.media.avatar6') },
    { selected: false, avatarRes: $r('app.media.avatar7') },
    { selected: false, avatarRes: $r('app.media.avatar8') },
    { selected: false, avatarRes: $r('app.media.avatar9') },
    { selected: false, avatarRes: $r('app.media.avatar10') },
    { selected: false, avatarRes: $r('app.media.avatar11') },
    { selected: false, avatarRes: $r('app.media.avatar12') },
    { selected: false, avatarRes: $r('app.media.avatar13') },
    { selected: false, avatarRes: $r('app.media.avatar14') },
    { selected: false, avatarRes: $r('app.media.avatar15') },
    { selected: false, avatarRes: $r('app.media.avatar16') },
    { selected: false, avatarRes: $r('app.media.avatar17') },
    { selected: false, avatarRes: $r('app.media.avatar18') },
    { selected: false, avatarRes: $r('app.media.avatar19') },
    { selected: false, avatarRes: $r('app.media.avatar20') },
    { selected: false, avatarRes: $r('app.media.avatar21') },
    { selected: false, avatarRes: $r('app.media.avatar22') },
    { selected: false, avatarRes: $r('app.media.avatar23') },
    { selected: false, avatarRes: $r('app.media.avatar24') },
    { selected: false, avatarRes: $r('app.media.avatar25') },
    { selected: false, avatarRes: $r('app.media.avatar26') },
    { selected: false, avatarRes: $r('app.media.avatar27') },
    { selected: false, avatarRes: $r('app.media.avatar28') },
    { selected: false, avatarRes: $r('app.media.avatar29') },
    { selected: false, avatarRes: $r('app.media.avatar30') },
    { selected: false, avatarRes: $r('app.media.avatar31') },
    { selected: false, avatarRes: $r('app.media.avatar32') },
    { selected: false, avatarRes: $r('app.media.avatar33') },
    { selected: false, avatarRes: $r('app.media.avatar34') },
    { selected: false, avatarRes: $r('app.media.avatar35') },
    { selected: false, avatarRes: $r('app.media.avatar36') },
    { selected: false, avatarRes: $r('app.media.avatar37') },
    { selected: false, avatarRes: $r('app.media.avatar38') },
    { selected: false, avatarRes: $r('app.media.avatar39') },
    { selected: false, avatarRes: $r('app.media.avatar40') },
    { selected: false, avatarRes: $r('app.media.avatar41') },
    { selected: false, avatarRes: $r('app.media.avatar42') },
    { selected: false, avatarRes: $r('app.media.avatar43') },
    { selected: false, avatarRes: $r('app.media.avatar44') },
    { selected: false, avatarRes: $r('app.media.avatar45') },
    { selected: false, avatarRes: $r('app.media.avatar46') },
    { selected: false, avatarRes: $r('app.media.avatar47') },
    { selected: false, avatarRes: $r('app.media.avatar48') },
    { selected: false, avatarRes: $r('app.media.avatar49') },
    { selected: false, avatarRes: $r('app.media.avatar50') },
    { selected: false, avatarRes: $r('app.media.avatar51') },
    { selected: false, avatarRes: $r('app.media.avatar52') },
    { selected: false, avatarRes: $r('app.media.avatar53') },
    { selected: false, avatarRes: $r('app.media.avatar54') },
    { selected: false, avatarRes: $r('app.media.avatar55') },
    { selected: false, avatarRes: $r('app.media.avatar56') },
    { selected: false, avatarRes: $r('app.media.avatar57') },
    { selected: false, avatarRes: $r('app.media.avatar58') },
    { selected: false, avatarRes: $r('app.media.avatar59') },
    { selected: false, avatarRes: $r('app.media.avatar60') },
    { selected: false, avatarRes: $r('app.media.avatar61') },
    { selected: false, avatarRes: $r('app.media.avatar62') },
    { selected: false, avatarRes: $r('app.media.avatar63') },
    { selected: false, avatarRes: $r('app.media.avatar64') },
    { selected: false, avatarRes: $r('app.media.avatar65') },
    { selected: false, avatarRes: $r('app.media.avatar66') },
    { selected: false, avatarRes: $r('app.media.avatar67') },
    { selected: false, avatarRes: $r('app.media.avatar68') },
    { selected: false, avatarRes: $r('app.media.avatar69') },
    { selected: false, avatarRes: $r('app.media.avatar70') },
    { selected: false, avatarRes: $r('app.media.avatar71') },
    { selected: false, avatarRes: $r('app.media.avatar72') },
    { selected: false, avatarRes: $r('app.media.avatar73') },
    { selected: false, avatarRes: $r('app.media.avatar74') },
    { selected: false, avatarRes: $r('app.media.avatar75') },
    { selected: false, avatarRes: $r('app.media.avatar76') },
    { selected: false, avatarRes: $r('app.media.avatar77') },
    { selected: false, avatarRes: $r('app.media.avatar78') },
    { selected: false, avatarRes: $r('app.media.avatar79') },
    { selected: false, avatarRes: $r('app.media.avatar80') },
    { selected: false, avatarRes: $r('app.media.avatar81') },
    { selected: false, avatarRes: $r('app.media.avatar82') },
    { selected: false, avatarRes: $r('app.media.avatar83') },
    { selected: false, avatarRes: $r('app.media.avatar84') },
    { selected: false, avatarRes: $r('app.media.avatar85') },
    { selected: false, avatarRes: $r('app.media.avatar86') },
    { selected: false, avatarRes: $r('app.media.avatar87') },
    { selected: false, avatarRes: $r('app.media.avatar88') },
    { selected: false, avatarRes: $r('app.media.avatar89') }
  ]
  private scroller: Scroller = new Scroller()
  private selectedIndex = 0
  @State private title: string = '头像选择'
  @State private avatarRes: Resource = $r('app.media.avatar1')
  @State private dataSource: AnyListDataSource = new AnyListDataSource()
  private theme = globalVM_Setting.getTheme()

  aboutToAppear() {
    this.avatars.forEach((item) => {
      this.dataSource.addData(item)
    })
    this.loadAvatarSetting()
  }

  private async loadAvatarSetting() {
    const avatarRes: Resource = await globalVM_Setting.getAvatar()
    this.avatarRes = avatarRes
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Stack() {
        this.previewLayout()
        ActionBarWeight({
          title: this.title,
          showBackButton: true,
          onBackPress: () => {
            RouterDelegate.back()
          },
          rightRowElement: this.rightRowLayout.bind(this)
        })
      }.align(Alignment.Top)

      this.avatarListLayout()
    }
  }

  @Builder
  private avatarListLayout() {
    Column() {
      Grid(this.scroller) {
        LazyForEach(this.dataSource, (item: AvatarItem, index: number) => {
          GridItem() {
            this.avatarItemLayout(item, index)
          }
        }, (item: AvatarItem, index: number) => index + "_" + item.avatarRes + "_" + item.selected)

      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .onScrollIndex((first: number) => {
        console.info(first.toString())
      })
      .width('100%')
      .height('100%')
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)

    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private previewLayout() {
    Stack() {
      Image(this.avatarRes)
        .width(86)
        .height(86)
        .objectFit(ImageFit.Auto)
        .margin({
          bottom: 56
        })
    }.width('100%').height(240).align(Alignment.Bottom)
    .backgroundColor(this.theme.PRIMARY_COLOR)
  }

  @Builder
  private avatarItemLayout(item: AvatarItem, index: number) {
    Stack() {
      Image(item.avatarRes)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Auto)

      if (item.selected) {
        Image($r('app.media.ic_selected_avatar'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Auto)
      }
    }

    .width(78)
    .height(78)
    .align(Alignment.BottomEnd)
    .onClick(() => {
      //这里需要加; ，因为在js中(）可以代表一个函数的调用属性，所以当 this.isNew = true 没有加 ‘;'号时，js会默认后面的（）是“isNew"方法的调用属性。 加上分号就好了
      (this.dataSource.getData(this.selectedIndex) as AvatarItem).selected = false;
      (this.dataSource.getData(index) as AvatarItem).selected = true
      this.dataSource.notifyDataChange(this.selectedIndex)
      this.dataSource.notifyDataChange(index)
      this.avatarRes = (this.dataSource.getData(index) as AvatarItem).avatarRes
      this.selectedIndex = index

    })

  }

  @Builder
  private rightRowLayout() {
    Row() {
      Image($r('app.media.ic_aceept'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 24,
        })
        .onClick(() => {
          globalVM_Setting.setAvatar(this.selectedIndex + 1)
          RouterDelegate.back()
        })
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