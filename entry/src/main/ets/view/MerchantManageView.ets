import router from '@ohos.router';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';

@Component
export struct MerchantProductView {
  // [新增] 监听刷新
  @Prop @Watch('refreshData') refreshTrigger: number = 0;

  @State myList: ProductItem[] = [];
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  async aboutToAppear() {
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
          this.refreshData();
        }
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text("商品管理").fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 15 })
      }.width('100%').padding(15).backgroundColor(Color.White)

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
                Image(item.image_url).width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)
                Column() {
                  Text(item.name).fontSize(16).maxLines(1).fontWeight(FontWeight.Bold)
                  Text(`¥${item.price}`).fontColor(Color.Red).margin({ top: 5 })
                }
                .alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)

                Column() {
                  Button("编辑").fontSize(12).height(28).backgroundColor(Color.Blue)
                    .onClick(() => { router.pushUrl({ url: 'pages/MerchantEditPage', params: item }) })
                  Button("删除").fontSize(12).height(28).backgroundColor(Color.Red).margin({ top: 5 })
                    .onClick(() => this.handleDelete(item))
                }
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