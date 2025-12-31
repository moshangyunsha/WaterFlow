import router from '@ohos.router';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import { MOCK_PRODUCTS, RawProductData } from '../viewmodel/MockData';

/**
 * 商品详情页
 */
@Entry
@Component
struct ProductDetail {
  @State product: ProductItem = new ProductItem({
    id: 0,
    merchantId: 0,
    image_url: $r('app.media.loading'),
    name: '加载中...',
    price: 0,
    width: 0,
    height: 0
  });

  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  // [新增] 是否已加入购物车状态
  @State isAddedToCart: boolean = false;

  async aboutToAppear() {
    const params = router.getParams();
    if (params) {
      let currentItem = params as ProductItem;
      // 补全描述信息
      if (!currentItem.description) {
        // 使用显式类型 RawProductData 防止推断错误
        const mockData: RawProductData | undefined = MOCK_PRODUCTS.find((item: RawProductData) => item.name === currentItem.name);
        currentItem.description = mockData?.description || '暂无详细介绍';
      }
      this.product = new ProductItem(currentItem);

      // [核心修复] 检查当前商品是否已在购物车中
      if (this.currentUser.id) {
        this.isAddedToCart = await RdbUtil.hasCartItem(this.currentUser.id, this.product.id);
      }
    }
  }

  // --- 加入购物车逻辑 ---
  async handleAddToCart() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    // 双重检查
    if (this.isAddedToCart) {
      promptAction.showToast({ message: '该商品已在购物车中' });
      return;
    }

    let success = await RdbUtil.addToCart(this.currentUser.id, this.product.id);
    if (success) {
      promptAction.showToast({ message: '已加入购物车' });
      // [关键] 立即更新状态，使按钮变灰
      this.isAddedToCart = true;
    } else {
      promptAction.showToast({ message: '加入失败' });
    }
  }

  // --- 立即购买逻辑 ---
  async handleBuy() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    // 确定图片 Key (用于存库)
    let imgForDb: string;
    if (typeof this.product.image_url === 'string') {
      imgForDb = this.product.image_url;
    } else {
      // 如果是 Resource，尝试兜底或查找 Mock
      imgForDb = 'ic_holder_computer';
    }

    let code = await RdbUtil.createOrder(
      this.currentUser.id,
      this.product.name,
      this.product.price,
      imgForDb
    );

    if (code === 1) {
      this.currentUser.balance -= this.product.price;
      promptAction.showToast({ message: '购买成功' });
    } else if (code === -1) {
      promptAction.showToast({ message: '余额不足，请充值' });
    } else {
      promptAction.showToast({ message: '系统错误' });
    }
  }

  async handleFav() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    await RdbUtil.addFavorite(this.currentUser.id, this.product.id);
    promptAction.showToast({ message: '已加入收藏' });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.product.image_url)
              .width('100%')
              .height(350)
              .objectFit(ImageFit.Contain)
              .backgroundColor(Color.White)
          }

          Column() {
            Row() {
              Text('¥').fontSize(16).fontColor('#FF5000').baselineOffset(-4).fontWeight(FontWeight.Bold)
              Text(this.product.price.toFixed(2))
                .fontSize(28)
                .fontColor('#FF5000')
                .fontWeight(FontWeight.Bold)
                .margin({ right: 8 })

              if (this.product.discount) {
                Text(this.product.discount)
                  .fontSize(12)
                  .fontColor('#FF5000')
                  .backgroundColor('#FFE4D0')
                  .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                  .borderRadius(2)
              }
            }.width('100%').alignItems(VerticalAlign.Bottom).margin({ bottom: 8 })

            // 原价
            Row() {
              Text('价格 ¥' + (this.product.price * 1.2).toFixed(0))
                .fontSize(12)
                .fontColor('#999')
                .decoration({ type: TextDecorationType.LineThrough })
            }.width('100%')
          }
          .padding(16)
          .backgroundColor(Color.White)
          .width('100%')

          Divider().strokeWidth(1).color('#F5F5F5')

          Column() {
            Text(this.product.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(24)
              .margin({ bottom: 8 })

            Text(this.product.description)
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 15 })
          }
          .padding(16)
          .backgroundColor(Color.White)
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Blank().height(80)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor('#F5F5F5')

      // --- 底部操作栏 ---
      Row() {
        // 收藏按钮
        Column() {
          Text("★").fontSize(20).fontColor(Color.Orange)
          Text("收藏").fontSize(10).fontColor(Color.Gray)
        }
        .justifyContent(FlexAlign.Center)
        .width(50)
        .onClick(() => this.handleFav())
        .backgroundColor(Color.White)

        // [修改] 加入购物车按钮 - 根据 isAddedToCart 状态变化
        Button(this.isAddedToCart ? "已在购物车" : "加入购物车")
          .type(ButtonType.Normal)
          .backgroundColor(this.isAddedToCart ? '#FFCC99' : '#FF9900') // 变淡
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(40)
          .borderRadius({ topLeft: 20, bottomLeft: 20 })
          .margin({ left: 10 })
          .enabled(!this.isAddedToCart) // 禁用点击
          .onClick(() => this.handleAddToCart())

        // 立即购买按钮
        Button("立即购买")
          .type(ButtonType.Normal)
          .backgroundColor('#FF5000')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(40)
          .borderRadius({ topRight: 20, bottomRight: 20 })
          .onClick(() => this.handleBuy())
      }
      .width('100%')
      .padding({ top: 10, bottom: 10, left: 15, right: 15 })
      .backgroundColor(Color.White)

      // 返回悬浮按钮
      Row() {
        Button('<')
          .type(ButtonType.Circle)
          .backgroundColor('#80000000')
          .fontColor(Color.White)
          .fontSize(18)
          .width(32)
          .height(32)
          .onClick(() => { router.back(); })
      }
      .position({ x: 16, y: 16 + this.getUIContext().px2vp(this.topRectHeight) })
      .zIndex(10)
    }
    .width('100%')
    .height('100%')
  }
}