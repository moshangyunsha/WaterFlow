import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import RdbUtil from '../common/utils/RdbUtil';
import { User } from '../viewmodel/User';
import { CITY_DATA, Province, City } from '../viewmodel/CityData';

@Entry
@Component
struct AddressEditPage {
  @StorageLink('currentUser') currentUser: User = new User(0, '', 0, 0, "");
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  @State name: string = '';
  @State phone: string = '';
  @State detail: string = ''; // 详细地址
  @State area: string = '';   // 省市区字符串
  @State selectedTag: string = '家'; // 默认标签
  @State isDefault: boolean = false;

  // Picker 选中的索引
  @State pIndex: number = 0;
  @State cIndex: number = 0;
  @State aIndex: number = 0;

  // 标签选项
  private tags: string[] = ['家', '公司', '学校'];

  // --- 省市区选择器弹窗 ---
  private cityPickerDialog: CustomDialogController = new CustomDialogController({
    builder: CityPicker({
      confirm: (areaStr: string) => { this.area = areaStr }
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true // 使用自定义样式，底部弹出
  })

  async handleSave() {
    if (!this.name) { promptAction.showToast({ message: '请填写收货人' }); return; }
    if (this.phone.length < 11) { promptAction.showToast({ message: '请输入正确的手机号' }); return; }
    if (!this.area) { promptAction.showToast({ message: '请选择所在地区' }); return; }
    if (!this.detail) { promptAction.showToast({ message: '请填写详细地址' }); return; }

    let success = await RdbUtil.addAddress(
      this.currentUser.id,
      this.name,
      this.phone,
      this.area,
      this.detail,
      this.selectedTag,
      this.isDefault
    );

    if (success) {
      promptAction.showToast({ message: '地址保存成功' });
      router.back();
    } else {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  build() {
    Column() {
      // 1. 标题栏
      Row() {
        Text("<").fontSize(24).width(40).height(40).textAlign(TextAlign.Center).onClick(() => router.back())
        Text("添加收货地址").fontSize(18).fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ top: this.getUIContext().px2vp(this.topRectHeight), bottom: 10 })
      .backgroundColor(Color.White)

      // 2. 表单内容
      Column() {
        // 收货人
        TextInput({ placeholder: '收货人', text: this.name })
          .onChange(v => this.name = v)
          .styleInput()

        Divider().color('#F5F5F5')

        // 手机号
        TextInput({ placeholder: '手机号码', text: this.phone })
          .type(InputType.PhoneNumber)
          .onChange(v => this.phone = v)
          .styleInput()

        Divider().color('#F5F5F5')

        // 所在地区 (点击弹出选择器)
        Row() {
          Text("所在地区").fontSize(16).width(80)
          Text(this.area || "请选择 省 / 市 / 区")
            .fontSize(16)
            .fontColor(this.area ? Color.Black : Color.Gray)
            .layoutWeight(1)
          Text(">").fontColor(Color.Gray)
        }
        .width('100%')
        .padding(15)
        .backgroundColor(Color.White)
        .onClick(() => {
          this.cityPickerDialog.open();
        })

        Divider().color('#F5F5F5')

        // 详细地址 (多行文本)
        TextArea({ placeholder: '详细地址：街道、门牌号等', text: this.detail })
          .height(100)
          .backgroundColor(Color.White)
          .borderRadius(0)
          .onChange(v => this.detail = v)

        Divider().color('#F5F5F5')

        // 标签选择
        Row() {
          Text("标签").fontSize(16).width(80)
          Row({ space: 10 }) {
            ForEach(this.tags, (tag: string) => {
              Text(tag)
                .fontSize(14)
                .padding({ left: 15, right: 15, top: 5, bottom: 5 })
                .borderRadius(15)
                .backgroundColor(this.selectedTag === tag ? '#FF5000' : '#F0F0F0')
                .fontColor(this.selectedTag === tag ? Color.White : Color.Black)
                .onClick(() => this.selectedTag = tag)
            })
            // 可以扩展自定义输入
            TextInput({ placeholder: '自定义', text: this.tags.includes(this.selectedTag) ? '' : this.selectedTag })
              .width(80)
              .height(30)
              .fontSize(12)
              .backgroundColor('#F0F0F0')
              .borderRadius(15)
              .onChange((v) => this.selectedTag = v)
          }
        }
        .width('100%')
        .padding(15)
        .backgroundColor(Color.White)
        .alignItems(VerticalAlign.Center)

        Divider().color('#F5F5F5')

        // 设为默认
        Row() {
          Column() {
            Text("设为默认地址").fontSize(16)
            Text("每次下单时会默认推荐该地址").fontSize(12).fontColor(Color.Gray).margin({ top: 5 })
          }.alignItems(HorizontalAlign.Start)

          Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
            .selectedColor('#FF5000')
            .onChange((isOn) => this.isDefault = isOn)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(15)
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        // 保存按钮
        Button("保存")
          .width('90%')
          .height(45)
          .backgroundColor('#FF5000')
          .margin({ top: 30 })
          .onClick(() => this.handleSave())

      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}

// 样式扩展
@Extend(TextInput) function styleInput() {
  .height(55)
  .backgroundColor(Color.White)
  .borderRadius(0)
  .padding({ left: 15, right: 15 })
}

// --- 自定义省市区选择器弹窗 ---
@CustomDialog
struct CityPicker {
  controller: CustomDialogController
  confirm: (value: string) => void = () => {}

  // 默认选中项
  @State selectedProv: number = 0
  @State selectedCity: number = 0
  @State selectedArea: number = 0

  // 动态数据源
  @State rangeProv: string[] = CITY_DATA.map(p => p.name)
  @State rangeCity: string[] = CITY_DATA[0].city.map(c => c.name)
  @State rangeArea: string[] = CITY_DATA[0].city[0].area

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        Text("取消").fontColor(Color.Gray).onClick(() => this.controller.close())
        Text("选择地区").fontWeight(FontWeight.Bold)
        Text("确定").fontColor('#FF5000').onClick(() => {
          let p = this.rangeProv[this.selectedProv]
          let c = this.rangeCity[this.selectedCity]
          let a = this.rangeArea[this.selectedArea]
          this.confirm(`${p} ${c} ${a}`)
          this.controller.close()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })

      // 核心组件: TextPicker
      TextPicker({ range: [this.rangeProv, this.rangeCity, this.rangeArea], selected: [this.selectedProv, this.selectedCity, this.selectedArea] })
        .onChange((value: string | string[], index: number | number[]) => {
          // value 是选中的文字数组，index 是选中的索引数组 [省, 市, 区]
          let idxs = index as number[];

          // 如果省份变了
          if (idxs[0] !== this.selectedProv) {
            this.selectedProv = idxs[0];
            this.selectedCity = 0; // 重置市
            this.selectedArea = 0; // 重置区

            // 更新数据源
            this.rangeCity = CITY_DATA[this.selectedProv].city.map(c => c.name);
            this.rangeArea = CITY_DATA[this.selectedProv].city[0].area;
          }
          // 如果城市变了
          else if (idxs[1] !== this.selectedCity) {
            this.selectedCity = idxs[1];
            this.selectedArea = 0; // 重置区

            // 更新数据源
            this.rangeArea = CITY_DATA[this.selectedProv].city[this.selectedCity].area;
          }
          else {
            this.selectedArea = idxs[2];
          }
        })
        .height(250)
        .width('100%')
        .backgroundColor(Color.White)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}