if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MerchantOrderView_Params {
    refreshTrigger?: number;
    orderList?: OrderItem[];
    currentUser?: User;
}
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type { OrderItem } from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import promptAction from "@ohos:promptAction";
export class MerchantOrderView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__refreshTrigger = new SynchedPropertySimpleOneWayPU(params.refreshTrigger, this, "refreshTrigger");
        this.__orderList = new ObservedPropertyObjectPU([], this, "orderList");
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.setInitiallyProvidedValue(params);
        this.declareWatch("refreshTrigger", this.refreshData);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MerchantOrderView_Params) {
        if (params.refreshTrigger === undefined) {
            this.__refreshTrigger.set(0);
        }
        if (params.orderList !== undefined) {
            this.orderList = params.orderList;
        }
    }
    updateStateVars(params: MerchantOrderView_Params) {
        this.__refreshTrigger.reset(params.refreshTrigger);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__refreshTrigger.purgeDependencyOnElmtId(rmElmtId);
        this.__orderList.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__refreshTrigger.aboutToBeDeleted();
        this.__orderList.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
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
    private __orderList: ObservedPropertyObjectPU<OrderItem[]>;
    get orderList() {
        return this.__orderList.get();
    }
    set orderList(newValue: OrderItem[]) {
        this.__orderList.set(newValue);
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
            // 获取当前商家的订单
            this.orderList = await RdbUtil.getMerchantOrders(this.currentUser.id);
        }
    }
    // 发货逻辑
    async handleShip(order: OrderItem) {
        let success = await RdbUtil.updateOrderStatus(order.id, 1); // 1 = Shipped
        if (success) {
            promptAction.showToast({ message: '发货成功' });
            this.refreshData();
        }
        else {
            promptAction.showToast({ message: '操作失败' });
        }
    }
    getImage(key: string): ResourceStr {
        if (key.startsWith('file://'))
            return key;
        if (key === 'ic_holder_50e')
            return { "id": 16777305, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
        if (key === 'ic_holder_xs2')
            return { "id": 16777302, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
        if (key === 'ic_holder_computer')
            return { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
        return { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
    }
    getStatusText(status: number): string {
        switch (status) {
            case 0: return '待发货';
            case 1: return '已发货';
            case 2: return '已完成';
            default: return '未知';
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(51:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(52:7)", "entry");
            Row.width('100%');
            Row.padding(15);
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("订单管理");
            Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(53:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ left: 15 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.orderList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(57:9)", "entry");
                        Column.height('80%');
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("暂无订单");
                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(58:11)", "entry");
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
                        List.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(61:9)", "entry");
                        List.width('95%');
                        List.layoutWeight(1);
                        List.margin({ top: 10 });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const order = _item;
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
                                    ListItem.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(63:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(64:15)", "entry");
                                        Column.padding(10);
                                        Column.backgroundColor(Color.White);
                                        Column.borderRadius(10);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(65:17)", "entry");
                                        Row.width('100%');
                                        Row.margin({ bottom: 10 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`订单号: ${order.id}`);
                                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(66:19)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor(Color.Gray);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                        Blank.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(67:19)", "entry");
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(this.getStatusText(order.status));
                                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(68:19)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor(order.status === 0 ? Color.Red : Color.Green);
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(73:17)", "entry");
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create(this.getImage(order.imgUrl));
                                        Image.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(74:19)", "entry");
                                        Image.width(60);
                                        Image.height(60);
                                        Image.objectFit(ImageFit.Cover);
                                        Image.borderRadius(8);
                                    }, Image);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(77:19)", "entry");
                                        Column.alignItems(HorizontalAlign.Start);
                                        Column.margin({ left: 10 });
                                        Column.layoutWeight(1);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(order.title);
                                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(78:21)", "entry");
                                        Text.fontSize(16);
                                        Text.maxLines(1);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`¥${order.price.toFixed(2)}`);
                                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(79:21)", "entry");
                                        Text.fontColor(Color.Red);
                                        Text.margin({ top: 5 });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(order.date);
                                        Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(80:21)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor(Color.Gray);
                                        Text.margin({ top: 2 });
                                    }, Text);
                                    Text.pop();
                                    Column.pop();
                                    Row.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 操作栏
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(88:17)", "entry");
                                        // 操作栏
                                        Row.width('100%');
                                        // 操作栏
                                        Row.margin({ top: 10 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                        Blank.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(89:19)", "entry");
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        If.create();
                                        if (order.status === 0) {
                                            this.ifElseBranchUpdateFunction(0, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Button.createWithLabel("立即发货");
                                                    Button.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(91:21)", "entry");
                                                    Button.fontSize(12);
                                                    Button.height(28);
                                                    Button.backgroundColor('#007DFF');
                                                    Button.onClick(() => this.handleShip(order));
                                                }, Button);
                                                Button.pop();
                                            });
                                        }
                                        else if (order.status === 1) {
                                            this.ifElseBranchUpdateFunction(1, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Text.create("等待买家收货");
                                                    Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(97:21)", "entry");
                                                    Text.fontSize(12);
                                                    Text.fontColor(Color.Gray);
                                                }, Text);
                                                Text.pop();
                                            });
                                        }
                                        else {
                                            this.ifElseBranchUpdateFunction(2, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Text.create("交易已完成");
                                                    Text.debugLine("entry/src/main/ets/view/MerchantOrderView.ets(99:21)", "entry");
                                                    Text.fontSize(12);
                                                    Text.fontColor(Color.Gray);
                                                }, Text);
                                                Text.pop();
                                            });
                                        }
                                    }, If);
                                    If.pop();
                                    // 操作栏
                                    Row.pop();
                                    Column.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.orderList, forEachItemGenFunction);
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
