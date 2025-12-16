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

  discount?: string;
  promotion?: string;
  bonus_points?: string;
  description?: string;
  detailImages?: ResourceStr[];
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

  discount: string;
  promotion: string;
  bonus_points: string;
  description: string;
  detailImages: ResourceStr[];

  constructor(props: IProductItem) {
    this.id = props.id;
    this.merchantId = props.merchantId;
    this.image_url = props.image_url;
    this.width = props.width;
    this.height = props.height;
    this.name = props.name;
    this.price = props.price;

    this.discount = props.discount || '';
    this.promotion = props.promotion || '';
    this.bonus_points = props.bonus_points || '';
    this.description = props.description || '暂无详细介绍';
    this.detailImages = props.detailImages || [];
  }
}