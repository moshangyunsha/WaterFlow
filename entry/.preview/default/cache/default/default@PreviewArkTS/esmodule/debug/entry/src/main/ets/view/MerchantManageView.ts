if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MerchantProductView_Params {
    refreshTrigger?: number;
    myList?: ProductItem[];
    currentUser?: User;
}
import router from "@ohos:router";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type ProductItem from '../viewmodel/ProductItem';
import promptAction from "@ohos:promptAction";
export class MerchantProductView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__refreshTrigger = new SynchedPropertySimpleOneWayPU(params.refreshTrigger, this, "refreshTrigger");
        this.__myList = new ObservedPropertyObjectPU([], this, "myList");
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.setInitiallyProvidedValue(params);
        this.declareWatch("refreshTrigger", this.refreshData);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MerchantProductView_Params) {
        if (params.refreshTrigger === undefined) {
            this.__refreshTrigger.set(0);
        }
        if (params.myList !== undefined) {
            this.myList = params.myList;
        }
    }
    updateStateVars(params: MerchantProductView_Params) {
        this.__refreshTrigger.reset(params.refreshTrigger);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__refreshTrigger.purgeDependencyOnElmtId(rmElmtId);
        this.__myList.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__refreshTrigger.aboutToBeDeleted();
        this.__myList.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // [新增] 监听刷新
    private __refreshTrigger: SynchedPropertySimpleOneWayPU<number>;
    get refreshTrigger() {
        return this.__refreshTrigger.get();
    }
    set refreshTrigger(newValue: number) {
        this.__refreshTrigger.set(newValue);
    }
    private __myList: ObservedPropertyObjectPU<ProductItem[]>;
    get myList() {
        return this.__myList.get();
    }
    set myList(newValue: ProductItem[]) {
        this.__myList.set(newValue);
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    async aboutToAppear() {
        this.refreshData();
    }
    async refreshData() {
        if (this.currentUser.id) {
            this.myList = await RdbUtil.getMerchantProducts(this.currentUser.id);
        }
    }
    async handleDelete(item: ProductItem) {
        AlertDialog.show({
            title: '确认删除',
            message: `确定要删除 "${item.name}" 吗？`,
            primaryButton: { value: '取消', action: () => { } },
            secondaryButton: {
                value: '删除',
                fontColor: Color.Red,
                action: async () => {
                    await RdbUtil.deleteProduct(item.id);
                    promptAction.showToast({ message: '已删除' });
                    this.refreshData();
                }
            }
        });
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/MerchantManageView.ets(43:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/view/MerchantManageView.ets(44:7)", "entry");
            Row.width('100%');
            Row.padding(15);
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("商品管理");
            Text.debugLine("entry/src/main/ets/view/MerchantManageView.ets(45:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ left: 15 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.myList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/view/MerchantManageView.ets(49:9)", "entry");
                        Column.height('80%');
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("您还没有发布任何商品");
                        Text.debugLine("entry/src/main/ets/view/MerchantManageView.ets(50:11)", "entry");
                        Text.fontColor(Color.Gray);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel("去发布");
                        Button.debugLine("entry/src/main/ets/view/MerchantManageView.ets(51:11)", "entry");
                        Button.margin({ top: 20 });
                        Button.onClick(() => router.pushUrl({ url: 'pages/MerchantUploadPage' }));
                    }, Button);
                    Button.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create({ space: 10 });
                        List.debugLine("entry/src/main/ets/view/MerchantManageView.ets(54:9)", "entry");
                        List.width('95%');
                        List.layoutWeight(1);
                        List.margin({ top: 10 });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const item = _item;
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
                                    ListItem.debugLine("entry/src/main/ets/view/MerchantManageView.ets(56:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/MerchantManageView.ets(57:15)", "entry");
                                        Row.padding(10);
                                        Row.backgroundColor(Color.White);
                                        Row.borderRadius(10);
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create(item.image_url);
                                        Image.debugLine("entry/src/main/ets/view/MerchantManageView.ets(58:17)", "entry");
                                        Image.width(80);
                                        Image.height(80);
                                        Image.borderRadius(8);
                                        Image.objectFit(ImageFit.Cover);
                                    }, Image);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/view/MerchantManageView.ets(59:17)", "entry");
                                        Column.alignItems(HorizontalAlign.Start);
                                        Column.margin({ left: 10 });
                                        Column.layoutWeight(1);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/view/MerchantManageView.ets(60:19)", "entry");
                                        Text.fontSize(16);
                                        Text.maxLines(1);
                                        Text.fontWeight(FontWeight.Bold);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`¥${item.price}`);
                                        Text.debugLine("entry/src/main/ets/view/MerchantManageView.ets(61:19)", "entry");
                                        Text.fontColor(Color.Red);
                                        Text.margin({ top: 5 });
                                    }, Text);
                                    Text.pop();
                                    Column.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/view/MerchantManageView.ets(65:17)", "entry");
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel("编辑");
                                        Button.debugLine("entry/src/main/ets/view/MerchantManageView.ets(66:19)", "entry");
                                        Button.fontSize(12);
                                        Button.height(28);
                                        Button.backgroundColor(Color.Blue);
                                        Button.onClick(() => { router.pushUrl({ url: 'pages/MerchantEditPage', params: item }); });
                                    }, Button);
                                    Button.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel("删除");
                                        Button.debugLine("entry/src/main/ets/view/MerchantManageView.ets(68:19)", "entry");
                                        Button.fontSize(12);
                                        Button.height(28);
                                        Button.backgroundColor(Color.Red);
                                        Button.margin({ top: 5 });
                                        Button.onClick(() => this.handleDelete(item));
                                    }, Button);
                                    Button.pop();
                                    Column.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.myList, forEachItemGenFunction);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
