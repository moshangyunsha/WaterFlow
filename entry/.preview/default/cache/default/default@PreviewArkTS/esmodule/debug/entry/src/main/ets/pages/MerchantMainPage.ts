if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MerchantMainPage_Params {
    currentIndex?: number;
    refreshSignal?: number;
    bottomRectHeight?: number;
}
import { MerchantProductView } from "@bundle:com.huawei.waterflow/entry/ets/view/MerchantManageView";
import { MineView } from "@bundle:com.huawei.waterflow/entry/ets/view/MineView";
import { MerchantOrderView } from "@bundle:com.huawei.waterflow/entry/ets/view/MerchantOrderView";
class MerchantMainPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentIndex = new ObservedPropertySimplePU(0, this, "currentIndex");
        this.__refreshSignal = new ObservedPropertySimplePU(0, this, "refreshSignal");
        this.__bottomRectHeight = this.createStorageLink('bottomRectHeight', 0, "bottomRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MerchantMainPage_Params) {
        if (params.currentIndex !== undefined) {
            this.currentIndex = params.currentIndex;
        }
        if (params.refreshSignal !== undefined) {
            this.refreshSignal = params.refreshSignal;
        }
    }
    updateStateVars(params: MerchantMainPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__refreshSignal.purgeDependencyOnElmtId(rmElmtId);
        this.__bottomRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentIndex.aboutToBeDeleted();
        this.__refreshSignal.aboutToBeDeleted();
        this.__bottomRectHeight.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentIndex: ObservedPropertySimplePU<number>;
    get currentIndex() {
        return this.__currentIndex.get();
    }
    set currentIndex(newValue: number) {
        this.__currentIndex.set(newValue);
    }
    private __refreshSignal: ObservedPropertySimplePU<number>;
    get refreshSignal() {
        return this.__refreshSignal.get();
    }
    set refreshSignal(newValue: number) {
        this.__refreshSignal.set(newValue);
    }
    private __bottomRectHeight: ObservedPropertyAbstractPU<number>;
    get bottomRectHeight() {
        return this.__bottomRectHeight.get();
    }
    set bottomRectHeight(newValue: number) {
        this.__bottomRectHeight.set(newValue);
    }
    onPageShow() {
        this.refreshSignal++;
    }
    TabBuilder(title: string, index: number, iconStr: string, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(18:5)", "entry");
            Column.justifyContent(FlexAlign.Center);
            Column.height('100%');
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(iconStr);
            Text.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(19:7)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.currentIndex === index ? '#007DFF' : '#999999');
            Text.margin({ bottom: 2 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(20:7)", "entry");
            Text.fontSize(10);
            Text.fontColor(this.currentIndex === index ? '#007DFF' : '#999999');
        }, Text);
        Text.pop();
        Column.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Tabs.create({ barPosition: BarPosition.End, index: this.currentIndex });
            Tabs.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(26:5)", "entry");
            Tabs.onChange((index) => {
                this.currentIndex = index;
                this.refreshSignal++;
            });
            Tabs.barHeight(56 + this.getUIContext().px2vp(this.bottomRectHeight));
            Tabs.backgroundColor(Color.White);
            Tabs.scrollable(false);
        }, Tabs);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new MerchantProductView(this, { refreshTrigger: this.refreshSignal }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MerchantMainPage.ets", line: 28, col: 9 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {
                                    refreshTrigger: this.refreshSignal
                                };
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {
                                refreshTrigger: this.refreshSignal
                            });
                        }
                    }, { name: "MerchantProductView" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, "商品管理", 0, "📦");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(27:7)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new MerchantOrderView(this, { refreshTrigger: this.refreshSignal }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MerchantMainPage.ets", line: 33, col: 9 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {
                                    refreshTrigger: this.refreshSignal
                                };
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {
                                refreshTrigger: this.refreshSignal
                            });
                        }
                    }, { name: "MerchantOrderView" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, "订单管理", 1, "📄");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(32:7)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new MineView(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MerchantMainPage.ets", line: 37, col: 9 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "MineView" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, "我的店铺", 2, "🏪");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MerchantMainPage.ets(36:7)", "entry");
        }, TabContent);
        TabContent.pop();
        Tabs.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MerchantMainPage";
    }
}
registerNamedRoute(() => new MerchantMainPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/MerchantMainPage", pageFullPath: "entry/src/main/ets/pages/MerchantMainPage", integratedHsp: "false", moduleType: "followWithHap" });
