

/**
 * 玩安卓公共响应格式
 */
export interface IWanCommonResponse<T> {
  data: T
  errorCode: number,
  errorMsg: string,
}