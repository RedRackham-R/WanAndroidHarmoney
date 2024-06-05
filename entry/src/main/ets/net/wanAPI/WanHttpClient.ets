import List from '@ohos.util.List'

import { AxiosClientResponseInterceptor } from '../base/interceptors/AxiosClientResponseInterceptor'
import { AxiosClientRequestInterceptor } from '../base/interceptors/AxiosClientRequestInterceptor'
import { ConfigurationAxiosClient } from '../base/configuration/ConfigurationAxiosClient'
import { BaseAxiosDelegate } from '../base/BaseAxiosDelegate'
import { AxiosResponse } from '@ohos/axios'
import { IWanCommonResponse } from './response/IWanCommonResponse'
import { IWanCommonListData } from './response/IWanCommonListData'
import { IArticle } from './response/IArticle'
import { IBanner } from './response/IBanner'
import { ILoginRegist } from './response/ILoginRegist'
import http from '@ohos.net.http'
import { IUserInfo } from './response/IUserInfo'
import { WanRequestInterceptor } from './interceptors/WanRequestInterceptor'
import { ICoinListInfo } from './response/ICoinListInfo'
import { IRankInfo } from './response/IRankInfo'
import { IHotKey } from './response/IHotKey'
import { HttpRequestLoggerInterceptor } from './interceptors/HttpRequestLoggerInterceptor'
import { HttpResponseLoggerInterceptor } from './interceptors/HttpResponseLoggerInterceptor'
import { ICollectedUrl } from './response/ICollectedUrl'
import { IShareArticleList } from './response/IShareArticleList'


interface LoginRegistResult {
  response: IWanCommonResponse<ILoginRegist>,
  cookies: string[]
}

/**
 * 玩Android http网络请求客户端
 */
export class WanHttpClient extends BaseAxiosDelegate {
  static readonly BASE_URL = "https://www.wanandroid.com"
  static readonly TIME_OUT = 5000

  configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
    let interceptors = new List()
    //添加拦截器
    interceptors.add(new WanRequestInterceptor())
    interceptors.add(new HttpRequestLoggerInterceptor())
    return interceptors
  }

  configurationResponseInterceptor(): List<AxiosClientResponseInterceptor> {
    let interceptors = new List()
    //添加拦截器
    interceptors.add(new HttpResponseLoggerInterceptor())
    return interceptors
  }


  configurationAxios(): ConfigurationAxiosClient {
    const config: ConfigurationAxiosClient = {
      baseURL: WanHttpClient.BASE_URL,
      timeout: WanHttpClient.TIME_OUT,
    }
    return config
  }


  /**
   * banner内容
   * https://www.wanandroid.com/banner/json
   * @returns
   */
  public banner(): Promise<AxiosResponse<IWanCommonResponse<Array<IBanner>>>> {
    return this.getRequest("/banner/json")
  }


  /**
   * 首页置顶文章
   * https://www.wanandroid.com/article/top/json
   * @returns
   */
  public topArticle(): Promise<AxiosResponse<IWanCommonResponse<Array<IArticle>>>> {
    return this.getRequest("/article/top/json")
  }

  /**
   * 首页文章列表
   * https://www.wanandroid.com/article/list/0/json
   * @param index 下标，从0开始
   * @returns
   */
  public articleList(index: number): Promise<AxiosResponse<IWanCommonResponse<IWanCommonListData<IArticle>>>> {
    return this.getRequest("/article/list/" + index + "/json")
  }


  public async login(username: string, password: string): Promise<LoginRegistResult> {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
        WanHttpClient.BASE_URL + "/user/login?username=" + username + "&password=" + password,
        {
          method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
          expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
          usingCache: false, // 可选，默认为true
          priority: 1, // 可选，默认为1
          connectTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
          readTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
        })

      let wanpesponse: IWanCommonResponse<ILoginRegist> = JSON.parse(response.result as string)
      let rawCookieString = response.cookies
      let cookies = rawCookieString.split("\r\n").map(cookieStr => {
        const parts = cookieStr.split("\t")
        // 格式化为: "CookieName=CookieValue Domain=DomainValue Expires=..."
        const domain = parts[0].replace("#HttpOnly_", "")
        const secure = parts[3] === 'TRUE' ? 'Secure ' : ''
        const httpOnly = parts[0].startsWith("#HttpOnly_") ? 'HttpOnly ' : ''
        const expiration = `Expires=${new Date(parseInt(parts[4]) * 1000).toUTCString()} `
        const path = `Path=${parts[2]} `
        // 注意: Expires部分可能需要根据实际情况调整
        return `${parts[5]}=${parts[6]} ${path}${secure}${httpOnly}${expiration}Domain=${domain}`
      })
      return new Promise<LoginRegistResult>((resolve, _reject) => {
        resolve({
          response: wanpesponse,
          cookies: cookies
        })
      })
    } catch (err) {
      return new Promise<LoginRegistResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    } finally {
      httpRequest.destroy()
    }
  }


  public async regist(username: string, password: string, repassword: string,): Promise<LoginRegistResult> {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp()
    try {
      const response = await httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
        WanHttpClient.BASE_URL + "/user/register?username=" + username + "&password=" + password + "&repassword=" + repassword,
        {
          method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
          expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
          usingCache: false, // 可选，默认为true
          priority: 1, // 可选，默认为1
          connectTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
          readTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
        })

      let wanpesponse: IWanCommonResponse<ILoginRegist> = JSON.parse(response.result as string)
      let rawCookieString = response.cookies
      let cookies = rawCookieString.split("\r\n").map(cookieStr => {
        const parts = cookieStr.split("\t")
        // 格式化为: "CookieName=CookieValue Domain=DomainValue Expires=..."
        const domain = parts[0].replace("#HttpOnly_", "")
        const secure = parts[3] === 'TRUE' ? 'Secure ' : ''
        const httpOnly = parts[0].startsWith("#HttpOnly_") ? 'HttpOnly ' : ''
        const expiration = `Expires=${new Date(parseInt(parts[4]) * 1000).toUTCString()} `
        const path = `Path=${parts[2]} `
        // 注意: Expires部分可能需要根据实际情况调整
        return `${parts[5]}=${parts[6]} ${path}${secure}${httpOnly}${expiration}Domain=${domain}`
      })
      return new Promise<LoginRegistResult>((resolve, _reject) => {
        resolve({
          response: wanpesponse,
          cookies: cookies
        })
      })
    } catch (err) {
      return new Promise<LoginRegistResult>((_resolve, reject) => {
        reject("获取数据失败，请检查网络！ " + err)
      })
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 登录 TODO 目前Axios框架有bug无法从header获取多个set-cookie，所以改用原生的请求实现
   * @param username
   * @param password
   * @param success
   * @param failure
   */

  public _login(username: string, password: string, success: (response: IWanCommonResponse<ILoginRegist>, cookies: string[]) => void, failure: (err) => void) {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp()

    httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
      WanHttpClient.BASE_URL + "/user/login?username=" + username + "&password=" + password,
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: false, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
        readTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
      }, (err, data) => {
      if (!err) {

        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy()
        let wanpesponse: IWanCommonResponse<ILoginRegist> = JSON.parse(data.result as string)
        let rawCookieString = data.cookies
        let cookies = rawCookieString.split("\r\n").map(cookieStr => {
          const parts = cookieStr.split("\t")
          // 格式化为: "CookieName=CookieValue Domain=DomainValue Expires=..."
          const domain = parts[0].replace("#HttpOnly_", "")
          const secure = parts[3] === 'TRUE' ? 'Secure ' : ''
          const httpOnly = parts[0].startsWith("#HttpOnly_") ? 'HttpOnly ' : ''
          const expiration = `Expires=${new Date(parseInt(parts[4]) * 1000).toUTCString()} `
          const path = `Path=${parts[2]} `
          // 注意: Expires部分可能需要根据实际情况调整
          return `${parts[5]}=${parts[6]} ${path}${secure}${httpOnly}${expiration}Domain=${domain}`
        })

        success(wanpesponse, cookies)
      } else {
        // 当该请求使用完毕时，调用destroy方法主动销毁。
        httpRequest.destroy()
        failure(err)
      }
    })
  }


  /**
   * 注册 TODO 目前Axios框架有bug无法从header获取多个set-cookie，所以改用原生的请求实现
   * https://www.wanandroid.com/user/register
   * @param username
   * @param password
   * @param repassword
   * @param success
   * @param failure
   */
  public _regist(username: string, password: string, repassword: string, success: (response: IWanCommonResponse<ILoginRegist>, cookies: string[]) => void, failure: (err) => void) {

    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp()

    httpRequest.request(// 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
      WanHttpClient.BASE_URL + "/user/register?username=" + username + "&password=" + password + "&repassword=" + repassword,
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: false, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
        readTimeout: WanHttpClient.TIME_OUT, // 可选，默认为60000ms
      }, (err, data) => {
      if (!err) {
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy()
        let wanpesponse: IWanCommonResponse<ILoginRegist> = JSON.parse(data.result as string)
        //处理cookie
        let rawCookieString = data.cookies
        let cookies = rawCookieString.split("\r\n").map(cookieStr => {
          const parts = cookieStr.split("\t")
          // 格式化为: "CookieName=CookieValue Domain=DomainValue Expires=..."
          const domain = parts[0].replace("#HttpOnly_", "")
          const secure = parts[3] === 'TRUE' ? 'Secure ' : ''
          const httpOnly = parts[0].startsWith("#HttpOnly_") ? 'HttpOnly ' : ''
          const expiration = `Expires=${new Date(parseInt(parts[4]) * 1000).toUTCString()} `
          const path = `Path=${parts[2]} `
          // 注意: Expires部分可能需要根据实际情况调整
          return `${parts[5]}=${parts[6]} ${path}${secure}${httpOnly}${expiration}Domain=${domain}`
        })
        success(wanpesponse, cookies)
      } else {
        // 当该请求使用完毕时，调用destroy方法主动销毁。
        httpRequest.destroy()
        failure(err)
      }
    })
  }


  /**
   *获取个人积分，需要登录后访问
   * https://www.wanandroid.com/lg/coin/userinfo/json
   * @returns
   */
  public fetchUserInfo(): Promise<AxiosResponse<IWanCommonResponse<IUserInfo>>> {
    return this.getRequest("/user/lg/userinfo/json")
  }

  /**
   * 获取个人积分获取列表，需要登录后访问
   * https://www.wanandroid.com//lg/coin/list/1/json
   * @param index 下标从1开始
   * @returns
   */
  public coinList(index: number): Promise<AxiosResponse<IWanCommonResponse<IWanCommonListData<ICoinListInfo>>>> {
    return this.getRequest("/lg/coin/list/" + index + "/json")
  }

  /**
   * 积分排行榜接口
   * https://www.wanandroid.com/coin/rank/1/json
   * @param index 下标从1开始
   * @returns
   */
  public rankList(index: number): Promise<AxiosResponse<IWanCommonResponse<IWanCommonListData<IRankInfo>>>> {
    return this.getRequest("/coin/rank/" + index + "/json")
  }


  /**
   * 收藏站内文章
   * https://www.wanandroid.com/lg/collect/{id}/json
   * @param id 文章id
   * @returns
   */
  public collect(id: number): Promise<AxiosResponse<IWanCommonResponse<any>>> {
    return this.postRequest("/lg/collect/" + id + "/json")
  }

  /**
   * 取消收藏站内文章
   * https://www.wanandroid.com/lg/uncollect_originId/{id}/json
   * @param id 文章id
   * @returns
   */
  public uncollect(id: number): Promise<AxiosResponse<IWanCommonResponse<any>>> {
    return this.postRequest("/lg/uncollect_originId/" + id + "/json")
  }

  /**
   * 搜索热词
   * https://www.wanandroid.com//hotkey/json
   * @returns
   * */
  public hotKey(): Promise<AxiosResponse<IWanCommonResponse<Array<IHotKey>>>> {
    return this.getRequest("/hotkey/json")
  }

  /**
   * 搜索
   * https://www.wanandroid.com/article/query/{index}/json?k={words}
   * @param words 关键字
   * @param index 页码 从0开始
   * @returns
   */
  public query(words: string, index: number): Promise<AxiosResponse<IWanCommonResponse<IWanCommonListData<IArticle>>>> {
    return this.postRequest("/article/query/" + index + "/json",
      {},
      {
        headers: {
          "Content-Type": 'text/plain; charset=UTF-8',
        },
        params: {
          k: words
        }
      }
    )
  }

  /**
   * 搜藏文章列表
   * https://www.wanandroid.com/lg/collect/list/{index}/json
   * @param index 页码 从0开始
   */
  public collectList(index: number): Promise<AxiosResponse<IWanCommonResponse<IWanCommonListData<IArticle>>>> {
    return this.getRequest("/lg/collect/list/" + index + "/json")
  }

  /**
   * 收藏网址列表
   * https://www.wanandroid.com/lg/collect/usertools/json
   * @returns
   */
  public collectUrlList(): Promise<AxiosResponse<IWanCommonResponse<Array<ICollectedUrl>>>> {
    return this.getRequest("/lg/collect/usertools/json")
  }

  /**
   * 取消收藏网站
   * https://www.wanandroid.com/lg/collect/deletetool/json
   * @param id 网址id
   */
  public uncollectUrl(id: number): Promise<AxiosResponse<IWanCommonResponse<any>>> {
    return this.postRequest(
      "/lg/collect/deletetool/json",
      {},
      {
        params: {
          id: id
        }
      },
    )
  }

  /**
   * 自己的分享的文章列表
   * https://wanandroid.com/user/lg/private_articles/{index}/json
   * @param index 页码，从1开始
   */
  public sharedArticleList(index: number): Promise<AxiosResponse<IWanCommonResponse<IShareArticleList>>> {
    return this.getRequest(
      "/user/lg/private_articles/" + index + "/json"
    )
  }

  /**
   * 删除自己分享的文章
   * https://wanandroid.com/lg/user_article/delete/{id}/json
   * 请求:POST
   * 参数：文章id，拼接在链接上
   * @returns
   */
  public deleteSharedArticle(id: number): Promise<AxiosResponse<IWanCommonResponse<any>>> {
    return this.postRequest(
      "/lg/user_article/delete/" + id + "/json"
    )
  }

  /**
   * 分享文章
   * https://www.wanandroid.com/lg/user_article/add/json
   * 请求：POST参数：
   * title:
   * link
   */
  public shareArticle(title: string, link: string): Promise<AxiosResponse<IWanCommonResponse<any>>> {
    return this.postRequest(
      "/lg/user_article/add/json",
      {},
      {
        params: {
          title: title,
          link: link
        }
      },
    )
  }

  /**
   * https://www.wanandroid.com/lg/collect/addtool/json
   * 收藏网址
   */
  public collectUrl(name: string, link: string): Promise<AxiosResponse<IWanCommonResponse<ICollectedUrl>>> {
    return this.postRequest(
      "lg/collect/addtool/json",
      {},
      {
        params: {
          name: name,
          link: link
        }
      },
    )
  }
}

const wanHttpClient = new WanHttpClient()

export default wanHttpClient
