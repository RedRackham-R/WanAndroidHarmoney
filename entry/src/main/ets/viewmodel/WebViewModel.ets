import { ICollectedUrl } from '../net/wanAPI/response/ICollectedUrl';
import wanHttpClient from '../net/wanAPI/WanHttpClient';


export class WebViewModel {
  async loadUrlListAsync(): Promise<Array<ICollectedUrl>> {
    try {
      const response = await wanHttpClient.collectUrlList()
      return new Promise<Array<ICollectedUrl>>((resolve, reject) => {
        if (response.data.errorCode === 0) {
          response.data.data.forEach((item: ICollectedUrl) => {
            item.extIsCollecting = false
          })

          resolve(response.data.data)
        } else {
          reject(response.data.errorMsg)
        }
      })
    } catch (err) {
      return new Promise<Array<ICollectedUrl>>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

const webViewModel = new WebViewModel()

export default webViewModel as WebViewModel