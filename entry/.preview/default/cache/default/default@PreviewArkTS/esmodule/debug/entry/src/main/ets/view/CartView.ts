if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface CartView_Params {
    refreshTrigger?: number;
    cartList?: CartItem[];
    currentUser?: User;
    selectedCartIds?: number[];
}
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type { CartItem } from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import promptAction from "@ohos:promptAction";
import ProductService from "@bundle:com.huawei.waterflow/entry/ets/service/ProductService";
export class CartView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__refreshTrigger = new SynchedPropertySimpleOneWayPU(params.refreshTrigger, this, "refreshTrigger");
        this.__cartList = new ObservedPropertyObjectPU([], this, "cartList");
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.__selectedCartIds = new ObservedPropertyObjectPU([], this, "selectedCartIds");
        this.setInitiallyProvidedValue(params);
        this.declareWatch("refreshTrigger", this.refreshData);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: CartView_Params) {
        if (params.refreshTrigger === undefined) {
            this.__refreshTrigger.set(0);
        }
        if (params.cartList !== undefined) {
            this.cartList = params.cartList;
        }
        if (params.selectedCartIds !== undefined) {
            this.selectedCartIds = params.selectedCartIds;
        }
    }
    updateStateVars(params: CartView_Params) {
        this.__refreshTrigger.reset(params.refreshTrigger);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__refreshTrigger.purgeDependencyOnElmtId(rmElmtId);
        this.__cartList.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedCartIds.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__refreshTrigger.aboutToBeDeleted();
        this.__cartList.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
        this.__selectedCartIds.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __refreshTrigger: SynchedPropertySimpleOneWayPU<number>;
    get refreshTrigger() {
        return this.__refreshTrigger.get();
    }
    set refreshTrigger(newValue: number) {
        this.__refreshTrigger.set(newValue);
    }
    private __cartList: ObservedPropertyObjectPU<CartItem[]>;
    get cartList() {
        return this.__cartList.get();
    }
    set cartList(newValue: CartItem[]) {
        this.__cartList.set(newValue);
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    private __selectedCartIds: ObservedPropertyObjectPU<number[]>;
    get selectedCartIds() {
        return this.__selectedCartIds.get();
    }
    set selectedCartIds(newValue: number[]) {
        this.__selectedCartIds.set(newValue);
    }
    async aboutToAppear() {
        this.refreshData();
    }
    async refreshData() {
        if (this.currentUser.id) {
            this.cartList = await ProductService.getCartList(this.currentUser.id);
            this.selectedCartIds = [];
        }
    }
    async handleDelete(item: CartItem) {
        await RdbUtil.deleteCartItem(item.cartId);
        this.selectedCartIds = this.selectedCartIds.filter(id => id !== item.cartId);
        this.refreshData();
    }
    async handleCheckout() {
        if (this.selectedCartIds.length === 0) {
            promptAction.showToast({ message: '请先勾选商品' });
            return;
        }
        let totalAmount = 0;
        let checkoutItems: CartItem[] = [];
        this.cartList.forEach(item => {
            if (this.selectedCartIds.includes(item.cartId)) {
                totalAmount += item.price * item.count;
                checkoutItems.push(item);
            }
        });
        if (this.currentUser.balance < totalAmount) {
            promptAction.showToast({ message: `余额不足，还需要 ¥${(totalAmount - this.currentUser.balance).toFixed(2)}` });
            return;
        }
        let successCount = 0;
        for (let item of checkoutItems) {
            // [修改] 传递 merchantId
            // 注意: item.merchantId 继承自 ProductItem
            let code = await RdbUtil.createOrder(this.currentUser.id, item.name, item.price * item.count, 'ic_holder_computer', // 兜底图片
            item.merchantId // 传入商家ID
            );
            if (code === 1) {
                await RdbUtil.deleteCartItem(item.cartId);
                successCount++;
                this.currentUser.balance -= (item.price * item.count);
            }
        }
        promptAction.showToast({ message: `成功结算 ${successCount} 件商品` });
        this.refreshData();
    }
    toggleSelect(cartId: number, isSelected: boolean) {
        if (isSelected) {
            this.selectedCartIds.push(cartId);
        }
        else {
            this.selectedCartIds = this.selectedCartIds.filter(id => id !== cartId);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/CartView.ets(84:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("购物车");
            Text.debugLine("entry/src/main/ets/view/CartView.ets(85:7)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.margin(20);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.cartList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/view/CartView.ets(88:9)", "entry");
                        Column.height('80%');
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Image.create({ "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Image.debugLine("entry/src/main/ets/view/CartView.ets(89:11)", "entry");
                        Image.width(100);
                        Image.height(100);
                        Image.opacity(0.3);
                        Image.margin({ bottom: 10 });
                    }, Image);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("购物车是空的");
                        Text.debugLine("entry/src/main/ets/view/CartView.ets(90:11)", "entry");
                        Text.fontColor(Color.Gray);
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create({ space: 10 });
                        List.debugLine("entry/src/main/ets/view/CartView.ets(93:9)", "entry");
                        List.layoutWeight(1);
                        List.width('95%');
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
                                    ListItem.debugLine("entry/src/main/ets/view/CartView.ets(95:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/CartView.ets(96:15)", "entry");
                                        Row.padding(10);
                                        Row.backgroundColor(Color.White);
                                        Row.borderRadius(10);
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Checkbox.create();
                                        Checkbox.debugLine("entry/src/main/ets/view/CartView.ets(97:17)", "entry");
                                        Checkbox.select(this.selectedCartIds.includes(item.cartId));
                                        Checkbox.selectedColor('#FF5000');
                                        Checkbox.onChange((val) => this.toggleSelect(item.cartId, val));
                                        Checkbox.margin({ right: 10 });
                                    }, Checkbox);
                                    Checkbox.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create(item.image_url);
                                        Image.debugLine("entry/src/main/ets/view/CartView.ets(103:17)", "entry");
                                        Image.width(80);
                                        Image.height(80);
                                        Image.borderRadius(8);
                                        Image.objectFit(ImageFit.Cover);
                                    }, Image);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/view/CartView.ets(105:17)", "entry");
                                        Column.layoutWeight(1);
                                        Column.padding({ left: 10 });
                                        Column.alignItems(HorizontalAlign.Start);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/view/CartView.ets(106:19)", "entry");
                                        Text.fontSize(16);
                                        Text.maxLines(1);
                                        Text.fontWeight(FontWeight.Bold);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`单价: ¥${item.price.toFixed(2)}`);
                                        Text.debugLine("entry/src/main/ets/view/CartView.ets(107:19)", "entry");
                                        Text.fontColor(Color.Gray);
                                        Text.fontSize(12);
                                        Text.margin({ top: 5 });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/CartView.ets(108:19)", "entry");
                                        Row.width('100%');
                                        Row.margin({ top: 5 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`数量: ${item.count}`);
                                        Text.debugLine("entry/src/main/ets/view/CartView.ets(109:21)", "entry");
                                        Text.fontSize(14);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                        Blank.debugLine("entry/src/main/ets/view/CartView.ets(110:21)", "entry");
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`¥${(item.price * item.count).toFixed(2)}`);
                                        Text.debugLine("entry/src/main/ets/view/CartView.ets(111:21)", "entry");
                                        Text.fontColor(Color.Red);
                                        Text.fontWeight(FontWeight.Bold);
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    Column.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel("删除");
                                        Button.debugLine("entry/src/main/ets/view/CartView.ets(116:17)", "entry");
                                        Button.backgroundColor(Color.Red);
                                        Button.height(30);
                                        Button.fontSize(12);
                                        Button.margin({ left: 10 });
                                        Button.onClick(() => this.handleDelete(item));
                                    }, Button);
                                    Button.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.cartList, forEachItemGenFunction);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.debugLine("entry/src/main/ets/view/CartView.ets(125:9)", "entry");
                        Row.width('100%');
                        Row.padding(15);
                        Row.backgroundColor(Color.White);
                        Row.justifyContent(FlexAlign.SpaceBetween);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`合计: ¥${this.cartList.reduce((sum, item) => {
                            return sum + (this.selectedCartIds.includes(item.cartId) ? item.price * item.count : 0);
                        }, 0).toFixed(2)}`);
                        Text.debugLine("entry/src/main/ets/view/CartView.ets(126:11)", "entry");
                        Text.fontColor(Color.Red);
                        Text.fontWeight(FontWeight.Bold);
                        Text.fontSize(18);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel(`去结算(${this.selectedCartIds.length})`);
                        Button.debugLine("entry/src/main/ets/view/CartView.ets(131:11)", "entry");
                        Button.backgroundColor(this.selectedCartIds.length > 0 ? '#FF5000' : '#CCCCCC');
                        Button.enabled(this.selectedCartIds.length > 0);
                        Button.onClick(() => this.handleCheckout());
                    }, Button);
                    Button.pop();
                    Row.pop();
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
