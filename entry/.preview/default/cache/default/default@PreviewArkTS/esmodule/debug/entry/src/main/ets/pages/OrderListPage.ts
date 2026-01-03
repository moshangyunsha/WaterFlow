if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface OrderListPage_Params {
    orderList?: OrderItem[];
    topRectHeight?: number;
}
import type { OrderItem } from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type { User } from '../viewmodel/User';
import promptAction from "@ohos:promptAction";
import router from "@ohos:router";
class OrderListPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__orderList = new ObservedPropertyObjectPU([], this, "orderList");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: OrderListPage_Params) {
        if (params.orderList !== undefined) {
            this.orderList = params.orderList;
        }
    }
    updateStateVars(params: OrderListPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__orderList.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__orderList.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __orderList: ObservedPropertyObjectPU<OrderItem[]>;
    get orderList() {
        return this.__orderList.get();
    }
    set orderList(newValue: OrderItem[]) {
        this.__orderList.set(newValue);
    }
    // [修复] 1. 获取状态栏高度
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    async aboutToAppear() {
        this.refreshData();
    }
    async refreshData() {
        let user = AppStorage.Get<User>('currentUser');
        if (user && user.id) {
            this.orderList = await RdbUtil.getMyOrders(user.id);
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
    getStatusColor(status: number): string {
        switch (status) {
            case 0: return '#FF9900';
            case 1: return '#007DFF';
            case 2: return '#00AA00';
            default: return '#999999';
        }
    }
    async handleConfirmReceipt(order: OrderItem) {
        let success = await RdbUtil.updateOrderStatus(order.id, 2);
        if (success) {
            promptAction.showToast({ message: '已确认收货' });
            this.refreshData();
        }
        else {
            promptAction.showToast({ message: '操作失败' });
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/OrderListPage.ets(62:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // [修复] 2. 为标题栏添加 Padding
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/OrderListPage.ets(64:7)", "entry");
            // [修复] 2. 为标题栏添加 Padding
            Row.width('100%');
            // [修复] 2. 为标题栏添加 Padding
            Row.padding({
                top: 10 + this.getUIContext().px2vp(this.topRectHeight),
                bottom: 10,
                left: 10,
                right: 10
            });
            // [修复] 2. 为标题栏添加 Padding
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("<");
            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(65:9)", "entry");
            Text.fontSize(24);
            Text.width(40);
            Text.height(40);
            Text.textAlign(TextAlign.Center);
            Text.onClick(() => router.back());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("我的订单");
            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(71:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // [修复] 2. 为标题栏添加 Padding
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create({ space: 10 });
            List.debugLine("entry/src/main/ets/pages/OrderListPage.ets(82:7)", "entry");
            List.layoutWeight(1);
            List.width('95%');
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
                        ListItem.debugLine("entry/src/main/ets/pages/OrderListPage.ets(84:11)", "entry");
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/OrderListPage.ets(85:13)", "entry");
                            Column.padding(10);
                            Column.backgroundColor(Color.White);
                            Column.borderRadius(10);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create();
                            Row.debugLine("entry/src/main/ets/pages/OrderListPage.ets(86:15)", "entry");
                            Row.width('100%');
                            Row.margin({ bottom: 10 });
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`订单号: ${order.id}`);
                            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(87:17)", "entry");
                            Text.fontSize(12);
                            Text.fontColor(Color.Gray);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Blank.create();
                            Blank.debugLine("entry/src/main/ets/pages/OrderListPage.ets(88:17)", "entry");
                        }, Blank);
                        Blank.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(this.getStatusText(order.status));
                            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(89:17)", "entry");
                            Text.fontSize(12);
                            Text.fontColor(this.getStatusColor(order.status));
                        }, Text);
                        Text.pop();
                        Row.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Row.create();
                            Row.debugLine("entry/src/main/ets/pages/OrderListPage.ets(94:15)", "entry");
                        }, Row);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Image.create(this.getImage(order.imgUrl));
                            Image.debugLine("entry/src/main/ets/pages/OrderListPage.ets(95:17)", "entry");
                            Image.width(80);
                            Image.height(80);
                            Image.objectFit(ImageFit.Cover);
                            Image.borderRadius(8);
                            Image.margin({ right: 10 });
                        }, Image);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Column.create();
                            Column.debugLine("entry/src/main/ets/pages/OrderListPage.ets(99:17)", "entry");
                            Column.alignItems(HorizontalAlign.Start);
                            Column.layoutWeight(1);
                        }, Column);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(order.title);
                            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(100:19)", "entry");
                            Text.fontSize(16);
                            Text.maxLines(1);
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(`¥${order.price.toFixed(2)}`);
                            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(101:19)", "entry");
                            Text.fontColor(Color.Red);
                            Text.margin({ top: 5 });
                        }, Text);
                        Text.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(order.date);
                            Text.debugLine("entry/src/main/ets/pages/OrderListPage.ets(102:19)", "entry");
                            Text.fontSize(12);
                            Text.fontColor(Color.Gray);
                            Text.margin({ top: 5 });
                        }, Text);
                        Text.pop();
                        Column.pop();
                        Row.pop();
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            If.create();
                            if (order.status === 1) {
                                this.ifElseBranchUpdateFunction(0, () => {
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/OrderListPage.ets(107:17)", "entry");
                                        Row.width('100%');
                                        Row.margin({ top: 10 });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                        Blank.debugLine("entry/src/main/ets/pages/OrderListPage.ets(108:19)", "entry");
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Button.createWithLabel("确认收货");
                                        Button.debugLine("entry/src/main/ets/pages/OrderListPage.ets(109:19)", "entry");
                                        Button.fontSize(12);
                                        Button.height(28);
                                        Button.backgroundColor('#FF5000');
                                        Button.onClick(() => this.handleConfirmReceipt(order));
                                    }, Button);
                                    Button.pop();
                                    Row.pop();
                                });
                            }
                            else {
                                this.ifElseBranchUpdateFunction(1, () => {
                                });
                            }
                        }, If);
                        If.pop();
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
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "OrderListPage";
    }
}
registerNamedRoute(() => new OrderListPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/OrderListPage", pageFullPath: "entry/src/main/ets/pages/OrderListPage", integratedHsp: "false", moduleType: "followWithHap" });
