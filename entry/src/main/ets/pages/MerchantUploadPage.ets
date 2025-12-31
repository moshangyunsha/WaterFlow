import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
// ✅ 核心修复：引入分类常量
import { CATEGORY_LIST } from '../viewmodel/HomeViewModel';

@Entry
@Component
struct MerchantUploadPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");

  // 表单状态
  @State imageUri: string = '';
  @State name: string = '';
  @State price: string = '';
  @State description: string = '';
  // 默认选中第2个（跳过“全部”），确保有默认值
  @State selectedCategory: string = CATEGORY_LIST.length > 1 ? CATEGORY_LIST[1] : '电子物品';

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
    if (!this.selectedCategory) {
      promptAction.showToast({ message: '请选择分类' });
      return;
    }
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

    // 3. 调用数据库
    // 参数顺序: merchantId, name, price, imgUrl, width, height, description, category
    await RdbUtil.addProduct(
      this.currentUser.id,
      this.name,
      priceNum,
      this.imageUri,
      300, // 默认宽度
      300 + Math.random() * 100, // 随机高度
      this.description,
      this.selectedCategory // ✅ 传入分类
    );

    promptAction.showToast({ message: '发布成功' });

    // 4. 清空表单或返回
    this.name = '';
    this.price = '';
    this.description = '';
    this.imageUri = '';
    // 不重置分类，方便连续发布

    // 延迟返回，让用户看到提示
    setTimeout(() => {
      router.back();
    }, 500);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
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

          // 4. 分类选择 (✅ 修复语法)
          Column() {
            Text("商品分类").fontSize(14).fontColor(Color.Gray).margin({ bottom: 5 }).width('100%')

            Select(
              // 过滤掉 '全部'，并将 string 转换为 SelectOption 对象
              CATEGORY_LIST.filter(c => c !== '全部').map((c) => {
                return { value: c } as SelectOption
              })
            )
              .selected(0) // 默认选中列表第一个
              .value(this.selectedCategory) // 显示当前选中的值
              .font({ size: 16 })
              .fontColor(Color.Black)
              .selectedOptionFont({ size: 16 })
              .optionFont({ size: 16 })
              .height(50)
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onSelect((index: number, value: string) => {
                this.selectedCategory = value;
              })
          }
          .width('100%')

          // 5. 商品详情介绍
          TextArea({ placeholder: '请输入详细的商品介绍（选填）...', text: this.description })
            .height(120)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(15)
            .onChange((val) => this.description = val)

          // 6. 发布按钮
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
      .layoutWeight(1) // 确保 Scroll 占用剩余空间
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}