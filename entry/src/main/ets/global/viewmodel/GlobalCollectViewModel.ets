import emitter from '@ohos.events.emitter'
import EventBus from '../../event/EventBus'
import { WanEventId } from '../../event/WanEventId'
import { CollectEvent, CollectUrlEvent, UncollectEvent } from '../../event/WanEvents'
import wanHttpClient from '../../net/wanAPI/WanHttpClient'

export class GlobalCollectViewModel {
  close() {
    EventBus.getInstance().unregistById(WanEventId.EVENT_COLLECT)
    EventBus.getInstance().unregistById(WanEventId.EVENT_COLLECT_URL)
    EventBus.getInstance().unregistById(WanEventId.EVENT_UNCOLLECT)
    EventBus.getInstance().unregistById(WanEventId.EVENT_UNCOLLECT_URL)

  }


  async collectUrl(name: string, link: string) {
    try {
      const response = await wanHttpClient.collectUrl(name, link)
      if (response.data.errorCode === 0) {
        const data = response.data.data
        EventBus.getInstance().post(
          WanEventId.EVENT_COLLECT_URL,
          new CollectUrlEvent(
            true,
            link,
            response.data.errorMsg,
            data.desc,
            data.icon,
            data.id,
            data.name,
            data.order,
            data.userId,
            data.visible
          )
        )
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_COLLECT_URL, new CollectUrlEvent(false, link, "" + response.data.errorMsg))
      }
    } catch (err) {
      EventBus.getInstance()
        .post(WanEventId.EVENT_COLLECT_URL, new CollectUrlEvent(false, link, "请求异常，请检查网络：" + err))
    }
  }


  /**
   * 取消收藏网站
   * @param id
   */
  async uncollectUrl(id: number) {
    try {
      const response = await wanHttpClient.uncollectUrl(id)
      if (response.data.errorCode === 0) {
        EventBus.getInstance().post(WanEventId.EVENT_UNCOLLECT_URL, new UncollectEvent(true, id))
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_UNCOLLECT_URL, new UncollectEvent(false, id, "" + response.data.errorMsg))
      }
    } catch (err) {
      EventBus.getInstance()
        .post(WanEventId.EVENT_UNCOLLECT_URL, new UncollectEvent(false, id, "请求异常，请检查网络：" + err))
    }
  }


  /**
   * 收藏文章
   * @param id article id
   */
  async collect(id: number) {
    try {
      const response = await wanHttpClient.collect(id)
      if (response.data.errorCode === 0) { //errorCode === 0说明收藏成功
        EventBus.getInstance().post(WanEventId.EVENT_COLLECT, new CollectEvent(true, id))
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_COLLECT, new CollectEvent(false, id, "" + response.data.errorMsg))
      }
    } catch (err) {
      EventBus.getInstance()
        .post(WanEventId.EVENT_COLLECT, new CollectEvent(false, id, "请求异常，请检查网络：" + err))
    }
  }

  /**
   * 取消收藏文章
   * @param id article id
   */
  async uncolect(id: number) {
    try {
      const response = await wanHttpClient.uncollect(id)
      if (response.data.errorCode === 0) { //errorCode === 0说明收藏成功
        EventBus.getInstance().post(WanEventId.EVENT_UNCOLLECT, new UncollectEvent(true, id))
      } else {
        EventBus.getInstance()
          .post(WanEventId.EVENT_UNCOLLECT, new UncollectEvent(false, id, "" + response.data.errorMsg))
      }
    } catch (err) {
      EventBus.getInstance()
        .post(WanEventId.EVENT_UNCOLLECT, new UncollectEvent(false, id, "请求异常，请检查网络：" + err))
    }
  }


  /**
   * 收藏Url事件
   * @param key
   * @param callback
   */
  subscribeCollectUrlEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_COLLECT_URL, key, callback)
  }


  /**
   * 取消收藏Url事件
   * @param key
   * @param callback
   */
  unSubscribeCollectUrlEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_COLLECT_URL, key)
  }



  /**
   * 取消收藏Url事件
   * @param key
   * @param callback
   */
  subscribeUnCollectUrlEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_UNCOLLECT_URL, key, callback)
  }


  /**
   * 取消收藏Url事件
   * @param key
   * @param callback
   */
  unSubscribeUnCollectUrlEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_UNCOLLECT_URL, key)
  }


  /**
   * 订阅取消收藏event
   * @param callback
   */
  subscribeUncollectEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_UNCOLLECT, key, callback)
  }


  /**
   * 取消订阅取消收藏event
   */
  unSubscribeUncollectEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_UNCOLLECT, key)
  }


  /**
   * 订阅收藏event
   * @param callback
   */
  subscribeCollectEvent(key: string, callback: (eventData: emitter.EventData) => void) {
    EventBus.getInstance().regist(WanEventId.EVENT_COLLECT, key, callback)
  }


  /**
   * 取消订阅收藏event
   */
  unSubscribeCollectEvent(key: string) {
    EventBus.getInstance().unregistByKey(WanEventId.EVENT_COLLECT, key)
  }
}

const globalVM_Collect = new GlobalCollectViewModel()

export default globalVM_Collect