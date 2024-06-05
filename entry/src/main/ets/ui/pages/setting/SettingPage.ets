import { AvatarChangeEvent, ThemeChangeEvent } from '../../../event/WanEvents'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { RouterDelegate } from '../../../router/RouterDelegate'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'
import { OptionItemLayout } from '../../layout/OptionItemLayout'
import { OptionTitleLayout } from '../../layout/OptionTitleLayout'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import storageStatistics from "@ohos.file.storageStatistics"
import { ByteConverter } from '../../../utils/ByteConverter'
import { OptionItemLinkLayout } from '../../layout/OptionItemLinkLayout'
import { extUIShowToast } from '../../../ext/UIExt'
import { WanConstant } from '../../../global/WanConstant'
import { Wanthemes } from '../../../theme/WanThemes'

@Entry
@Component
export struct SettingPage {
  private readonly TAG: string = 'SettingPage'
  private scroller: Scroller = new Scroller()
  @State private title: string = '系统设置'
  @State private isShowTopArticle: boolean = true
  @State private isDarkMode: boolean = false
  @State private isShowLoginOutItem: boolean = globalVM_User.hasLogged()
  @State private clearCacheDesc: string = "清除缓存"
  @State private appCacheText: string = "0 KB"
  @State private avatarRes: Resource = $r('app.media.avatar1')
  @State private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  private confirmClearCacheDialog: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: "是否清除应用缓存？",
      onComfrim: () => {
        this.confirmClearCacheDialog.close()
        this.clearCache()
      },
      onCancel: () => {
        this.confirmClearCacheDialog.close()
      }
    }),
    // 点击遮障层退出时的回调
    cancel: () => {

    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })
  private confirmLoginOutDialog: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: "退出当前账号: " + globalVM_User.getLoginInfo().username,
      onComfrim: () => {
        globalVM_User.loginOut()
        this.confirmLoginOutDialog.close()
        extUIShowToast('已登出')
      },
      onCancel: () => {
        this.confirmLoginOutDialog.close()
      }
    }),
    // 点击遮障层退出时的回调
    cancel: () => {

    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  aboutToAppear() {
    //注册头像更换event
    globalVM_Setting.subscribeAvatarChangeEvent(this.TAG, (event) => {
      const realEvent = event.data as AvatarChangeEvent
      this.avatarRes = WanConstant.AVATAR_MAP[realEvent.avatarNumber]
    })
    //主题
    globalVM_Setting.subscribeThemeChangeEvent(this.TAG, (event) => {
      const realEvent = event.data as ThemeChangeEvent
      this.isDarkMode = realEvent.themeNum !== 1
      this.theme = globalVM_Setting.getTheme()
    })

    //注册登出event
    globalVM_User.subscribLoginOutEvent(this.TAG, (_event) => {
      this.isShowLoginOutItem = false
    })

    this.initAppSettings()
  }

  aboutToDisappear() {
    globalVM_User.unSubscribeLoginOutEvent(this.TAG)
    globalVM_Setting.unSubscribeAvatarChangeEvent(this.TAG)
    globalVM_Setting.unSubscribeThemeChangeEvent(this.TAG)
    this.confirmLoginOutDialog = null
    this.confirmClearCacheDialog = null
  }

  private async initAppSettings() {
    //显示置顶文章开关
    this.isShowTopArticle = await globalVM_Setting.isShowTopArticle()
    //获取app缓存
    this.loadCacheSize()
    //设置头像
    this.avatarRes = await globalVM_Setting.getAvatar()
    //主题
    this.isDarkMode = (globalVM_Setting.getTheme() === Wanthemes.DarkTheme)
  }

  private async loadCacheSize() {
    //获取app缓存大小 单位byte
    const status = await storageStatistics.getCurrentBundleStats()

    this.appCacheText = ByteConverter.convertBytes(status.cacheSize)
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      ActionBarWeight({
        title: this.title,
        showBackButton: true,
        onBackPress: () => {
          RouterDelegate.back()
        },
      })

      this.contentLayout()

    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.BG_COLOR)
  }

  @Builder
  private contentLayout() {
    Scroll(this.scroller) {
      Column() {
        //---基本设置
        OptionTitleLayout({
          title: '基本设置',
          theme: this.theme
        })
        //置顶文章开关
        OptionItemLayout({
          desc: '显示置顶文章',
          subDesc: '显示置顶的文章，修改后刷新首页或者重启APP生效',
          itemRightLayout: this.showTopArticleRightLayout.bind(this),
          theme: this.theme,
          onItemClick: () => {
            this.isShowTopArticle = !this.isShowTopArticle
            globalVM_Setting.setShowTopArticle(this.isShowTopArticle)
          }
        })
        //清除缓存
        OptionItemLinkLayout({
          desc: this.clearCacheDesc,
          subDesc: this.appCacheText,
          onItemClick: () => {
            this.confirmClearCacheDialog.open()
          },
          theme: this.theme
        })
        //登出
        if (this.isShowLoginOutItem) {
          OptionItemLayout({
            desc: '退出登录',
            subDesc: '退出当前账号登录状态',
            onItemClick: () => {
              this.confirmLoginOutDialog.open()
            },
            theme: this.theme
          })
        }

        //---主题相关
        OptionTitleLayout({
          title: '主题相关',
          theme: this.theme
        })

        if (this.isShowLoginOutItem) {
          OptionItemLayout({
            desc: '修改头像',
            subDesc: '点击更改本地头像',
            itemRightLayout: this.avatarRightLayout.bind(this),
            onItemClick: () => {
              RouterDelegate.toAvatarPage()
            },
            theme: this.theme
          })
        }

        //深色模式
        OptionItemLayout({
          desc: '深色模式',
          subDesc: 'App深色模式开关',
          itemRightLayout: this.changeThemeRightLayout.bind(this),
          theme: this.theme,
          onItemClick: () => {
            this.isDarkMode = !this.isDarkMode
          }
        })
        //---关于
        OptionTitleLayout({
          title: '关于',
          theme: this.theme
        })

        OptionItemLayout({
          desc: '应用版本',
          subDesc: '1.0.0',
          theme: this.theme
        })
        OptionItemLayout({
          desc: '声明',
          subDesc: '本软件存寻GPLv3通用公共许可协议',
          itemRightLayout: this.imageRightLayout.bind(this, ($r('app.media.pic_gplv3'))),
          theme: this.theme,
          onItemClick: () => {
            RouterDelegate.toWebPage('https://www.gnu.org/licenses/gpl-3.0.en.html')
          }
        })
        OptionItemLayout({
          desc: '项目地址',
          subDesc: 'https://github.com/RedRackham-R/WanAndroidHarmoney',
          itemRightLayout: this.imageRightGitHubLayout.bind(this),
          theme: this.theme,
          onItemClick: () => {
            RouterDelegate.toWebPage('https://github.com/RedRackham-R/WanAndroidHarmoney')
          }
        })

        OptionItemLayout({
          desc: '特别感谢',
          subDesc: '玩安卓：https://www.wanandroid.com',
          itemRightLayout: this.imageRightWanandroidLayout.bind(this),
          theme: this.theme,
          onItemClick: () => {
            RouterDelegate.toWebPage('https://www.wanandroid.com')
          }
        })
      }
      .justifyContent(FlexAlign.Start)
      .padding({
        left: 18,
        right: 18,
        bottom: 18,
      })
    }
    .align(Alignment.Top)
    .width('100%')
    .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
    .scrollBar(BarState.Off) // 滚动条常驻显示
    .layoutWeight(1)
  }

  @Builder
  private changeThemeRightLayout() {
    Checkbox()
      .select(this.isDarkMode)
      .onChange((isChecked: boolean) => {
        if (isChecked) {
          globalVM_Setting.setTheme(0)
        } else {
          globalVM_Setting.setTheme(1)
        }
      }).alignSelf(ItemAlign.Center)
  }

  @Builder
  private imageRightLayout(imageRes: Resource) {
    Image(imageRes).width(42).height(42).objectFit(ImageFit.Auto).alignSelf(ItemAlign.Center)
  }

  @Builder
  private imageRightGitHubLayout() {
    Image(this.theme.ICON_GITHUB_LOGO_RES as Resource)
      .width(42)
      .height(42)
      .objectFit(ImageFit.Auto)
      .alignSelf(ItemAlign.Center)
  }

  @Builder
  private imageRightWanandroidLayout() {
    Image(this.theme.ICON_WANANDROID_LOGO_RES as Resource)
      .width(42)
      .height(42)
      .objectFit(ImageFit.Auto)
      .alignSelf(ItemAlign.Center)
  }

  @Builder
  private avatarRightLayout() {
    Image(this.avatarRes)
      .width(42)
      .height(42)
      .objectFit(ImageFit.Auto)
      .alignSelf(ItemAlign.Center)
      .onClick(() => {
        RouterDelegate.toAvatarPage()
      })
  }

  @Builder
  private showTopArticleRightLayout() {
    Checkbox()
      .select(this.isShowTopArticle)
      .onChange((isChecked: boolean) => {
        if (this.isShowTopArticle !== isChecked) {
          globalVM_Setting.setShowTopArticle(isChecked)
          this.isShowTopArticle = isChecked
        }
      }).alignSelf(ItemAlign.Center)
  }

  private async clearCache() {
    try {
      await globalVM_Setting.clearAppCache()
      this.loadCacheSize()
      extUIShowToast("缓存清除成功")
    } catch (err) {
      extUIShowToast("缓存清除失败：" + err)
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