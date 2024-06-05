export class ByteConverter {
  //byte转换文本
  static convertBytes(bytes: number): string {
    const units = ['Byte', 'KB', 'MB', 'GB', 'TB']
    let unitIndex = 0

    while (bytes >= 1024 && unitIndex < units.length - 1) {
      bytes /= 1024
      unitIndex++
    }

    return `${bytes.toFixed(2)} ${units[unitIndex]}`
  }
}