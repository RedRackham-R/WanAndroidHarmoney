import { IHotKey } from '../net/wanAPI/response/IHotKey'
import wanHttpClient from '../net/wanAPI/WanHttpClient'

interface SearchResult {
  datas: Array<IHotKey>
}

export class SearchViewModel {
  async fetchHotKeyAsync(): Promise<SearchResult> {
    try {
      const response = await wanHttpClient.hotKey()
      return new Promise<SearchResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          resolve({
            datas: response.data.data
          })
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<SearchResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}


const searchViewModel = new SearchViewModel()

export default searchViewModel as SearchViewModel