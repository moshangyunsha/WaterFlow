if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MineView_Params {
    currentUser?: User;
    avatarUrl?: string;
}
import router from "@ohos:router";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import picker from "@ohos:file.picker";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import ProductService from "@bundle:com.huawei.waterflow/entry/ets/service/ProductService";
import promptAction from "@ohos:promptAction";
export class MineView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.__avatarUrl = new ObservedPropertySimplePU("", this, "avatarUrl");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MineView_Params) {
        if (params.avatarUrl !== undefined) {
            this.avatarUrl = params.avatarUrl;
        }
    }
    updateStateVars(params: MineView_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
        this.__avatarUrl.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentUser.aboutToBeDeleted();
        this.__avatarUrl.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    private __avatarUrl: ObservedPropertySimplePU<string>;
    get avatarUrl() {
        return this.__avatarUrl.get();
    }
    set avatarUrl(newValue: string) {
        this.__avatarUrl.set(newValue);
    }
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
        }
        catch (e) {
            console.error("Change avatar failed", e);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/MineView.ets(43:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 1. 顶部用户信息卡片
            if (this.currentUser.id > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/view/MineView.ets(46:9)", "entry");
                        Column.width('100%');
                        Column.padding(30);
                        Column.backgroundColor(Color.White);
                        Column.margin({ bottom: 10 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Image.create(this.avatarUrl || { "id": 16777303, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Image.debugLine("entry/src/main/ets/view/MineView.ets(47:11)", "entry");
                        Image.width(80);
                        Image.height(80);
                        Image.borderRadius(40);
                        Image.margin({ bottom: 10 });
                        Image.objectFit(ImageFit.Cover);
                        Image.onClick(() => {
                            this.changeAvatar();
                        });
                    }, Image);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("点击头像更换");
                        Text.debugLine("entry/src/main/ets/view/MineView.ets(54:11)", "entry");
                        Text.fontSize(10);
                        Text.fontColor(Color.Gray);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.currentUser.username);
                        Text.debugLine("entry/src/main/ets/view/MineView.ets(56:11)", "entry");
                        Text.fontSize(20);
                        Text.fontWeight(FontWeight.Bold);
                        Text.margin({ top: 5 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.debugLine("entry/src/main/ets/view/MineView.ets(58:11)", "entry");
                        Row.margin({ top: 10 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.currentUser.role === 1 ? "身份：商家" : "身份：买家");
                        Text.debugLine("entry/src/main/ets/view/MineView.ets(59:13)", "entry");
                        Text.fontSize(12);
                        Text.fontColor(Color.White);
                        Text.backgroundColor(Color.Blue);
                        Text.padding(5);
                        Text.borderRadius(5);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`余额：¥${this.currentUser.balance.toFixed(2)}`);
                        Text.debugLine("entry/src/main/ets/view/MineView.ets(61:13)", "entry");
                        Text.fontSize(12);
                        Text.fontColor(Color.White);
                        Text.backgroundColor(Color.Red);
                        Text.padding(5);
                        Text.borderRadius(5);
                        Text.margin({ left: 10 });
                    }, Text);
                    Text.pop();
                    Row.pop();
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 2. 菜单列表
                        List.create();
                        List.debugLine("entry/src/main/ets/view/MineView.ets(71:9)", "entry");
                        // 2. 菜单列表
                        List.width('95%');
                        // 2. 菜单列表
                        List.backgroundColor(Color.White);
                        // 2. 菜单列表
                        List.borderRadius(10);
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.currentUser.role === 1) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                {
                                    const itemCreation = (elmtId, isInitialRender) => {
                                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                        ListItem.create(deepRenderFunction, true);
                                        if (!isInitialRender) {
                                            // --- 商家菜单 ---
                                            ListItem.pop();
                                        }
                                        ViewStackProcessor.StopGetAccessRecording();
                                    };
                                    const itemCreation2 = (elmtId, isInitialRender) => {
                                        ListItem.create(deepRenderFunction, true);
                                        ListItem.debugLine("entry/src/main/ets/view/MineView.ets(74:13)", "entry");
                                    };
                                    const deepRenderFunction = (elmtId, isInitialRender) => {
                                        itemCreation(elmtId, isInitialRender);
                                        this.MenuCell.bind(this)("发布商品", () => {
                                            router.pushUrl({ url: 'pages/MerchantUploadPage' });
                                        });
                                        // --- 商家菜单 ---
                                        ListItem.pop();
                                    };
                                    this.observeComponentCreation2(itemCreation2, ListItem);
                                    // --- 商家菜单 ---
                                    ListItem.pop();
                                }
                                {
                                    const itemCreation = (elmtId, isInitialRender) => {
                                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                        ListItem.create(deepRenderFunction, true);
                                        if (!isInitialRender) {
                                            // 商品管理已移至主 Tab，这里作为快捷入口或移除均可，保留作为二级入口
                                            ListItem.pop();
                                        }
                                        ViewStackProcessor.StopGetAccessRecording();
                                    };
                                    const itemCreation2 = (elmtId, isInitialRender) => {
                                        ListItem.create(deepRenderFunction, true);
                                        ListItem.debugLine("entry/src/main/ets/view/MineView.ets(80:13)", "entry");
                                    };
                                    const deepRenderFunction = (elmtId, isInitialRender) => {
                                        itemCreation(elmtId, isInitialRender);
                                        this.MenuCell.bind(this)("我的收藏", () => {
                                            router.pushUrl({ url: 'pages/MyFavoritesPage' });
                                        });
                                        // 商品管理已移至主 Tab，这里作为快捷入口或移除均可，保留作为二级入口
                                        ListItem.pop();
                                    };
                                    this.observeComponentCreation2(itemCreation2, ListItem);
                                    // 商品管理已移至主 Tab，这里作为快捷入口或移除均可，保留作为二级入口
                                    ListItem.pop();
                                }
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                                {
                                    const itemCreation = (elmtId, isInitialRender) => {
                                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                        ListItem.create(deepRenderFunction, true);
                                        if (!isInitialRender) {
                                            // --- 买家菜单 ---
                                            ListItem.pop();
                                        }
                                        ViewStackProcessor.StopGetAccessRecording();
                                    };
                                    const itemCreation2 = (elmtId, isInitialRender) => {
                                        ListItem.create(deepRenderFunction, true);
                                        ListItem.debugLine("entry/src/main/ets/view/MineView.ets(87:13)", "entry");
                                    };
                                    const deepRenderFunction = (elmtId, isInitialRender) => {
                                        itemCreation(elmtId, isInitialRender);
                                        this.MenuCell.bind(this)("我的收藏", () => {
                                            router.pushUrl({ url: 'pages/MyFavoritesPage' });
                                        });
                                        // --- 买家菜单 ---
                                        ListItem.pop();
                                    };
                                    this.observeComponentCreation2(itemCreation2, ListItem);
                                    // --- 买家菜单 ---
                                    ListItem.pop();
                                }
                                {
                                    const itemCreation = (elmtId, isInitialRender) => {
                                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                        ListItem.create(deepRenderFunction, true);
                                        if (!isInitialRender) {
                                            ListItem.pop();
                                        }
                                        ViewStackProcessor.StopGetAccessRecording();
                                    };
                                    const itemCreation2 = (elmtId, isInitialRender) => {
                                        ListItem.create(deepRenderFunction, true);
                                        ListItem.debugLine("entry/src/main/ets/view/MineView.ets(92:13)", "entry");
                                    };
                                    const deepRenderFunction = (elmtId, isInitialRender) => {
                                        itemCreation(elmtId, isInitialRender);
                                        this.MenuCell.bind(this)("我的订单", () => {
                                            router.pushUrl({ url: 'pages/OrderListPage' });
                                        });
                                        ListItem.pop();
                                    };
                                    this.observeComponentCreation2(itemCreation2, ListItem);
                                    ListItem.pop();
                                }
                            });
                        }
                    }, If);
                    If.pop();
                    {
                        const itemCreation = (elmtId, isInitialRender) => {
                            ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                            ListItem.create(deepRenderFunction, true);
                            if (!isInitialRender) {
                                ListItem.pop();
                            }
                            ViewStackProcessor.StopGetAccessRecording();
                        };
                        const itemCreation2 = (elmtId, isInitialRender) => {
                            ListItem.create(deepRenderFunction, true);
                            ListItem.debugLine("entry/src/main/ets/view/MineView.ets(99:11)", "entry");
                        };
                        const deepRenderFunction = (elmtId, isInitialRender) => {
                            itemCreation(elmtId, isInitialRender);
                            this.MenuCell.bind(this)("重置所有数据 (清除测试数据)", async () => {
                                await ProductService.clearAllData();
                                promptAction.showToast({ message: '数据已重置' });
                                AppStorage.SetOrCreate('currentUser', new User(0, '', 0, 0, ""));
                                this.avatarUrl = "";
                                router.replaceUrl({ url: 'pages/LoginPage' }); // [修改] 使用 replaceUrl
                            });
                            ListItem.pop();
                        };
                        this.observeComponentCreation2(itemCreation2, ListItem);
                        ListItem.pop();
                    }
                    {
                        const itemCreation = (elmtId, isInitialRender) => {
                            ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                            ListItem.create(deepRenderFunction, true);
                            if (!isInitialRender) {
                                ListItem.pop();
                            }
                            ViewStackProcessor.StopGetAccessRecording();
                        };
                        const itemCreation2 = (elmtId, isInitialRender) => {
                            ListItem.create(deepRenderFunction, true);
                            ListItem.debugLine("entry/src/main/ets/view/MineView.ets(109:11)", "entry");
                        };
                        const deepRenderFunction = (elmtId, isInitialRender) => {
                            itemCreation(elmtId, isInitialRender);
                            this.MenuCell.bind(this)("退出登录", () => {
                                AppStorage.SetOrCreate('currentUser', new User(0, '', 0, 0, ""));
                                this.avatarUrl = "";
                                router.replaceUrl({ url: 'pages/LoginPage' }); // [修改] 使用 replaceUrl
                            });
                            ListItem.pop();
                        };
                        this.observeComponentCreation2(itemCreation2, ListItem);
                        ListItem.pop();
                    }
                    // 2. 菜单列表
                    List.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 未登录
                        Column.create();
                        Column.debugLine("entry/src/main/ets/view/MineView.ets(123:9)", "entry");
                        // 未登录
                        Column.height('100%');
                        // 未登录
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("您尚未登录");
                        Text.debugLine("entry/src/main/ets/view/MineView.ets(124:11)", "entry");
                        Text.fontSize(20);
                        Text.margin({ bottom: 20 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("去登录 / 注册");
                        Button.debugLine("entry/src/main/ets/view/MineView.ets(125:11)", "entry");
                        Button.onClick(() => {
                            router.replaceUrl({ url: 'pages/LoginPage' });
                        });
                    }, Button);
                    Button.pop();
                    // 未登录
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    MenuCell(title: string, action: () => void, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/view/MineView.ets(140:5)", "entry");
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceBetween);
            Row.padding(15);
            Row.backgroundColor(Color.White);
            Row.onClick(action);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.debugLine("entry/src/main/ets/view/MineView.ets(141:7)", "entry");
            Text.fontSize(16);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(">");
            Text.debugLine("entry/src/main/ets/view/MineView.ets(142:7)", "entry");
            Text.fontSize(16);
            Text.fontColor(Color.Gray);
        }, Text);
        Text.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
