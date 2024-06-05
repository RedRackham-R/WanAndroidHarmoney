/**
 * 玩安卓二级数据list类型公共响应参数格式
 */
export interface IWanCommonListData<T> {
  curPage: number,
  datas: Array<T>,
  offset: number,
  over: boolean,
  pageCount: number,
  size: number,
  total: number,
}