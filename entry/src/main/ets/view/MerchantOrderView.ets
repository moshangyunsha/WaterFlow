import RdbUtil, { OrderItem } from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';

@Component
export struct MerchantOrderView {
  @Prop @Watch('refreshData') refreshTrigger: number = 0;
  @State orderList: OrderItem[] = [];
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  async aboutToAppear() {
    this.refreshData();
  }

  async refreshData() {
    if (this.currentUser.id) {
      // 获取当前商家的订单
      this.orderList = await RdbUtil.getMerchantOrders(this.currentUser.id);
    }
  }

  // 发货逻辑
  async handleShip(order: OrderItem) {
    let success = await RdbUtil.updateOrderStatus(order.id, 1); // 1 = Shipped
    if (success) {
      promptAction.showToast({ message: '发货成功' });
      this.refreshData();
    } else {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  getImage(key: string): ResourceStr {
    if (key.startsWith('file://')) return key;
    if (key === 'ic_holder_50e') return $r('app.media.ic_holder_50e');
    if (key === 'ic_holder_xs2') return $r('app.media.ic_holder_xs2');
    if (key === 'ic_holder_computer') return $r('app.media.ic_holder_computer');
    return $r('app.media.ic_holder_computer');
  }

  getStatusText(status: number): string {
    switch (status) {
      case 0: return '待发货';
      case 1: return '已发货';
      case 2: return '已完成';
      default: return '未知';
    }
  }

  build() {
    Column() {
      Row() {
        Text("订单管理").fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 15 })
      }.width('100%').padding(15).backgroundColor(Color.White)

      if (this.orderList.length === 0) {
        Column() {
          Text("暂无订单").fontColor(Color.Gray)
        }.height('80%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.orderList, (order: OrderItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`订单号: ${order.id}`).fontSize(12).fontColor(Color.Gray)
                  Blank()
                  Text(this.getStatusText(order.status))
                    .fontSize(12)
                    .fontColor(order.status === 0 ? Color.Red : Color.Green)
                }.width('100%').margin({bottom: 10})

                Row() {
                  Image(this.getImage(order.imgUrl))
                    .width(60).height(60).objectFit(ImageFit.Cover).borderRadius(8)

                  Column() {
                    Text(order.title).fontSize(16).maxLines(1)
                    Text(`¥${order.price.toFixed(2)}`).fontColor(Color.Red).margin({ top: 5 })
                    Text(order.date).fontSize(12).fontColor(Color.Gray).margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 10 })
                  .layoutWeight(1)
                }

                // 操作栏
                Row() {
                  Blank()
                  if (order.status === 0) {
                    Button("立即发货")
                      .fontSize(12)
                      .height(28)
                      .backgroundColor('#007DFF')
                      .onClick(() => this.handleShip(order))
                  } else if (order.status === 1) {
                    Text("等待买家收货").fontSize(12).fontColor(Color.Gray)
                  } else {
                    Text("交易已完成").fontSize(12).fontColor(Color.Gray)
                  }
                }.width('100%').margin({top: 10})
              }
              .padding(10).backgroundColor(Color.White).borderRadius(10)
            }
          })
        }.width('95%').layoutWeight(1).margin({top: 10})
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}