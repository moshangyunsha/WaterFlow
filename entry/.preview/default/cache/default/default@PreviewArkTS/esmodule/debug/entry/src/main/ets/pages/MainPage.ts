if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MainPage_Params {
    currentIndex?: number;
    refreshSignal?: number;
    topRectHeight?: number;
    bottomRectHeight?: number;
}
import { HomeView } from "@bundle:com.huawei.waterflow/entry/ets/view/HomeView";
import { MineView } from "@bundle:com.huawei.waterflow/entry/ets/view/MineView";
import { CartView } from "@bundle:com.huawei.waterflow/entry/ets/view/CartView";
class MainPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentIndex = new ObservedPropertySimplePU(0, this, "currentIndex");
        this.__refreshSignal = new ObservedPropertySimplePU(0, this, "refreshSignal");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.__bottomRectHeight = this.createStorageLink('bottomRectHeight', 0, "bottomRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MainPage_Params) {
        if (params.currentIndex !== undefined) {
            this.currentIndex = params.currentIndex;
        }
        if (params.refreshSignal !== undefined) {
            this.refreshSignal = params.refreshSignal;
        }
    }
    updateStateVars(params: MainPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__refreshSignal.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__bottomRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentIndex.aboutToBeDeleted();
        this.__refreshSignal.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
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
    // [新增] 用于通知子组件刷新的信号
    private __refreshSignal: ObservedPropertySimplePU<number>;
    get refreshSignal() {
        return this.__refreshSignal.get();
    }
    set refreshSignal(newValue: number) {
        this.__refreshSignal.set(newValue);
    }
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    private __bottomRectHeight: ObservedPropertyAbstractPU<number>;
    get bottomRectHeight() {
        return this.__bottomRectHeight.get();
    }
    set bottomRectHeight(newValue: number) {
        this.__bottomRectHeight.set(newValue);
    }
    // [新增] 页面显示时（从详情页返回），强制刷新信号
    onPageShow() {
        this.refreshSignal++;
    }
    TabBuilder(title: string, index: number, iconStr: string, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MainPage.ets(21:5)", "entry");
            Column.justifyContent(FlexAlign.Center);
            Column.height('100%');
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(iconStr);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(22:7)", "entry");
            Text.fontSize(24);
            Text.fontColor(this.currentIndex === index ? '#FF5000' : '#999999');
            Text.margin({ bottom: 2 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.debugLine("entry/src/main/ets/pages/MainPage.ets(23:7)", "entry");
            Text.fontSize(10);
            Text.fontColor(this.currentIndex === index ? '#FF5000' : '#999999');
        }, Text);
        Text.pop();
        Column.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Tabs.create({ barPosition: BarPosition.End, index: this.currentIndex });
            Tabs.debugLine("entry/src/main/ets/pages/MainPage.ets(29:5)", "entry");
            Tabs.onChange((index) => {
                this.currentIndex = index;
                // [新增] 切换 Tab 时，也更新信号，确保切过去看到最新的
                this.refreshSignal++;
            });
            Tabs.barMode(BarMode.Fixed);
            Tabs.barHeight(56 + this.getUIContext().px2vp(this.bottomRectHeight));
            Tabs.backgroundColor(Color.White);
            Tabs.scrollable(false);
        }, Tabs);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new HomeView(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 31, col: 9 });
                            ViewPU.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "HomeView" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, "首页", 0, "🏠");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MainPage.ets(30:7)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new 
                            // [修改] 传递刷新信号给 CartView
                            CartView(this, { refreshTrigger: this.refreshSignal }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 36, col: 9 });
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
                    }, { name: "CartView" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, "购物车", 1, "🛒");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MainPage.ets(34:7)", "entry");
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new MineView(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/MainPage.ets", line: 40, col: 9 });
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
                    this.TabBuilder.call(this, "我的", 2, "👤");
                } });
            TabContent.debugLine("entry/src/main/ets/pages/MainPage.ets(39:7)", "entry");
        }, TabContent);
        TabContent.pop();
        Tabs.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MainPage";
    }
}
registerNamedRoute(() => new MainPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/MainPage", pageFullPath: "entry/src/main/ets/pages/MainPage", integratedHsp: "false", moduleType: "followWithHap" });
