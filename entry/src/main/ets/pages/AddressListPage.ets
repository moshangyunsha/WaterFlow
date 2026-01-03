import router from '@ohos.router';
import RdbUtil, { AddressItem } from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AddressListPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @State addressList: AddressItem[] = [];

  // [新增] 是否为选择模式 (由上个页面传参决定)
  @State isSelectMode: boolean = false;

  async aboutToAppear() { // 改用 aboutToAppear 获取参数
    const params = router.getParams() as Record<string, boolean>;
    if (params && params['isSelectMode']) {
      this.isSelectMode = params['isSelectMode'];
    }
    this.refreshList();
  }
  onPageShow() {
    this.refreshList();
  }

  async refreshList() {
    if (this.currentUser.id) {
      this.addressList = await RdbUtil.getAddressList(this.currentUser.id);
    }
  }

  async handleSetDefault(item: AddressItem) {
    if (item.isDefault) return;
    await RdbUtil.setAddressDefault(this.currentUser.id, item.id);
    this.refreshList();
    promptAction.showToast({ message: '已设为默认' });
  }

  async handleDelete(item: AddressItem) {
    AlertDialog.show({
      title: '删除地址',
      message: '确定要删除这条地址吗？',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '删除', fontColor: Color.Red,
        action: async () => {
          await RdbUtil.deleteAddress(item.id);
          this.refreshList();
        }
      }
    })
  }

  // [新增] 选择地址并返回
  selectAddress(item: AddressItem) {
    if (this.isSelectMode) {
      // 携带选中的地址返回上一页
      router.back({
        url: 'pages/OrderConfirmPage', // 显式指定返回给谁(可选)
        params: { selectedAddress: item }
      });
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("<").fontSize(24).width(40).height(40).textAlign(TextAlign.Center).onClick(() => router.back())
        Text(this.isSelectMode ? "选择收货地址" : "地址管理").fontSize(18).fontWeight(FontWeight.Bold) // 动态标题
        Blank()
        Text("添加").fontSize(16).fontColor('#FF5000').margin({ right: 15 })
          .onClick(() => router.pushUrl({ url: 'pages/AddressEditPage' }))
      }
      .width('100%').padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: 10 }).backgroundColor(Color.White)

      if (this.addressList.length === 0) {
        Column() {
          Text("暂无地址，去添加一个吧").fontColor(Color.Gray).margin({ top: 100 })
        }.width('100%')
      } else {
        List({ space: 10 }) {
          ForEach(this.addressList, (item: AddressItem) => {
            ListItem() {
              Column() {
                Row() {
                  // [新增] 显示标签
                  if (item.tag) {
                    Text(item.tag)
                      .fontSize(10)
                      .fontColor(Color.White)
                      .backgroundColor('#007DFF')
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .borderRadius(2)
                      .margin({ right: 5 })
                  }

                  Text(item.name).fontSize(16).fontWeight(FontWeight.Bold)
                  Text(item.phone).fontSize(16).margin({ left: 10 }).fontColor(Color.Gray)
                  Blank()
                  Text("删除").fontSize(14).fontColor(Color.Red).onClick(() => this.handleDelete(item))
                }.width('100%').margin({ bottom: 5 }).alignItems(VerticalAlign.Center)

                // 显示完整地址 (Area + Detail)
                Text(item.address).fontSize(14).maxLines(2).fontColor('#333')

                Divider().color('#F0F0F0').margin({ top: 10, bottom: 10 })

                // 第三行：设为默认操作
                Row() {
                  Radio({ value: 'default', group: 'addr' })
                    .checked(item.isDefault)
                    .onChange(() => this.handleSetDefault(item))
                    .width(16).height(16)

                  Text(item.isDefault ? "默认地址" : "设为默认")
                    .fontSize(12)
                    .fontColor(item.isDefault ? '#FF5000' : Color.Black)
                    .margin({ left: 5 })
                    .onClick(() => this.handleSetDefault(item))
                }
              }
              .padding(15).backgroundColor(Color.White).borderRadius(10)
              .onClick(() => {
                // [修改] 点击列表项：如果是选择模式则返回，否则无操作(或进入编辑)
                if (this.isSelectMode) {
                  this.selectAddress(item);
                }
              })
            }
          })
        }.width('95%').layoutWeight(1).margin({ top: 10 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}