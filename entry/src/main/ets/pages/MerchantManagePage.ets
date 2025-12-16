import router from '@ohos.router';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MerchantManagePage {
  @State myList: ProductItem[] = [];
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  async onPageShow() {
    this.refreshData();
  }

  async refreshData() {
    if (this.currentUser.id) {
      this.myList = await RdbUtil.getMerchantProducts(this.currentUser.id);
    }
  }

  async handleDelete(item: ProductItem) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除 "${item.name}" 吗？`,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          await RdbUtil.deleteProduct(item.id);
          promptAction.showToast({ message: '已删除' });
          this.refreshData(); // 刷新列表
        }
      }
    })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("<") // 确保有返回图标
          .width(24).height(24).onClick(() => router.back())
        Text("商品管理").fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 15 })
      }.width('100%').padding(15)

      if (this.myList.length === 0) {
        Column() {
          Text("您还没有发布任何商品").fontColor(Color.Gray)
          Button("去发布").margin({ top: 20 }).onClick(() => router.pushUrl({ url: 'pages/MerchantUploadPage' }))
        }.height('80%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.myList, (item: ProductItem) => {
            ListItem() {
              Row() {
                // 图片
                Image(item.image_url)
                  .width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)

                // 信息
                Column() {
                  Text(item.name).fontSize(16).maxLines(1).fontWeight(FontWeight.Bold)
                  Text(`¥${item.price}`).fontColor(Color.Red).margin({ top: 5 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 10 })
                .layoutWeight(1)

                // 操作按钮
                Column() {
                  Button("编辑").fontSize(12).height(28).backgroundColor(Color.Blue)
                    .onClick(() => {
                      // 跳转到编辑页，传递商品信息
                      router.pushUrl({ url: 'pages/MerchantEditPage', params: item })
                    })

                  Button("删除").fontSize(12).height(28).backgroundColor(Color.Red).margin({ top: 5 })
                    .onClick(() => this.handleDelete(item))
                }
              }
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(10)
            }
          })
        }
        .width('95%').layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}