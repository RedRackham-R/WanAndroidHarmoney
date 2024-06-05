/**
 * 刷新加载视图控制器
 */
export class PullToRefreshController {
  private refreshing: boolean = false
  private loading: boolean = false
  private startRefresh: boolean = false
  private startLoadMore: boolean = false
  private scroller: Scroller = new Scroller()

  updateRefreshState(isRefreshing: boolean) {
    if (this.startRefresh && !isRefreshing) {
      this.startRefresh = false
    }
    this.refreshing = isRefreshing
  }


  updateLoadMoreState(isLoadMore: boolean) {
    if (this.startLoadMore && !isLoadMore) {
      this.startLoadMore = false
    }
    this.loading = isLoadMore
  }


  scrollToTop() {
    this.scroller.scrollEdge(Edge.Top)
  }

  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom)
  }


  getScroller(): Scroller {
    return this.scroller
  }


  isStartedRefresh() {
    return this.startRefresh
  }


  isStartedLoadMore() {
    return this.startLoadMore
  }

  isRefreshing(): boolean {
    return this.refreshing
  }


  isLoading(): boolean {
    return this.loading
  }


  refresh() {
    //如果视图未加载绑定则不处理
    if (this.scroller.currentOffset() === undefined) {
      return
    }
    if (!this.isLoading() && !this.isRefreshing()) {
      this.scrollToTop()
      if (this.scroller.currentOffset().yOffset === 0) {
        this.startRefresh = true
      }
    }
  }


  loadMore() {
    //如果视图未加载绑定则不处理
    if (this.scroller.currentOffset() === undefined) {
      return
    }

    if (!this.isLoading() && !this.isRefreshing()) {
      this.scrollToBottom()
      if (this.scroller.currentOffset().yOffset !== 0) {
        this.startLoadMore = true
      }
    }
  }
}
