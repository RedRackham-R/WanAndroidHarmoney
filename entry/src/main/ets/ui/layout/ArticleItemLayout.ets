import { IArticle, IArticleTag } from '../../net/wanAPI/response/IArticle'
import { RouterDelegate } from '../../router/RouterDelegate'
import { Wanthemes } from '../../theme/WanThemes'


/**
 * article和banner布局
 */
@Component
export struct ArticleItemLayout {
  article: IArticle
  onCollect: (isCollect: boolean, article: IArticle) => void = () => {
  }
  onItemClick: (article: IArticle) => void = () => {
  }
  onItemLongClick: (article: IArticle, event: GestureEvent) => void = () => {
  }
  @Link theme: Wanthemes.IWanTheme
  private subTagColors = [
    $r('app.color.blue500'),
    $r('app.color.green500'),
    $r('app.color.orange500'),
    $r('app.color.yellow500'),

  ]
  private title: string[]

  aboutToAppear() {
    this.title = this.splitHighlightedText(this.article.title)
  }

  build() {
    if (this.isProject()) {
      this.projectItemLayout()
    } else {
      this.articleItemLayout()
    }
  }

  //文章 UI
  @Builder
  private articleItemLayout() {
    Column() {
      //作者和TAG、时间
      Row() {
        Text(this.getAuthorName())
          .fontSize(12)
          .fontColor(this.theme.TEXT_COLOR)
        this.tagComponent()

        Blank()

        Text(this.article.niceShareDate)
          .fontSize(12)
          .margin({
            left: 8,
          })
          .fontColor(this.theme.TEXT_SEC_COLOR)
      }
      .width('100%')
      .padding(8)

      //标题内容
      Text() {
        ForEach(this.title, (value: string, index: number) => {
          if (index === 1) {
            Span(value).fontColor(this.theme.TEXT_COLOR).fontSize(18).fontColor($r('app.color.blue500'))
          } else {
            Span(value).fontColor(this.theme.TEXT_COLOR)
          }
        })
      }
      .constraintSize({
        maxWidth: '100%'
      })
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(2)
      .fontSize(18)
      .width('100%')
      .padding({
        left: 8
      })
      .margin({
        top: 12,
        bottom: 12,
      })
      .onClick(() => {
        this.onItemClick(this.article)
        RouterDelegate.toWebPage(this.article.link)
      })

      //底部TAG以及like
      Row() {
        Text(this.article.superChapterName + '-' + this.article.chapterName)
          .fontSize(12)
          .padding(8)
          .fontColor(Color.Green)
        Blank()
        if (this.article.extIsCollecting) {
          LoadingProgress()
            .color(this.theme.PROGRESS_COLOR)
            .width(30)
            .height(30)
            .margin({
              right: 8,
            })
        } else {
          if (this.article.collect) {
            Image($r('app.media.ic_collected'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                this.onCollect(false, this.article)
              })
          } else {
            Image($r('app.media.ic_uncollect'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                this.onCollect(true, this.article)
              })
          }
        }
      }
      .width('100%')
    }
    .backgroundColor(this.theme.BG_COLOR)
    .width('100%')
    .onClick(() => {
      this.onItemClick(this.article)
      RouterDelegate.toWebPage(this.article.link)
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => { //长按触发
          this.onItemLongClick(this.article, event)
        })
        .onActionEnd(() => { // 长按动作一结束触发

        })
    )
  }

