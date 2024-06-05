import relationalStore from '@ohos.data.relationalStore'
import { DBHelper } from '../../db/DBHelper'
import { WanConstant } from '../WanConstant'
import { GlobalUserDBModel } from '../model/GlobalUserDBModel'
import { GlobalSearchHistoryDBModel } from '../model/GlobalSearchHistoryDBModel'

export class GlobalWanDBViewModel {
  private isInited = false
  private store: relationalStore.RdbStore | null
  private wanUserModel: GlobalUserDBModel
  private searchHistoryModel: GlobalSearchHistoryDBModel

  async deleteAllSearchKeywordsHistory() {
    if (this.isReady()) {
      await this.searchHistoryModel.deleteAllKeywords()
    }
  }

  /**
   * 添加搜索词到本地
   * @param word
   */
  async addSearchKeywords(word: string) {
    if (this.isReady()) {
      await this.searchHistoryModel.addSearchKeywords(word)
    }
  }


  /**
   * 获取所有历史搜索词
   * @returns
   */
  async fetchSearchKeywords(): Promise<Array<string>> {
    if (this.isReady()) {
      return this.searchHistoryModel.fetchSearchKeywords()
    } else {
      return new Promise((_resolve, reject) => {
        reject(" WanDB is not ready!")
      })
    }
  }


  /**
   * 获取本地登录用户数据
   * 返回依次为：id，login_info，user_info，cookie，password，login_state .为空则是没有登录账户
   */
  async fetchLocalLoginInfo(): Promise<[number, string, string, string, string, number] | null> {
    if (this.isReady()) {
      return this.wanUserModel.fetchLocalLoginInfo()
    } else {
      return new Promise((_resolve, reject) => {
        reject(" WanDB is not ready!")
      })
    }
  }


  /**
   * 更新用户信息
   * @param id
   * @param user_info
   */
  async updateUserInfo(id: number, user_info: string) {
    if (this.isReady()) {
      await this.wanUserModel.updateUserInfo(id, user_info)
    }
  }


  /**
   * 更新用户登录状态
   * @param id 用户id
   * @param login_state 登录状态
   */
  async updateLoginState(id: number, login_state: number) {
    if (this.isReady()) {
      await this.wanUserModel.updateLoginState(id, login_state)
    }
  }


  /**
   * 保存本地登录信息
   * @param id
   * @param loginInfoJson
   * @param cookie
   * @param password
   */
  async saveLoginInfo(id: number, loginInfoJson: string, cookie: string, password: string) {

    if (this.isReady()) {
      await this.wanUserModel.saveLoginInfo(id, loginInfoJson, cookie, password)
    }
  }


  //创建表
  async init(context: Context,) {
    this.store = DBHelper.getRdbStore(WanConstant.DB_CONFIG.name)
    if (this.store === null) {
      let initPromise = DBHelper.getWithCreateDb(context, WanConstant.DB_CONFIG)

      try {
        this.store = await initPromise
        //创建表
        await this.store.executeSql(GlobalUserDBModel.SQL_CREAT_TABLE)
        await this.store.executeSql(GlobalSearchHistoryDBModel.SQL_CREAT_TABLE)

        this.wanUserModel = new GlobalUserDBModel(this.store)
        this.searchHistoryModel = new GlobalSearchHistoryDBModel(this.store)
        this.isInited = true
      } catch (err) {
      }
    }
  }

  isReady(): boolean {
    return this.isInited
  }
}

const globalVM_WanDB = new GlobalWanDBViewModel()

export default globalVM_WanDB
