import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import ProductItem from '../viewmodel/ProductItem';

export interface RawProductData {
  name: string;
  price: string;
  imageKey: string;
  discount: string;
  promotion: string;
  bonus_points: string;
}

const LOCAL_IMAGES: Record<string, Resource> = {
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

const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS PRODUCT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PRICE TEXT, IMAGE_KEY TEXT, DISCOUNT TEXT, PROMOTION TEXT, BONUS_POINTS TEXT)`;
const STORE_CONFIG: relationalStore.StoreConfig = { name: 'Shop.db', securityLevel: relationalStore.SecurityLevel.S1 };

class ProductService {
  private static instance: ProductService;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly TABLE_NAME = 'PRODUCT';

  private constructor() {}
  public static getInstance(): ProductService {
    if (!ProductService.instance) { ProductService.instance = new ProductService(); }
    return ProductService.instance;
  }

  public async initDB(context: common.UIAbilityContext): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(SQL_CREATE_TABLE);
    } catch (err) {}
  }

  public async saveInitialData(rawData: RawProductData[]): Promise<void> {
    if (!this.rdbStore) return;
    try {
      let predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
      let resultSet = await this.rdbStore.query(predicates);
      if (resultSet.rowCount > 0) { resultSet.close(); return; }
      resultSet.close();

      this.rdbStore.beginTransaction();
      for (const item of rawData) {
        const valueBucket: relationalStore.ValuesBucket = { 'NAME': item.name, 'PRICE': item.price, 'IMAGE_KEY': item.imageKey, 'DISCOUNT': item.discount, 'PROMOTION': item.promotion, 'BONUS_POINTS': item.bonus_points };
        await this.rdbStore.insert(this.TABLE_NAME, valueBucket);
      }
      this.rdbStore.commit();
    } catch (e) { if(this.rdbStore) this.rdbStore.rollBack(); }
  }

  public async getAllProducts(): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    let resultSet = await this.rdbStore.query(predicates);
    return this.processResultSet(resultSet);
  }

  public async searchProducts(keyword: string): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    let predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    if (keyword?.trim()) { predicates.contains('NAME', keyword); }
    let resultSet = await this.rdbStore.query(predicates);
    return this.processResultSet(resultSet);
  }

  private processResultSet(resultSet: relationalStore.ResultSet): ProductItem[] {
    let list: ProductItem[] = [];
    if (resultSet.rowCount > 0) { while (resultSet.goToNextRow()) { list.push(this.convert(resultSet)); } }
    resultSet.close();
    return list;
  }

  private convert(resultSet: relationalStore.ResultSet): ProductItem {
    const key = resultSet.getString(resultSet.getColumnIndex('IMAGE_KEY'));

    // 优先从本地Map找，找不到就直接返回Key（作为URL）
    const imageSrc = LOCAL_IMAGES[key] ? LOCAL_IMAGES[key] : key;

    return new ProductItem({
      name: resultSet.getString(resultSet.getColumnIndex('NAME')),
      price: resultSet.getString(resultSet.getColumnIndex('PRICE')),
      image_url: imageSrc,
      discount: resultSet.getString(resultSet.getColumnIndex('DISCOUNT')),
      promotion: resultSet.getString(resultSet.getColumnIndex('PROMOTION')),
      bonus_points: resultSet.getString(resultSet.getColumnIndex('BONUS_POINTS'))
    });
  }
}
export default ProductService.getInstance();