import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type ProductItem from '../viewmodel/ProductItem';
import { MOCK_PRODUCTS } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/MockData";
const LOCAL_IMAGES_MAP: Record<string, Resource> = {
    'ic_holder_50e': { "id": 16777292, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_xs2': { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_computer': { "id": 16777294, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_mouse': { "id": 16777296, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_pad': { "id": 16777297, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_mate50': { "id": 16777295, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_holder_60pro': { "id": 16777293, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'loading': { "id": 16777305, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    'ic_app_background': { "id": 16777290, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }
};
class ProductService {
    private static instance: ProductService;
    private constructor() { }
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
                        // 解析价格: "¥4088" -> 4088
                        const numStr = item.price.replace(/[^\d.]/g, '');
                        priceNum = parseFloat(numStr);
                    }
                }
                catch (error) {
                    priceNum = 0;
                }
                if (isNaN(priceNum))
                    priceNum = 0;
                // ✅ 关键修复：传入 item.description
                // RdbUtil.addProduct 的最后一个参数现在是 description
                await RdbUtil.addProduct(0, item.name, priceNum, item.imageKey, 300, 300 + Math.random() * 200, item.description // 写入详细介绍文案
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
}
export default ProductService.getInstance();
