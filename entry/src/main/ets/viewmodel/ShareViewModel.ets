import { IArticle } from '../net/wanAPI/response/IArticle'
import wanHttpClient from '../net/wanAPI/WanHttpClient'


interface deleteSharedArticleResult {
  id: number
}

interface SharedArticleListResult {
  over: boolean,
  datas: Array<IArticle>
}

export class ShareViewModel {
  private index: number = 1

  async shareArticleAsync(
    title: string,
    link: string,
  ): Promise<void> {
    try {
      const response = await wanHttpClient.shareArticle(title, link)
      return new Promise<void>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          resolve()
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<void>((_resolve, reject) => {
        reject("请求异常，请检查网络！ " + err)
      })
    }
  }


  async deleteSharedArticleAsync(
    id: number
  ): Promise<deleteSharedArticleResult> {
    try {
      const response = await wanHttpClient.deleteSharedArticle(id)
      return new Promise<deleteSharedArticleResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          resolve({ id: id })
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<deleteSharedArticleResult>((_resolve, reject) => {
        reject("请求异常，请检查网络！ " + err)
      })
    }
  }


  async fetchSharedArticleListAsync(
    isRefresh: boolean,
  ): Promise<SharedArticleListResult> {
    if (isRefresh) {
      this.index = 1
    }

    try {
      const response = await wanHttpClient.sharedArticleList(this.index)

      return new Promise<SharedArticleListResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          if (!response.data.data.shareArticles.over) {
            this.index++
          }
          //收藏列表没有collect参数，这边需要单独添加下
          response.data.data.shareArticles.datas.forEach((article: IArticle) => {
            article.collect = true
          })
          resolve({
            over: response.data.data.shareArticles.over,
            datas: response.data.data.shareArticles.datas
          })
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<SharedArticleListResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

const shareViewModel = new ShareViewModel()

export default shareViewModel as ShareViewModel