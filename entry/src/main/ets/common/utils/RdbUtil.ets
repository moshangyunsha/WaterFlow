import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import ProductItem from '../../viewmodel/ProductItem';
import { User } from '../../viewmodel/User';

// 订单接口定义
export interface OrderItem {
  title: string;
  price: number;
  date: string;
  imgUrl: string;
}

// [修复] 定义购物车原始记录接口 (用于内部数据库查询)
interface CartRecord {
  cartId: number;
  productId: number;
  count: number;
}

// [修复] 定义购物车商品类 (继承 ProductItem，供外部 UI 使用)
// 必须 export，因为 CartView 需要引用它作为 List 的数据源类型
export class CartItem extends ProductItem {
  cartId: number;
  count: number;

  constructor(product: ProductItem, cartId: number, count: number) {
    // ProductItem 实例本身符合 IProductItem 接口，可直接传给 super
    super(product);
    this.cartId = cartId;
    this.count = count;
  }
}

class RdbUtil {
  private rdbStore: relationalStore.RdbStore | null = null;
  private static instance: RdbUtil;

  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'Mall.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  public static getInstance(): RdbUtil {
    if (!RdbUtil.instance) { RdbUtil.instance = new RdbUtil(); }
    return RdbUtil.instance;
  }

  // --- 初始化数据库 (建表) ---
  async initDB(context: common.UIAbilityContext) {
    if (this.rdbStore) return;
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);

      // 1. 用户表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS USER (ID INTEGER PRIMARY KEY AUTOINCREMENT, USERNAME TEXT, PASSWORD TEXT, ROLE INTEGER, BALANCE REAL, AVATAR TEXT)`);

      // 2. 商品表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS PRODUCT (ID INTEGER PRIMARY KEY AUTOINCREMENT, MERCHANT_ID INTEGER, NAME TEXT, PRICE REAL, IMAGE_URL TEXT, WIDTH INTEGER, HEIGHT INTEGER, DESCRIPTION TEXT, CATEGORY TEXT)`);

      // 3. 收藏表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS FAVORITE (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_ID INTEGER, UNIQUE(USER_ID, PRODUCT_ID))`);

      // 4. 订单表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS ORDERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_NAME TEXT, PRICE REAL, CREATE_TIME TEXT, IMAGE_URL TEXT)`);

      // 5. 购物车表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS CART (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_ID INTEGER, COUNT INTEGER)`);

    } catch (err) {
      console.error(`RdbUtil initDB failed: ${JSON.stringify(err)}`);
    }
  }

  // --- 彻底清空数据库 (重置用) ---
  async resetDatabase() {
    if (!this.rdbStore) return;
    try {
      await this.rdbStore.executeSql('DELETE FROM USER');
      await this.rdbStore.executeSql('DELETE FROM PRODUCT');
      await this.rdbStore.executeSql('DELETE FROM FAVORITE');
      await this.rdbStore.executeSql('DELETE FROM ORDERS');
      await this.rdbStore.executeSql('DELETE FROM CART');
      await this.rdbStore.executeSql("DELETE FROM sqlite_sequence WHERE name IN ('USER','PRODUCT','FAVORITE','ORDERS','CART')");
    } catch (e) {
      console.error("Reset DB failed", JSON.stringify(e));
    }
  }

  // --- 检查商品是否为空 ---
  async isProductEmpty(): Promise<boolean> {
    if (!this.rdbStore) return true;
    try {
      let rs = await this.rdbStore.query(new relationalStore.RdbPredicates("PRODUCT"));
      let count = rs.rowCount;
      rs.close();
      return count === 0;
    } catch (e) { return true; }
  }

  // --- 登录 (含头像读取) ---
  async login(username: string, password: string): Promise<User | null> {
    if (!this.rdbStore) return null;
    try {
      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("USERNAME", username).equalTo("PASSWORD", password);
      let rs = await this.rdbStore.query(predicates);

      if (rs.goToFirstRow()) {
        let avatar = "";
        try { avatar = rs.getString(rs.getColumnIndex("AVATAR")); } catch(e) {}

        let user = new User(
          rs.getLong(rs.getColumnIndex("ID")),
          rs.getString(rs.getColumnIndex("USERNAME")),
          rs.getLong(rs.getColumnIndex("ROLE")),
          rs.getDouble(rs.getColumnIndex("BALANCE")),
          ""
        );
        user.token = avatar;
        rs.close();
        return user;
      }
      rs.close();
      return null;
    } catch (err) { return null; }
  }

  // --- 注册 ---
  async register(username: string, password: string, role: number): Promise<User | null> {
    if (!this.rdbStore) return null;
    try {
      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("USERNAME", username);
      let rs = await this.rdbStore.query(predicates);
      if (rs.rowCount > 0) { rs.close(); return null; }
      rs.close();

      let balance = role === 1 ? 0 : 50000;
      const value: relationalStore.ValuesBucket = {
        USERNAME: username, PASSWORD: password, ROLE: role, BALANCE: balance, AVATAR: ""
      };
      let rowId = await this.rdbStore.insert("USER", value);
      return new User(rowId, username, role, balance, "");
    } catch (err) { return null; }
  }

  // --- 上架/插入商品 ---
  async addProduct(merchantId: number, name: string, price: number, imgUrl: string, width: number = 300, height: number = 300, description: string = "", category: string = "电子物品") {
    if (!this.rdbStore) return;
    try {
      const value: relationalStore.ValuesBucket = {
        MERCHANT_ID: merchantId,
        NAME: name,
        PRICE: price,
        IMAGE_URL: imgUrl,
        WIDTH: width,
        HEIGHT: height,
        DESCRIPTION: description,
        CATEGORY: category
      };
      await this.rdbStore.insert("PRODUCT", value);
    } catch (err) { console.error(`Add product failed: ${JSON.stringify(err)}`); }
  }

  // --- 通用行转对象方法 (私有辅助) ---
  private rowToProduct(rs: relationalStore.ResultSet): ProductItem {
    let desc = "";
    let cat = "电子物品";
    try { desc = rs.getString(rs.getColumnIndex("DESCRIPTION")); } catch(e){}
    try { cat = rs.getString(rs.getColumnIndex("CATEGORY")); } catch(e){}

    return new ProductItem({
      id: rs.getLong(rs.getColumnIndex("ID")),
      merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
      name: rs.getString(rs.getColumnIndex("NAME")),
      price: rs.getDouble(rs.getColumnIndex("PRICE")),
      image_url: rs.getString(rs.getColumnIndex("IMAGE_URL")),
      width: rs.getLong(rs.getColumnIndex("WIDTH")),
      height: rs.getLong(rs.getColumnIndex("HEIGHT")),
      description: desc,
      category: cat,
      detailImages: []
    });
  }

  // --- 获取所有商品 ---
  async getAllProducts(): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.orderByDesc("ID");
      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];
      while (rs.goToNextRow()) {
        list.push(this.rowToProduct(rs));
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- 按分类获取商品 ---
  async getProductsByCategory(category: string): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      if (category !== '全部') {
        predicates.equalTo("CATEGORY", category);
      }
      predicates.orderByDesc("ID");

      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];
      while (rs.goToNextRow()) {
        list.push(this.rowToProduct(rs));
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- 创建订单并扣款 ---
  async createOrder(userId: number, productName: string, price: number, imgUrl: string): Promise<number> {
    // 1=成功, -1=余额不足, -2=系统/数据库错误
    if (!this.rdbStore) return -2;

    try {
      this.rdbStore.beginTransaction();

      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("ID", userId);
      let rs = await this.rdbStore.query(predicates);

      if (!rs.goToFirstRow()) {
        rs.close();
        this.rdbStore.rollBack();
        return -2;
      }

      let currentBalance = rs.getDouble(rs.getColumnIndex("BALANCE"));
      rs.close();

      if (currentBalance < price) {
        this.rdbStore.rollBack();
        return -1;
      }

      const userVal: relationalStore.ValuesBucket = { BALANCE: currentBalance - price };
      await this.rdbStore.update(userVal, predicates);

      const orderVal: relationalStore.ValuesBucket = {
        USER_ID: userId,
        PRODUCT_NAME: productName,
        PRICE: price,
        CREATE_TIME: new Date().toLocaleString(),
        IMAGE_URL: imgUrl
      };
      await this.rdbStore.insert("ORDERS", orderVal);

      this.rdbStore.commit();
      return 1;

    } catch (err) {
      this.rdbStore.rollBack();
      return -2;
    }
  }

  // --- 获取订单 ---
  async getMyOrders(userId: number): Promise<OrderItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("ORDERS");
      predicates.equalTo("USER_ID", userId);
      let rs = await this.rdbStore.query(predicates);
      let list: OrderItem[] = [];
      while (rs.goToNextRow()) {
        list.push({
          title: rs.getString(rs.getColumnIndex("PRODUCT_NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          date: rs.getString(rs.getColumnIndex("CREATE_TIME")),
          imgUrl: rs.getString(rs.getColumnIndex("IMAGE_URL"))
        });
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- 获取指定商户的商品 ---
  async getMerchantProducts(merchantId: number): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.equalTo("MERCHANT_ID", merchantId);
      predicates.orderByDesc("ID");
      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];
      while (rs.goToNextRow()) list.push(this.rowToProduct(rs));
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- 删除商品 ---
  async deleteProduct(productId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.equalTo("ID", productId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch (e) { return false; }
  }

  // --- 更新商品信息 ---
  async updateProduct(productId: number, name: string, price: number, imgUrl: string, description: string = ""): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const value: relationalStore.ValuesBucket = {
        NAME: name,
        PRICE: price,
        IMAGE_URL: imgUrl,
        DESCRIPTION: description
      };
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.equalTo("ID", productId);
      await this.rdbStore.update(value, predicates);
      return true;
    } catch (e) { return false; }
  }

  // --- 更新用户头像 ---
  async updateUserAvatar(userId: number, avatarUri: string): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const value: relationalStore.ValuesBucket = { AVATAR: avatarUri };
      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("ID", userId);
      await this.rdbStore.update(value, predicates);
      return true;
    } catch (err) { return false; }
  }

  // --- 添加收藏 ---
  async addFavorite(userId: number, productId: number) {
    if (!this.rdbStore) return;
    try {
      const value: relationalStore.ValuesBucket = { USER_ID: userId, PRODUCT_ID: productId };
      await this.rdbStore.insert("FAVORITE", value);
    } catch (e) { }
  }

  // --- 获取收藏 ---
  async getMyFavorites(userId: number): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("FAVORITE");
      predicates.equalTo("USER_ID", userId);
      let rs = await this.rdbStore.query(predicates);
      let ids: number[] = [];
      while (rs.goToNextRow()) ids.push(rs.getLong(rs.getColumnIndex("PRODUCT_ID")));
      rs.close();
      if (ids.length === 0) return [];

      let prodPredicates = new relationalStore.RdbPredicates("PRODUCT");
      prodPredicates.in("ID", ids);
      let prodRs = await this.rdbStore.query(prodPredicates);
      let list: ProductItem[] = [];
      while (prodRs.goToNextRow()) list.push(this.rowToProduct(prodRs));
      prodRs.close();
      return list;
    } catch (err) { return []; }
  }

  async searchProducts(keyword: string): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.contains("NAME", keyword);
      predicates.orderByDesc("ID");
      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];
      while (rs.goToNextRow()) list.push(this.rowToProduct(rs));
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // ================= 购物车功能新增 (严格类型修复) =================

  // --- 加入购物车 (支持数量叠加) ---
  async addToCart(userId: number, productId: number, count: number = 1): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      // 1. 查重，如果有了就数量+count
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("USER_ID", userId).equalTo("PRODUCT_ID", productId);
      let rs = await this.rdbStore.query(predicates);

      if (rs.goToFirstRow()) {
        let currentCount = rs.getLong(rs.getColumnIndex("COUNT"));
        let value: relationalStore.ValuesBucket = { COUNT: currentCount + count };
        await this.rdbStore.update(value, predicates);
      } else {
        let value: relationalStore.ValuesBucket = { USER_ID: userId, PRODUCT_ID: productId, COUNT: count };
        await this.rdbStore.insert("CART", value);
      }
      rs.close();
      return true;
    } catch (e) { return false; }
  }

  // --- 获取购物车列表 (关联商品表) ---
  // [修复] 返回类型改为 CartItem[]，彻底消除 any
  async getCartList(userId: number): Promise<CartItem[]> {
    if (!this.rdbStore) return [];
    try {
      // 1. 先获取该用户的购物车记录
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("USER_ID", userId);
      let rs = await this.rdbStore.query(predicates);

      // 使用明确定义的 CartRecord 数组
      let cartItems: CartRecord[] = [];
      while(rs.goToNextRow()) {
        cartItems.push({
          cartId: rs.getLong(rs.getColumnIndex("ID")),
          productId: rs.getLong(rs.getColumnIndex("PRODUCT_ID")),
          count: rs.getLong(rs.getColumnIndex("COUNT"))
        });
      }
      rs.close();

      // 2. 根据 productId 查询商品详情，并拼装结果
      let resultList: CartItem[] = [];
      for (let item of cartItems) {
        let prodPred = new relationalStore.RdbPredicates("PRODUCT");
        prodPred.equalTo("ID", item.productId);
        let prodRs = await this.rdbStore.query(prodPred);
        if (prodRs.goToFirstRow()) {
          // 获取原始商品对象
          let product: ProductItem = this.rowToProduct(prodRs);

          // [修复] 使用 new CartItem 构造强类型对象，避免使用 any
          let cartItem = new CartItem(product, item.cartId, item.count);

          resultList.push(cartItem);
        }
        prodRs.close();
      }
      return resultList;
    } catch (e) { return []; }
  }

  // --- 删除购物车项 ---
  async deleteCartItem(cartId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("ID", cartId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch(e) { return false; }
  }

  // --- 检查购物车是否已存在某商品 ---
  async hasCartItem(userId: number, productId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("USER_ID", userId).equalTo("PRODUCT_ID", productId);
      let rs = await this.rdbStore.query(predicates);
      let count = rs.rowCount;
      rs.close();
      return count > 0;
    } catch (e) { return false; }
  }
}
export default RdbUtil.getInstance();