import router from '@ohos.router';
// 修改 1: 引用 ProductService
import ProductService from '../service/ProductService';
import ProductItem from '../viewmodel/ProductItem';
import { User } from '../viewmodel/User';

@Entry
@Component
struct MyFavoritesPage {
  @State favoriteList: ProductItem[] = [];

  async aboutToAppear() {
    let user = AppStorage.Get<User>('currentUser');
    if (user && user.id) {
      // 修改 2: 调用 Service 层的方法，获取带图片资源的商品列表
      this.favoriteList = await ProductService.getMyFavorites(user.id);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text("<") // 如果没有这个图，可用 Text("<") 代替
          .width(24).height(24).margin({right: 10})
          .onClick(() => router.back())
        Text("我的收藏").fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding(15)

      if (this.favoriteList.length === 0) {
        Text("暂无收藏，快去首页逛逛吧").fontColor(Color.Gray).margin({ top: 100 })
      } else {
        List({ space: 10 }) {
          ForEach(this.favoriteList, (item: ProductItem) => {
            ListItem() {
              Row() {
                // 此时 item.image_url 已经是 Resource 类型了，可以正常显示
                Image(item.image_url)
                  .width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)

                Column() {
                  Text(item.name).fontSize(16).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`¥${item.price.toFixed(2)}`).fontColor(Color.Red).fontSize(18).margin({ top: 10 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 15 })
                .layoutWeight(1)
              }
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .onClick(() => {
                // 跳转详情页，此时传递的 item 包含正确的 image_url
                router.pushUrl({ url: 'pages/ProductDetailPage', params: item })
              })
            }
          })
        }
        .width('95%')
        .layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}