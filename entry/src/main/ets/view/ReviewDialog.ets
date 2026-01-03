import promptAction from '@ohos.promptAction';

@CustomDialog
export struct ReviewDialog {
  controller: CustomDialogController

  // 外部传入参数
  orderId: number = 0;
  productId: number = 0; // 以前的订单表可能没存 productId?
  // 注意：RdbUtil.addOrder 里其实没有存 PRODUCT_ID 字段到 ORDERS 表，
  // 而是存了 MERCHANT_ID。我们需要检查你的 ORDERS 表结构。
  // 如果 ORDERS 表里没存 PRODUCT_ID，那只能暂时用 0 或者改表。
  // **修正**：你的 ORDERS 表确实没 PRODUCT_ID，只有 PRODUCT_NAME。
  // 为了不再次改表（导致重装应用），我们暂时演示“对订单评价”，不强绑定具体的商品ID查库。
  // 或者，你可以通过 PRODUCT_NAME 反查 ID，但这不稳。
  // **最佳临时方案**：我们在调用弹窗时，把 productId 传进来（如果列表里有的话）。
  // 如果实在没有，就在这里存 0，只做展示用。

  action: (rating: number, content: string) => void = () => {}

  @State rating: number = 5;
  @State content: string = '';

  build() {
    Column() {
      Text("评价商品").fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })

      // 星星打分
      Row({ space: 10 }) {
        ForEach([1, 2, 3, 4, 5], (item: number) => {
          Text("★")
            .fontSize(30)
            .fontColor(item <= this.rating ? '#FF5000' : '#CCCCCC')
            .onClick(() => {
              this.rating = item;
            })
        })
      }.margin({ top: 20, bottom: 20 })

      Text(this.getRatingText(this.rating)).fontSize(14).fontColor(Color.Gray)

      // 文本输入
      TextArea({ placeholder: '宝贝满足你的期待吗？说说你的使用心得...' })
        .height(120)
        .width('90%')
        .margin({ top: 15 })
        .backgroundColor('#F5F5F5')
        .onChange((value) => {
          this.content = value;
        })

      // 按钮
      Row() {
        Button('取消').backgroundColor(Color.White).fontColor(Color.Black).layoutWeight(1)
          .onClick(() => this.controller.close())

        Button('发布').backgroundColor('#FF5000').fontColor(Color.White).layoutWeight(1)
          .onClick(() => {
            if (!this.content) {
              promptAction.showToast({ message: '写点什么吧' });
              return;
            }
            this.action(this.rating, this.content);
            this.controller.close();
          })
      }.width('90%').margin({ top: 20, bottom: 20 })
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('85%')
  }

  getRatingText(score: number): string {
    if (score === 5) return '非常满意';
    if (score === 4) return '满意';
    if (score === 3) return '一般';
    return '差评';
  }
}