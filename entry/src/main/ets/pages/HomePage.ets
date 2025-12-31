import { CommonConstants as Const } from '../common/constants/CommonConstants';
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
  // 瀑布流的数据源
  @State productList: ProductItem[] = [];

  // ✅ 修复：显式添加返回值类型 Promise<void>
  async handleCategoryChange(category: string): Promise<void> {
    // 调用 Service 层根据分类筛选数据
    this.productList = await ProductService.getProductsByCategory(category);
  }

  // 处理搜索逻辑 (此前已加，保持现状)
  async handleSearch(keyword: string): Promise<void> {
    if (!keyword || keyword.trim() === '') return;

    try {
      await router.pushUrl({
        url: 'pages/SearchResultPage',
        params: { keyword: keyword }
      });
    } catch (err) {
      console.error(`HomePage jump failed: ${JSON.stringify(err)}`);
    }
  }

  // ✅ 修复：显式添加返回值类型 Promise<void>
  async onPageShow(): Promise<void> {
    // 确保数据已初始化
    await ProductService.initData();
    // 默认加载所有商品
    this.productList = await ProductService.getAllProducts();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景图
      Image($r('app.media.ic_app_background'))
        .width(Const.FULL_WIDTH)
        .height($r('app.float.image_background_height'))
        .objectFit(ImageFit.Cover)

      Column() {
        // 1. 搜索栏
        SearchComponent({
          onSearch: (val: string) => this.handleSearch(val)
        })

        // 2. 分类栏
        ClassifyComponent({
          onCategoryChange: (cat: string) => this.handleCategoryChange(cat)
        })

        // 3. 轮播图
        SwiperComponent()

        // 4. 瀑布流列表
        WaterFlowComponent({ productList: this.productList })
          .layoutWeight(1)
      }
      .padding({
        left: $r('app.float.home_margin_left'),
        right: $r('app.float.home_margin_right'),
        // 适配沉浸式状态栏的高度
        top: this.getUIContext().px2vp(this.topRectHeight)
      })

      // 5. 悬浮按钮 (跳转到个人中心)
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