import { IArticle } from '../net/wanAPI/response/IArticle'
import wanHttpClient from '../net/wanAPI/WanHttpClient'

interface SearchListResult {
  over: boolean,
  datas: Array<IArticle>
}

export class SearchListViewModel {
  private index: number = 0

  async searchAsync(
    isRefresh: boolean,
    words: string,
  ): Promise<SearchListResult> {
    if (isRefresh) {
      this.index = 0
    }
    try {
      const response = await wanHttpClient.query(words, this.index)
      return new Promise<SearchListResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          if (!response.data.data.over) {
            this.index++
          }
          resolve({
            over: response.data.data.over,
            datas: response.data.data.datas
          })
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<SearchListResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}


const searchListViewModel = new SearchListViewModel()

export default searchListViewModel as SearchListViewModel


