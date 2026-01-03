import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { User } from '../viewmodel/User';
import RdbUtil, { OrderItem } from '../common/utils/RdbUtil';

@Entry
@Component
struct MerchantOrderPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @State orderList: OrderItem[] = [];

  async onPageShow() {
    this.refreshData();
  }

  async refreshData() {
    if (this.currentUser.id && this.currentUser.role === 1) {
      // 调用 RdbUtil 里已有的 getMerchantOrders 方法
      this.orderList = await RdbUtil.getMerchantOrders(this.currentUser.id);
    }
  }

  // 商家发货逻辑
  async handleShip(order: OrderItem) {
    AlertDialog.show({
      title: '确认发货',
      message: `订单号：${order.id}\n商品：${order.title}\n\n确定要执行发货操作吗？`,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '确认发货',
        fontColor: '#007DFF',
        action: async () => {
          // 将状态从 0 改为 1
          let success = await RdbUtil.updateOrderStatus(order.id, 1);
          if (success) {
            promptAction.showToast({ message: '发货成功' });
            this.refreshData(); // 刷新列表
          } else {
            promptAction.showToast({ message: '操作失败' });
          }
        }
      }
    })
  }

  getStatusText(status: number): string {
    switch (status) {
      case 0: return '待发货';
      case 1: return '已发货';
      case 2: return '已完成';
      default: return '未知';
    }
  }

  getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#FF9900'; // 橙色警告
      case 1: return '#007DFF'; // 蓝色进行中
      case 2: return '#00AA00'; // 绿色完成
      default: return '#999999';
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("<").fontSize(24).width(40).height(40).textAlign(TextAlign.Center).onClick(() => router.back())
        Text("订单管理(商家)").fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: 10 })
      .backgroundColor(Color.White)

      if (this.orderList.length === 0) {
        Column() {
          Text("暂无订单").fontColor(Color.Gray).margin({ top: 100 })
        }.width('100%')
      } else {
        List({ space: 10 }) {
          ForEach(this.orderList, (order: OrderItem) => {
            ListItem() {
              Column() {
                // 订单头部
                Row() {
                  Text(`订单号: ${order.id}`).fontSize(12).fontColor(Color.Gray)
                  Blank()
                  Text(this.getStatusText(order.status))
                    .fontSize(12)
                    .fontColor(this.getStatusColor(order.status))
                }.width('100%').margin({ bottom: 10 })

                // 订单内容
                Row() {
                  Image(order.imgUrl.startsWith('http') || order.imgUrl.startsWith('file') ? order.imgUrl : $r('app.media.ic_holder_computer'))
                    .width(60).height(60).borderRadius(4).margin({ right: 10 })

                  Column() {
                    Text(order.title).fontSize(16).maxLines(1).fontWeight(FontWeight.Bold)
                    Text(`成交价: ¥${order.price.toFixed(2)}`).fontColor(Color.Red).fontSize(14).margin({ top: 5 })
                    Text(order.date).fontSize(12).fontColor(Color.Gray).margin({ top: 5 })
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                }

                // 操作栏
                // 只有状态为 0 (待发货) 时，显示发货按钮
                if (order.status === 0) {
                  Divider().color('#F5F5F5').margin({ top: 10, bottom: 10 })
                  Row() {
                    Blank()
                    Button("立即发货")
                      .fontSize(12)
                      .height(28)
                      .backgroundColor('#007DFF')
                      .onClick(() => this.handleShip(order))
                  }.width('100%')
                }
              }
              .padding(15).backgroundColor(Color.White).borderRadius(10)
            }
          })
        }
        .layoutWeight(1).width('95%').margin({ top: 10 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}