  //项目 UI
  @Builder
  private projectItemLayout() {
    Column() {
      //作者和TAG、时间
      Row() {
        Text(this.getAuthorName())
          .fontSize(12)
          .fontColor(this.theme.TEXT_COLOR)
        this.tagComponent()

        Blank()

        Text(this.article.niceShareDate)
          .fontSize(12)
          .margin({
            left: 8,
          })
          .fontColor(this.theme.TEXT_SEC_COLOR)
      }
      .width('100%')
      .padding(8)

      //标题内容
      Flex({ direction: FlexDirection.Row }) {
        Image(this.article.envelopePic)// 直接加载网络地址，请填写一个具体的网络图片地址
          .alt($r('app.media.pic_image_placeholder'))// 使用alt，在网络图片加载成功前使用占位图
          .objectFit(ImageFit.Fill)
          .width(120)
          .height(120)
          .border({ radius: 24 })
        Flex({ direction: FlexDirection.Column }) {
          Text() {
            ForEach(this.title, (value: string, index: number) => {
              if (index === 1) {
                Span(value).fontColor(this.theme.TEXT_COLOR).fontSize(18).fontColor($r('app.color.blue500'))
              } else {
                Span(value).fontColor(this.theme.TEXT_COLOR)
              }
            })
          }
          .constraintSize({
            maxWidth: '100%'
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .width('100%')
          .fontSize(18)
          .textAlign(TextAlign.Start)
          .onClick(() => {
            this.onItemClick(this.article)
            RouterDelegate.toWebPage(this.article.link)
          })


          Text(this.article.desc)
            .width('100%')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .fontColor(this.theme.TEXT_SEC_COLOR)
            .margin({
              top: 8,
            })
            .constraintSize({
              maxWidth: '100%'
            })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(6)
        }
        .layoutWeight(1)
        .height(120)
        .align(Alignment.TopStart)
        .margin({
          left: 8
        })
      }
      .padding(8)
      .width('100%')

      //底部TAG以及like
      Row() {
        Text(this.article.superChapterName + '-' + this.article.chapterName)
          .fontSize(12)
          .padding(8)
          .fontColor(Color.Green)
        Blank()
        if (this.article.extIsCollecting) {
          LoadingProgress()
            .color(this.theme.PROGRESS_COLOR)
            .width(30)
            .height(30)
            .margin({
              right: 8,
            })
        } else {
          if (this.article.collect) {
            Image($r('app.media.ic_collected'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                this.onCollect(false, this.article)
              })
          } else {
            Image($r('app.media.ic_uncollect'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                this.onCollect(true, this.article)
              })
          }
        }
      }
      .width('100%')
    }
    .backgroundColor(this.theme.BG_COLOR)
    .width('100%')
    .onClick(() => {
      this.onItemClick(this.article)
      RouterDelegate.toWebPage(this.article.link)
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => { //长按触发
          this.onItemLongClick(this.article, event)
        })
        .onActionEnd(() => { // 长按动作一结束触发

        })
    )
  }

  private getAuthorName(): string {
    if (this.article.author !== "") {
      return this.article.author
    } else if (this.article.shareUser !== "") {
      return this.article.shareUser
    } else {
      return "佚名"
    }
  }

  //判断数据会否是项目（根据是否有图片判断）
  private isProject(): boolean {
    return this.article.envelopePic !== ""
  }

  @Builder
  tagComponent() {
    Row() {
      if (this.article.type === 1) {
        Text('置顶')
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .border({ color: Color.Red, radius: 6, width: 1 })
          .fontSize(10)
      }

      if (this.article.fresh) {
        Text('新')
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.purple500'))
          .border({ color: Color.Orange, radius: 6, width: 1 })
          .fontSize(10)
      }

      ForEach(this.article.tags, (value: IArticleTag, index: number) => {
        Text(value.name)
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor(this.subTagColors[index%5])
          .border({ color: this.subTagColors[index%5], radius: 6, width: 1 })
          .fontSize(10)
      })

    }
  }

  /**
   * 处理高亮title
   * @param input
   * @returns
   */
  private splitHighlightedText(input: string): string[] {
    // 正则表达式匹配 <em class='highlight'> 和 </em>
    const regex = /<em class='highlight'>(.*?)<\/em>/

    // 提取高亮部分和前后文本
    const match = input.match(regex)
    if (!match) return [input]; // 如果没有匹配到，返回原字符串

    const highlightedText = match[1]
    const parts = input.split(regex) // 分割原字符串，移除匹配的部分

    // parts 数组中，index 为 0 的是前面的文本，index 为 2 的是后面的文本
    return [parts[0], highlightedText, parts[2]].map(part => part.trim())
  }
}

