import globalVM_Setting from '../global/viewmodel/GlobalSettingViewModel'
import { IArticle } from '../net/wanAPI/response/IArticle'
import wanHttpClient from '../net/wanAPI/WanHttpClient'

export interface HomeDataResult {
  over: boolean,
  datas: Array<any>,
}

export class HomeViewModel {
  private pageIndex: number = 0

  async loadDataAsync(
    isRefresh: boolean,
  ): Promise<HomeDataResult> {
    try {
      if (isRefresh) {
        this.pageIndex = 0
        //是否添加topArticle数据
        const isShowTopArticle = await globalVM_Setting.isShowTopArticle()
        const responses = await Promise.all([wanHttpClient.banner(), wanHttpClient.topArticle(), wanHttpClient.articleList(this.pageIndex)])
        //返回响应
        return new Promise<HomeDataResult>((resolve, reject) => {
          const bannerResp = responses[0]
          const topArticleResp = responses[1]
          const articlesResp = responses[2]
          const retList = Array<any>()

          //处理banner 如果banner响应失败无需处理，响应成功
          if (bannerResp.data.errorCode === 0) {
            //添加banner
            retList.push(bannerResp.data.data)
          }

          //处理top article如果article接口返回失败则视为请求失败
          if (topArticleResp.data.errorCode !== 0) {
            reject(topArticleResp.data.errorMsg)
            return
          }

          //处理article 如果article接口返回失败则视为请求失败
          if (articlesResp.data.errorCode !== 0) {
            reject(topArticleResp.data.errorMsg)
            return
          }

          //添加topArticle
          if (isShowTopArticle) {
            topArticleResp.data.data.forEach((article: IArticle) => {
              article.extIsCollecting = false
              retList.push(article)
            })
          }

          //添加article数据
          articlesResp.data.data.datas.forEach((article: IArticle) => {
            article.extIsCollecting = false
            retList.push(article)
          })

          //增加index
          if (!articlesResp.data.data.over) {
            this.pageIndex += 1
          }

          //返回响应
          resolve({
            over: articlesResp.data.data.over,
            datas: retList
          })
        })
      } else {
        const response = await wanHttpClient.articleList(this.pageIndex)
        //返回响应
        return new Promise<HomeDataResult>((resolve, reject) => {
          if (response.data.errorCode === 0) {
            //增加index
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
      }
    } catch (err) {
      return new Promise<HomeDataResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    }
  }
}

const homeViewModel = new HomeViewModel()

export default homeViewModel