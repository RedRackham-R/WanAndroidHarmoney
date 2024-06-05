import { IArticle } from '../net/wanAPI/response/IArticle'
import { ICollectedUrl } from '../net/wanAPI/response/ICollectedUrl'
import wanHttpClient from '../net/wanAPI/WanHttpClient'


export interface CollectedURLDataResult {
  datas: Array<ICollectedUrl>
}

export interface CollectedArticleDataResult {
  over: boolean,
  datas: Array<IArticle>
}

export class CollectedListViewModel {
  private index: number = 0

  async loadUrlListAsync(): Promise<CollectedURLDataResult> {
    try {
      const response = await wanHttpClient.collectUrlList()
      return new Promise<CollectedURLDataResult>((resolve, reject) => {
        if (response.data.errorCode === 0){
          response.data.data.forEach((item: ICollectedUrl) => {
            item.extIsCollecting = false
          })
          resolve({
            datas: response.data.data
          })
        }else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<CollectedURLDataResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }


  async loadArticleListAsync(
    isRefresh: boolean,
  ): Promise<CollectedArticleDataResult> {
    if (isRefresh) {
      this.index = 0
    }
    try {
      const response = await wanHttpClient.collectList(this.index)
      return new Promise<CollectedArticleDataResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          if (!response.data.data.over) {
            this.index++
          }
          //收藏列表没有collect参数，这边需要单独添加下
          response.data.data.datas.forEach((article: IArticle) => {
            article.collect = true
          })
          resolve({
            over: response.data.data.over,
            datas: response.data.data.datas
          })
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<CollectedArticleDataResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

const collectedListViewModel = new CollectedListViewModel()

export default collectedListViewModel