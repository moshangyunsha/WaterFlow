import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import ProductItem from '../../viewmodel/ProductItem';
import { User } from '../../viewmodel/User';

// [新增] 评价数据接口
export interface ReviewItem {
  id: number;
  orderId: number;
  userId: number;
  userName: string;   // 关联出来的用户名
  userAvatar: string; // 关联出来的头像
  rating: number;     // 1-5 星
  content: string;
  date: string;
}

export interface AddressItem {
  id: number;
  userId: number;
  name: string;
  phone: string;
  address: string;     // 这里存 "广东省 深圳市 南山区 科技园路xxx号"
  area: string;        // [新增] 存 "广东省 深圳市 南山区"
  detail: string;      // [新增] 存 "科技园路xxx号"
  tag: string;         // [新增] 标签：家/公司/学校
  isDefault: boolean;
}

// [修改] 订单接口定义，增加 ID, 商家ID, 状态
export interface OrderItem {
  id: number;           // 订单主键
  merchantId: number;   // 商家ID
  title: string;
  price: number;
  date: string;
  imgUrl: string;
  status: number;       // 0:待发货, 1:已发货, 2:已完成
}

// 购物车原始记录接口
interface CartRecord {
  cartId: number;
  productId: number;
  count: number;
}

// 购物车商品类
export class CartItem extends ProductItem {
  cartId: number;
  count: number;

