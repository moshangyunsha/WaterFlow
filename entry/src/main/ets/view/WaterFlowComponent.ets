import ProductItem from '../viewmodel/ProductItem';
import FlowItemComponent from './FlowItemComponent';
import { WaterFlowDataSource } from '../viewmodel/WaterFlowDataSource';
import { CommonConstants as Const } from '../common/constants/CommonConstants';

@Component
export default struct WaterFlowComponent {
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

  @Prop @Watch('onListChange') productList: ProductItem[];
  private dataSource: WaterFlowDataSource = new WaterFlowDataSource();

  onListChange() {
    this.dataSource.setDataArray(this.productList);
    this.dataSource.notifyDataReload();
  }

  aboutToAppear() {
    this.dataSource.setDataArray(this.productList);
  }

  build() {
    Column() {
      if (this.productList.length === 0) {
        Column() {
          Text("暂无数据").fontColor(Color.Gray).margin({top: 50})
        }.width('100%').justifyContent(FlexAlign.Center)
      } else {
        WaterFlow({ footer: (): void => this.itemFoot() }) {
          LazyForEach(this.dataSource, (item: ProductItem) => {
            FlowItem() {
              FlowItemComponent({ item: item })
            }
          }, (item: ProductItem) => item.id.toString())
        }
        .layoutWeight(Const.WATER_FLOW_LAYOUT_WEIGHT)
        .columnsTemplate(Const.WATER_FLOW_COLUMNS_TEMPLATE)
        .columnsGap($r('app.float.water_flow_columns_gap'))
        .rowsGap($r('app.float.water_flow_row_gap'))
        // 优化 1: 减少底部内边距，从 100/300 改为 80 (刚好避开悬浮按钮)
        .padding({ left: 10, right: 10, bottom: 80 })
      }
    }
  }

  @Builder itemFoot() {
    // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
    Column() {
      Text("—— 到底了 ——")
        .fontColor('#999999')
        .fontSize(12)
        .textAlign(TextAlign.Center) // 文字内部居中
        .margin({ top: 10, bottom: 10 })
    }
    .width('100%') // 容器占满宽度
    .justifyContent(FlexAlign.Center) // 垂直居中
    .alignItems(HorizontalAlign.Center) // 水平居中
    // 适配系统底部导航条高度，防止被黑条遮挡
    .padding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }
}