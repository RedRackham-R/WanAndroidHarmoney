import { AxiosResponse } from '@ohos/axios'
import { AxiosClientResponseInterceptor } from '../../base/interceptors/AxiosClientResponseInterceptor'
import { IWanCommonResponse } from '../response/IWanCommonResponse'

export class HttpResponseLoggerInterceptor implements AxiosClientResponseInterceptor {
  onFulfilled(response: AxiosResponse) {

    console.log("http response <--- " + response.config.baseURL + response.config.url + "   " + response.status)
    console.log("http status: " + response.status)
    console.log("http headers: " + JSON.stringify(response.headers))
    console.log("http config: " + JSON.stringify(response.config))
    if (response.status === 200) {
      console.log("http data: " + JSON.stringify(response.data as IWanCommonResponse<any>))
    }

    return response
  }
}