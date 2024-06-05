import { extUIHideKeybroad, extUIShowKeybroad, extUIShowToast } from '../../../ext/UIExt'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import { PagesConstant, RouterDelegate } from '../../../router/RouterDelegate'
import {  Wanthemes } from '../../../theme/WanThemes'
import { ComfrimDialog } from '../../dialog/ComfrimDialog'
import { LogdingDialog } from '../../dialog/LoadingDialog'
import { RuleDescribeDialog } from '../../dialog/RuleDescribeDialog'
import { ActionBarWeight } from '../../weight/ActionBarWeight'
import shareViewModel from '../../../viewmodel/ShareViewModel'


@Entry
@Component
export struct ShareArticlePage {
  @State private artionBartitle: string = '分享文章'
  @State btnTitle: string = '发 布 文 章'
  //是否是重新编辑文章
  private isModifyArticle: boolean = (RouterDelegate.getParams()['id'] !== null)
  //编辑文章传入的title和link
  private title: string = RouterDelegate.getParams()['title']
  private link: string = RouterDelegate.getParams()['link']
  //正在编辑的title和link
  @State editingTitle: string = ''
  @State editingLink: string = ''
  //titile和link的controller
  private titleController = new TextInputController()
  private linkController = new TextInputController()
  //title和link输入框编辑状态
  @State titleInputEnable: boolean = true
  @State linkInputEnable: boolean = true
  private theme: Wanthemes.IWanTheme = globalVM_Setting.getTheme()
  //title和link输入框边框选中颜色
  @State private titleBorderColor: string = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
  @State private linkBorderColor: string = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
  //弹窗
  private coinRuleDialogController: CustomDialogController = new CustomDialogController({
    builder: RuleDescribeDialog({
      content: $r('app.string.share_article_description')
    }),
    // 点击遮障层退出时的回调
    cancel: () => {
      this.coinRuleDialogController.close()
    },
    //是否允许点击遮障层退出
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: true
  })
  private comfrimDialogController: CustomDialogController = new CustomDialogController({
    builder: ComfrimDialog({
      message: '发布文章 \n \n《' + this.editingTitle + '》 \n \n ' + this.editingLink,
      onComfrim: () => {
        this.comfrimDialogController.close()
        this.loadingDialogController.open()
        extUIHideKeybroad()
        this.shareArticleAsnyc(this.editingTitle, this.editingLink)
      },
      onCancel: () => {
        this.comfrimDialogController.close()
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
  @State loadingMsg: string = '发布中...'
  //loading弹窗
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

  aboutToAppear() {
    if (this.isModifyArticle) {
      this.editingTitle = this.title
      this.editingLink = this.link
      this.artionBartitle = '编辑文章'
      this.btnTitle = '重 新 发 布'
    }
  }

  onPageShow() {
    this.titleController.caretPosition(0)
    this.linkController.caretPosition(0)
    if (!this.isModifyArticle) {
      extUIShowKeybroad("ShareArticlePage_title_textInput")
    }
  }

  aboutToDisappear() {
    this.coinRuleDialogController = null
    this.comfrimDialogController = null
    this.loadingDialogController = null
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      ActionBarWeight({
        title: this.artionBartitle,
        showBackButton: true,
        rightRowElement: this.rightRowLayout.bind(this), //这里需要绑定本页面，不然rightRowLayout中的this是ActionBarWeight的this，造成undefined
        onBackPress: () => {
          RouterDelegate.back(
            PagesConstant.SHARE_LIST_PAGE,
            {
              refresh: false
            }
          )
        },
      })
      this.contentLayout()
    }
    .backgroundColor(this.theme.BG_SEC_COLOR)
    .width('100%')
    .height('100%')
  }

  @Builder
  private contentLayout() {
    Column() {
      Row() {
        Text('文章标题：').fontSize(14).fontColor(this.theme.TEXT_COLOR)
        if (this.isModifyArticle) {
          Blank()
          Text('重置标题')
            .fontSize(14)
            .fontColor(this.theme.TEXT_PROGRESS_COLOR)
            .onClick(() => {
              if (this.isModifyArticle) {
                this.editingTitle = this.title
              } else {
                this.editingTitle = ''
              }
            })
        }
      }
      .margin({
        top: 12,
      })
      .width('100%')

      TextInput({
        text: this.editingTitle,
        placeholder: '文章标题',
        controller: this.titleController
      })
        .placeholderColor(this.theme.TEXTINPUT_PLACEHOLDER_COLOR)
        .placeholderFont({ size: 14, weight: 320 })
        .caretColor(this.theme.TEXTINPUT_CREATE_COLOR)
        .width('100%')
        .height(58)
        .margin({
          top: 18
        })
        .enabled(this.titleInputEnable)
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
        .onChange((value: string) => {
          if (this.editingTitle !== value) {
            this.editingTitle = value
          }
          if (this.isModifyArticle) {
            //判断当前title和传入的title是否相同，不同则锁定link
            if (value !== this.title) {
              this.linkInputEnable = false
            } else {
              this.linkInputEnable = true
            }
          }
        })
        .onFocus(() => {
          this.titleBorderColor = this.theme.TEXTINPUT_FOCUS_COLOR as string
          this.linkBorderColor = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
        })
        .border({
          width: 1,
          color: this.titleBorderColor
        })
        .backgroundColor(this.theme.TEXTINPUT_BG_COLOR)
        .defaultFocus(true)
        .focusable(true)
        .key("ShareArticlePage_title_textInput")
        .id("ShareArticlePage_title_textInput")

      Row() {
        Text('文章链接：').fontSize(14).fontColor(this.theme.TEXT_COLOR)
        if (this.isModifyArticle) {
          Blank()
          Text('重置链接')
            .fontSize(14)
            .fontColor(this.theme.TEXT_PROGRESS_COLOR)
            .onClick(() => {
              if (this.isModifyArticle) {
                this.editingLink = this.link
              } else {
                this.editingLink = ''
              }
            })
        }
      }
      .width('100%')
      .margin({
        top: 36,
      })

      TextInput({
        text: this.editingLink,
        placeholder: '文章链接（如：https://www.wanandroid.com）',
        controller: this.linkController
      })
        .placeholderColor(this.theme.TEXTINPUT_PLACEHOLDER_COLOR)
        .placeholderFont({ size: 14, weight: 320 })
        .caretColor(this.theme.TEXTINPUT_CREATE_COLOR)
        .width('100%')
        .height(58)
        .textAlign(TextAlign.Start)
        .margin({
          top: 18
        })
        .enabled(this.linkInputEnable)
        .fontSize(16)
        .fontColor(this.theme.TEXT_COLOR)
        .onChange((value: string) => {
          if (this.editingLink !== value) {
            this.editingLink = value
          }
          if (this.isModifyArticle) {
            //判断当前link和传入的link是否相同，不同则锁定title
            if (value !== this.link) {
              this.titleInputEnable = false
            } else {
              this.titleInputEnable = true
            }
          }
        })
        .onFocus(() => {
          this.titleBorderColor = this.theme.TEXTINPUT_UNFOCUS_COLOR as string
          this.linkBorderColor = this.theme.TEXTINPUT_FOCUS_COLOR as string

        })
        .border({
          width: 1,
          color: this.linkBorderColor
        })
        .backgroundColor(this.theme.TEXTINPUT_BG_COLOR)


      Row() {
        Blank()
        Text('<-测试链接->')
          .fontSize(14)
          .fontColor(this.theme.TEXT_PROGRESS_COLOR)
          .onClick(() => {
            extUIShowToast('测试链接')
          })
      }
      .width('100%')
      .margin({
        top: 12,
      })

      //登录、注册按钮
      Text(this.btnTitle)
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
        .backgroundColor(this.theme.PRIMARY_COLOR)
        .fontColor(this.theme.TEXT_ON_PRIMARY_COLOR)
        .fontSize(16)
        .border({ color: Color.Transparent, radius: 20, width: 2 })
        .onClick(() => {
          extUIHideKeybroad()
          if (this.editingTitle.length === 0 || this.editingLink.length === 0) {
            extUIShowToast("标题和链接不能为空！")
            return
          }
          this.comfrimDialogController.open()
        })

    }
    .padding({
      top: 18,
      left: 12,
      right: 12,
      bottom: 18,
    })
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.BG_SEC_COLOR)
  }

  @Builder
  private rightRowLayout() {
    Row() {
      Image($r('app.media.ic_introduce'))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Auto)
        .margin({
          right: 24,
        })
        .onClick(() => {
          this.coinRuleDialogController.open()
        })
    }
  }

  private async shareArticleAsnyc(title: string, link: string) {
    try {
      await shareViewModel.shareArticleAsync(title, link)
      extUIShowToast("发布成功")
      RouterDelegate.back(
        PagesConstant.SHARE_LIST_PAGE,
        {
          refresh: true
        }
      )
    } catch (err) {
      extUIShowToast("发布失败：" + err)
    }
    this.loadingDialogController.close()
  }
}