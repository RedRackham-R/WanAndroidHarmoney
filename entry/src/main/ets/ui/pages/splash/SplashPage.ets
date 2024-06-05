import { GradientColorWeight } from '../../weight/GradientColorWeight'
import { WaveAnimWeight } from '../../weight/WaveAnimWeight'
import { RouterDelegate } from '../../../router/RouterDelegate'
import globalVM_WanDB from '../../../global/viewmodel/GlobalWanDBViewModel'
import GlobalWanCache from '../../../global/GlobalWanCache'
import globalVM_Setting from '../../../global/viewmodel/GlobalSettingViewModel'
import Animator, { AnimatorResult } from '@ohos.animator'

@Entry
@Component
struct SplashPage {
  private alphaAnimator: AnimatorResult = null
  @State logoAlpha: number = 0

  private animationOn() {
    this.alphaAnimator = Animator.create({
      duration: 5000,
      easing: "ease",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: 0,
      end: 1
    })

    this.alphaAnimator.onframe = (value: number) => {
      this.logoAlpha = value
    }

    this.alphaAnimator.play()
  }

  aboutToAppear() {
    this.init(getContext(this))
  }

  aboutToDisappear() {
    this.alphaAnimator = null
  }

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

      Column() {
        Column() {
          Text('WanAndroid on')
            .fontWeight(FontWeight.Medium)
            .fontSize(46)
            .fontColor(Color.White)
          Image($r('app.media.pic_harmoney_logo_new'))
            .height(140)
            .width(320)
            .objectFit(ImageFit.Auto)
        }
        .opacity(this.logoAlpha)
        .margin({
          bottom: 86
        })
        .onAppear(() => {
          this.animationOn()
        })

        Text('进  入')
          .margin({
            bottom: 200
          })
          .textAlign(TextAlign.Center)
          .width('80%')
          .padding({
            top: 12,
            bottom: 12,
          })
          .fontColor(Color.White)
          .border({ color: Color.White, radius: 20, width: 2 })
          .onClick(() => {
            RouterDelegate.toMainPage()
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }

  private async init(context: Context) {


    //初始化数据库
    await globalVM_WanDB.init(context)

    //初始化键值对存储preferences
    await GlobalWanCache.init(context)

    //初始化设置
    await globalVM_Setting.init()

  }
}