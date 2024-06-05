export class CollectUrlEvent {
  isSuccess: boolean
  link: string
  errMsg: string
  desc?: string | null
  icon?: string | null
  id?: number | null
  name?: string | null
  order?: number | null
  userId?: number | null
  visible?: number | null

  constructor(
    isSuccess: boolean,
    link: string,
    errMsg: string,
    desc?: string,
    icon?: string,
    id?: number,
    name?: string,
    order?: number,
    userId?: number,
    visible?: number,
  ) {
    this.isSuccess = isSuccess
    this.link = link
    this.desc = desc
    this.icon = icon
    this.id = id
    this.name = name
    this.order = order
    this.userId = userId
    this.visible = visible
    this.errMsg = errMsg
  }
}


export class ThemeChangeEvent {
  themeNum: number

  constructor(themeNum: number) {
    this.themeNum = themeNum
  }
}


/**
 * 头像更换事件
 */
export class AvatarChangeEvent {
  avatarNumber: number

  constructor(avatarNumber: number) {
    this.avatarNumber = avatarNumber
  }
}


/**
 * 取消收藏文章事件
 */
export class UncollectEvent {
  isSuccess: boolean
  id: number
  errMsg?: string

  constructor(
    isSuccess: boolean,
    id: number,
    errMsg?: string) {
    this.isSuccess = isSuccess
    this.id = id
    this.errMsg = errMsg
  }
}

/**
 * 收藏文章事件
 */
export class CollectEvent {
  isSuccess: boolean
  id: number
  errMsg?: string

  constructor(
    isSuccess: boolean,
    id: number,
    errMsg?: string) {
    this.isSuccess = isSuccess
    this.id = id
    this.errMsg = errMsg
  }
}


/**
 * 用户信息更新
 */
export class UserInfoUpdateEvent {
  isUpdating: boolean

  constructor(isUpdating: boolean) {
    this.isUpdating = isUpdating
  }
}

/**
 * 登出 event
 */
export class LoginOutEvent {
}

/**
 * 登录、注册 event
 */
export class LoginRegistEvent {
  isSuccess: boolean
  errMsg?: string

  constructor(
    isSuccess: boolean,
    errMsg?: string) {
    this.isSuccess = isSuccess
    this.errMsg = errMsg
  }
}