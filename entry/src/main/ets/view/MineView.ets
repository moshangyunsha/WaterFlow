// 文件位置: entry/src/main/ets/view/MineView.ets
import router from '@ohos.router';
import { User } from '../viewmodel/User'; // 路径层级一致，无需修改
import picker from '@ohos.file.picker';
import RdbUtil from '../common/utils/RdbUtil';
import ProductService from '../service/ProductService';
import promptAction from '@ohos.promptAction';

@Component // [修改]
export struct MineView { // [修改] 导出名 MineView
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  @State avatarUrl: string = "";

  aboutToAppear() {
    this.avatarUrl = this.currentUser.token || "";
  }

  // 更换头像逻辑
  async changeAvatar() {
    if (!this.currentUser || this.currentUser.id === 0) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    try {
      let photoPicker = new picker.PhotoViewPicker();
      let result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris.length > 0) {
        let newAvatar = result.photoUris[0];
        await RdbUtil.updateUserAvatar(this.currentUser.id, newAvatar);
        this.avatarUrl = newAvatar;
        this.currentUser.token = newAvatar;
      }
    } catch (e) {
      console.error("Change avatar failed", e);
    }
  }

  build() {
    Column() {
      // 1. 顶部用户信息卡片
      if (this.currentUser.id > 0) {
        Column() {
          Image(this.avatarUrl || $r('app.media.ic_holder_mate50'))
            .width(80).height(80).borderRadius(40).margin({ bottom: 10 })
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.changeAvatar();
            })

          Text("点击头像更换").fontSize(10).fontColor(Color.Gray)

          Text(this.currentUser.username).fontSize(20).fontWeight(FontWeight.Bold).margin({top:5})

          Row() {
            Text(this.currentUser.role === 1 ? "身份：商家" : "身份：买家")
              .fontSize(12).fontColor(Color.White).backgroundColor(Color.Blue).padding(5).borderRadius(5)
            Text(`余额：¥${this.currentUser.balance.toFixed(2)}`)
              .fontSize(12).fontColor(Color.White).backgroundColor(Color.Red).padding(5).borderRadius(5).margin({ left: 10 })
          }.margin({ top: 10 })
        }
        .width('100%')
        .padding(30)
        .backgroundColor(Color.White)
        .margin({ bottom: 10 })

        // 2. 菜单列表
        List() {
          if (this.currentUser.role === 1) {
            // --- 商家菜单 ---
            ListItem() {
              this.MenuCell("发布商品", () => {
                router.pushUrl({ url: 'pages/MerchantUploadPage' })
              })
            }
            // 商品管理已移至主 Tab，这里作为快捷入口或移除均可，保留作为二级入口
            ListItem() {
              this.MenuCell("我的收藏", () => {
                router.pushUrl({ url: 'pages/MyFavoritesPage' })
              })
            }
            ListItem() {
              this.MenuCell("商品管理", () => {
                router.pushUrl({ url: 'pages/MerchantMainPage' })
              })
            }
          } else {
            // --- 买家菜单 ---
            ListItem() {
              this.MenuCell("我的收藏", () => {
                router.pushUrl({ url: 'pages/MyFavoritesPage' })
              })
            }
            ListItem() {
              this.MenuCell("我的订单", () => {
                router.pushUrl({ url: 'pages/OrderListPage' })
              })
            }
            // 在 "我的订单" 下面添加
            ListItem() {
              this.MenuCell("地址管理", () => {
                router.pushUrl({ url: 'pages/AddressListPage' })
              })
            }
          }

          ListItem() {
            this.MenuCell("重置所有数据 (清除测试数据)", async () => {
              await ProductService.clearAllData();
              promptAction.showToast({ message: '数据已重置' });
              AppStorage.SetOrCreate('currentUser', new User(0, '', 0, 0, ""));
              this.avatarUrl = "";
              router.replaceUrl({ url: 'pages/LoginPage' }); // [修改] 使用 replaceUrl
            })
          }

          ListItem() {
            this.MenuCell("退出登录", () => {
              AppStorage.SetOrCreate('currentUser', new User(0, '', 0, 0, ""));
              this.avatarUrl = "";
              router.replaceUrl({ url: 'pages/LoginPage' }); // [修改] 使用 replaceUrl
            })
          }
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(10)

      } else {
        // 未登录
        Column() {
          Text("您尚未登录").fontSize(20).margin({ bottom: 20 })
          Button("去登录 / 注册")
            .onClick(() => {
              router.replaceUrl({ url: 'pages/LoginPage' })
            })
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder MenuCell(title: string, action: () => void) {
    Row() {
      Text(title).fontSize(16)
      Text(">").fontSize(16).fontColor(Color.Gray)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(15)
    .backgroundColor(Color.White)
    .onClick(action)
  }
}