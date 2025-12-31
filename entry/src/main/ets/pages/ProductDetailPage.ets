import router from '@ohos.router';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import { MOCK_PRODUCTS } from '../viewmodel/MockData';

/**
 * 商品详情页
 */
@Entry
@Component
struct ProductDetail {
  // ✅ 修复：构造函数现在只需要传一个对象，完美匹配
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

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      // 1. 获取传递过来的商品对象
      let currentItem = params as ProductItem;

      // 2. 【核心修复】如果不包含 description (或者为空)，尝试从 MockData 补全
      // 这是为了解决旧数据库数据缺失的问题
      if (!currentItem.description) {
        // 根据名字在 MOCK_PRODUCTS 里找对应的原始数据
        const mockData = MOCK_PRODUCTS.find(item => item.name === currentItem.name);
        if (mockData && mockData.description) {
          console.info('ProductDetail: 补全缺失的描述信息');
          currentItem.description = mockData.description;
        } else {
          currentItem.description = '暂无详细介绍';
        }
      }

      // 3. 赋值给状态变量，触发 UI 刷新
      this.product = new ProductItem(currentItem);
    }
  }

  async handleBuy() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    let imgForDb: string = "";

    if (typeof this.product.image_url === 'string') {
      imgForDb = this.product.image_url;
    } else {
      const mockItem = MOCK_PRODUCTS.find(item => item.name === this.product.name);
      if (mockItem) {
        // MockData 里的 imageKey 是 Resource，这里为了存数据库
        // 我们需要约定好 MockData 的图片存入策略。
        // 简化处理：如果是 Mock 商品，给一个固定标识，ProductService 会处理
        imgForDb = 'ic_holder_computer'; // 兜底
      } else {
        imgForDb = 'ic_holder_computer';
      }
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
              // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
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

              Blank()
              Text('已售 100+').fontSize(12).fontColor('#999')
            }.width('100%').alignItems(VerticalAlign.Bottom).margin({ bottom: 8 })

            // 原价展示
            Row() {
              // ✅ 修复：直接计算
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

            Row({ space: 8 }) {
              if (this.product.promotion) {
                Text(this.product.promotion)
                  .fontSize(10)
                  .fontColor('#FF0036')
                  .border({ width: 1, color: '#FF0036' })
                  .padding(2)
                  .borderRadius(2)
              }
              Text('包邮').fontSize(10).fontColor('#999').backgroundColor('#F0F0F0').padding(2).borderRadius(2)
            }.width('100%')

            // 详情描述
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

      Row() {
        Button("收藏")
          .type(ButtonType.Normal)
          .backgroundColor('#FF9900')
          .fontColor(Color.White)
          .width('40%')
          .height(40)
          .borderRadius({ topLeft: 20, bottomLeft: 20 })
          .onClick(() => { this.handleFav(); })

        Button("立即购买")
          .type(ButtonType.Normal)
          .backgroundColor('#FF5000')
          .fontColor(Color.White)
          .width('40%')
          .height(40)
          .borderRadius({ topRight: 20, bottomRight: 20 })
          .onClick(() => this.handleBuy())
      }
      .width('100%')
      .padding({ top: 10, bottom: 10, left: 15, right: 15 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)

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