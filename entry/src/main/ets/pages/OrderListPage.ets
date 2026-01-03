import { OrderItem } from '../common/utils/RdbUtil';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { ReviewDialog } from '../view/ReviewDialog';

@Entry
@Component
struct OrderListPage {
  @State orderList: OrderItem[] = [];

  // 1. 获取状态栏高度
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  // [修复] 补上这一行！否则 this.currentUser 会报错
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  // 临时存储当前要评价的订单信息
  @State currentReviewOrder: OrderItem | null = null;

  // 评价弹窗
  reviewController: CustomDialogController = new CustomDialogController({
    builder: ReviewDialog({
      action: (rating, content) => this.submitReview(rating, content)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  async submitReview(rating: number, content: string): Promise<void> {
    if (!this.currentReviewOrder) return;

    // [变通] 通过商品名反查商品ID
    let products = await RdbUtil.searchProducts(this.currentReviewOrder.title);
    let productId = products.length > 0 ? products[0].id : 0;

    // 这里的 this.currentUser 现在可以正常访问了
    let success = await RdbUtil.addReview(
      this.currentReviewOrder.id,
      productId,
      this.currentUser.id,
      rating,
      content
    );

    if (success) {
      promptAction.showToast({ message: '评价成功' });
      // 这里的逻辑可以优化：评价成功后，刷新一下列表，或者本地更新该订单状态
    }
  }

  // 触发评价
  handleReview(item: OrderItem) {
    this.currentReviewOrder = item;
    this.reviewController.open();
  }

  // [新增] 点击订单跳转到商品详情
  async handleToDetail(orderName: string) {
    // 因为订单表没存 productId，只能用名字反查
    // 这在真实项目中是不严谨的，但在当前数据库结构下是唯一解法
    let products = await RdbUtil.searchProducts(orderName);

    if (products.length > 0) {
      // 找到商品，跳转详情页
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: products[0] // 传递商品对象
      });
    } else {
      promptAction.showToast({ message: '该商品已下架或不存在' });
    }
  }

  async aboutToAppear() {
    this.refreshData();
  }

  async refreshData() {
    // [优化] 既然定义了 currentUser，这里直接用 this.currentUser 即可
    if (this.currentUser && this.currentUser.id) {
      this.orderList = await RdbUtil.getMyOrders(this.currentUser.id);
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

  getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#FF9900';
      case 1: return '#007DFF';
      case 2: return '#00AA00';
      default: return '#999999';
    }
  }

  // [修改] 确认收货 - 增加二次确认弹窗
  async handleConfirmReceipt(order: OrderItem) {
    AlertDialog.show({
      title: '确认收货',
      message: '您确认已收到商品且无质量问题吗？\n\n确认收货后订单将标记为完成，且资金将结算给商家。',
      autoCancel: true, // 点击遮罩层关闭
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '还未收到',
        action: () => {
          // 点击取消，什么都不做
        }
      },
      secondaryButton: {
        value: '确认收货',
        fontColor: Color.Red, // 警示色
        action: async () => {
          // 1. 更新订单状态为 2 (已完成)
          let success = await RdbUtil.updateOrderStatus(order.id, 2);

          if (success) {
            promptAction.showToast({ message: '交易完成！快去评价吧' });
            // 2. 刷新列表 (此时该订单状态变为2，"确认收货"按钮消失，"评价"按钮出现)
            this.refreshData();
          } else {
            promptAction.showToast({ message: '操作失败，请重试' });
          }
        }
      }
    })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("<")
          .fontSize(24)
          .width(40).height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())

        Text("我的订单").fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({
        top: 10 + this.getUIContext().px2vp(this.topRectHeight), // 加上状态栏高度
        bottom: 10,
        left: 10,
        right: 10
      })
      .backgroundColor(Color.White)

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

              // [修改] 给商品展示区域添加 onClick
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
              .onClick(() => {
                // [新增] 点击跳转
                this.handleToDetail(order.title);
              })

              /*
              Row() {
                Image(this.getImage(order.imgUrl))
                  .width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
                  .margin({ right: 10 })

                Column() {
                  Text(order.title).fontSize(16).maxLines(1)
                  Text(`¥${order.price.toFixed(2)}`).fontColor(Color.Red).margin({ top: 5 })
                  Text(order.date).fontSize(12).fontColor(Color.Gray).margin({ top: 5 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }*/

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
              // 在 "已完成" 状态显示评价按钮
              if (order.status === 2) {
                Button("评价")
                  .fontSize(12)
                  .height(28)
                  .backgroundColor(Color.White)
                  .fontColor('#FF5000')
                  .border({ width: 1, color: '#FF5000', radius: 14 })
                  .margin({ left: 10 })
                  .onClick(() => this.handleReview(order))
              }
            }
            .padding(10).backgroundColor(Color.White).borderRadius(10)
          }
        })
      }.layoutWeight(1).width('95%').margin({top: 10})
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}