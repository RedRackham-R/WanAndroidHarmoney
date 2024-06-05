/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { PullToRefreshConfigurator } from './PullToRefreshConfigurator'
import { PullToRefreshController } from './PullToRefreshController';

const IS_FREE = 0;
const IS_PULL_DOWN_1 = 11;
const IS_PULL_DOWN_2 = 12;
const IS_REFRESHING = 2;
const IS_REFRESHED = 3;
const IS_PULL_UP_1 = 41;
const IS_PULL_UP_2 = 42;
const IS_LOADING = 5;


@Component
export struct PullToRefresh {
  @Link data: any;
  @BuilderParam customList: () => void;
  refreshConfigurator?: PullToRefreshConfigurator;
  @State @Watch('onRefreshLoadMoreUpdate') controller: PullToRefreshController = new PullToRefreshController()
  mWidth?: Length = '100%';
  mHeight?: Length = '100%';
  onRefresh?: () => Promise<string> = () => {
    return new Promise<string>((resolve, _reject) => {
      setTimeout(() => {
        resolve('刷新失败');
      }, 1000);
    });
  };
  onLoadMore?: () => Promise<string> = () => {
    return new Promise<string>((resolve, _reject) => {
      setTimeout(() => {
        resolve('');
      }, 1000);
    });
  };
  // 自定义下拉动画
  @BuilderParam customRefresh?: () => void;
  onAnimPullDown?: (value?: number, width?: number, height?: number) => void;
  onAnimRefreshing?: (value?: number, width?: number, height?: number) => void;
  // 自定义上拉动画
  @BuilderParam customLoad?: () => void;
  onAnimPullUp?: (value?: number, width?: number, height?: number) => void;
  onAnimLoading?: (value?: number, width?: number, height?: number) => void;
  //-----------------------------以下为组件内自用属性-----------------------------//
  @State private mHeightNumber?: number = 0;
  @State private trYTop?: number = 0;
  @State private trYBottom?: number = 0;
  @State private state?: number = IS_FREE;
  @State private refreshText?: string = '';
  @State private loadText?: string = '';
  @State private angle1?: number = 0;
  @State private angle2?: number = 0;
  private mWidthNumber?: number = 0;
  private touchYOld?: number = 0;
  private touchYNew?: number = 0;
  private listOffsetOld?: number = 0;
  private listOffsetNew?: number = 0;
  private canvasSetting?: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRefresh?: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSetting);
  private value?: number = 0;
  private timer?: number;
  private refreshRingOx?: number = 0;
  private refreshRingOy?: number = 0;
  private refreshRingRadius?: number = 0;
  private refreshPoint1x?: number = 0;
  private refreshPoint1y?: number = 0;
  private refreshPoint2x?: number = 0;
  private refreshPoint2y?: number = 0;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Up | PanDirection.Down })
  //记录最后一次刷新偏移量
  private lastedRefreshOffset: number = 0.0

  aboutToAppear() {
    if (!this.refreshConfigurator) {
      this.refreshConfigurator = new PullToRefreshConfigurator();
    }
  }

  private initCanvas(): void {
    if (this.refreshRingOx == 0) {
      this.canvasRefresh.strokeStyle = this.refreshConfigurator.getRefreshColor();
      this.canvasRefresh.fillStyle = this.refreshConfigurator.getRefreshColor();
      this.canvasRefresh.lineWidth = this.refreshConfigurator.getRefreshHeight() / 60 + 1;
      this.refreshRingOx = this.refreshConfigurator.getRefreshWidth() / 2; // 圆心x坐标
      this.refreshRingOy = this.refreshConfigurator.getRefreshHeight() / 2; // 圆心y坐标
      this.refreshRingRadius = this.refreshConfigurator.getRefreshHeight() / 4; // 半径
      this.refreshPoint1x = this.refreshRingOx + this.refreshRingRadius * Math.cos(Math.PI * 150 / 180);
      this.refreshPoint1y = this.refreshRingOy + this.refreshRingRadius * Math.sin(Math.PI * 150 / 180);
      this.refreshPoint2x = this.refreshRingOx + this.refreshRingRadius * Math.cos(Math.PI * -30 / 180);
      this.refreshPoint2y = this.refreshRingOy + this.refreshRingRadius * Math.sin(Math.PI * -30 / 180);
    }
  }

  build() {
    Column() {
      // 下拉刷新动画部分
      Stack() {
        this.headerUI()
      }
      .width('100%')
      .height(this.trYTop)
      .backgroundColor(this.refreshConfigurator.getRefreshBackgroundColor())

      // 主体列表部分
      Column() {
        this.customList()
      }
      .width('100%')
      .height(this.mHeightNumber - this.trYTop + this.trYBottom)

      // 上拉加载动画部分
      Stack() {
        this.footerUI()
      }
      .width('100%')
      .height(-this.trYBottom)
      .backgroundColor(this.refreshConfigurator.getLoadBackgroundColor())
    }
    .width(this.mWidth === undefined ? '100%' : this.mWidth)
    .height(this.mHeight === undefined ? '100%' : this.mHeight)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.mWidthNumber = Math.round(newValue.width as number);
      this.mHeightNumber = Math.round(newValue.height as number);
    })
    .parallelGesture(
      PanGesture(this.panOption)
        .onActionStart((event: GestureEvent) => {
          this.touchYOld = event.offsetY;
        })
        .onActionUpdate((event: GestureEvent) => {
          this.onActionUpdate(event.offsetY);
        })
        .onActionEnd(() => {
          this.onActionEnd();
        })
    )
  }

  @Builder
  private headerUI() {
    if (this.customRefresh) {
      Column() {
        this.customRefresh()
      }
      .width('100%')
      .height('100%')
    } else {
      Stack() {
        Text(this.refreshText)
          .textAlign(TextAlign.Center)
          .fontColor(this.refreshConfigurator.getRefreshTextColor())
          .fontSize(this.refreshConfigurator.getRefreshTextSize())
        Stack() {
          Canvas(this.canvasRefresh)
            .width('100%')
            .height('100%')
            .onReady(() => {
              this.initCanvas();
            })
            .visibility(this.state == IS_PULL_DOWN_2 ? Visibility.Visible : Visibility.Hidden)
          LoadingProgress()
            .width(this.refreshConfigurator.getRefreshHeight())
            .height(this.refreshConfigurator.getRefreshHeight())
            .color(this.refreshConfigurator.getRefreshColor())
            .visibility(this.state == IS_REFRESHING ? Visibility.Visible : Visibility.Hidden)
        }
        .width(this.refreshConfigurator.getRefreshWidth())
        .height(this.refreshConfigurator.getRefreshHeight())
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private footerUI() {
    if (this.customLoad) {
      Column() {
        this.customLoad()
      }
      .width('100%')
      .height('100%')
    } else {
      Row() {
        Stack() {
          Image($r('app.media.icon_up'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .visibility(this.state == IS_PULL_UP_2 ? Visibility.Visible : Visibility.Hidden)
            .rotate({
              z: 1,
              angle: this.angle1
            })
          Image($r('app.media.icon_load'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .visibility(this.state == IS_LOADING ? Visibility.Visible : Visibility.Hidden)
            .rotate({
              z: 1,
              angle: this.angle2
            })
        }
        .width(this.refreshConfigurator.getLoadImgHeight())
        .height(this.refreshConfigurator.getLoadImgHeight())

        Text(this.loadText)
          .height('100%')
          .textAlign(TextAlign.Center)
          .margin({ left: 8 })
          .fontColor(this.refreshConfigurator.getLoadTextColor())
          .fontSize(this.refreshConfigurator.getLoadTextSize())
      }
      .height('100%')
    }
  }

  private onActionUpdate(offsetY: number): void {
    if (this.state == IS_FREE ||
      this.state == IS_PULL_DOWN_1 || this.state == IS_PULL_DOWN_2 ||
      this.state == IS_PULL_UP_1 || this.state == IS_PULL_UP_2) {
      if (!this.controller.getScroller().currentOffset()) {
        return;
      }
      this.touchYNew = offsetY;

      // 当前手势是否下拉
      let distanceY = this.touchYNew - this.touchYOld;
      let isPullAction = distanceY > 0;

      let currentYOffset = this.controller.getScroller().currentOffset().yOffset
      //解决先上拉加载，再下拉刷新后无法拉动下拉刷新控件的问题 目前这么判断还是有问题，因为滚动列表时，回顶部yOffset会不为0，需要多置顶一次才为0
      if ((this.state == IS_FREE && (currentYOffset === 0 || this.lastedRefreshOffset === currentYOffset) && isPullAction) || // 处于自由状态且列表处于顶部位置 并且 当前手势是下拉手势
        this.state == IS_PULL_DOWN_1 || this.state == IS_PULL_DOWN_2) { // 处于下拉状态中
        if (this.refreshConfigurator.getHasRefresh()) {
          // 获取最新位移距离
          var trY = this.touchYNew - this.touchYOld;
          // 计算当前需要位移的总距离
          this.trYTop = this.getTranslateYOfRefresh(trY);
          if (this.trYTop < this.refreshConfigurator.getRefreshHeight()) {
            this.state = IS_PULL_DOWN_1;
          } else {
            this.state = IS_PULL_DOWN_2;
          }
          // 如果没有自定义刷新动画，就执行内置动画下拉时的逻辑
          if (!this.customRefresh) {
            this.drawRefreshView(this.trYTop / this.refreshConfigurator.getMaxTranslate());
          }
          // 如果有下拉中动画回调，就执行下拉中动画回调
          if (this.onAnimPullDown) {
            this.onAnimPullDown(this.trYTop / this.refreshConfigurator.getMaxTranslate(), this.mWidthNumber, this.trYTop);
          }
        }
      } else if (this.refreshConfigurator.getHasLoadMore()) {
        this.listOffsetNew = this.controller.getScroller().currentOffset().yOffset;
        // 列表处于底部位置且上滑时，2.已上滑时
        if ((this.state == IS_FREE && this.listOffsetOld == this.listOffsetNew && this.listOffsetOld != 0 && this.touchYNew < this.touchYOld) ||
          this.state == IS_PULL_UP_1 || this.state == IS_PULL_UP_2) {
          // 获取最新的位移距离
          var trY = this.touchYNew - this.touchYOld;
          // 计算当前需要位移的总距离
          this.trYBottom = this.getTranslateYOfLoadMore(trY);

          if (this.trYBottom > -this.refreshConfigurator.getLoadImgHeight()) {
            this.state = IS_PULL_UP_1;
          } else {
            this.state = IS_PULL_UP_2;
          }
          // 如果没有自定义加载更多动画，就执行内置动画上拉时的逻辑
          if (!this.customLoad) {
            this.drawLoadView(true, -this.trYBottom / this.refreshConfigurator.getMaxTranslate());
          }
          // 如果有上拉中动画回调，就执行上拉中动画回调
          if (this.onAnimPullUp) {
            this.onAnimPullUp(-this.trYBottom / this.refreshConfigurator.getMaxTranslate(), this.mWidthNumber, -this.trYBottom);
          }
        }
        this.listOffsetOld = this.listOffsetNew;
      }
      this.lastedRefreshOffset = currentYOffset
      this.touchYOld = this.touchYNew;
    }
  }

  private onActionEnd(): void {
    if (this.refreshConfigurator.getListIsPlacement()) {
      if (this.state == IS_PULL_DOWN_1 || this.state == IS_PULL_DOWN_2) {
        // 让列表归位到顶部
        this.controller.getScroller().scrollEdge(Edge.Top);
        // 让列表归位到底部
      } else if (this.state == IS_PULL_UP_1 || this.state == IS_PULL_UP_2) {
        this.controller.getScroller().scrollEdge(Edge.Bottom);
      }
    }
    if (this.trYTop > 0) { // 下拉结束
      if (this.state == IS_FREE || this.state == IS_PULL_DOWN_1 || this.state == IS_PULL_DOWN_2) {
        if (this.trYTop / this.refreshConfigurator.getMaxTranslate() < 0.75) {
          this.closeRefresh();
        } else {
          this.state = IS_REFRESHING;
          this.controller.updateRefreshState(true);
          this.trYTop = this.refreshConfigurator.getMaxTranslate() * 0.75;
          clearInterval(this.timer);
          this.timer = setInterval(() => {
            if (this.value >= 1) {
              this.value -= 1;
            } else {
              this.value += 10 / this.refreshConfigurator.getRefreshAnimDuration();
            }
            // 保留3位小数
            this.value = Math.round(this.value * 1000) / 1000;
            // 刷新中动画采用系统组件，因此不用自己去执行动画
            // 如果有刷新中动画回调，就执行刷新中动画回调
            if (this.onAnimRefreshing) {
              this.onAnimRefreshing(this.value, this.mWidthNumber, this.trYTop);
            }
          }, 10);
          this.onRefresh().then((refreshText) => {
            if (refreshText.length == 0) {
              this.closeRefresh();
            } else {
              this.state = IS_REFRESHED;
              if (!this.customRefresh) {
                this.refreshText = refreshText;
              }
              setTimeout(() => {
                this.closeRefresh();
              }, 1000);

            }
          });
        }
      }
    } else if (this.trYBottom < 0) { // 上拉结束
      if (this.state == IS_FREE || this.state == IS_PULL_UP_1 || this.state == IS_PULL_UP_2) {
        if (-this.trYBottom / this.refreshConfigurator.getMaxTranslate() < 0.75) {
          this.closeLoad();
        } else {
          this.state = IS_LOADING;
          this.controller.updateLoadMoreState(true);
          this.trYBottom = -this.refreshConfigurator.getMaxTranslate() * 0.75;
          clearInterval(this.timer);
          this.timer = setInterval(() => {
            if (this.value >= 1) {
              this.value -= 1;
            } else {
              this.value += 0.01;
            }
            // 保留2位小数
            this.value = Math.round(this.value * 100) / 100;
            // 如果没有自定义加载中动画，就执行内置加载中动画
            if (!this.customLoad) {
              this.drawLoadView(false, this.value);
            }
            // 如果有加载中动画回调，就执行加载中动画回调
            if (this.onAnimLoading) {
              this.onAnimLoading(this.value, this.mWidthNumber, -this.trYBottom);
            }
          }, 10);
          this.onLoadMore().then((_loadText) => {
            this.closeLoad();
          });

        }
      }
    } else {
      this.state = IS_FREE;
    }
  }

  private getTranslateYOfRefresh(newTranslateY: number): number {
    var maxTranslateY = this.refreshConfigurator.getMaxTranslate();
    var sensitivity = this.refreshConfigurator.getSensitivity();
    // 阻尼值计算
    if (this.trYTop / maxTranslateY < 0.2) {
      newTranslateY = newTranslateY * 1 * sensitivity;
    } else if (this.trYTop / maxTranslateY < 0.4) {
      newTranslateY = newTranslateY * 0.8 * sensitivity;
    } else if (this.trYTop / maxTranslateY < 0.6) {
      newTranslateY = newTranslateY * 0.6 * sensitivity;
    } else if (this.trYTop / maxTranslateY < 0.8) {
      newTranslateY = newTranslateY * 0.4 * sensitivity;
    } else {
      newTranslateY = newTranslateY * 0.2 * sensitivity;
    }
    // 下拉值计算
    if (this.trYTop + newTranslateY > maxTranslateY) {
      return maxTranslateY;
    } else if (this.trYTop + newTranslateY < 0) {
      return 0;
    } else {
      return this.trYTop + newTranslateY;
    }
  }

  private getTranslateYOfLoadMore(newTranslateY: number): number {
    var maxTranslateY = this.refreshConfigurator.getMaxTranslate();
    var sensitivity = this.refreshConfigurator.getSensitivity();
    // 阻尼值计算
    if (this.trYBottom / maxTranslateY > -0.2) {
      newTranslateY = newTranslateY * 1 * sensitivity;
    } else if (this.trYBottom / maxTranslateY > -0.4) {
      newTranslateY = newTranslateY * 0.8 * sensitivity;
    } else if (this.trYBottom / maxTranslateY > -0.6) {
      newTranslateY = newTranslateY * 0.6 * sensitivity;
    } else if (this.trYBottom / maxTranslateY > -0.8) {
      newTranslateY = newTranslateY * 0.4 * sensitivity;
    } else {
      newTranslateY = newTranslateY * 0.2 * sensitivity;
    }
    // 下拉值计算
    if (this.trYBottom + newTranslateY < -maxTranslateY) {
      return -maxTranslateY;
    } else if (this.trYBottom + newTranslateY > 0) {
      return 0;
    } else {
      return this.trYBottom + newTranslateY;
    }
  }

  private drawRefreshView(value: number): void {
    if (this.trYTop >= this.refreshConfigurator.getRefreshHeight()) {
      this.canvasRefresh.clearRect(0, 0, this.refreshConfigurator.getRefreshWidth(), this.refreshConfigurator.getRefreshHeight());
      // 绘制圆环
      this.canvasRefresh.beginPath();
      this.canvasRefresh.arc(this.refreshRingOx, this.refreshRingOy, this.refreshRingRadius, 0, Math.PI * 2);
      this.canvasRefresh.stroke();
      // 绘制卫星
      value = value > 0.75 ? 0.75 : value;
      this.canvasRefresh.beginPath();
      this.canvasRefresh.arc(
        value * (this.refreshPoint2x - this.refreshPoint1x) + this.refreshPoint1x,
        value * (this.refreshPoint2y - this.refreshPoint1y) + this.refreshPoint1y,
        this.refreshConfigurator.getRefreshHeight() / 20 + 1, 0, Math.PI * 2);
      this.canvasRefresh.fill();
    }
  }

  private drawLoadView(isPullUp: boolean, value: number): void {
    if (isPullUp) {
      if (this.trYBottom <= -this.refreshConfigurator.getLoadImgHeight()) {
        if (value < 0.75) {
          this.angle1 = 0;
          this.loadText = this.refreshConfigurator.getLoadTextPullUp1();
        } else {
          this.angle1 = 180;
          this.loadText = this.refreshConfigurator.getLoadTextPullUp2();
        }
      } else {
        this.loadText = '';
      }
    } else {
      this.angle2 = value * 360;
      this.loadText = this.refreshConfigurator.getLoadTextLoading();
    }
  }

  public closeRefresh(): void {
    clearInterval(this.timer);
    animateTo({ duration: this.refreshConfigurator.getAnimDuration() }, () => {
      this.trYTop = 0;
    });
    setTimeout(() => {
      this.state = IS_FREE;
      this.refreshText = '';
      this.controller.updateRefreshState(false);
    }, this.refreshConfigurator.getAnimDuration());
  }

  public closeLoad(): void {
    clearInterval(this.timer);
    animateTo({ duration: this.refreshConfigurator.getAnimDuration() }, () => {
      this.trYBottom = 0;
    });
    this.state = IS_FREE;
    this.loadText = '';
    this.controller.updateLoadMoreState(false);
  }

  onRefreshLoadMoreUpdate() {
    if (this.controller.isStartedRefresh() && !this.controller.isRefreshing()) {
      this.touchYOld = 0
      this.onActionUpdate(Number.MAX_VALUE)
      this.onActionEnd()
    }


    if (this.controller.isStartedLoadMore() && !this.controller.isLoading()) {
      this.touchYOld = 0
      this.listOffsetOld = this.controller.getScroller().currentOffset().yOffset
      this.listOffsetNew = this.controller.getScroller().currentOffset().yOffset
      this.onActionUpdate(-Number.MAX_VALUE)
      this.onActionEnd()
    }

  }
}