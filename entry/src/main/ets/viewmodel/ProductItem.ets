/**
 * 统一商品接口定义
 */
export interface IProductItem {
  id: number;
  merchantId: number;
  image_url: ResourceStr;
  width: number;
  height: number;
  name: string;
  price: number; // 注意：这里是 number

  // 新增分类字段
  category?: string;

  discount?: string;
  promotion?: string;
  bonus_points?: string;
  description?: string;
  detailImages?: ResourceStr[];
  // [新增] 数量字段 (可选)
  count?: number;
  cartId?: number;
}

@Observed
export default class ProductItem implements IProductItem {
  id: number;
  merchantId: number;
  image_url: ResourceStr;
  width: number;
  height: number;
  name: string;
  price: number;

  // 新增分类字段
  category?: string;

  discount: string;
  promotion: string;
  bonus_points: string;
  description: string;
  detailImages: ResourceStr[];
  // [新增] 数量字段
  count: number;
  cartId?: number;

  constructor(props: IProductItem) {
    this.id = props.id;
    this.merchantId = props.merchantId;
    this.image_url = props.image_url;
    this.width = props.width;
    this.height = props.height;
    this.name = props.name;
    this.price = props.price;

    //  初始化分类，默认为'电子物品'防止空指针
    this.category = props.category || '电子物品';

    this.discount = props.discount || '';
    this.promotion = props.promotion || '';
    this.bonus_points = props.bonus_points || '';
    this.description = props.description || '暂无详细介绍';
    this.detailImages = props.detailImages || [];
    // [新增] 初始化 count，默认为 0
    this.count = props.count || 0;
    this.cartId = props.cartId;
  }
}