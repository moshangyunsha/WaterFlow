// 文件路径: entry/src/main/ets/view/PayPasswordDialog.ets
import promptAction from '@ohos.promptAction';

@CustomDialog
export struct PayPasswordDialog {
  controller: CustomDialogController
  // 支付金额
  price: number = 0
  // 支付成功后的回调
  action: () => void = () => {}

  @State inputPass: string = ''

  build() {
    Column() {
      // 标题
      Text('请输入支付密码').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })

      // 金额显示
      Text(`¥${this.price.toFixed(2)}`)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .margin({ top: 15, bottom: 15 })

      Divider().color('#F5F5F5')

      // 支付方式模拟
      Row() {
        Text("支付方式").fontColor(Color.Gray)
        Blank()
        Text("账户余额").fontColor('#007DFF')
      }.width('90%').height(50)

      Divider().color('#F5F5F5')

      // 密码输入框
      TextInput({ placeholder: '请输入 6 位支付密码', text: this.inputPass })
        .type(InputType.Password)
        .maxLength(6)
        .width('90%')
        .height(50)
        .margin({ top: 20 })
        .backgroundColor('#F5F5F5')
        .textAlign(TextAlign.Center)
        .onChange((val) => {
          this.inputPass = val
        })

      // 按钮组
      Row() {
        Button('取消')
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })

        Button('确认支付')
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .margin({ left: 15 })
          .onClick(() => {
            // 这里以后可以改成读取 currentUser.paymentPassword
            if (this.inputPass === '123456') {
              this.controller.close()
              this.action() // 密码正确，执行外部传入的逻辑
            } else {
              promptAction.showToast({ message: '密码错误（测试密码：123456）' })
            }
          })
      }
      .width('90%')
      .margin({ top: 20, bottom: 20 })
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('85%')
  }
}