import Curves from '@ohos.curves'

/**
 * 海浪动画控件
 */
@Component
export struct WaveAnimWeight {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private PI2: number = 2 * Math.PI
  private progress: number = 0
  private speed: number = 0.5
  private waveHeightPercent: number = 0.8
  private waveColor: string | CanvasGradient | CanvasPattern = "#55ffffff"
  private waveOffset: number = 0.0
  private intervalId: number = null

  /**
   * 波浪控件
   * @param speed 波浪速度。取值：0-1，默认：0.5
   * @param waveHeight 波浪高度百分比。取值：0-1,默认：0.8
   * @param waveColor 波浪颜色。默认半透明白色：#66ffffff
   * @param waveOffset 波浪偏差值。起始位置。默认：0.0
   */
  constructor(
    speed: number = 0.5,
    waveHeightPercent: number = 0.8,
    waveColor: string | CanvasGradient | CanvasPattern = "#66ffffff",
    waveOffset: number = 0.0
  ) {
    super()
    this.speed = speed
    this.waveHeightPercent = waveHeightPercent
    this.waveColor = waveColor
    this.waveOffset = waveOffset
  }

  aboutToDisappear() {
    clearInterval(this.intervalId)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .onReady(() => {
          //获取匀速插值
          let curve = Curves.initCurve(Curve.Linear)
          this.intervalId = setInterval(() => {
            //计算插值
            let interpolate = curve.interpolate(this.progress)
            this.progress += 0.01 * this.speed
            if (this.progress > 1) {
              this.progress = 0
            }
            this.drawWave(this.PI2 * interpolate + this.waveOffset)
          }, 16)
        })
    }
    .width('100%')
    .height('100%')
  }

  private drawWave(value: number) {
    let width = this.context.width
    let height = this.context.height

    this.context.lineWidth = 6
    //使用正弦函数获取到三个点坐标当前比例 0 --> π/2 --> π --> π+π/2 --> 2π正弦函数返回从0 --> 1--> 0 --> -1 --> 0
    let y1 = Math.sin(value)
    let y2 = Math.sin(value + Math.PI / 2)
    let y3 = Math.sin(value + Math.PI)

    let startPointY = height * (0.5 + 0.5 * this.waveHeightPercent * y1)
    let controlPointY = height * (0.5 + 0.5 * this.waveHeightPercent * y2)
    let endPointY = height * (0.5 + 0.5 * this.waveHeightPercent * y3)

    this.context.beginPath()
    this.context.clearRect(0, 0, width, height)
    this.context.moveTo(width * 0, startPointY);
    this.context.bezierCurveTo(width * 0, startPointY, width * 0.5, controlPointY, width, endPointY);
    this.context.lineTo(width, height);
    this.context.lineTo(0, height);
    this.context.closePath()
    this.context.fillStyle = this.waveColor

    this.context.fill()
  }
}