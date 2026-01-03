import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { User } from '../viewmodel/User';
import ProductItem from '../viewmodel/ProductItem';
import RdbUtil, { AddressItem } from '../common/utils/RdbUtil';
import { PayPasswordDialog } from '../view/PayPasswordDialog';

@Entry
@Component
struct OrderConfirmPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  // 订单商品列表
  @State orderProducts: ProductItem[] = [];
  @State totalAmount: number = 0;

  // 当前选中的地址
  @State currentAddress: AddressItem | null = null;

  // 支付弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PayPasswordDialog({
      price: this.totalAmount,
      action: () => this.createOrder() // 密码正确后调用创建订单
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  async onPageShow(): Promise<void> {
    // 1. 获取传递过来的商品数据 (如果是第一次进入)
    // 注意：router.getParams() 在返回时也会携带数据，需要区分
    let params = router.getParams() as Record<string, Object>;

    // 情况A: 从地址列表选完返回
    if (params && params['selectedAddress']) {
      this.currentAddress = params['selectedAddress'] as AddressItem;
      // 商品数据需要从本地状态维持，或者重新传（这里简化逻辑，假设商品数据已在 state 中）
      // *注意*：实际开发中，router.back 传参比较麻烦，建议用 AppStorage 或全局变量暂存订单商品
      // 这里为了演示流畅，如果 orderProducts 为空才去读 params 里的 product
    }

    // 情况B: 从商品详情页/购物车进来
    if (this.orderProducts.length === 0 && params) {
      if (params['product']) {
        // 单个商品购买
        let p = params['product'] as ProductItem;
        // 确保有 count 属性，如果没有默认为 1
        if (!p.count) { p.count = 1; }
        this.orderProducts = [p];
      } else if (params['products']) {
        // 购物车多商品结算
        this.orderProducts = params['products'] as ProductItem[];
      }
      this.calculateTotal();
    }

    // 2. 如果还没有地址，去数据库查默认地址
    if (!this.currentAddress) {
      await this.loadDefaultAddress();
    }
  }

  async loadDefaultAddress(): Promise<void> {
    let list = await RdbUtil.getAddressList(this.currentUser.id);
    if (list.length > 0) {
      // RdbUtil 里的 getAddressList 已经把默认地址排在第一个了
      this.currentAddress = list[0];
    }
  }

  calculateTotal() {
    this.totalAmount = this.orderProducts.reduce((sum, item) => {
      // 兼容 ProductItem 和 CartItem (CartItem 有 count 属性)
      let count = item.count || 1;
      return sum + item.price * count;
    }, 0);
  }

  // 提交订单逻辑
  async handleSubmit(): Promise<void> {
    if (!this.currentAddress) {
      promptAction.showToast({ message: '请选择收货地址' });
      return;
    }
    if (this.currentUser.balance < this.totalAmount) {
      promptAction.showToast({ message: '余额不足' });
      return;
    }
    // 弹出支付密码
    this.dialogController.open();
  }

  // 真正的写库操作 (支付密码验证通过后回调)
  async createOrder(): Promise<void> {
    try {
      // 1. 扣余额
      let newBalance = this.currentUser.balance - this.totalAmount;
      await RdbUtil.updateUserBalance(this.currentUser.id, newBalance);
      this.currentUser.balance = newBalance;
      AppStorage.SetOrCreate('currentUser', this.currentUser);

      // 2. 循环创建订单
      for (let item of this.orderProducts) {
        let count = item.count || 1;
        let imgKey = typeof item.image_url === 'string' ? item.image_url : 'ic_holder_computer';

        // 这里的 item.name 建议拼接上 "x2" 这样的数量信息，或者订单表加个 Count 字段
        // 为了不改表结构，暂时拼接到标题里
        let title = count > 1 ? `${item.name} x${count}` : item.name;

        await RdbUtil.addOrder(
          this.currentUser.id,
          item.merchantId,
          title,
          item.price * count,
          imgKey
        );
        // [新增] 如果该商品有 cartId (说明来自购物车)，则从购物车表中删除
        // 注意：ProductItem 默认没有 cartId，但如果是从 CartView 传过来的 CartItem 是有的
        // 这里用 as any 临时访问一下，或者你去 ProductItem 加个 cartId 字段
        let cId = item.cartId;
        if (cId) {
          await RdbUtil.deleteCartItem(cId);
        }
      }

      promptAction.showToast({ message: '支付成功' });

      // 跳转到订单列表，并清空路由栈防止返回支付页
      router.replaceUrl({ url: 'pages/OrderListPage' });

    } catch (e) {
      promptAction.showToast({ message: '订单创建失败' });
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text("<").fontSize(24).width(40).height(40).textAlign(TextAlign.Center).onClick(() => router.back())
        Text("确认订单").fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: 10 }).backgroundColor(Color.White)

      Scroll() {
        Column({ space: 12 }) {
          // --- 地址卡片 ---
          Row() {
            Image($r('app.media.ic_holder_computer')) // 哪怕用个定位图标也好
              .width(20).height(20).margin({right: 10}).opacity(0.5)

            if (this.currentAddress) {
              Column() {
                Row() {
                  Text(this.currentAddress.tag).fontSize(10).fontColor(Color.White).backgroundColor('#007DFF').padding(3).borderRadius(3).margin({right:5})
                  Text(`${this.currentAddress.name}  ${this.currentAddress.phone}`).fontSize(16).fontWeight(FontWeight.Bold)
                }.margin({bottom: 5})
                Text(this.currentAddress.address).fontSize(14).fontColor('#666').maxLines(2)
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            } else {
              Text("请选择收货地址").fontSize(16).fontWeight(FontWeight.Bold).layoutWeight(1)
            }

            Text(">").fontColor('#999').fontSize(18)
          }
          .width('100%')
          .padding(15)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            // 跳转去选地址
            router.pushUrl({
              url: 'pages/AddressListPage',
              params: { isSelectMode: true }
            })
          })

          // --- 商品清单 ---
          List({ space: 10 }) {
            ForEach(this.orderProducts, (item: ProductItem) => {
              ListItem() {
                Row() {
                  Image(item.image_url).width(70).height(70).borderRadius(6).objectFit(ImageFit.Cover).backgroundColor('#F5F5F5')
                  Column() {
                    Text(item.name).fontSize(14).maxLines(2).textOverflow({overflow: TextOverflow.Ellipsis})
                    Blank()
                    Row() {
                      Text(`¥${item.price.toFixed(2)}`).fontColor(Color.Red).fontWeight(FontWeight.Bold)
                      // 显示数量
                      Text(`x${item.count || 1}`).fontColor('#999').fontSize(12)
                    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
                  }
                  .layoutWeight(1)
                  .height(70)
                  .padding({left: 10, top: 2, bottom: 2})
                  .alignItems(HorizontalAlign.Start)
                }
                .padding(10).backgroundColor(Color.White).borderRadius(12)
              }
            })
          }

          // --- 价格明细 ---
          Column() {
            Row() { Text("商品总额").fontColor('#666'); Text(`¥${this.totalAmount.toFixed(2)}`).fontColor('#333') }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({bottom: 8})
            Row() { Text("运费").fontColor('#666'); Text("¥0.00").fontColor('#333') }.width('100%').justifyContent(FlexAlign.SpaceBetween)
          }
          .padding(15).backgroundColor(Color.White).borderRadius(12)

        }.padding(12)
      }.layoutWeight(1)

      // --- 底部结算栏 ---
      Row() {
        Text(`实付款: `).fontSize(14)
        Text(`¥${this.totalAmount.toFixed(2)}`).fontSize(20).fontColor('#FF5000').fontWeight(FontWeight.Bold).margin({right: 15})

        Button("立即支付")
          .height(40)
          .width(120)
          .backgroundColor('#FF5000')
          .onClick(() => this.handleSubmit())
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 + this.getUIContext().px2vp(0) }) // 简单适配底部
      .backgroundColor(Color.White)
      .shadow({radius: 10, color: '#1A000000', offsetY: -2})
    }
    .height('100%').backgroundColor('#F1F3F5')
  }
}