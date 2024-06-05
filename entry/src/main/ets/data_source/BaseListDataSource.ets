export class BaseListDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  private originData: T[] = []

  public totalCount(): number {
    return this.originData.length
  }

  public getData(index: number): T {
    return this.originData[index]
  }

  public getAllData(): T[] {
    return this.originData
  }

  public addData(data: T, withNotify: boolean = true) {
    this.originData.push(data)
    if (withNotify) {
      this.notifyDataAdd(this.originData.length - 1)
    }
  }

  public addListData(data: T[], withNotify: boolean = true) {
    if (data.length === 0) {
      return
    }
    let oldIndex = this.originData.length - 1
    data.forEach((item) => {
      data.push(item)
    })

    if (withNotify) {
      for (let index = oldIndex; index < this.originData.length; index++) {
        this.notifyDataAdd(index)
      }
    }
  }

  public removeAll(withNotify: boolean = true) {
    this.originData = []
    if (withNotify) {
      this.notifyDataReload()
    }
  }

  public remove(index: number, withNotify: boolean = true) {
    this.originData.splice(index, 1)
    if (withNotify) {
      this.notifyDataReload()
    }
  }


  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }
}

