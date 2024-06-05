import promptAction from '@ohos.promptAction'
import inputMethod from '@ohos.inputMethod'


export function extUIShowToast(msg: string, duration: number = 2000) {
  try {
    promptAction.showToast({
      message: msg,
      duration: duration,
    })
  } catch (error) {
    console.error(`showToast args error code is ${error.code}, message is ${error.message}`)
  }
}


/**
 * 显示软键盘
 * @param id 需要focus的输入控件key
 */
export function extUIShowKeybroad(key: string) {
  sendEventByKey(key, 10, "弹出键盘")
}


/**
 * 隐藏软键盘 目前用禁止输入实现
 */
export function extUIHideKeybroad() {
  inputMethod.getController().stopInputSession()
}