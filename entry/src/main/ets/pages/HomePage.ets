import { CommonConstants as Const } from '../common/constants/CommonConstants';
// ✅ 修复：确保这些组件文件存在，并且路径相对于 HomePage 是正确的
import ClassifyComponent from '../view/ClassifyComponent';
import SearchComponent from '../view/SearchComponent';
import SwiperComponent from '../view/SwiperComponent';
import WaterFlowComponent from '../view/WaterFlowComponent';
import router from '@ohos.router';
import ProductService from '../service/ProductService';
import ProductItem from '../viewmodel/ProductItem';

@Entry
@Component
struct HomePage {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @State productList: ProductItem[] = [];

  async onPageShow() {
    // 业务逻辑放在这里，不要放在 build() 里面
    await ProductService.initData();
    this.productList = await ProductService.getAllProducts();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ic_app_background'))
        .width(Const.FULL_WIDTH)
        .height($r('app.float.image_background_height'))
        .objectFit(ImageFit.Cover)

      Column() {
        SearchComponent()
        ClassifyComponent()
        SwiperComponent()

        // 传递数据给瀑布流
        // ✅ 修复：这里只能写 UI 组件，不能写 console.log 或 if 语句(除非是 ArkTS 条件渲染)
        WaterFlowComponent({ productList: this.productList })
          .layoutWeight(1)
      }
      .padding({
        left: $r('app.float.home_margin_left'),
        right: $r('app.float.home_margin_right'),
        top: this.getUIContext().px2vp(this.topRectHeight)
      })

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text("我的")
          .fontColor(Color.White)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .backgroundColor(Color.Blue)
      .position({ x: '80%', y: '85%' })
      .shadow({ radius: 10, color: '#00000040', offsetY: 5 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/MinePage' });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.home_background_color'))
  }
}