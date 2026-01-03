import router from '@ohos.router';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import { MOCK_PRODUCTS, RawProductData } from '../viewmodel/MockData';
import { PayPasswordDialog } from '../view/PayPasswordDialog';
import { ReviewItem } from '../common/utils/RdbUtil'; // 引入接口

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
  @State isAddedToCart: boolean = false;
  @State merchantName: string = '官方自营'; // [新增]
  @State merchantAvatar: string | Resource = $r('app.media.ic_holder_computer'); // [新增]
  @State reviews: ReviewItem[] = [];
  // [新增] 收藏状态
  @State isFavorite: boolean = false;

  // [新增] 定义弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PayPasswordDialog({
      price: this.product.price, // 单个商品价格
      action: () => this.executeBuy() // 密码验证成功后执行的方法
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  async aboutToAppear() {
    const params = router.getParams();
    if (params) {
      let currentItem = params as ProductItem;
      if (!currentItem.description) {
        const mockData: RawProductData | undefined = MOCK_PRODUCTS.find((item: RawProductData) => item.name === currentItem.name);
        currentItem.description = mockData?.description || '暂无详细介绍';
      }
      this.product = new ProductItem(currentItem);

      if (this.currentUser.id) {
        this.isAddedToCart = await RdbUtil.hasCartItem(this.currentUser.id, this.product.id);
        // [新增] 检查是否已收藏
        this.isFavorite = await RdbUtil.hasFavorite(this.currentUser.id, this.product.id);
      }
    }

    // [新增] 根据 product.merchantId 获取店铺信息
    if (this.product.merchantId) {
      let merchant = await RdbUtil.getUserById(this.product.merchantId);
      if (merchant) {
        this.merchantName = merchant.username; // 商家名即店铺名
        if (merchant.token) {
          this.merchantAvatar = merchant.token;
        }
      }
    }

    // [新增] 加载评价
    this.reviews = await RdbUtil.getReviewsByProduct(this.product.id);
  }

  async handleAddToCart() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    if (this.isAddedToCart) {
      promptAction.showToast({ message: '该商品已在购物车中' });
      return;
    }

    let success = await RdbUtil.addToCart(this.currentUser.id, this.product.id);
    if (success) {
      promptAction.showToast({ message: '已加入购物车' });
      this.isAddedToCart = true;
    } else {
      promptAction.showToast({ message: '加入失败' });
    }
  }

  // --- 立即购买逻辑 ---
  // 1. 用户点击“立即购买”按钮触发
  // 1. 用户点击“立即购买”按钮触发
  async handleBuy(): Promise<void> {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    // [修改] 直接赋值，不再需要 (as any)
    this.product.count = 1;

    // 跳转到确认订单页
    router.pushUrl({
      url: 'pages/OrderConfirmPage',
      params: {
        product: this.product
      }
    });
  }

  // 2. 密码输入正确后自动触发 (这里是真正的业务逻辑)
  async executeBuy(): Promise<void> {
    // 确定图片 Key
    let imgForDb: string;
    if (typeof this.product.image_url === 'string') {
      imgForDb = this.product.image_url;
    } else {
      imgForDb = 'ic_holder_computer';
    }

    promptAction.showToast({ message: '正在交易...' });

    // 调用数据库下单
    let code = await RdbUtil.createOrder(
      this.currentUser.id,
      this.product.name,
      this.product.price,
      imgForDb,
      this.product.merchantId
    );

    if (code === 1) {
      // 更新本地余额显示
      this.currentUser.balance -= this.product.price;
      // 持久化余额更新 (重要！)
      AppStorage.setOrCreate('currentUser', this.currentUser);

      promptAction.showToast({ message: '购买成功' });

      // 自动跳转到订单页查看
      setTimeout(() => {
        router.pushUrl({ url: 'pages/OrderListPage' });
      }, 500)

    } else if (code === -1) {
      promptAction.showToast({ message: '余额不足' });
    } else {
      promptAction.showToast({ message: '系统错误' });
    }
  }

  // [修改] 处理收藏点击
  async handleFav() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    if (this.isFavorite) {
      // 1. 如果已收藏 -> 取消收藏
      await RdbUtil.removeFavorite(this.currentUser.id, this.product.id);
      this.isFavorite = false;
      promptAction.showToast({ message: '已取消收藏' });
    } else {
      // 2. 如果未收藏 -> 添加收藏
      await RdbUtil.addFavorite(this.currentUser.id, this.product.id);
      this.isFavorite = true;
      promptAction.showToast({ message: '收藏成功' });
    }
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

          // ... 上面是价格和标题 ...

          // [新增] 店铺入口卡片
          Row() {
            Image(this.merchantAvatar)
              .width(40).height(40)
              .borderRadius(20)
              .backgroundColor('#F0F0F0')
              .margin({ right: 10 })

            Column() {
              Text(this.merchantName)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Text("正品保证 · 极速发货")
                .fontSize(12)
                .fontColor(Color.Gray)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Button("进店逛逛")
              .height(28)
              .fontSize(12)
              .backgroundColor(Color.White)
              .fontColor('#FF5000')
              .border({ width: 1, color: '#FF5000', radius: 14 })
              .onClick(() => {
                // 跳转到店铺页
                router.pushUrl({
                  url: 'pages/MerChantShopPage',
                  params: { merchantId: this.product.merchantId }
                })
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Color.White)
          .margin({ top: 10, bottom: 10 }) // 上下留白，区分区块

          // [新增] 评价列表区域
          Column() {
            Row() {
              Text(`商品评价 (${this.reviews.length})`).fontSize(16).fontWeight(FontWeight.Bold)
              Blank()
              Text("查看全部 >")
                .fontSize(12)
                .fontColor(Color.Gray)
                .onClick(() => {
                  // [新增] 跳转到全部评价页
                  router.pushUrl({
                    url: 'pages/ProductReviewsPage',
                    params: { productId: this.product.id }
                  })
                })
            }.width('100%').margin({ bottom: 10 })

            if (this.reviews.length === 0) {
              Text("暂无评价，快来抢沙发吧~").fontSize(14).fontColor(Color.Gray).padding(20)
            } else {
              List({ space: 15 }) {
                // 只展示前 3 条
                ForEach(this.reviews.slice(0, 3), (item: ReviewItem) => {
                  ListItem() {
                    Column() {
                      Row() {
                        Image(item.userAvatar || $r('app.media.ic_holder_computer'))
                          .width(24).height(24).borderRadius(12).margin({ right: 8 })
                        Text(item.userName).fontSize(12).fontColor(Color.Gray)
                        Blank()
                        // 简单的星星展示
                        Row() {
                          ForEach([1,2,3,4,5], (star: number) => {
                            if (star <= item.rating) Text("★").fontColor('#FF5000').fontSize(10)
                          })
                        }
                      }.width('100%').margin({ bottom: 5 })

                      Text(item.content).fontSize(14).maxLines(2).textOverflow({overflow: TextOverflow.Ellipsis})
                    }.alignItems(HorizontalAlign.Start)
                  }
                })
              }
            }
          }
          .padding(16).backgroundColor(Color.White).width('100%')
          .margin({ top: 10, bottom: 80 }) // 底部留白给操作栏

          // ... 下面是 Divider 和 商品详情描述 ...
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

      Row() {
        Column() {
          // [修改] 根据 isFavorite 改变颜色
          Text("★")
            .fontSize(20)
            .fontColor(this.isFavorite ? Color.Orange : Color.Gray) // 核心修改：动态颜色

          Text(this.isFavorite ? "已收藏" : "收藏") // 可选：文字也跟着变
            .fontSize(10)
            .fontColor(this.isFavorite ? Color.Orange : Color.Gray)
        }
        .justifyContent(FlexAlign.Center)
        .width(50)
        .onClick(() => this.handleFav())
        .backgroundColor(Color.White)

        Button(this.isAddedToCart ? "已在购物车" : "加入购物车")
          .type(ButtonType.Normal)
          .backgroundColor(this.isAddedToCart ? '#FFCC99' : '#FF9900')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(40)
          .borderRadius({ topLeft: 20, bottomLeft: 20 })
          .margin({ left: 10 })
          .enabled(!this.isAddedToCart)
          .onClick(() => this.handleAddToCart())

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