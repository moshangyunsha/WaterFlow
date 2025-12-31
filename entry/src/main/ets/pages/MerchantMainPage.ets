import { MerchantProductView } from '../view/MerchantManageView';
import { MineView } from '../view/MineView';

@Entry
@Component
struct MerchantMainPage {
  @State currentIndex: number = 0;
  // [新增]
  @State refreshSignal: number = 0;

  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

  // [新增] 每次页面显示（比如发布商品回来）都触发
  onPageShow() {
    this.refreshSignal++;
  }

  @Builder TabBuilder(title: string, index: number, iconStr: string) {
    Column() {
      Text(iconStr).fontSize(24).fontColor(this.currentIndex === index ? '#007DFF' : '#999999').margin({bottom: 2})
      Text(title).fontSize(10).fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
    }
    .justifyContent(FlexAlign.Center).height('100%').width('100%')
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        // [修改] 传入信号
        MerchantProductView({ refreshTrigger: this.refreshSignal })
      }.tabBar(this.TabBuilder("商品管理", 0, "📦"))

      TabContent() {
        MineView()
      }.tabBar(this.TabBuilder("我的店铺", 1, "🏪"))
    }
    .onChange((index) => {
      this.currentIndex = index;
      this.refreshSignal++; // 切 Tab 也刷新
    })
    .barHeight(56 + this.getUIContext().px2vp(this.bottomRectHeight))
    .backgroundColor(Color.White)
    .scrollable(false)
  }
}