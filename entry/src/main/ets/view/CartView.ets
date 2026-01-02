import RdbUtil, { CartItem } from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';
import ProductService from '../service/ProductService';

@Component
export struct CartView {
  @Prop @Watch('refreshData') refreshTrigger: number = 0;
  @State cartList: CartItem[] = [];
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  @State selectedCartIds: number[] = [];

  async aboutToAppear() {
    this.refreshData();
  }

  async refreshData() {
    if (this.currentUser.id) {
      this.cartList = await ProductService.getCartList(this.currentUser.id);
      this.selectedCartIds = [];
    }
  }

  async handleDelete(item: CartItem) {
    await RdbUtil.deleteCartItem(item.cartId);
    this.selectedCartIds = this.selectedCartIds.filter(id => id !== item.cartId);
    this.refreshData();
  }

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
                    Text(`数量: ${item.count}`).fontSize(14)
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