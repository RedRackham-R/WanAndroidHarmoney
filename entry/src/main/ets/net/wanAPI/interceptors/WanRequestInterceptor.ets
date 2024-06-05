import { InternalAxiosRequestConfig } from '@ohos/axios';
import globalVM_User from '../../../global/viewmodel/GlobalUserViewModel';
import { AxiosClientRequestInterceptor } from '../../base/interceptors/AxiosClientRequestInterceptor';

/**
 * 玩安卓发
 */
export class WanRequestInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    //配置Cookie
    if (globalVM_User.hasLogged()) {
      let cookie = globalVM_User.getCookie()
      config.headers.set('Cookie', cookie)
    }
    return config
  }
}