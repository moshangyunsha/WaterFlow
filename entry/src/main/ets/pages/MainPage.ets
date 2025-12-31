import { HomeView } from '../view/HomeView';
import { MineView } from '../view/MineView';
import { CartView } from '../view/CartView';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  // [新增] 用于通知子组件刷新的信号
  @State refreshSignal: number = 0;

  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

  // [新增] 页面显示时（从详情页返回），强制刷新信号
  onPageShow() {
    this.refreshSignal++;
  }

  @Builder TabBuilder(title: string, index: number, iconStr: string) {
    Column() {
      Text(iconStr).fontSize(24).fontColor(this.currentIndex === index ? '#FF5000' : '#999999').margin({bottom: 2})
      Text(title).fontSize(10).fontColor(this.currentIndex === index ? '#FF5000' : '#999999')
    }
    .justifyContent(FlexAlign.Center).height('100%').width('100%')
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeView()
      }.tabBar(this.TabBuilder("首页", 0, "🏠"))

      TabContent() {
        // [修改] 传递刷新信号给 CartView
        CartView({ refreshTrigger: this.refreshSignal })
      }.tabBar(this.TabBuilder("购物车", 1, "🛒"))

      TabContent() {
        MineView()
      }.tabBar(this.TabBuilder("我的", 2, "👤"))
    }
    .onChange((index) => {
      this.currentIndex = index;
      // [新增] 切换 Tab 时，也更新信号，确保切过去看到最新的
      this.refreshSignal++;
    })
    .barMode(BarMode.Fixed)
    .barHeight(56 + this.getUIContext().px2vp(this.bottomRectHeight))
    .backgroundColor(Color.White)
    .scrollable(false)
  }
}