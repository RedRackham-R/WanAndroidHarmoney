import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from '@ohos/axios'
import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './interceptors/AxiosClientRequestInterceptor'
import { AxiosClientResponseInterceptor } from './interceptors/AxiosClientResponseInterceptor'
import { ConfigurationAxiosClient } from './configuration/ConfigurationAxiosClient'


export abstract class BaseAxiosDelegate {
  // 请求库实例
  private readonly instance: AxiosInstance

  constructor() {
    //配置基本信息
    this.instance = axios.create(this.configurationAxios())

    // 配置请求拦截器
    this.configurationRequestInterceptor().forEach((interceptor: AxiosClientRequestInterceptor) => {
      this.instance.interceptors.request.use(interceptor.onFulfilled, interceptor.onRejected)
    })

    // 配置响应拦截器
    this.configurationResponseInterceptor().forEach((interceptor: AxiosClientResponseInterceptor) => {
      this.instance.interceptors.response.use(interceptor.onFulfilled, interceptor.onRejected)
    })

  }

  /**
   * 封装get请求
   *
   * @param path
   * @param config
   * @returns
   */
  protected getRequest<T = any>(path: string, config?: AxiosRequestConfig): Promise<AxiosResponse<T, any>> {
    return this.instance.get<T>(path, config)
  }

  /**
   * 封装post请求
   *
   * @param path
   * @param data
   * @param config
   * @returns
   */
  protected postRequest<T = any>(path: string, data?: any, config?: AxiosRequestConfig): Promise<AxiosResponse<T, any>> {
    return this.instance.post<T>(path, data, config)
  }


  /**
   * 配置Axios基本信息
   *
   * @returns ConfigurationAxiosClient
   */
  abstract configurationAxios(): ConfigurationAxiosClient

  /**
   * 配置请求拦截器
   *
   * @returns List<AxiosClientRequestInterceptor>
   */
  abstract configurationRequestInterceptor(): List<AxiosClientRequestInterceptor>

  /**
   * 配置响应拦截器
   *
   * @returns List<AxiosClientResponseInterceptor>
   */
  abstract configurationResponseInterceptor(): List<AxiosClientResponseInterceptor>
}




