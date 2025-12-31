import RdbUtil from '../common/utils/RdbUtil';
import ProductItem from '../viewmodel/ProductItem';
// 引入 Mock 数据和接口
import { MOCK_PRODUCTS, RawProductData } from '../viewmodel/MockData';

const LOCAL_IMAGES_MAP: Record<string, Resource> = {
  'ic_holder_50e': $r('app.media.ic_holder_50e'),
  'ic_holder_xs2': $r('app.media.ic_holder_xs2'),
  'ic_holder_computer': $r('app.media.ic_holder_computer'),
  'ic_holder_mouse': $r('app.media.ic_holder_mouse'),
  'ic_holder_pad': $r('app.media.ic_holder_pad'),
  'ic_holder_mate50': $r('app.media.ic_holder_mate50'),
  'ic_holder_60pro': $r('app.media.ic_holder_60pro'),
  'loading': $r('app.media.loading'),
  'ic_app_background': $r('app.media.ic_app_background')
};

class ProductService {
  private static instance: ProductService;

  private constructor() {}

  public static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }

  // 图片映射处理: 将数据库里的 String Key 转换为 Resource 对象
  private mapProductList(rawList: ProductItem[]): ProductItem[] {
    return rawList.map(item => {
      const imgStr = item.image_url as string;
      if (LOCAL_IMAGES_MAP[imgStr]) {
        item.image_url = LOCAL_IMAGES_MAP[imgStr];
      }
      return item;
    });
  }

  // 初始化数据
  public async initData(): Promise<void> {
    const isEmpty = await RdbUtil.isProductEmpty();
    if (isEmpty) {
      console.info('ProductService: Start inserting Mock Data...');

      for (const item of MOCK_PRODUCTS) {
        let priceNum = 0;
        try {
          if (item.price) {
            const numStr = item.price.replace(/[^\d.]/g, '');
            priceNum = parseFloat(numStr);
          }
        } catch (error) { priceNum = 0; }
        if (isNaN(priceNum)) priceNum = 0;

        // ✅ 关键修复：传入 item.category (如果 Mock 数据没定义，兜底为电子物品)
        await RdbUtil.addProduct(
          0,
          item.name,
          priceNum,
          item.imageKey,
          300,
          300 + Math.random() * 200,
          item.description,
          item.category || '电子物品'
        );
      }
      console.info('ProductService: Mock Data inserted.');
    }
  }

  // 获取所有商品 (首页)
  public async getAllProducts(): Promise<ProductItem[]> {
    const rawList = await RdbUtil.getAllProducts();
    return this.mapProductList(rawList);
  }

  // 搜索商品
  public async searchProducts(keyword: string): Promise<ProductItem[]> {
    if (!keyword || keyword.trim() === '') {
      return this.getAllProducts(); // 关键字为空则返回全部
    }
    const rawList = await RdbUtil.searchProducts(keyword);
    return this.mapProductList(rawList);
  }

  // 获取收藏 (收藏页)
  public async getMyFavorites(userId: number): Promise<ProductItem[]> {
    const rawList = await RdbUtil.getMyFavorites(userId);
    return this.mapProductList(rawList);
  }

  // 重置数据
  public async clearAllData(): Promise<void> {
    await RdbUtil.resetDatabase();
    await this.initData();
  }

  // 按分类查询
  public async getProductsByCategory(category: string): Promise<ProductItem[]> {
    if (!category || category === '全部') {
      return this.getAllProducts();
    }
    const rawList = await RdbUtil.getProductsByCategory(category);
    return this.mapProductList(rawList);
  }
}

export default ProductService.getInstance();