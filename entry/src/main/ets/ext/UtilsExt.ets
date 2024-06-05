import util from '@ohos.util';


export function extUtilsGenerateRadomUUID(): string {
  return util.generateRandomUUID(true)
}

export function extUtilsPrintLog(msg: string, tag: string = 'WanLog') {
  console.log(tag + " " + msg)
}