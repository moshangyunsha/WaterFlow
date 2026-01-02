import { OrderItem } from '../common/utils/RdbUtil';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

@Entry
@Component
struct OrderListPage {
  @State orderList: OrderItem[] = [];

  async aboutToAppear() {
    this.refreshData();
  }

  async refreshData() {
    let user = AppStorage.Get<User>('currentUser');
    if (user && user.id) {
      this.orderList = await RdbUtil.getMyOrders(user.id);
    }
  }

  getImage(key: string): ResourceStr {
    if (key.startsWith('file://')) return key;
    if (key === 'ic_holder_50e') return $r('app.media.ic_holder_50e');
    if (key === 'ic_holder_xs2') return $r('app.media.ic_holder_xs2');
    if (key === 'ic_holder_computer') return $r('app.media.ic_holder_computer');
    return $r('app.media.ic_holder_computer');
  }

  // 获取状态文本
  getStatusText(status: number): string {
    switch (status) {
      case 0: return '待发货';
      case 1: return '已发货';
      case 2: return '已完成';
      default: return '未知';
    }
  }

  // 获取状态颜色
  getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#FF9900'; // Orange
      case 1: return '#007DFF'; // Blue
      case 2: return '#00AA00'; // Green
      default: return '#999999';
    }
  }

  // 确认收货逻辑
  async handleConfirmReceipt(order: OrderItem) {
    let success = await RdbUtil.updateOrderStatus(order.id, 2); // 2 = Completed
    if (success) {
      promptAction.showToast({ message: '已确认收货' });
      this.refreshData();
    } else {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  build() {
    Column() {
      Row() {
        Text("<").fontSize(24).onClick(() => router.back()).padding(10)
        Text("我的订单").fontSize(20).fontWeight(FontWeight.Bold)
      }.width('100%').padding({top: 10})

      List({ space: 10 }) {
        ForEach(this.orderList, (order: OrderItem) => {
          ListItem() {
            Column() {
              Row() {
                Text(`订单号: ${order.id}`).fontSize(12).fontColor(Color.Gray)
                Blank()
                Text(this.getStatusText(order.status))
                  .fontSize(12)
                  .fontColor(this.getStatusColor(order.status))
              }.width('100%').margin({bottom: 10})

              Row() {
                Image(this.getImage(order.imgUrl))
                  .width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
                  .margin({ right: 10 })

                Column() {
                  Text(order.title).fontSize(16).maxLines(1)
                  Text(`¥${order.price.toFixed(2)}`).fontColor(Color.Red).margin({ top: 5 })
                  Text(order.date).fontSize(12).fontColor(Color.Gray).margin({ top: 5 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }

              // 如果已发货，显示确认收货按钮
              if (order.status === 1) {
                Row() {
                  Blank()
                  Button("确认收货")
                    .fontSize(12)
                    .height(28)
                    .backgroundColor('#FF5000')
                    .onClick(() => this.handleConfirmReceipt(order))
                }.width('100%').margin({top: 10})
              }
            }
            .padding(10).backgroundColor(Color.White).borderRadius(10)
          }
        })
      }.layoutWeight(1).width('95%')
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}