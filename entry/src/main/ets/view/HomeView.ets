import { CommonConstants as Const } from '../common/constants/CommonConstants';
import ClassifyComponent from './ClassifyComponent';
import SearchComponent from './SearchComponent';
import SwiperComponent from './SwiperComponent';
import WaterFlowComponent from './WaterFlowComponent';
import router from '@ohos.router';
import ProductService from '../service/ProductService';
import ProductItem from '../viewmodel/ProductItem';

// [修改] 移除 @Entry，改为 @Component 并 export
@Component
export struct HomeView {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  // 瀑布流的数据源
  @State productList: ProductItem[] = [];

  async handleCategoryChange(category: string): Promise<void> {
    // 调用 Service 层根据分类筛选数据
    this.productList = await ProductService.getProductsByCategory(category);
  }

  // 处理搜索逻辑
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

  // [修改] onPageShow -> aboutToAppear
  async aboutToAppear(): Promise<void> {
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

      // [修改] 移除了原本在这里的“我的”悬浮按钮
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.home_background_color'))
  }
}