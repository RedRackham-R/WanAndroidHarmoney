import { IRankInfo } from '../net/wanAPI/response/IRankInfo'
import wanHttpClient from '../net/wanAPI/WanHttpClient'


interface RankResult {
  over: boolean,
  datas: Array<IRankInfo>
}

export class RankViewModel {
  private pageIndex: number = 1

  async loadDataAsync(
    isRefresh: boolean,
  ): Promise<RankResult> {
    if (isRefresh) {
      this.pageIndex = 1
    }
    try {
      const response = await wanHttpClient.rankList(this.pageIndex)
      return new Promise<RankResult>((resolve, reject) => {
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
      return new Promise<RankResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

//模块化导出mainviewmodel，只提供值。
const rankViewModel = new RankViewModel()

export default rankViewModel as RankViewModel
