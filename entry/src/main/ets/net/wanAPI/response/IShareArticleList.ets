import { IArticle } from './IArticle'
import { IWanCommonListData } from './IWanCommonListData'

export interface IShareArticleList {
  shareArticles: IWanCommonListData<IArticle>
}