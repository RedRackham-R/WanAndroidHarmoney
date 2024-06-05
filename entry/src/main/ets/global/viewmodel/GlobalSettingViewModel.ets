import GlobalWanCache from '../GlobalWanCache'
import fs from '@ohos.file.fs'
import { WanEventId } from '../../event/WanEventId'
import EventBus from '../../event/EventBus'
import emitter from '@ohos.events.emitter'
import { AvatarChangeEvent, ThemeChangeEvent } from '../../event/WanEvents'
import { WanConstant } from '../WanConstant'
import { Wanthemes } from '../../theme/WanThemes'
import { SyncSafetyLock } from '../../utils/SyncSafetyLock'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';

const lock = new SyncSafetyLock()

export class GlobalSettingViewModel {
  //头像
  private readonly KEY_AVATAR_NUMBER = "avatarNumber"
  //显示置顶文章
  private readonly KEY_SHOW_TOP_ARTICLE = "showTopArticle"
  //主题
  private readonly KEY_WAN_THEME = "wanTheme"

  private currentTheme: Wanthemes.IWanTheme = Wanthemes.LightTheme
  private currentThemeNum: number = 0

  async init() {
    await lock.acquire()

    const themeNum: number = await GlobalWanCache.get(this.KEY_WAN_THEME, 0) as number
    if (themeNum === 0) {
      this.currentTheme = Wanthemes.LightTheme
    } else {
      this.currentTheme = Wanthemes.DarkTheme
    }
    this.currentThemeNum = themeNum
    lock.release()
    EventBus.getInstance().post(WanEventId.EVENT_AVATAR_CHANGE, new ThemeChangeEvent(themeNum))
  }



  /**
   * 设置主题
   * @param themeNum 1 亮色主题  0 深色主题
   */
  public async setTheme(themeNum: number) {
    await lock.acquire()
    await GlobalWanCache.put(this.KEY_WAN_THEME, themeNum)
    if (themeNum === 0) {
      this.currentTheme = Wanthemes.DarkTheme
    } else {
      this.currentTheme = Wanthemes.LightTheme

    }
    this.currentThemeNum = themeNum
    lock.release()
    EventBus.getInstance().post(WanEventId.EVENT_THEME_CHANGE, new ThemeChangeEvent(themeNum))

  }

  /**
   * 获取主题
   * @returns
   */
  public getTheme(): Wanthemes.IWanTheme {
    return this.currentTheme
  }

  /**
   * 主获取题编号
   * @returns
   */
  public getThemeNum(): number {
    return this.currentThemeNum
  }


  //设置头像
  public async setAvatar(avatarNumber: number) {
    await GlobalWanCache.put(this.KEY_AVATAR_NUMBER, avatarNumber)
    EventBus.getInstance().post(WanEventId.EVENT_AVATAR_CHANGE, new AvatarChangeEvent(avatarNumber))
  }

  //获取头像
  public async getAvatar(): Promise<Resource> {
    const avatarNumber: number = await GlobalWanCache.get(this.KEY_AVATAR_NUMBER, 1) as number
    return new Promise<Resource>((resolve, _reject) => {
      resolve(WanConstant.AVATAR_MAP[avatarNumber])
    })
  }

  //设置显示显示置顶文章
  public setShowTopArticle(isShow: boolean) {
    GlobalWanCache.put(this.KEY_SHOW_TOP_ARTICLE, isShow)
  }

  //获取显示置顶文章状态
  public async isShowTopArticle(): Promise<boolean> {
    const showTopArticle: boolean = await GlobalWanCache.get(this.KEY_SHOW_TOP_ARTICLE, true) as boolean
    return new Promise<boolean>((resolve, _reject) => {
      resolve(showTopArticle)
    })
  }


  /**
   * 清除应用缓存
   * @returns
   */
  public clearAppCache(): Promise<void> {
    return fs.rmdir(getContext().cacheDir)
  }


  close() {
    EventBus.getInstance().unregistById(WanEventId.EVENT_AVATAR_CHANGE)
  }


  subscribeThemeChangeEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_THEME_CHANGE, key, callback)
  }

  unSubscribeThemeChangeEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_THEME_CHANGE, key)
  }

  /**
   * 注册头像更换通知事件
   * @param key
   * @param callback
   */
  subscribeAvatarChangeEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_AVATAR_CHANGE, key, callback)
  }

  /**
   * 解绑头像更换通知事件
   * @param key
   */
  unSubscribeAvatarChangeEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_AVATAR_CHANGE, key)
  }
}


const globalVM_Setting = new GlobalSettingViewModel()

export default globalVM_Setting