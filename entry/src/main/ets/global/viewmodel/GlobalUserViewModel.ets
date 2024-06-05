import WanHttpClient from '../../net/wanAPI/WanHttpClient'
import EventBus from '../../event/EventBus';
import { WanEventId } from '../../event/WanEventId';
import { LoginRegistEvent, UserInfoUpdateEvent } from '../../event/WanEvents';
import emitter from '@ohos.events.emitter';
import { ILoginRegist } from '../../net/wanAPI/response/ILoginRegist';
import { IUserInfo } from '../../net/wanAPI/response/IUserInfo';
import globalVM_WanDB from './GlobalWanDBViewModel';
import { SyncSafetyLock } from '../../utils/SyncSafetyLock';


const lock = new SyncSafetyLock()

export class GlobalUserViewModel {
  // 当前账号登录信息
  private loginInfo?: ILoginRegist | null = null;
  // 登录账户cookie
  private cookie: string = null;
  // 用户信息
  private userInfo?: IUserInfo | null = null;

  constructor() {
  }

  /**
   * 取消订阅所有事件
   */
  close() {
    EventBus.getInstance().unregistById(WanEventId.EVENT_UPDATE_USER_INFO);
    EventBus.getInstance().unregistById(WanEventId.EVENT_LOGIN_OUT);
    EventBus.getInstance().unregistById(WanEventId.EVENT_LOGIN);
  }

  /**
   * 判断当前是否已登录
   * @returns
   */
  hasLogged(): boolean {
    return this.loginInfo !== null;
  }

  /**
   * 获取用户信息
   * @returns
   */
  getUserInfo(): IUserInfo | null {
    return this.userInfo;
  }

  /**
   * 获取当前用户的登录信息
   * @returns
   */
  getLoginInfo(): ILoginRegist | null {
    return this.loginInfo;
  }

  /**
   * 获取当前用户的cookie
   * @returns
   */
  getCookie(): string | null {
    return this.cookie;
  }

  /**
   * 更新用户信息，并保存到数据库
   * @param userinfo
   */
  private async updateUserInfo(userinfo?: IUserInfo) {
    await lock.acquire();
    try {
      this.userInfo = userinfo;
      if (userinfo != null) {
        globalVM_WanDB.updateUserInfo(userinfo.userInfo.id, JSON.stringify(userinfo));
      }
    } finally {
      lock.release();
    }
  }

  /**
   * 更新登录信息，并保存到数据库
   * @param loginInfo
   * @param cookie
   * @param password
   */
  private async updateLoginInfo(loginInfo?: ILoginRegist, cookie?: string, password?: string) {
    await lock.acquire();
    try {
      this.loginInfo = loginInfo;
      this.cookie = cookie;
      if (password !== null) {
        globalVM_WanDB.saveLoginInfo(loginInfo.id, JSON.stringify(loginInfo), cookie, password);
      }
    } finally {
      lock.release();
    }
  }

  /**
   * 获取当前用户信息
   */
  async fetchUserInfo() {
    EventBus.getInstance().post(WanEventId.EVENT_UPDATE_USER_INFO, new UserInfoUpdateEvent(true));
    try {
      const response = await WanHttpClient.fetchUserInfo();
      if (response.data.errorCode === 0) {
        await this.updateUserInfo(response.data.data);
      }
    } catch (err) {

    } finally {
      EventBus.getInstance().post(WanEventId.EVENT_UPDATE_USER_INFO, new UserInfoUpdateEvent(false));
    }
  }

  /**
   * 注册并登录
   * @param username wanandroid账号
   * @param password  密码
   * @param repassword 二次密码
   */
  async registWithLogin(username: string, password: string, repassword: string) {
    try {
      const result = await WanHttpClient.regist(username, password, repassword);
      if (result.response.errorCode === 0) {
        await this.updateLoginInfo(result.response.data, result.cookies.join(';'), password);
        EventBus.getInstance().post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(true));
        await this.fetchUserInfo();
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(false, '注册失败:' + result.response.errorMsg));
      }
    } catch (err) {
      await this.loginOut();
      EventBus.getInstance().post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(false, '注册失败，请检查网络:' + err));
    }
  }

  /**
   * 登录
   * @param username wanandroid账号
   * @param password 密码
   */
  async login(username: string, password: string) {
    try {
      const result = await WanHttpClient.login(username, password);
      if (result.response.errorCode === 0) {
        await this.updateLoginInfo(result.response.data, result.cookies.join(';'), password);
        EventBus.getInstance().post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(true));
        await this.fetchUserInfo();
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(false, '登录失败:' + result.response.errorMsg));
      }
    } catch (err) {
      EventBus.getInstance().post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(false, '登录失败，请检查网络:' + err));
    }
  }

  /**
   * 从本地获取登录信息并登录
   */
  async loginFromLocal() {
    try {
      let result = await globalVM_WanDB.fetchLocalLoginInfo();
      if (result !== null) {
        // let id = result[0];
        let login_info = result[1];
        let user_info = result[2];
        let cookie = result[3];
        let password = result[4];
        // let login_state = result[5];
        let loginInfo = JSON.parse(login_info) as ILoginRegist;
        await this.updateLoginInfo(loginInfo, cookie, password);
        EventBus.getInstance().post(WanEventId.EVENT_LOGIN, new LoginRegistEvent(true));
        EventBus.getInstance().post(WanEventId.EVENT_UPDATE_USER_INFO, new UserInfoUpdateEvent(true));
        if (user_info !== null || user_info.length > 0) {
          await this.updateUserInfo(JSON.parse(user_info) as IUserInfo);
          EventBus.getInstance().post(WanEventId.EVENT_UPDATE_USER_INFO, new UserInfoUpdateEvent(false));
        }
        await this.login(loginInfo.username, password);
      }
    } catch (err) {
      console.error(`lxyTest Query failed, code is ${err.code},message is ${err.message}`);
    }
  }

  /**
   * 登出，发布登出事件
   */
  async loginOut() {
    if (this.loginInfo !== null) {
      globalVM_WanDB.updateLoginState(this.loginInfo.id, 0)
    }
    await this.updateLoginInfo(null, null, null)
    await this.updateUserInfo(null)
    EventBus.getInstance().post(WanEventId.EVENT_LOGIN_OUT)
  }

  // 订阅用户信息更新事件
  subscribeUserInfoUpdateEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_UPDATE_USER_INFO, key, callback);
  }

  // 取消订阅用户信息更新事件
  unSubscribeUserInfoUpdateEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_UPDATE_USER_INFO, key);
  }

  // 订阅登出事件
  subscribLoginOutEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_LOGIN_OUT, key, callback);
  }

  // 取消订阅登出事件
  unSubscribeLoginOutEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_LOGIN_OUT, key);
  }

  // 订阅登录事件
  subscribeLoginEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_LOGIN, key, callback);
  }

  // 取消订阅登录事件
  unSubscribeLoginEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_LOGIN, key);
  }
}

// 创建 GlobalUserViewModel 的实例并导出
const globalVM_User = new GlobalUserViewModel();

export default globalVM_User;
