import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';

@Entry
@Component
struct MerchantUploadPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  // 表单状态
  @State imageUri: string = '';
  @State name: string = '';
  @State price: string = '';
  // ✅ 新增：商品介绍
  @State description: string = '';

  // 选择图片
  async selectImage() {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
      }
    } catch (e) {
      console.error('Select image failed', e);
    }
  }

  // 发布商品
  async handlePublish() {
    // 1. 校验
    if (!this.imageUri) {
      promptAction.showToast({ message: '请选择商品图片' });
      return;
    }
    if (!this.name) {
      promptAction.showToast({ message: '请输入商品名称' });
      return;
    }
    if (!this.price) {
      promptAction.showToast({ message: '请输入价格' });
      return;
    }

    // 2. 转换价格
    const priceNum = parseFloat(this.price);
    if (isNaN(priceNum)) {
      promptAction.showToast({ message: '价格格式不正确' });
      return;
    }

    // 3. 调用数据库 (传入 description)
    // 参数顺序: merchantId, name, price, imgUrl, width, height, description
    await RdbUtil.addProduct(
      this.currentUser.id,
      this.name,
      priceNum,
      this.imageUri,
      300, // 默认宽度
      300 + Math.random() * 100, // 随机高度，为了瀑布流好看
      this.description // ✅ 传入商品介绍
    );

    promptAction.showToast({ message: '发布成功' });

    // 4. 清空表单或返回
    this.name = '';
    this.price = '';
    this.description = '';
    this.imageUri = '';

    // 延迟返回，让用户看到提示
    setTimeout(() => {
      router.back();
    }, 500);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<') // 确保你有这个图标，没有就用 Text('<')
          .width(24).height(24)
          .onClick(() => router.back())
        Text('上架新商品').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      Scroll() {
        Column({ space: 15 }) {
          // 1. 图片上传区
          Column() {
            if (this.imageUri) {
              Image(this.imageUri)
                .width(150)
                .height(150)
                .objectFit(ImageFit.Cover)
                .borderRadius(10)
                .onClick(() => this.selectImage()) // 点击更换
            } else {
              Column() {
                Text('+').fontSize(40).fontColor('#999')
                Text('上传图片').fontSize(14).fontColor('#999')
              }
              .width(150)
              .height(150)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.selectImage())
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 20 })

          // 2. 商品名称
          TextInput({ placeholder: '商品名称', text: this.name })
            .height(50)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding({ left: 15 })
            .onChange((val) => this.name = val)

          // 3. 价格
          TextInput({ placeholder: '价格 (¥)', text: this.price })
            .height(50)
            .type(InputType.Number) // 数字键盘
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding({ left: 15 })
            .onChange((val) => this.price = val)

          // 4. ✅ 新增：商品详情介绍
          TextArea({ placeholder: '请输入详细的商品介绍（选填）...', text: this.description })
            .height(120) // 给大一点的高度
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(15)
            .onChange((val) => this.description = val)

          // 5. 发布按钮
          Button('立即发布')
            .width('90%')
            .height(50)
            .backgroundColor('#FF5000') // 淘宝红
            .margin({ top: 30 })
            .onClick(() => this.handlePublish())

        }
        .padding(15)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}