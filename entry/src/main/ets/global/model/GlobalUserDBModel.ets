import relationalStore from '@ohos.data.relationalStore'

export class GlobalUserDBModel {
  private TABLE_USER: string = 'wanUser'
  //添加或替换全部列
  private SQL_TABLE_WANUSER_INSERT_OR_REPLEACE_FULL_COLUMN: string =
    `INSERT OR REPLACE INTO wanUser (
                          id,
                          login_info,
                          user_info,
                          cookie,
                          password,
                          login_state
                         ) VALUES (?,?,?,?,?,?);`
  //添加或替换login_state
  private SQL_TABLE_WANUSER_INSERT_OR_REPLEACE_LOGIN_STATE: string =
    `INSERT OR REPLACE INTO wanUser (id,login_state) VALUES (?,?);`
  //创建wanUser表
  static readonly SQL_CREAT_TABLE: string =
    `CREATE TABLE IF NOT EXISTS wanUser (
                            id number primary key ,
                            login_info text ,
                            user_info text ,
                            cookie text ,
                            password text,
                            login_state number
                          );`
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }


  /**
   * 获取本地登录用户数据
   */
  async fetchLocalLoginInfo(): Promise<[number, string, string, string, string, number] | null> {
    let resultSet: relationalStore.ResultSet
    let predicates = new relationalStore.RdbPredicates(this.TABLE_USER)
    predicates.equalTo("login_state", 1) //查找登录中的账号

    try {

      let resultSet = await this.store.query(predicates, ["id", "login_info", "user_info", "cookie", "password", "login_state"])

      for (let rowIndex = 0; rowIndex < resultSet.rowCount; rowIndex++) {
        let isSuccess = resultSet.goToRow(rowIndex)
        console.info(`lxyTest ResultSet goToRow = ` + isSuccess);
        if (isSuccess) {
          let id = resultSet.getLong(resultSet.getColumnIndex('id'))
          let login_info = resultSet.getString(resultSet.getColumnIndex('login_info'))
          let user_info = resultSet.getString(resultSet.getColumnIndex('user_info'))
          let cookie = resultSet.getString(resultSet.getColumnIndex('cookie'))
          let password = resultSet.getString(resultSet.getColumnIndex('password'))
          let login_state = resultSet.getLong(resultSet.getColumnIndex('login_state'))
          resultSet.close()
          return new Promise((resolve) => {
            resolve([id, login_info, user_info, cookie, password, login_state])
          })
        }
      }
      resultSet.close()
      return new Promise((resolve) => {
        resolve(null)
      })
    } catch (err) {
      if (resultSet !== null) {
        resultSet.close()
      }
      return new Promise((_resolve, reject) => {
        reject(err)
      })
    }
  }

  /**
   * 更新用户信息
   * @param id
   * @param user_info
   */
  async updateUserInfo(id: number, user_info: string) {
    let predicates = new relationalStore.RdbPredicates(this.TABLE_USER)
    predicates.equalTo("id", id)
    try {
      //更新login_state
      let rowNum = await this.store.update({ "user_info": user_info }, predicates)
    } catch (err) {
    }

  }


  /**
   * 更新用户登录状态
   * @param id 用户id
   * @param login_state 登录状态
   */
  async updateLoginState(id: number, login_state: number) {
    let predicates = new relationalStore.RdbPredicates(this.TABLE_USER)
    predicates.equalTo("id", id)
    try {
      //更新login_state
      let rowNum = await this.store.update({ "login_state": login_state }, predicates)
    } catch (err) {
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
    //先找到上一个登录的账号 如果有的话
    let predicates = new relationalStore.RdbPredicates(this.TABLE_USER)
    predicates.equalTo("login_state", 1)
    let queryResultSet: relationalStore.ResultSet
    //处理账号状态
    try {
      queryResultSet = await this.store.query(predicates, ["id"])
      //处理更新状态
      if (queryResultSet.rowCount !== 0) {
        for (let rowIndex = 0; rowIndex < queryResultSet.rowCount; rowIndex++) {
          let isSuccess = queryResultSet.goToRow(rowIndex)
          if (isSuccess) {
            let query_id = queryResultSet.getLong(queryResultSet.getColumnIndex('id'))
            if (query_id === id) { //id一致就不处理了
              continue
            }
            //把当前在线账号登录状态设为未登录
            let params = [id, 0]
            await this.store.executeSql(this.SQL_TABLE_WANUSER_INSERT_OR_REPLEACE_LOGIN_STATE, params)
          }
        }
      }
    } catch (err) {

    }
    if (queryResultSet !== null) {
      queryResultSet.close()
    }

    try {
      let params = [id, loginInfoJson, null, cookie, password, 1]
      await this.store.executeSql(this.SQL_TABLE_WANUSER_INSERT_OR_REPLEACE_FULL_COLUMN, params)
    } catch (err) {

    }

  }
}