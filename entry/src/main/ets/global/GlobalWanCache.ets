import preferences from '@ohos.data.preferences'
import { PreferencesHelper } from '../db/PreferencesHelper'
import { WanConstant } from './WanConstant'


export class GlobalWanCache {
  private preferences: preferences.Preferences | null = null

  async init(context: Context) {
    this.preferences = await PreferencesHelper.getPreferences(context, WanConstant.PERFERENCES_CONFIG.name)
  }


  async put(key: string, value: preferences.ValueType) {
    await this.preferences.put(key, value)
    await this.preferences.flush()
  }

  async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    const result = await this.preferences.get(key, defaultValue)
    return result
  }
}

const globalWan_Cache = new GlobalWanCache()

export default globalWan_Cache