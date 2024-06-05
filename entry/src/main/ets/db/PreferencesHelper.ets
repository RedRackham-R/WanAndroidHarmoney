import dataPreferences from '@ohos.data.preferences'

export class PreferencesHelper {
  static getPreferences(context: Context, name: string): Promise<dataPreferences.Preferences> {
    return dataPreferences.getPreferences(context, name)
  }


  static deletePreferences(context: Context, name: string): Promise<void> {
    return dataPreferences.deletePreferences(context, name)
  }
}