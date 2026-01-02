import { MerchantProductView } from '../view/MerchantManageView';
import { MineView } from '../view/MineView';
import { MerchantOrderView } from '../view/MerchantOrderView'; // 引入新视图

@Entry
@Component
struct MerchantMainPage {
  @State currentIndex: number = 0;
  @State refreshSignal: number = 0;

  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

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
        MerchantProductView({ refreshTrigger: this.refreshSignal })
      }.tabBar(this.TabBuilder("商品管理", 0, "📦"))

      // [新增] 订单管理 Tab
      TabContent() {
        MerchantOrderView({ refreshTrigger: this.refreshSignal })
      }.tabBar(this.TabBuilder("订单管理", 1, "📄"))

      TabContent() {
        MineView()
      }.tabBar(this.TabBuilder("我的店铺", 2, "🏪"))
    }
    .onChange((index) => {
      this.currentIndex = index;
      this.refreshSignal++;
    })
    .barHeight(56 + this.getUIContext().px2vp(this.bottomRectHeight))
    .backgroundColor(Color.White)
    .scrollable(false)
  }
}