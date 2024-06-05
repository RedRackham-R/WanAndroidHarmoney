/**
 * 颜色渐变控件
 */
@Component
export struct GradientColorWeight {
  @State bgColors: Array<any> = [['#4a148c', 0.1], ['#2a36b1', 1.0]]
  private progress = 0.000
  private intervalId: number = null

  aboutToAppear() {
    //获取匀速插值
    let bgColor = Number.parseInt('2a36b1', 16)
    const colors = [
      ColorDelegate.fromHexString("#4a148c"),
      ColorDelegate.fromHexString("#1a237e"),
      ColorDelegate.fromHexString("#0d5302"),
      ColorDelegate.fromHexString("#4a148c"),
    ]

    const colorTween = new ColorTween(colors)

    this.intervalId = setInterval(() => {
      const middleColor = colorTween.getColor(this.progress)
      this.progress += 0.002
      if (this.progress > 1.000) {
        this.progress = 0.000
      }

      this.bgColors = [[middleColor.toHexString(), 0.1], [bgColor, 1.0]]
    }, 16)
  }

  aboutToDisappear() {
    clearInterval(this.intervalId)
  }

  build() {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 0,
        colors: this.bgColors
      })
  }
}


export class ColorDelegate {
  constructor(public r: number, public g: number, public b: number) {
  }

  static fromHexString(hexString: string): ColorDelegate {
    const r = parseInt(hexString.slice(1, 3), 16);
    const g = parseInt(hexString.slice(3, 5), 16);
    const b = parseInt(hexString.slice(5, 7), 16);
    return new ColorDelegate(r, g, b);
  }

  toHexString(): string {
    return `#${this.r.toString(16).padStart(2, '0')}${this.g.toString(16).padStart(2, '0')}${this.b.toString(16)
      .padStart(2, '0')}`;
  }
}

export class ColorTween {
  private colors: ColorDelegate[];

  constructor(colors: ColorDelegate[]) {
    if (colors.length < 2) {
      throw new Error("CustomColorTween requires at least two colors.");
    }
    this.colors = colors;
  }

  getColor(progress: number): ColorDelegate {
    const segment = 1 / (this.colors.length - 1);
    const index = Math.min(Math.floor(progress / segment), this.colors.length - 2);
    const localT = (progress - segment * index) / segment;
    return this.lerpColor(this.colors[index], this.colors[index + 1], localT);
  }

  private lerpColor(start: ColorDelegate, end: ColorDelegate, t: number): ColorDelegate {
    const r = this.lerp(start.r, end.r, t);
    const g = this.lerp(start.g, end.g, t);
    const b = this.lerp(start.b, end.b, t);
    return new ColorDelegate(r, g, b);
  }

  private lerp(start: number, end: number, t: number): number {
    return Math.round(start + (end - start) * t);
  }
}