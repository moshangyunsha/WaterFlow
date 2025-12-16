import { OrderItem } from '../common/utils/RdbUtil';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import ProductService from '../service/ProductService'; // 需要 Service 来解析图片

@Entry
@Component
struct OrderListPage {
  @State orderList: OrderItem[] = [];

  async aboutToAppear() {
    let user = AppStorage.Get<User>('currentUser');
    if (user && user.id) {
      let rawOrders = await RdbUtil.getMyOrders(user.id);

      // 需要处理订单图片的映射 (String -> Resource)
      // 这里逻辑比较简单：因为 Service 里的 MAP 是私有的，我们可以复制一份逻辑，
      // 或者简单点：如果 imgUrl 在 Service 的 keys 里，就转换。
      // 为了简便，我们直接在 UI 里判断
      this.orderList = rawOrders;
    }
  }

  // 辅助函数：解析图片
  getImage(key: string): ResourceStr {
    // 这里简单硬编码映射，或者你可以把 MAP 提到公共文件
    if (key.startsWith('file://')) return key;
    if (key === 'ic_holder_50e') return $r('app.media.ic_holder_50e');
    if (key === 'ic_holder_xs2') return $r('app.media.ic_holder_xs2');
    if (key === 'ic_holder_computer') return $r('app.media.ic_holder_computer');
    // ... 建议把 ProductService 里的 MAP export 出来复用
    return $r('app.media.ic_holder_computer'); // 兜底
  }

  build() {
    Column() {
      Text("我的订单").fontSize(20).fontWeight(FontWeight.Bold).margin(20)

      List({ space: 10 }) {
        ForEach(this.orderList, (order: OrderItem) => {
          ListItem() {
            Row() {
              // 显示图片
              Image(this.getImage(order.imgUrl))
                .width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
                .margin({ right: 10 })

              Column() {
                Text(order.title).fontSize(16).maxLines(1)
                Text(`¥${order.price}`).fontColor(Color.Red).margin({ top: 5 })
                Text(order.date).fontSize(12).fontColor(Color.Gray).margin({ top: 5 })
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
            }
            .padding(10).backgroundColor(Color.White).borderRadius(10)
          }
        })
      }.layoutWeight(1).width('95%')
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}