import ProductItem from '../viewmodel/ProductItem';
import { WaterFlowDataSource } from '../viewmodel/WaterFlowDataSource';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import FlowItemComponent from '../view/FlowItemComponent';
import common from '@ohos.app.ability.common';
import ProductService from '../service/ProductService';
import { MOCK_PRODUCTS } from '../viewmodel/MockData';

@Component
export default struct WaterFlowComponent {
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;
  private datasource: WaterFlowDataSource = new WaterFlowDataSource();
  @State isDataLoaded: boolean = false;

  async aboutToAppear() {
    let context = getContext(this) as common.UIAbilityContext;
    await ProductService.initDB(context);
    await ProductService.saveInitialData(MOCK_PRODUCTS);
    const products = await ProductService.getAllProducts();
    this.datasource.setDataArray(products);
    this.isDataLoaded = true;
  }

  build() {
    Column() {
      if (!this.isDataLoaded) {
        Column() { Text("数据加载中...").fontColor(Color.Gray) }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else {
        WaterFlow({ footer: (): void => this.itemFoot() }) {
          LazyForEach(this.datasource, (item: ProductItem) => {
            FlowItem() { FlowItemComponent({ item: item }) }
          }, (item: ProductItem) => JSON.stringify(item))
        }
        .layoutWeight(Const.WATER_FLOW_LAYOUT_WEIGHT)
        .columnsTemplate(Const.WATER_FLOW_COLUMNS_TEMPLATE)
        .columnsGap($r('app.float.water_flow_columns_gap'))
        .rowsGap($r('app.float.water_flow_row_gap'))
      }
    }
  }

  @Builder itemFoot() {
    Column() {
      Text($r('app.string.footer_text')).fontColor(Color.Gray).fontSize($r('app.float.footer_text_size')).width(Const.FULL_WIDTH).height($r('app.float.footer_text_height')).textAlign(TextAlign.Center)
    }
    .margin({ top: $r('app.float.water_flow_row_gap'), bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }
}