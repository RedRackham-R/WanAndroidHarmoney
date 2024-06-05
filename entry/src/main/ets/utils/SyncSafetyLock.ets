/**
 * 简单异步安全锁
 */
export class SyncSafetyLock {
  private _locked: boolean = false;
  private _waiting: (() => void)[] = [];

  async acquire() {
    while (this._locked) {
      await new Promise<void>(resolve => this._waiting.push(resolve));
    }
    this._locked = true;
  }

  release() {
    this._locked = false;
    if (this._waiting.length > 0) {
      const resolve = this._waiting.shift();
      resolve && resolve();
    }
  }
}