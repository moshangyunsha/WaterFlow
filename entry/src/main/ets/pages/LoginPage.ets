import router from '@ohos.router';
import { User } from '../viewmodel/User';
import RdbUtil from '../common/utils/RdbUtil';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isMerchant: boolean = false;

  async handleLogin() {
    if (!this.username || !this.password) {
      promptAction.showToast({ message: '请输入账号和密码' });
      return;
    }

    // 1. 尝试登录
    let user = await RdbUtil.login(this.username, this.password);

    if (user) {
      // 登录成功 - 校验角色
      let selectRole = this.isMerchant ? 1 : 0;
      if (user.role !== selectRole) {
        promptAction.showToast({
          message: this.isMerchant ? '该账号不是商户账号' : '该账号是商户，请勾选商户登录'
        });
        return;
      }

      AppStorage.SetOrCreate<User>('currentUser', user);
      promptAction.showToast({ message: '登录成功' });

      // [修改] 根据角色跳转到不同的主页容器，并销毁当前登录页
      if (user.role === 1) {
        router.replaceUrl({ url: 'pages/MerchantMainPage' });
      } else {
        router.replaceUrl({ url: 'pages/MainPage' });
      }

    } else {
      // 2. 登录失败，尝试自动注册
      // 注意：如果重置了数据库，这里就是注册新用户，应该成功。
      let newUser = await RdbUtil.register(this.username, this.password, this.isMerchant ? 1 : 0);

      if (newUser) {
        AppStorage.SetOrCreate<User>('currentUser', newUser);
        promptAction.showToast({ message: '新用户注册并登录成功' });

        // [修改] 注册成功同样跳转
        if (newUser.role === 1) {
          router.replaceUrl({ url: 'pages/MerchantMainPage' });
        } else {
          router.replaceUrl({ url: 'pages/MainPage' });
        }
      } else {
        // 3. 注册也失败了
        // 如果走到这里，说明用户名在数据库里确实存在，但密码不对（因为 login 失败了）。
        promptAction.showToast({ message: '登录失败：密码错误或用户名已被占用' });
      }
    }
  }

  build() {
    Column() {
      Text("账户系统").fontSize(30).fontWeight(FontWeight.Bold).margin({ bottom: 50 })

      TextInput({ placeholder: '账号' }).onChange(v => this.username = v).margin({ bottom: 10 }).width('80%')
      TextInput({ placeholder: '密码' }).type(InputType.Password).onChange(v => this.password = v).margin({ bottom: 20 }).width('80%')

      Row() {
        Text("我是商家").margin({ right: 10 })
        Toggle({ type: ToggleType.Switch, isOn: this.isMerchant }).onChange(v => this.isMerchant = v)
      }.width('80%').justifyContent(FlexAlign.End).margin({ bottom: 20 })

      Button("登录 / 自动注册").width('80%').onClick(() => this.handleLogin())
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }
}