import router from '@ohos.router';
import RdbUtil from '../common/utils/RdbUtil';
import ProductItem from '../viewmodel/ProductItem';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';

@Entry
@Component
struct MerchantEditPage {
  @State productId: number = 0;
  @State title: string = '';
  @State price: string = '';
  @State imageUri: string = '';

  // [修复] 1. 获取状态栏高度
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  aboutToAppear() {
    const params = router.getParams() as ProductItem;
    if (params) {
      this.productId = params.id;
      this.title = params.name;
      this.price = params.price.toString();
      this.imageUri = params.image_url as string;
    }
  }

  async selectImage() {
    try {
      let photoPicker = new picker.PhotoViewPicker();
      let result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      if (result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
      }
    } catch (e) {
      console.error("Select image failed", e);
    }
  }

  async submit() {
    if (!this.title || !this.price || !this.imageUri) {
      promptAction.showToast({ message: '请补全信息' });
      return;
    }
    let success = await RdbUtil.updateProduct(this.productId, this.title, parseFloat(this.price), this.imageUri);

    if (success) {
      promptAction.showToast({ message: '修改成功' });
      setTimeout(() => { router.back(); }, 500);
    } else {
      promptAction.showToast({ message: '修改失败' });
    }
  }

  build() {
    Column() {
      // [修复] 2. 为标题栏添加 Padding
      Row() {
        Text("<")
          .fontSize(24)
          .width(40).height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())
        Text("编辑商品").fontSize(20).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({
        top: 10 + this.getUIContext().px2vp(this.topRectHeight),
        bottom: 10,
        left: 10,
        right: 10
      })
      .backgroundColor(Color.White)

      // 图片区域
      Image(this.imageUri || $r('app.media.ic_holder_computer'))
        .width(200).height(200).objectFit(ImageFit.Contain)
        .margin({ top: 20, bottom: 10 })
        .onClick(() => this.selectImage())

      Text("点击图片更换").fontSize(12).fontColor(Color.Gray).margin({ bottom: 20 })

      TextInput({ text: this.title, placeholder: '标题' })
        .onChange(v => this.title = v).margin(10).width('90%')

      TextInput({ text: this.price, placeholder: '价格' })
        .type(InputType.Number)
        .onChange(v => this.price = v).margin(10).width('90%')

      Button("保存修改").width('90%').margin({ top: 20 })
        .onClick(() => this.submit())
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}