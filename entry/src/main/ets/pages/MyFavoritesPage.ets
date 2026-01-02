import router from '@ohos.router';
import ProductService from '../service/ProductService';
import ProductItem from '../viewmodel/ProductItem';
import { User } from '../viewmodel/User';

@Entry
@Component
struct MyFavoritesPage {
  @State favoriteList: ProductItem[] = [];
  // [修复] 1. 获取状态栏高度
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  async aboutToAppear() {
    let user = AppStorage.Get<User>('currentUser');
    if (user && user.id) {
      this.favoriteList = await ProductService.getMyFavorites(user.id);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text("<")
          .fontSize(24) //稍微加大一点字体方便点击
          .width(40)    // 固定宽度增加点击区域
          .height(40)
          .textAlign(TextAlign.Center)
          .margin({right: 5})
          .onClick(() => router.back())
        Text("我的收藏").fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      // [修复] 2. 添加顶部内边距，避开状态栏
      .padding({
        top: 15 + this.getUIContext().px2vp(this.topRectHeight),
        left: 15,
        right: 15,
        bottom: 15
      })
      .backgroundColor(Color.White) // 确保背景色覆盖状态栏区域

      if (this.favoriteList.length === 0) {
        Text("暂无收藏，快去首页逛逛吧").fontColor(Color.Gray).margin({ top: 100 })
      } else {
        List({ space: 10 }) {
          ForEach(this.favoriteList, (item: ProductItem) => {
            ListItem() {
              Row() {
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