import { AxiosResponse } from '@ohos/axios';

export interface AxiosClientResponseInterceptor {
  onFulfilled?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>
  onRejected?: (error: any) => any
}