  constructor(product: ProductItem, cartId: number, count: number) {
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

      // 4. [修改] 订单表 - 增加 MERCHANT_ID 和 STATUS 字段
      // 注意：如果已安装应用，需点击"我的-重置所有数据"触发重建，或卸载重装
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS ORDERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, MERCHANT_ID INTEGER, PRODUCT_NAME TEXT, PRICE REAL, CREATE_TIME TEXT, IMAGE_URL TEXT, STATUS INTEGER)`);

      // 5. 购物车表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS CART (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_ID INTEGER, COUNT INTEGER)`);

      // 6.地址表
      // [修改] 6. 地址表 - 增加 AREA(省市区), DETAIL(详细), TAG(标签)
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS ADDRESS (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, NAME TEXT, PHONE TEXT, AREA TEXT, DETAIL TEXT, ADDRESS TEXT, TAG TEXT, IS_DEFAULT INTEGER)`);
      // [新增] 7. 评价表
      // 字段: ID, 订单ID, 商品ID, 用户ID, 评分, 内容, 时间
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS REVIEWS (ID INTEGER PRIMARY KEY AUTOINCREMENT, ORDER_ID INTEGER, PRODUCT_ID INTEGER, USER_ID INTEGER, RATING INTEGER, CONTENT TEXT, CREATE_TIME TEXT)`);
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

  async isProductEmpty(): Promise<boolean> {
    if (!this.rdbStore) return true;
    try {
      let rs = await this.rdbStore.query(new relationalStore.RdbPredicates("PRODUCT"));
      let count = rs.rowCount;
      rs.close();
      return count === 0;
    } catch (e) { return true; }
  }

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

  // --- [修改] 创建订单 ---
  // 增加 merchantId 参数, 初始化 status 为 0 (待发货)
  async createOrder(userId: number, productName: string, price: number, imgUrl: string, merchantId: number): Promise<number> {
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

      // 1. 扣除买家余额
      const userVal: relationalStore.ValuesBucket = { BALANCE: currentBalance - price };
      await this.rdbStore.update(userVal, predicates);

      // 2. 创建订单记录
      const orderVal: relationalStore.ValuesBucket = {
        USER_ID: userId,
        MERCHANT_ID: merchantId,
        PRODUCT_NAME: productName,
        PRICE: price,
        CREATE_TIME: new Date().toLocaleString(),
        IMAGE_URL: imgUrl,
        STATUS: 0 // 默认待发货
      };
      await this.rdbStore.insert("ORDERS", orderVal);

      // (可选) 增加商家余额逻辑暂省略，专注于订单状态流转

      this.rdbStore.commit();
      return 1;

    } catch (err) {
      this.rdbStore.rollBack();
      return -2;
    }
  }


  // --- [新增] 单独更新用户余额 ---
  async updateUserBalance(userId: number, newBalance: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const value: relationalStore.ValuesBucket = { BALANCE: newBalance };
      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("ID", userId);
      await this.rdbStore.update(value, predicates);
      return true;
    } catch (e) {
      console.error(`Update balance failed: ${JSON.stringify(e)}`);
      return false;
    }
  }

  // --- [新增] 单独创建订单记录 ---
  async addOrder(userId: number, merchantId: number, title: string, price: number, imgUrl: string): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const orderVal: relationalStore.ValuesBucket = {
        USER_ID: userId,
        MERCHANT_ID: merchantId,
        PRODUCT_NAME: title,
        PRICE: price,
        CREATE_TIME: new Date().toLocaleString(),
        IMAGE_URL: imgUrl,
        STATUS: 0 // 默认待发货
      };
      await this.rdbStore.insert("ORDERS", orderVal);
      return true;
    } catch (e) {
      console.error(`Add order failed: ${JSON.stringify(e)}`);
      return false;
    }
  }

  // --- [修改] 获取买家订单 ---
  async getMyOrders(userId: number): Promise<OrderItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("ORDERS");
      predicates.equalTo("USER_ID", userId);
      predicates.orderByDesc("ID"); // 最新订单在前
      let rs = await this.rdbStore.query(predicates);
      let list: OrderItem[] = [];
      while (rs.goToNextRow()) {
        list.push({
          id: rs.getLong(rs.getColumnIndex("ID")),
          merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
          title: rs.getString(rs.getColumnIndex("PRODUCT_NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          date: rs.getString(rs.getColumnIndex("CREATE_TIME")),
          imgUrl: rs.getString(rs.getColumnIndex("IMAGE_URL")),
          status: rs.getLong(rs.getColumnIndex("STATUS"))
        });
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- [新增] 获取商家收到的订单 ---
  async getMerchantOrders(merchantId: number): Promise<OrderItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("ORDERS");
      predicates.equalTo("MERCHANT_ID", merchantId);
      predicates.orderByDesc("ID");
      let rs = await this.rdbStore.query(predicates);
      let list: OrderItem[] = [];
      while (rs.goToNextRow()) {
        list.push({
          id: rs.getLong(rs.getColumnIndex("ID")),
          merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
          title: rs.getString(rs.getColumnIndex("PRODUCT_NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          date: rs.getString(rs.getColumnIndex("CREATE_TIME")),
          imgUrl: rs.getString(rs.getColumnIndex("IMAGE_URL")),
          status: rs.getLong(rs.getColumnIndex("STATUS"))
        });
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }

  // --- [新增] 更新订单状态 ---
  async updateOrderStatus(orderId: number, newStatus: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const value: relationalStore.ValuesBucket = { STATUS: newStatus };
      let predicates = new relationalStore.RdbPredicates("ORDERS");
      predicates.equalTo("ID", orderId);
      await this.rdbStore.update(value, predicates);
      return true;
    } catch (e) { return false; }
  }

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

  async deleteProduct(productId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.equalTo("ID", productId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch (e) { return false; }
  }

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

  async addFavorite(userId: number, productId: number) {
    if (!this.rdbStore) return;
    try {
      const value: relationalStore.ValuesBucket = { USER_ID: userId, PRODUCT_ID: productId };
      await this.rdbStore.insert("FAVORITE", value);
    } catch (e) { }
  }

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

  async addToCart(userId: number, productId: number, count: number = 1): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
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

  async getCartList(userId: number): Promise<CartItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("USER_ID", userId);
      let rs = await this.rdbStore.query(predicates);

      let cartItems: CartRecord[] = [];
      while(rs.goToNextRow()) {
        cartItems.push({
          cartId: rs.getLong(rs.getColumnIndex("ID")),
          productId: rs.getLong(rs.getColumnIndex("PRODUCT_ID")),
          count: rs.getLong(rs.getColumnIndex("COUNT"))
        });
      }
      rs.close();

      let resultList: CartItem[] = [];
      for (let item of cartItems) {
        let prodPred = new relationalStore.RdbPredicates("PRODUCT");
        prodPred.equalTo("ID", item.productId);
        let prodRs = await this.rdbStore.query(prodPred);
        if (prodRs.goToFirstRow()) {
          let product: ProductItem = this.rowToProduct(prodRs);
          let cartItem = new CartItem(product, item.cartId, item.count);
          resultList.push(cartItem);
        }
        prodRs.close();
      }
      return resultList;
    } catch (e) { return []; }
  }

  async deleteCartItem(cartId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("CART");
      predicates.equalTo("ID", cartId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch(e) { return false; }
  }

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

  // --- 地址管理方法 ---

  // 1. 获取地址列表 (默认地址排最前)
  async getAddressList(userId: number): Promise<AddressItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("ADDRESS");
      predicates.equalTo("USER_ID", userId);
      predicates.orderByDesc("IS_DEFAULT").orderByDesc("ID"); // 默认的排第一个

      let rs = await this.rdbStore.query(predicates);
      let list: AddressItem[] = [];
      while (rs.goToNextRow()) {
        // 修改 while 循环内的 push 对象
        list.push({
          id: rs.getLong(rs.getColumnIndex("ID")),
          userId: rs.getLong(rs.getColumnIndex("USER_ID")),
          name: rs.getString(rs.getColumnIndex("NAME")),
          phone: rs.getString(rs.getColumnIndex("PHONE")),
          address: rs.getString(rs.getColumnIndex("ADDRESS")),
          // [新增读取]
          area: rs.getColumnIndex("AREA") >= 0 ? rs.getString(rs.getColumnIndex("AREA")) : "",
          detail: rs.getColumnIndex("DETAIL") >= 0 ? rs.getString(rs.getColumnIndex("DETAIL")) : "",
          tag: rs.getColumnIndex("TAG") >= 0 ? rs.getString(rs.getColumnIndex("TAG")) : "家",
          isDefault: rs.getLong(rs.getColumnIndex("IS_DEFAULT")) === 1
        });
      }
      rs.close();
      return list;
    } catch (e) { return []; }
  }

  // [修改] 接收更多参数
  async addAddress(userId: number, name: string, phone: string, area: string, detail: string, tag: string, isDefault: boolean): Promise<boolean> {
    if (!this.rdbStore) return false;

    try {
      // 1. 先查询（移到事务外面）
      let currentList = await this.getAddressList(userId);

      // 2. 开启事务
      this.rdbStore.beginTransaction();

      // 3. 逻辑判断
      if (isDefault) {
        // 如果用户选了默认，把其他的改成非默认
        let val: relationalStore.ValuesBucket = { IS_DEFAULT: 0 };
        let pred = new relationalStore.RdbPredicates("ADDRESS");
        pred.equalTo("USER_ID", userId);
        await this.rdbStore.update(val, pred);
      } else {
        // 如果列表为空，强制设为默认
        if (currentList.length === 0) isDefault = true;
      }

      // 4. 插入新数据
      const value: relationalStore.ValuesBucket = {
        USER_ID: userId,
        NAME: name,
        PHONE: phone,
        AREA: area,
        DETAIL: detail,
        ADDRESS: area + " " + detail,
        TAG: tag,
        IS_DEFAULT: isDefault ? 1 : 0
      };
      await this.rdbStore.insert("ADDRESS", value);

      // 5. 提交
      this.rdbStore.commit();
      return true;
    } catch (e) {
      console.error(`Add Address Failed: ${JSON.stringify(e)}`); // 方便调试
      this.rdbStore.rollBack();
      return false;
    }
  }

  // 3. 删除地址
  async deleteAddress(addressId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("ADDRESS");
      predicates.equalTo("ID", addressId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch (e) { return false; }
  }

  // 4. 设为默认地址 (核心互斥逻辑)
  async setAddressDefault(userId: number, addressId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      this.rdbStore.beginTransaction();

      // 全部置 0
      let val0: relationalStore.ValuesBucket = { IS_DEFAULT: 0 };
      let pred0 = new relationalStore.RdbPredicates("ADDRESS");
      pred0.equalTo("USER_ID", userId);
      await this.rdbStore.update(val0, pred0);

      // 指定行置 1
      let val1: relationalStore.ValuesBucket = { IS_DEFAULT: 1 };
      let pred1 = new relationalStore.RdbPredicates("ADDRESS");
      pred1.equalTo("ID", addressId);
      await this.rdbStore.update(val1, pred1);

      this.rdbStore.commit();
      return true;
    } catch (e) {
      this.rdbStore.rollBack();
      return false;
    }
  }

  // --- [新增] 根据ID获取用户信息 (用于查询店铺信息) ---
  async getUserById(userId: number): Promise<User | null> {
    if (!this.rdbStore) return null;
    try {
      let predicates = new relationalStore.RdbPredicates("USER");
      predicates.equalTo("ID", userId);
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
        user.token = avatar; // 借用 token 字段存头像，或者你在 User 类里加个 avatar 字段
        rs.close();
        return user;
      }
      rs.close();
      return null;
    } catch (err) { return null; }
  }

  // --- [新增] 评价系统方法 ---

  // A. 发布评价
  async addReview(orderId: number, productId: number, userId: number, rating: number, content: string): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      const value: relationalStore.ValuesBucket = {
        ORDER_ID: orderId,
        PRODUCT_ID: productId,
        USER_ID: userId,
        RATING: rating,
        CONTENT: content,
        CREATE_TIME: new Date().toLocaleDateString() // 简单存日期
      };
      await this.rdbStore.insert("REVIEWS", value);

      // (可选) 评价完成后，可以将订单状态更新一下，或者仅仅作为已完成的附加动作
      return true;
    } catch (e) {
      console.error(`Add Review Failed: ${JSON.stringify(e)}`);
      return false;
    }
  }

  // B. 获取某商品的评价列表
  async getReviewsByProduct(productId: number): Promise<ReviewItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("REVIEWS");
      predicates.equalTo("PRODUCT_ID", productId);
      predicates.orderByDesc("ID"); // 新评价在前

      let rs = await this.rdbStore.query(predicates);
      let list: ReviewItem[] = [];

      while (rs.goToNextRow()) {
        let userId = rs.getLong(rs.getColumnIndex("USER_ID"));
        // 查用户信息 (同步等待)
        let user = await this.getUserById(userId);

        list.push({
          id: rs.getLong(rs.getColumnIndex("ID")),
          orderId: rs.getLong(rs.getColumnIndex("ORDER_ID")),
          userId: userId,
          userName: user ? user.username : "匿名用户",
          userAvatar: user ? user.token : "", // 借用token存头像
          rating: rs.getLong(rs.getColumnIndex("RATING")),
          content: rs.getString(rs.getColumnIndex("CONTENT")),
          date: rs.getString(rs.getColumnIndex("CREATE_TIME"))
        });
      }
      rs.close();
      return list;
    } catch (e) { return []; }
  }

  // C. 检查某个订单是否已经评价过 (防止重复评价)
  async hasReviewed(orderId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("REVIEWS");
      predicates.equalTo("ORDER_ID", orderId);
      let rs = await this.rdbStore.query(predicates);
      let count = rs.rowCount;
      rs.close();
      return count > 0;
    } catch (e) { return false; }
  }

  // [新增] 检查是否已收藏
  async hasFavorite(userId: number, productId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("FAVORITE");
      predicates.equalTo("USER_ID", userId).equalTo("PRODUCT_ID", productId);
      let rs = await this.rdbStore.query(predicates);
      let count = rs.rowCount;
      rs.close();
      return count > 0;
    } catch (e) { return false; }
  }

  // [新增] 取消收藏
  async removeFavorite(userId: number, productId: number): Promise<boolean> {
    if (!this.rdbStore) return false;
    try {
      let predicates = new relationalStore.RdbPredicates("FAVORITE");
      predicates.equalTo("USER_ID", userId).equalTo("PRODUCT_ID", productId);
      await this.rdbStore.delete(predicates);
      return true;
    } catch (e) { return false; }
  }

}
export default RdbUtil.getInstance();