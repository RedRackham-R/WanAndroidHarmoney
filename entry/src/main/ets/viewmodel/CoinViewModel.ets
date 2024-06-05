import { ICoinListInfo } from '../net/wanAPI/response/ICoinListInfo'
import wanHttpClient from '../net/wanAPI/WanHttpClient'

export interface CoinDataResult {
  over: boolean,
  datas: Array<ICoinListInfo>
}

export class CoinViewModel {
  private pageIndex: number = 1

  async loadDataAsync(isRefresh: boolean): Promise<CoinDataResult> {
    if (isRefresh) {
      this.pageIndex = 1
    }
    try {
      const response = await wanHttpClient.coinList(this.pageIndex)
      return new Promise<CoinDataResult>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          if (!response.data.data.over) {
            this.pageIndex += 1
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
      return new Promise<CoinDataResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

const coinViewModel = new CoinViewModel()

export default coinViewModel