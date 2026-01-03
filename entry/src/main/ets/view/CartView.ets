import RdbUtil, { CartItem } from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';
import ProductService from '../service/ProductService';
import router from '@ohos.router';
import { PayPasswordDialog } from './PayPasswordDialog';

@Component
export struct CartView {
  @Prop @Watch('refreshData') refreshTrigger: number = 0;
  @State cartList: CartItem[] = [];
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  @State selectedCartIds: number[] = [];

  // [新增] 暂存当前要支付的总金额
  @State payAmount: number = 0;

  // [新增] 初始化自定义弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PayPasswordDialog({
      price: this.payAmount,
      // 这里的箭头函数就是“密码正确”后要执行的代码
      action: () => this.executePaymentTransaction()
    }),
    autoCancel: true, // 点击空白处关闭
    alignment: DialogAlignment.Center // 居中显示
  });

  async aboutToAppear(): Promise<void> {
    this.refreshData();
  }

  async refreshData(): Promise<void> {
    if (this.currentUser.id) {
      this.cartList = await ProductService.getCartList(this.currentUser.id);
      this.selectedCartIds = [];
    }
  }

  async handleDelete(item: CartItem): Promise<void> {
    await RdbUtil.deleteCartItem(item.cartId);
    this.selectedCartIds = this.selectedCartIds.filter(id => id !== item.cartId);
    this.refreshData();
  }

  // 修改商品数量
  async changeCount(item: CartItem, delta: number): Promise<void> {
    if (!this.currentUser || this.currentUser.id === 0) return;

    // 如果当前数量是 1 且用户点减号，直接触发删除逻辑或提示
    if (item.count === 1 && delta === -1) {
      this.handleDelete(item);
      return;
    }

    // 调用已有的 addToCart 方法，传入 delta (1 或 -1)
    // 注意：item.id 在这里就是 productId
    let success = await RdbUtil.addToCart(this.currentUser.id, item.id, delta);

    if (success) {
      // 成功后重新加载数据，界面会自动刷新
      this.refreshData();
    }
  }

  /*
  async handleCheckout() {
    if (this.selectedCartIds.length === 0) {
      promptAction.showToast({ message: '请先勾选商品' });
      return;
    }

    let totalAmount = 0;
    let checkoutItems: CartItem[] = [];

    this.cartList.forEach(item => {
      if (this.selectedCartIds.includes(item.cartId)) {
        totalAmount += item.price * item.count;
        checkoutItems.push(item);
      }
    });

    if (this.currentUser.balance < totalAmount) {
      promptAction.showToast({ message: `余额不足，还需要 ¥${(totalAmount - this.currentUser.balance).toFixed(2)}` });
      return;
    }

    let successCount = 0;
    for (let item of checkoutItems) {
      // [修改] 传递 merchantId
      // 注意: item.merchantId 继承自 ProductItem
      let code = await RdbUtil.createOrder(
        this.currentUser.id,
        item.name,
        item.price * item.count,
        'ic_holder_computer', // 兜底图片
        item.merchantId // 传入商家ID
      );

      if (code === 1) {
        await RdbUtil.deleteCartItem(item.cartId);
        successCount++;
        this.currentUser.balance -= (item.price * item.count);
      }
    }

    promptAction.showToast({ message: `成功结算 ${successCount} 件商品` });
    this.refreshData();
  }
  * */

  // [修改] 点击结算，不再弹窗，而是跳转到确认页
  async handleCheckout(): Promise<void> {
    // 1. 基础校验
    const checkoutItems = this.cartList.filter(item => this.selectedCartIds.includes(item.cartId));
    if (checkoutItems.length === 0) {
      promptAction.showToast({ message: '请先勾选要结算的商品' });
      return;
    }

    // 2. 跳转到确认订单页，并传递选中的商品
    try {
      router.pushUrl({
        url: 'pages/OrderConfirmPage',
        params: {
          products: checkoutItems, // 传递商品数组
          fromCart: true           // [可选] 标记来自购物车，方便后续扩展清理逻辑
        }
      });
    } catch (err) {
      console.error(`Checkout jump failed: ${JSON.stringify(err)}`);
    }
  }

  // [新增] 核心支付交易逻辑 (数据库操作)
  async executePaymentTransaction(): Promise<void> {
    // 这里就是之前那堆扣钱、生订单的逻辑
    // 1. 获取要买的商品
    const checkoutItems = this.cartList.filter(item => this.selectedCartIds.includes(item.cartId));

    // 2. 模拟网络延迟 Loading (可选，增加真实感)
    promptAction.showToast({ message: '正在安全支付...' });

    try {
      // A. 扣余额
      let newBalance = this.currentUser.balance - this.payAmount;
      let updateSuccess = await RdbUtil.updateUserBalance(this.currentUser.id, newBalance);

      if (updateSuccess) {
        this.currentUser.balance = newBalance;
        // 更新并持久化
        AppStorage.setOrCreate('currentUser', this.currentUser);

        // B. 生成订单
        for (let item of checkoutItems) {
          await RdbUtil.addOrder(
            this.currentUser.id,
            item.merchantId,
            item.name,
            item.price * item.count,
            item.image_url as string
          );
          // C. 删购物车
          await RdbUtil.deleteCartItem(item.cartId);
        }

        // 成功提示
        promptAction.showToast({ message: '支付成功！' });
        this.refreshData(); // 刷新页面

        // D. 跳转订单页 (完美闭环)
        setTimeout(() => {
          router.pushUrl({ url: 'pages/OrderListPage' });
        }, 500)

      }
    } catch (error) { // 这里写 error 或者 e 都可以
      // [修改] 加上 JSON.stringify 转换，或者干脆不打印 error 对象
      console.error(`Pay failed`);
      promptAction.showToast({ message: '支付异常' });
    }
  }

  toggleSelect(cartId: number, isSelected: boolean) {
    if (isSelected) {
      this.selectedCartIds.push(cartId);
    } else {
      this.selectedCartIds = this.selectedCartIds.filter(id => id !== cartId);
    }
  }

  build() {
    Column() {
      Text("购物车").fontSize(20).fontWeight(FontWeight.Bold).margin(20)

      if (this.cartList.length === 0) {
        Column() {
          Image($r('app.media.ic_holder_computer')).width(100).height(100).opacity(0.3).margin({bottom: 10})
          Text("购物车是空的").fontColor(Color.Gray)
        }.height('80%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.cartList, (item: CartItem) => {
            ListItem() {
              Row() {
                Checkbox()
                  .select(this.selectedCartIds.includes(item.cartId))
                  .selectedColor('#FF5000')
                  .onChange((val) => this.toggleSelect(item.cartId, val))
                  .margin({ right: 10 })

                Image(item.image_url).width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)

                Column() {
                  Text(item.name).fontSize(16).maxLines(1).fontWeight(FontWeight.Bold)
                  Text(`单价: ¥${item.price.toFixed(2)}`).fontColor(Color.Gray).fontSize(12).margin({top:5})
                  Row() {
                    //Text(`数量: ${item.count}`).fontSize(14)
                    Row({ space: 8 }) {
                      // 减号按钮
                      Button() {
                        Text("-").fontSize(14).fontColor(Color.Black)
                      }
                      .type(ButtonType.Normal)
                      .width(24).height(24)
                      .borderRadius(4)
                      .backgroundColor('#F5F5F5')
                      .onClick(() => this.changeCount(item, -1))

                      // 数量显示
                      Text(`${item.count}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .width(30)
                        .textAlign(TextAlign.Center)

                      // 加号按钮
                      Button() {
                        Text("+").fontSize(14).fontColor(Color.Black)
                      }
                      .type(ButtonType.Normal)
                      .width(24).height(24)
                      .borderRadius(4)
                      .backgroundColor('#F5F5F5')
                      .onClick(() => this.changeCount(item, 1))
                    }
                    .alignItems(VerticalAlign.Center)
                    Blank()
                    Text(`¥${(item.price * item.count).toFixed(2)}`).fontColor(Color.Red).fontWeight(FontWeight.Bold)
                  }.width('100%').margin({top: 5})
                }
                .layoutWeight(1).padding({left: 10}).alignItems(HorizontalAlign.Start)

                Button("删除").backgroundColor(Color.Red).height(30).fontSize(12)
                  .margin({left: 10})
                  .onClick(() => this.handleDelete(item))
              }
              .padding(10).backgroundColor(Color.White).borderRadius(10)
            }
          })
        }.layoutWeight(1).width('95%')

        Row() {
          Text(`合计: ¥${this.cartList.reduce((sum, item) => {
            return sum + (this.selectedCartIds.includes(item.cartId) ? item.price * item.count : 0)
          }, 0).toFixed(2)}`)
            .fontColor(Color.Red).fontWeight(FontWeight.Bold).fontSize(18)

          Button(`去结算(${this.selectedCartIds.length})`)
            .backgroundColor(this.selectedCartIds.length > 0 ? '#FF5000' : '#CCCCCC')
            .enabled(this.selectedCartIds.length > 0)
            .onClick(() => this.handleCheckout())
        }
        .width('100%').padding(15).backgroundColor(Color.White).justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}


/*
// --- [新增] 支付密码弹窗组件 ---
@CustomDialog
struct PayPasswordDialog {
  controller: CustomDialogController
  // [修改] 给个默认值 0
  price: number = 0
  // [修改] 给个空函数的默认值
  action: () => void = () => {}

  @State inputPass: string = ''

  build() {
    Column() {
      // 标题
      Text('请输入支付密码').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })

      // 金额显示
      Text(`¥${this.price.toFixed(2)}`)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .margin({ top: 15, bottom: 15 })

      Divider().color('#F5F5F5')

      // 支付方式模拟
      Row() {
        Text("支付方式").fontColor(Color.Gray)
        Blank()
        Text("账户余额").fontColor('#007DFF')
      }.width('90%').height(50)

      Divider().color('#F5F5F5')

      // 密码输入框
      TextInput({ placeholder: '请输入 6 位支付密码', text: this.inputPass })
        .type(InputType.Password) // 密码模式
        .maxLength(6)             // 限制长度
        .width('90%')
        .height(50)
        .margin({ top: 20 })
        .backgroundColor('#F5F5F5')
        .textAlign(TextAlign.Center)
        .onChange((val) => {
          this.inputPass = val
        })

      // 按钮组
      Row() {
        Button('取消')
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })

        Button('确认支付')
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .margin({ left: 15 })
          .onClick(() => {
            // [模拟安全校验] 强制密码为 123456
            if (this.inputPass === '123456') {
              this.controller.close() // 关闭弹窗
              this.action()           // 执行父组件传进来的支付逻辑
            } else {
              // 提示错误
              promptAction.showToast({ message: '密码错误（测试密码：123456）' })
            }
          })
      }
      .width('90%')
      .margin({ top: 20, bottom: 20 })
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('85%') // 弹窗宽度
  }
}
*/