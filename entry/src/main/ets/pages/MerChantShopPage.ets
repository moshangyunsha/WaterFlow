import router from '@ohos.router';
import { User } from '../viewmodel/User';
import ProductItem from '../viewmodel/ProductItem';
import RdbUtil from '../common/utils/RdbUtil';

@Entry
@Component
struct MerchantShopPage {
  @State merchantId: number = 0;
  @State merchantInfo: User | null = null;
  @State shopProducts: ProductItem[] = [];
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['merchantId']) {
      this.merchantId = params['merchantId'] as number;

      // 1. 获取店铺(商家)信息
      this.merchantInfo = await RdbUtil.getUserById(this.merchantId);

      // 2. 获取该店铺下的所有商品
      this.shopProducts = await RdbUtil.getMerchantProducts(this.merchantId);
    }
  }

  build() {
    Column() {
      // --- 1. 顶部店铺信息卡片 ---
      Stack({ alignContent: Alignment.BottomStart }) {
        // 背景图 (可以用模糊的头像或者是默认背景)
        Image($r('app.media.ic_holder_computer')) // 这里建议换个好看的店铺背景图
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .opacity(0.8)

        // 遮罩层
        Row().width('100%').height(180).backgroundColor('#60000000')

        // 返回按钮
        Text("<")
          .fontColor(Color.White)
          .fontSize(24)
          .position({ x: 15, y: 15 + this.getUIContext().px2vp(this.topRectHeight) })
          .zIndex(10)
          .onClick(() => router.back())

        // 店铺头像和名称
        Row() {
          if (this.merchantInfo) {
            Image(this.merchantInfo.token || $r('app.media.ic_holder_computer')) // token暂存头像
              .width(60).height(60)
              .borderRadius(30)
              .backgroundColor(Color.White)
              .margin({ right: 15 })

            Column() {
              Text(this.merchantInfo.username) // 店铺名就是商家名
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ bottom: 5 })

              Text(`在售商品 ${this.shopProducts.length} 件`)
                .fontSize(12)
                .fontColor('#DDDDDD')
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .padding(20)
        .width('100%')
      }
      .width('100%')
      .height(180)

      // --- 2. 商品列表 (网格展示) ---
      List({ space: 10 }) {
        ListItem() {
          Grid() {
            ForEach(this.shopProducts, (item: ProductItem) => {
              GridItem() {
                Column() {
                  Image(item.image_url)
                    .width('100%')
                    .height(120)
                    .objectFit(ImageFit.Cover)
                    .borderRadius({ topLeft: 8, topRight: 8 })

                  Column() {
                    Text(item.name)
                      .fontSize(14)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .height(40)

                    Text(`¥${item.price.toFixed(2)}`)
                      .fontSize(16)
                      .fontColor('#FF5000')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: 5 })
                  }
                  .padding(8)
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                }
                .backgroundColor(Color.White)
                .borderRadius(8)
                .onClick(() => {
                  // 点击去商品详情 (复用逻辑)
                  router.pushUrl({
                    url: 'pages/ProductDetailPage',
                    params: item
                  })
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
          .padding(10)
          .height('100%')
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F1F3F5')
    }
    .width('100%')
    .height('100%')
  }
}