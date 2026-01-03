if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface LoginPage_Params {
    username?: string;
    password?: string;
    isMerchant?: boolean;
}
import router from "@ohos:router";
import type { User } from '../viewmodel/User';
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import promptAction from "@ohos:promptAction";
class LoginPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__username = new ObservedPropertySimplePU('', this, "username");
        this.__password = new ObservedPropertySimplePU('', this, "password");
        this.__isMerchant = new ObservedPropertySimplePU(false, this, "isMerchant");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: LoginPage_Params) {
        if (params.username !== undefined) {
            this.username = params.username;
        }
        if (params.password !== undefined) {
            this.password = params.password;
        }
        if (params.isMerchant !== undefined) {
            this.isMerchant = params.isMerchant;
        }
    }
    updateStateVars(params: LoginPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__username.purgeDependencyOnElmtId(rmElmtId);
        this.__password.purgeDependencyOnElmtId(rmElmtId);
        this.__isMerchant.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__username.aboutToBeDeleted();
        this.__password.aboutToBeDeleted();
        this.__isMerchant.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __username: ObservedPropertySimplePU<string>;
    get username() {
        return this.__username.get();
    }
    set username(newValue: string) {
        this.__username.set(newValue);
    }
    private __password: ObservedPropertySimplePU<string>;
    get password() {
        return this.__password.get();
    }
    set password(newValue: string) {
        this.__password.set(newValue);
    }
    private __isMerchant: ObservedPropertySimplePU<boolean>;
    get isMerchant() {
        return this.__isMerchant.get();
    }
    set isMerchant(newValue: boolean) {
        this.__isMerchant.set(newValue);
    }
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
            }
            else {
                router.replaceUrl({ url: 'pages/MainPage' });
            }
        }
        else {
            // 2. 登录失败，尝试自动注册
            // 注意：如果重置了数据库，这里就是注册新用户，应该成功。
            let newUser = await RdbUtil.register(this.username, this.password, this.isMerchant ? 1 : 0);
            if (newUser) {
                AppStorage.SetOrCreate<User>('currentUser', newUser);
                promptAction.showToast({ message: '新用户注册并登录成功' });
                // [修改] 注册成功同样跳转
                if (newUser.role === 1) {
                    router.replaceUrl({ url: 'pages/MerchantMainPage' });
                }
                else {
                    router.replaceUrl({ url: 'pages/MainPage' });
                }
            }
            else {
                // 3. 注册也失败了
                // 如果走到这里，说明用户名在数据库里确实存在，但密码不对（因为 login 失败了）。
                promptAction.showToast({ message: '登录失败：密码错误或用户名已被占用' });
            }
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/LoginPage.ets(66:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("账户系统");
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(67:7)", "entry");
            Text.fontSize(30);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ bottom: 50 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '账号' });
            TextInput.debugLine("entry/src/main/ets/pages/LoginPage.ets(69:7)", "entry");
            TextInput.onChange(v => this.username = v);
            TextInput.margin({ bottom: 10 });
            TextInput.width('80%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '密码' });
            TextInput.debugLine("entry/src/main/ets/pages/LoginPage.ets(70:7)", "entry");
            TextInput.type(InputType.Password);
            TextInput.onChange(v => this.password = v);
            TextInput.margin({ bottom: 20 });
            TextInput.width('80%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(72:7)", "entry");
            Row.width('80%');
            Row.justifyContent(FlexAlign.End);
            Row.margin({ bottom: 20 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("我是商家");
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(73:9)", "entry");
            Text.margin({ right: 10 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Toggle.create({ type: ToggleType.Switch, isOn: this.isMerchant });
            Toggle.debugLine("entry/src/main/ets/pages/LoginPage.ets(74:9)", "entry");
            Toggle.onChange(v => this.isMerchant = v);
        }, Toggle);
        Toggle.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel("登录 / 自动注册");
            Button.debugLine("entry/src/main/ets/pages/LoginPage.ets(77:7)", "entry");
            Button.width('80%');
            Button.onClick(() => this.handleLogin());
        }, Button);
        Button.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "LoginPage";
    }
}
registerNamedRoute(() => new LoginPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/LoginPage", pageFullPath: "entry/src/main/ets/pages/LoginPage", integratedHsp: "false", moduleType: "followWithHap" });
