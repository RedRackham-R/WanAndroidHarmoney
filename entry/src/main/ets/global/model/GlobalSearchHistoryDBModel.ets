import relationalStore from '@ohos.data.relationalStore'

export class GlobalSearchHistoryDBModel {
  private TABLE_SEARCH_HISTORY: string = 'searchHistory'
  static readonly SQL_CREAT_TABLE: string =
    `CREATE TABLE IF NOT EXISTS searchHistory (
                            id integer primary key autoincrement,
                            word text
                          );`
  //添加或替换login_state
  private SQL_INSERT_OR_REPLACE_WORD: string =
    `INSERT OR REPLACE INTO searchHistory (word) VALUES (?);`
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }

  /**
   *
   */
  async deleteAllKeywords() {
    let predicates = new relationalStore.RdbPredicates(this.TABLE_SEARCH_HISTORY)
    predicates.isNotNull('id')
    let deletedNum = await this.store.delete(predicates)
  }


  async addSearchKeywords(word: string) {
    let predicates = new relationalStore.RdbPredicates(this.TABLE_SEARCH_HISTORY)
    predicates.equalTo("word", word)
    let querySet: relationalStore.ResultSet

    try {
      querySet = await this.store.query(predicates)
      if (querySet.rowCount === 0) {
        let params = [word]
        await this.store.executeSql(this.SQL_INSERT_OR_REPLACE_WORD, params)
      }
    } catch (err) {
    }
    if (querySet !== null) {
      querySet.close()
    }
  }


  async fetchSearchKeywords(): Promise<Array<string>> {
    let predicates = new relationalStore.RdbPredicates(this.TABLE_SEARCH_HISTORY)
    predicates.isNotNull('word')
    let resultSet: relationalStore.ResultSet
    try {
      resultSet = await this.store.query(predicates, ['word'])
      let retArray = new Array<string>()
      for (let rowIndex = 0; rowIndex < resultSet.rowCount; rowIndex++) {
        let isSuccess = resultSet.goToRow(rowIndex)
        console.info(`lxyTest ResultSet goToRow = ` + isSuccess);
        if (isSuccess) {
          let word = resultSet.getString(resultSet.getColumnIndex('word'))
          retArray.push(word)
        }
      }
      resultSet.close()
      return new Promise((resolve) => {
        resolve(retArray)
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
}