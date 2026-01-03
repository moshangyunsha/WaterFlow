import router from '@ohos.router';
import RdbUtil, { ReviewItem } from '../common/utils/RdbUtil';

@Entry
@Component
struct ProductReviewsPage {
  @State reviews: ReviewItem[] = [];
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @State productId: number = 0;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['productId']) {
      this.productId = params['productId'] as number;
      // 获取该商品的所有评价
      this.reviews = await RdbUtil.getReviewsByProduct(this.productId);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("<").fontSize(24).width(40).height(40).textAlign(TextAlign.Center).onClick(() => router.back())
        Text(`全部评价 (${this.reviews.length})`).fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: 10 }).backgroundColor(Color.White)

      if (this.reviews.length === 0) {
        Column() {
          Text("暂无评价").fontColor(Color.Gray).margin({ top: 100 })
        }.width('100%')
      } else {
        List({ space: 1 }) { // space 1 用于显示分割线效果
          ForEach(this.reviews, (item: ReviewItem) => {
            ListItem() {
              Column() {
                // 用户信息栏
                Row() {
                  Image(item.userAvatar || $r('app.media.ic_holder_computer'))
                    .width(32).height(32).borderRadius(16).margin({ right: 10 })

                  Column() {
                    Text(item.userName).fontSize(14)
                    // 星星
                    Row() {
                      ForEach([1, 2, 3, 4, 5], (star: number) => {
                        if (star <= item.rating) Text("★").fontColor('#FF5000').fontSize(10)
                        else Text("★").fontColor('#EEEEEE').fontSize(10)
                      })
                    }.margin({ top: 2 })
                  }.alignItems(HorizontalAlign.Start)

                  Blank()
                  Text(item.date).fontSize(12).fontColor(Color.Gray)
                }.width('100%').margin({ bottom: 8 })

                // 评价内容
                Text(item.content).fontSize(15).lineHeight(22)
              }
              .padding(15).backgroundColor(Color.White)
            }
          })
        }.width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}