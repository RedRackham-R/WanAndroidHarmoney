/**
 * 我的界面
 */
import {
  AvatarChangeEvent,
  LoginOutEvent,
  LoginRegistEvent,
  ThemeChangeEvent,
  UserInfoUpdateEvent
} from '../../../event/WanEvents'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { WanConstant } from '../../../global/WanConstant'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { Wanthemes } from '../../../theme/WanThemes'

@Component
export struct MineComponent {
  private readonly TAG: string = 'MineComponent'
  @State private coinText: string = '-- --'
  @State private userNameText: string = '登录 Wanandroid'
  @State private rankLevelText: string = '等 级: -- --   排 名: -- --'
  @State private avatarRes: Resource = $r('app.media.ic_user')
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  private scroller = new Scroller()

  build() {
    Scroll(this.scroller) {
      Column() {
        //用户信息
        Column() {
          Image(this.avatarRes)
            .height(86)
            .width(86)
            .objectFit(ImageFit.Fill)

          Column() {
            Text(this.userNameText)
              .textAlign(TextAlign.Start)
              .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
              .fontSize(22)
            Text(this.rankLevelText)
              .textAlign(TextAlign.Start)
              .fontSize(14)
              .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
              .margin({
                top: 20
              })
          }
          .margin({
            top: 18
          })

        }
        .width('100%')
        .height(240)
        .align(Alignment.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.theme.PRIMARY_COLOR)
        .onClick(() => {
          if (globalVM_User.hasLogged()) {
            globalVM_User.fetchUserInfo()
          } else {
            RouterDelegate.toLoginPage(false)
          }
        })

        Divider().height(10).color(Color.Transparent)

        //我的积分
        this.itemCoinLayout(() => {
          RouterDelegate.toCoinPage()
        })

        //我的收藏
        this.itemCommonLayout('我的收藏', $r('app.media.ic_uncollect'), () => {
          RouterDelegate.toCollectPage()
        })

        //我的分享
        this.itemCommonLayout('我的分享', $r('app.media.ic_share'), () => {
          RouterDelegate.toShareListPage()
        })

        //系统设置
        this.itemCommonLayout('系统设置', $r('app.media.ic_setting'), () => {
          RouterDelegate.toSettingPage()
        })
      }
      .backgroundColor(this.theme.BG_COLOR)
      .width('100%')
      .height('100%')
    }
    .scrollable(ScrollDirection.Vertical)
  }

  // TODO 坑：因为目前@State 修饰变量无法传递引用，所以专门多增加一个积分layout
  @Builder
  itemCoinLayout(onClick: (event?: ClickEvent) => void) {
    Row() {
      Image($r('app.media.ic_integral'))
        .height(22)
        .width(22)
        .objectFit(ImageFit.Auto)
        .margin({
          left: 20,
        })

      Text('我的积分')
        .margin({
          left: 32
        })
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
      Blank()
      Text(this.coinText)
        .margin({
          right: 32
        })
        .fontSize(16)
        .fontColor(this.theme.TEXT_SEC_COLOR)
    }
    .align(Alignment.Start)
    .alignItems(VerticalAlign.Center)
    .height(58)
    .width('100%')
    .onClick(onClick)
  }

  @Builder
  itemCommonLayout(title: string, iconRes: Resource, onClick: (event?: ClickEvent) => void) {
    Row() {
      Image(iconRes)
        .height(22)
        .width(22)
        .objectFit(ImageFit.Auto)
        .margin({
          left: 20,
        })

      Text(title)
        .margin({
          left: 32
        })
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
    }
    .align(Alignment.Start)
    .alignItems(VerticalAlign.Center)
    .height(58)
    .width('100%')
    .onClick(onClick)
  }

  aboutToAppear() {
    //配置数据
    if (globalVM_User.hasLogged()) {
      let loginInfo = globalVM_User.getLoginInfo()
      this.userNameText = loginInfo.nickname
      this.coinText = loginInfo.coinCount.toString()
    } else {
      this.userNameText = '登录 Wanandroid'
      this.coinText = '-- --'
    }

    let userInfo = globalVM_User.getUserInfo()
    if (userInfo !== null) {
      this.rankLevelText = '等 级: ' + userInfo.coinInfo.level + '   排 名: ' + userInfo.coinInfo.rank
    } else {
      this.rankLevelText = '等 级: -- --   排 名: -- --'
    }

    //监听主题变换
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (event) => {
      const realEvent = event.data as ThemeChangeEvent
      this.theme = globalVM_Setting.getTheme()
    })

    //监听头像更换
    globalVM_Setting.subscribeAvatarChangeEvent(this.TAG, (event) => {
      const realEvent = event.data as AvatarChangeEvent
      this.avatarRes = WanConstant.AVATAR_MAP[realEvent.avatarNumber]
    })

    //监听登录
    globalVM_User.subscribeLoginEvent(this.TAG, (event) => {
      const realEvent = event.data as LoginRegistEvent
      this.handleLoginEvent(realEvent)
    })

    //监听登出
    globalVM_User.subscribLoginOutEvent(this.TAG, (event) => {
      const realEvent = event.data as LoginOutEvent
      this.handleLoginOutEvent(realEvent)
    })

    //监听用户信息更新
    globalVM_User.subscribeUserInfoUpdateEvent(this.TAG, (event) => {
      const realEvent = event.data as UserInfoUpdateEvent
      if (realEvent.isUpdating) {
        this.rankLevelText = '等 级: 正在更新...   排 名: 正在更新...'
      } else {
        let info = globalVM_User.getUserInfo()
        if (info !== null) {
          this.rankLevelText = '等 级: ' + info.coinInfo.level + '   排 名: ' + info.coinInfo.rank
        } else {
          this.rankLevelText = '等 级: -- --   排 名: -- --'
        }
      }

    })

  }

  private async handleLoginEvent(event: LoginRegistEvent) {
    if (event.isSuccess) {
      this.userNameText = globalVM_User.getLoginInfo().nickname
      this.coinText = globalVM_User.getLoginInfo().coinCount.toString()
      this.avatarRes = await globalVM_Setting.getAvatar()
    }
  }

  private async handleLoginOutEvent(_event: LoginOutEvent) {
    this.userNameText = '登录 Wanandroid'
    this.coinText = '-- --'
    this.rankLevelText = '等 级: -- --   排 名: -- --'
    this.avatarRes = $r('app.media.ic_user')
  }

  aboutToDisappear() {
    //解除订阅
    globalVM_User.unSubscribeLoginEvent(this.TAG)
    globalVM_User.unSubscribeLoginOutEvent(this.TAG)
    globalVM_User.unSubscribeUserInfoUpdateEvent(this.TAG)
    globalVM_Setting.unSubscribeAvatarChangeEvent(this.TAG)
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)

  }
}