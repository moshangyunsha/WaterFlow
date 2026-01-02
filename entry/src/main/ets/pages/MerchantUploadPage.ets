import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import { CATEGORY_LIST } from '../viewmodel/HomeViewModel';

@Entry
@Component
struct MerchantUploadPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  // [修复] 1. 获取状态栏高度
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  @State imageUri: string = '';
  @State name: string = '';
  @State price: string = '';
  @State description: string = '';
  @State selectedCategory: string = CATEGORY_LIST.length > 1 ? CATEGORY_LIST[1] : '电子物品';

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

  async handlePublish() {
    if (!this.selectedCategory) { promptAction.showToast({ message: '请选择分类' }); return; }
    if (!this.imageUri) { promptAction.showToast({ message: '请选择商品图片' }); return; }
    if (!this.name) { promptAction.showToast({ message: '请输入商品名称' }); return; }
    if (!this.price) { promptAction.showToast({ message: '请输入价格' }); return; }

    const priceNum = parseFloat(this.price);
    if (isNaN(priceNum)) { promptAction.showToast({ message: '价格格式不正确' }); return; }

    await RdbUtil.addProduct(
      this.currentUser.id,
      this.name,
      priceNum,
      this.imageUri,
      300,
      300 + Math.random() * 100,
      this.description,
      this.selectedCategory
    );

    promptAction.showToast({ message: '发布成功' });

    this.name = '';
    this.price = '';
    this.description = '';
    this.imageUri = '';

    setTimeout(() => { router.back(); }, 500);
  }

  build() {
    Column() {
      // [修复] 2. 为标题栏添加 Padding
      Row() {
        Text('<')
          .width(40).height(40) // 确保触摸区域够大
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())
        Text('上架新商品').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 10 })
      }
      .width('100%')
      .padding({
        top: 15 + this.getUIContext().px2vp(this.topRectHeight), // 加上状态栏高度
        left: 15,
        right: 15,
        bottom: 15
      })
      .backgroundColor(Color.White)

      Scroll() {
        Column({ space: 15 }) {
          // 1. 图片上传区
          Column() {
            if (this.imageUri) {
              Image(this.imageUri)
                .width(150).height(150).objectFit(ImageFit.Cover).borderRadius(10)
                .onClick(() => this.selectImage())
            } else {
              Column() {
                Text('+').fontSize(40).fontColor('#999')
                Text('上传图片').fontSize(14).fontColor('#999')
              }
              .width(150).height(150).backgroundColor('#F5F5F5').borderRadius(10)
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.selectImage())
            }
          }
          .width('100%').alignItems(HorizontalAlign.Center).margin({ top: 20 })

          TextInput({ placeholder: '商品名称', text: this.name })
            .height(50).backgroundColor(Color.White).borderRadius(8).padding({ left: 15 })
            .onChange((val) => this.name = val)

          TextInput({ placeholder: '价格 (¥)', text: this.price })
            .height(50).type(InputType.Number).backgroundColor(Color.White).borderRadius(8).padding({ left: 15 })
            .onChange((val) => this.price = val)

          Column() {
            Text("商品分类").fontSize(14).fontColor(Color.Gray).margin({ bottom: 5 }).width('100%')
            Select(
              CATEGORY_LIST.filter(c => c !== '全部').map((c) => {
                return { value: c } as SelectOption
              })
            )
              .selected(0)
              .value(this.selectedCategory)
              .font({ size: 16 }).fontColor(Color.Black)
              .selectedOptionFont({ size: 16 }).optionFont({ size: 16 })
              .height(50).width('100%').backgroundColor(Color.White).borderRadius(8)
              .onSelect((index: number, value: string) => { this.selectedCategory = value; })
          }.width('100%')

          TextArea({ placeholder: '请输入详细的商品介绍（选填）...', text: this.description })
            .height(120).backgroundColor(Color.White).borderRadius(8).padding(15)
            .onChange((val) => this.description = val)

          Button('立即发布')
            .width('90%').height(50).backgroundColor('#FF5000').margin({ top: 30 })
            .onClick(() => this.handlePublish())

        }
        .padding(15)
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}