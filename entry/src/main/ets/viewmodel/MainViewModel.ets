import { TabItem } from '../pojo/TabItem'

export class MainViewModel {
  pages = []
  private
  tabTitles = [
    new TabItem(0, "文章"),
    new TabItem(1, "我的"),
  ]
}

//模块化导出mainviewmodel，只提供值。
const mainViewModel = new MainViewModel()

export default mainViewModel as MainViewModel