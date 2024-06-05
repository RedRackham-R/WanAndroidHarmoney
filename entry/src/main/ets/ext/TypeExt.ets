/**
 * Interface 判断类型（鸭子类型，Duck Typing）
 * 因为typescript的Interface无法直接通过类型判断实现类，所以需要判断该类中是否含有某个字段参数或者函数（duck typing）进行判断
 * @param v
 * @param k
 * @returns
 */
export function extTypeIs<T extends object>(v: any, k: string): v is T {
  return k in v;
}