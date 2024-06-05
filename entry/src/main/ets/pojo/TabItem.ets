/**
 * tab item数据类
 */
export class TabItem {
  index: number
  title: string
  constructor(
    index: number,
    title: string,
  ) {
    this.index = index
    this.title = title
  }
}