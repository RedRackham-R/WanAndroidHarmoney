import { InternalAxiosRequestConfig } from '@ohos/axios'
import { AxiosClientRequestInterceptor } from '../../base/interceptors/AxiosClientRequestInterceptor'

export class HttpRequestLoggerInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    console.log("http request ---> " + config.baseURL + config.url + "   " + config.method)
    console.log("http config: " + JSON.stringify(config))
    return config
  }
}