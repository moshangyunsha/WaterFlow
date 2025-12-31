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

      // 2. 商品表 (【关键修改】增加了 DESCRIPTION 字段)
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS PRODUCT (ID INTEGER PRIMARY KEY AUTOINCREMENT, MERCHANT_ID INTEGER, NAME TEXT, PRICE REAL, IMAGE_URL TEXT, WIDTH INTEGER, HEIGHT INTEGER, DESCRIPTION TEXT)`);

      // 3. 收藏表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS FAVORITE (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_ID INTEGER, UNIQUE(USER_ID, PRODUCT_ID))`);

      // 4. 订单表
      await this.rdbStore.executeSql(`CREATE TABLE IF NOT EXISTS ORDERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, PRODUCT_NAME TEXT, PRICE REAL, CREATE_TIME TEXT, IMAGE_URL TEXT)`);
    } catch (err) {
      console.error(`RdbUtil initDB failed: ${err.message}`);
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
      await this.rdbStore.executeSql("DELETE FROM sqlite_sequence WHERE name IN ('USER','PRODUCT','FAVORITE','ORDERS')");
    } catch (e) {
      console.error("Reset DB failed", e);
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

  // --- 上架/插入商品 (【关键修改】增加 description 参数) ---
  async addProduct(merchantId: number, name: string, price: number, imgUrl: string, width: number = 300, height: number = 300, description: string = "") {
    if (!this.rdbStore) return;
    try {
      const value: relationalStore.ValuesBucket = {
        MERCHANT_ID: merchantId,
        NAME: name,
        PRICE: price,
        IMAGE_URL: imgUrl,
        WIDTH: width,
        HEIGHT: height,
        DESCRIPTION: description // 写入详情
      };
      await this.rdbStore.insert("PRODUCT", value);
    } catch (err) { console.error(`Add product failed: ${err.message}`); }
  }

  // --- 获取所有商品 (【关键修改】读取 DESCRIPTION) ---
  async getAllProducts(): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.orderByDesc("ID");
      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];

      while (rs.goToNextRow()) {
        // 安全读取 description，防止旧表结构报错
        let desc = "";
        try { desc = rs.getString(rs.getColumnIndex("DESCRIPTION")); } catch(e){}

        list.push(new ProductItem({
          id: rs.getLong(rs.getColumnIndex("ID")),
          merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
          name: rs.getString(rs.getColumnIndex("NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          image_url: rs.getString(rs.getColumnIndex("IMAGE_URL")),
          width: rs.getLong(rs.getColumnIndex("WIDTH")),
          height: rs.getLong(rs.getColumnIndex("HEIGHT")),
          description: desc, // 赋值给对象
          detailImages: []
        }));
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }



  // --- 创建订单并扣款 (带事务保护) ---
  async createOrder(userId: number, productName: string, price: number, imgUrl: string): Promise<number> {
    // 1=成功, -1=余额不足, -2=系统/数据库错误
    if (!this.rdbStore) return -2;

    try {
      // 1. 开启事务 (确保扣款和生成订单同时成功或同时失败)
      this.rdbStore.beginTransaction();

      // 2. 查余额
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

      // 3. 检查余额
      if (currentBalance < price) {
        this.rdbStore.rollBack();
        return -1;
      }

      // 4. 扣款
      const userVal: relationalStore.ValuesBucket = { BALANCE: currentBalance - price };
      await this.rdbStore.update(userVal, predicates);

      // 5. 记录订单
      const orderVal: relationalStore.ValuesBucket = {
        USER_ID: userId,
        PRODUCT_NAME: productName,
        PRICE: price,
        CREATE_TIME: new Date().toLocaleString(),
        IMAGE_URL: imgUrl
      };
      await this.rdbStore.insert("ORDERS", orderVal);

      // 6. 提交事务
      this.rdbStore.commit();
      return 1;

    } catch (err) {
      // 7. 回滚事务
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

  // --- 获取指定商户的商品 (【关键修改】读取 DESCRIPTION) ---
  async getMerchantProducts(merchantId: number): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      predicates.equalTo("MERCHANT_ID", merchantId);
      predicates.orderByDesc("ID");

      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];
      while (rs.goToNextRow()) {
        let desc = "";
        try { desc = rs.getString(rs.getColumnIndex("DESCRIPTION")); } catch(e){}

        list.push(new ProductItem({
          id: rs.getLong(rs.getColumnIndex("ID")),
          merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
          name: rs.getString(rs.getColumnIndex("NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          image_url: rs.getString(rs.getColumnIndex("IMAGE_URL")),
          width: rs.getLong(rs.getColumnIndex("WIDTH")),
          height: rs.getLong(rs.getColumnIndex("HEIGHT")),
          description: desc,
          detailImages: []
        }));
      }
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

  // --- 更新商品信息 (【关键修改】支持更新 DESCRIPTION) ---
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

  // --- 获取收藏 (【关键修改】读取 DESCRIPTION) ---
  async getMyFavorites(userId: number): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      // 1. 查收藏表获取 ID 列表
      let predicates = new relationalStore.RdbPredicates("FAVORITE");
      predicates.equalTo("USER_ID", userId);
      let rs = await this.rdbStore.query(predicates);
      let ids: number[] = [];
      while (rs.goToNextRow()) ids.push(rs.getLong(rs.getColumnIndex("PRODUCT_ID")));
      rs.close();
      if (ids.length === 0) return [];

      // 2. 查商品表
      let prodPredicates = new relationalStore.RdbPredicates("PRODUCT");
      prodPredicates.in("ID", ids);
      let prodRs = await this.rdbStore.query(prodPredicates);
      let list: ProductItem[] = [];
      while (prodRs.goToNextRow()) {
        let desc = "";
        try { desc = prodRs.getString(prodRs.getColumnIndex("DESCRIPTION")); } catch(e){}

        list.push(new ProductItem({
          id: prodRs.getLong(prodRs.getColumnIndex("ID")),
          merchantId: prodRs.getLong(prodRs.getColumnIndex("MERCHANT_ID")),
          name: prodRs.getString(prodRs.getColumnIndex("NAME")),
          price: prodRs.getDouble(prodRs.getColumnIndex("PRICE")),
          image_url: prodRs.getString(prodRs.getColumnIndex("IMAGE_URL")),
          width: prodRs.getLong(prodRs.getColumnIndex("WIDTH")),
          height: prodRs.getLong(prodRs.getColumnIndex("HEIGHT")),
          description: desc,
          detailImages: []
        }));
      }
      prodRs.close();
      return list;
    } catch (err) { return []; }
  }

  async searchProducts(keyword: string): Promise<ProductItem[]> {
    if (!this.rdbStore) return [];
    try {
      let predicates = new relationalStore.RdbPredicates("PRODUCT");
      // 模糊匹配商品名称 (如果需要搜描述，可以加 .or().contains("DESCRIPTION", keyword))
      predicates.contains("NAME", keyword);
      predicates.orderByDesc("ID");

      let rs = await this.rdbStore.query(predicates);
      let list: ProductItem[] = [];

      while (rs.goToNextRow()) {
        let desc = "";
        try { desc = rs.getString(rs.getColumnIndex("DESCRIPTION")); } catch(e){}

        list.push(new ProductItem({
          id: rs.getLong(rs.getColumnIndex("ID")),
          merchantId: rs.getLong(rs.getColumnIndex("MERCHANT_ID")),
          name: rs.getString(rs.getColumnIndex("NAME")),
          price: rs.getDouble(rs.getColumnIndex("PRICE")),
          image_url: rs.getString(rs.getColumnIndex("IMAGE_URL")),
          width: rs.getLong(rs.getColumnIndex("WIDTH")),
          height: rs.getLong(rs.getColumnIndex("HEIGHT")),
          description: desc,
          detailImages: []
        }));
      }
      rs.close();
      return list;
    } catch (err) { return []; }
  }
}
export default RdbUtil.getInstance();