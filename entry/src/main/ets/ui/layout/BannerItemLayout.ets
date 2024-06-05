import { IBanner } from '../../net/wanAPI/response/IBanner'

/**
 * bannerUI页面
 */
@Component
export struct BannerItemLayout {
  @State private banners: Array<IBanner> = []
  private swiperController: SwiperController = new SwiperController()
  onItemClick: (item: IBanner) => void

  build() {
    Swiper(this.swiperController) {
      ForEach(this.banners, (value: IBanner) => {
        this.bannerContentComponent(value)
      })
    }
    .indicatorStyle({
      bottom: 0,
      right: 0,
    })
    .cachedCount(this.banners.length)
    .index(0)
    .autoPlay(true)
    .interval(4000)
    .indicator(true)
    .loop(true)
    .duration(1000)
    .itemSpace(0)
    .curve(Curve.Linear)
    .onChange((index: number) => {
      console.info(index.toString())
    })
  }

  @Builder
  bannerContentComponent(item: IBanner) {
    Stack({ alignContent: Alignment.Center }) {
      Image(item.imagePath)// 直接加载网络地址，请填写一个具体的网络图片地址
        .alt($r('app.media.pic_image_placeholder'))// 使用alt，在网络图片加载成功前使用占位图
        .objectFit(ImageFit.Fill)
        .width('100%')
        .height('100%')
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Text(`${item.title}`)
          .fontColor(Color.White)
      }
      .position({ x: 0, y: 200 })
      .height(40).width('100%')
      .backgroundColor('#44000000')
    }
    .onClick(() => {
      this.onItemClick(item)
    })
    .width('100%')
    .height(240)
  }
}