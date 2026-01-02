import RdbUtil, { CartItem } from '../common/utils/RdbUtil';
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

// [新增] 定义一个辅助类，解决 "Object literal must correspond to..." 报错
class MerchantConfig {
  user: string;
  pass: string;

  constructor(user: string, pass: string) {
    this.user = user;
    this.pass = pass;
  }
}

class ProductService {
  private static instance: ProductService;

  private constructor() {}

  public static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }

  // 公开的图片解析方法
  public resolveImage(key: string): Resource {
    if (LOCAL_IMAGES_MAP[key]) {
      return LOCAL_IMAGES_MAP[key];
    }
    return $r('app.media.ic_holder_computer'); // 默认兜底
  }

  // 图片映射处理: 将数据库里的 String Key 转换为 Resource 对象
  private mapProductList(rawList: ProductItem[]): ProductItem[] {
    return rawList.map((item: ProductItem) => {
      const imgStr = item.image_url as string;
      if (LOCAL_IMAGES_MAP[imgStr]) {
        item.image_url = LOCAL_IMAGES_MAP[imgStr];
      }
      return item;
    });
  }

  // [核心修改] 初始化数据：创建3个默认商家并分配商品
  public async initData(): Promise<void> {
    const isEmpty = await RdbUtil.isProductEmpty();
    if (isEmpty) {
      console.info('ProductService: Start initializing Data...');

      // [修改] 使用类实例数组，解决 ArkTS 类型推断报错
      const merchantAccounts: MerchantConfig[] = [
        new MerchantConfig('testMall1', 'Mall1'),
        new MerchantConfig('testMall2', 'Mall2'),
        new MerchantConfig('testMall3', 'Mall3')
      ];

      const merchantIds: number[] = [];

      // 2. 确保这三个商家存在，并获取他们的 ID
      for (const acc of merchantAccounts) {
        // 尝试登录获取 ID
        let user = await RdbUtil.login(acc.user, acc.pass);

        // 如果不存在，则注册 (Role=1 代表商家)
        if (!user) {
          user = await RdbUtil.register(acc.user, acc.pass, 1);
        }

        if (user) {
          merchantIds.push(user.id);
          console.info(`ProductService: Ensure merchant ${acc.user} exists, ID=${user.id}`);
        }
      }

      // 如果商家创建失败（极端情况），兜底使用 ID 0
      if (merchantIds.length === 0) merchantIds.push(0);

      // 3. 插入商品，并循环分配给这几个商家
      console.info('ProductService: Start inserting Mock Products...');

      for (let i = 0; i < MOCK_PRODUCTS.length; i++) {
        const item = MOCK_PRODUCTS[i];

        // 解析价格
        let priceNum = 0;
        try {
          if (item.price) {
            const numStr = item.price.replace(/[^\d.]/g, '');
            priceNum = parseFloat(numStr);
          }
        } catch (error) { priceNum = 0; }
        if (isNaN(priceNum)) priceNum = 0;

        // [关键] 轮询分配商家ID (取模运算)
        const assignedMerchantId = merchantIds[i % merchantIds.length];

        await RdbUtil.addProduct(
          assignedMerchantId, // 传入分配的商家ID
          item.name,
          priceNum,
          item.imageKey,
          300,
          300 + Math.random() * 200,
          item.description,
          item.category || '电子物品'
        );
      }
      console.info('ProductService: Mock Data inserted with merchant allocation.');
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
      return this.getAllProducts();
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

  // 获取购物车列表
  public async getCartList(userId: number): Promise<CartItem[]> {
    const rawList: CartItem[] = await RdbUtil.getCartList(userId);
    return rawList.map((item: CartItem) => {
      const imgKey = item.image_url as string;
      item.image_url = this.resolveImage(imgKey);
      return item;
    });
  }
}

export default ProductService.getInstance();