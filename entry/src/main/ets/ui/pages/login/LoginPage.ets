import { RouterDelegate } from '../../../router/RouterDelegate'
import { LogdingDialog } from '../../dialog/LoadingDialog'
import { GradientColorWeight } from '../../weight/GradientColorWeight'
import { WaveAnimWeight } from '../../weight/WaveAnimWeight'
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel'
import { LoginRegistEvent } from '../../../event/WanEvents'
import { extUIShowToast } from '../../../ext/UIExt'

/**
 * 登录模块
 */
@Entry
@Component
struct LoginPage {
  private TAG = 'LoginPage'
  //账号
  @State account: string = ''
  //密码
  @State passwd: string = ''
  //再次输入密码
  @State rePasswd: string = ''
  //页面类型 0 登录 1 注册
  @State pageType: number = 0
  @State title: string = '登 录 Wanandroid'
  //底部说明
  @State tags: string = '没有账号？ 立即注册。'
  //密码说明
  @State passwdHint: string = '密 码'
  @State buttonTitle: string = '登  录'
  //输入控件控制器
  private controllerAccount: TextInputController = new TextInputController()
  private controllerPasswd: TextInputController = new TextInputController()
  private controllerRePasswd: TextInputController = new TextInputController()
  //正则：汉字、大小写英文、下划线
  private REGULAR_ACCOUNT: string = '[\u4E00-\u9FA5A-Za-z0-9_]'
  //正则：汉字、大小写英文、下划线
  private REGULAR_PASSWD: string = '[\u4E00-\u9FA5A-Za-z0-9_]'
  @State loadingMsg: string = '登录中...'
  //弹窗
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LogdingDialog({
      text: this.loadingMsg
    }),
    // 点击遮障层退出时的回调
    cancel: () => {
    },
    //是否允许点击遮障层退出
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  build() {
    Stack() {
      GradientColorWeight()
        .width('100%')
        .height('100%')

      WaveAnimWeight({
        waveOffset: 0,
      })
        .alignSelf(ItemAlign.End)
        .width('100%')
        .height(180)

      WaveAnimWeight({
        waveOffset: 5,
      })
        .alignSelf(ItemAlign.End)
        .width('100%')
        .height(220)

      WaveAnimWeight({
        waveOffset: -5,
      })
        .alignSelf(ItemAlign.End)
        .width('100%')
        .height(160)

      this.loginLayout()
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }

  @Builder
  loginLayout() {
    RelativeContainer() {
      Image($r('app.media.ic_close'))
        .width(28)
        .height(28)
        .objectFit(ImageFit.Auto)
        .onClick(() => {
          RouterDelegate.back()
        })
        .id('close_img')
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
        })
        .margin({
          top: 24,
          left: 24,
        })

      Column() {
        Text(this.title)
          .fontColor(Color.White)
          .fontSize(28)
          .margin({
            bottom: 40,
          })

        TextInput({ text: this.account, placeholder: '账 号', controller: this.controllerAccount })
          .placeholderColor($r('app.color.grey100'))
          .placeholderFont({ size: 14, weight: 320 })
          .caretColor($r('app.color.red900'))
          .width(320)
          .height(58)
          .margin(20)
          .fontSize(16)
          .fontColor(Color.White)
          .inputFilter(this.REGULAR_ACCOUNT, (e) => {

          })
          .onChange((value: string) => {

            this.account = value
          })
          .backgroundColor($r('app.color.white24'))

        Column() {
          TextInput({ text: this.passwd, placeholder: this.passwdHint, controller: this.controllerPasswd })
            .placeholderColor($r('app.color.grey100'))
            .placeholderFont({ size: 14, weight: 320 })
            .caretColor($r('app.color.red900'))
            .width(320)
            .height(58)
            .margin(20)
            .fontSize(16)
            .fontColor(Color.White)
            .inputFilter(this.REGULAR_PASSWD, (e) => {

            })
            .onChange((value: string) => {

              this.passwd = value
            })
            .backgroundColor($r('app.color.white24'))
            .type(InputType.Password)
            .showPasswordIcon(false)

          //二次输入密码
          if (this.pageType === 1) {
            Column() {
              TextInput({ text: this.rePasswd, placeholder: '再次输入密码', controller: this.controllerRePasswd })
                .placeholderColor($r('app.color.grey100'))
                .placeholderFont({ size: 14, weight: 320 })
                .caretColor($r('app.color.red900'))
                .width(320)
                .height(58)
                .margin(20)
                .fontSize(16)
                .fontColor(Color.White)
                .inputFilter(this.REGULAR_PASSWD, (e) => {
                })
                .onChange((value: string) => {
                  this.rePasswd = value
                })
                .backgroundColor($r('app.color.white24'))
                .type(InputType.Password)
                .showPasswordIcon(false)
            }
          }
          //登录、注册按钮
          Text(this.buttonTitle)
            .textAlign(TextAlign.Center)
            .width('80%')
            .height(58)
            .margin({
              top: 48,
            })
            .padding({
              top: 12,
              bottom: 12,
            })
            .fontColor(Color.White)
            .fontSize(16)
            .border({ color: Color.White, radius: 20, width: 2 })
            .onClick(() => {
              this.handleLogin()
            })
        }
      }
      .margin({
        top: 160,
      })
      .id('input_container')
      .alignRules({
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        top: { anchor: "__container__", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End },
      })


      Text(this.tags)
        .fontColor(Color.White)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .margin({
          bottom: 48,
        })
        .id('tags_text')
        .alignRules({
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          right: { anchor: "__container__", align: HorizontalAlign.End },
        })
        .onClick(() => {
          if (this.pageType === 0) {
            this.pageType = 1
            this.title = '注 册 账 号'
            this.tags = '已有帐号？ 即刻登录。'
            this.passwd = ''
            this.passwdHint = '密 码（建议至少8位长度）'
            this.rePasswd = ''
            this.buttonTitle = '注册并登录'
          } else {
            this.pageType = 0
            this.title = '登 录 Wanandroid'
            this.tags = '没有账号？ 点击注册。'
            this.passwd = ''
            this.passwdHint = '密 码'
            this.rePasswd = ''
            this.buttonTitle = '登  录'
          }
        })
    }
    .width('100%')
    .height('100%')
  }

  private handleLogin() {
    if (this.pageType === 0) { //登录
      this.loadingDialogController.open()
      globalVM_User.login(this.account, this.passwd)
    } else { //注册
      this.loadingDialogController.open()
      globalVM_User.registWithLogin(this.account, this.passwd, this.rePasswd)

    }

  }

  aboutToAppear() {
    //注册登录事件监听
    globalVM_User.subscribeLoginEvent(this.TAG, (event) => {
      this.loadingDialogController.close()
      let loginEvent = event.data as LoginRegistEvent
      if (loginEvent.isSuccess) {
        if (this.pageType === 0) {
          extUIShowToast("登录成功")
        } else {
          extUIShowToast("注册成功")
        }
        RouterDelegate.back()
      } else {
        extUIShowToast(loginEvent.errMsg)
      }
    })
  }

  aboutToDisappear() {
    //解除订阅
    globalVM_User.unSubscribeLoginEvent(this.TAG,)
    //退出需要把dialog controller置空
    this.loadingDialogController = null
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300 })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 300 })
      .slide(SlideEffect.Right)
  }
}
