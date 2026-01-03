if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MyFavoritesPage_Params {
    favoriteList?: ProductItem[];
    topRectHeight?: number;
}
import router from "@ohos:router";
import ProductService from "@bundle:com.huawei.waterflow/entry/ets/service/ProductService";
import type ProductItem from '../viewmodel/ProductItem';
import type { User } from '../viewmodel/User';
class MyFavoritesPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__favoriteList = new ObservedPropertyObjectPU([], this, "favoriteList");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MyFavoritesPage_Params) {
        if (params.favoriteList !== undefined) {
            this.favoriteList = params.favoriteList;
        }
    }
    updateStateVars(params: MyFavoritesPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__favoriteList.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__favoriteList.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __favoriteList: ObservedPropertyObjectPU<ProductItem[]>;
    get favoriteList() {
        return this.__favoriteList.get();
    }
    set favoriteList(newValue: ProductItem[]) {
        this.__favoriteList.set(newValue);
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
        let user = AppStorage.Get<User>('currentUser');
        if (user && user.id) {
            this.favoriteList = await ProductService.getMyFavorites(user.id);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(21:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 顶部标题栏
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(23:7)", "entry");
            // 顶部标题栏
            Row.width('100%');
            // 顶部标题栏
            Row.padding({
                top: 15 + this.getUIContext().px2vp(this.topRectHeight),
                left: 15,
                right: 15,
                bottom: 15
            });
            // 顶部标题栏
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("<");
            Text.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(24:9)", "entry");
            Text.fontSize(24);
            Text.width(40);
            Text.height(40);
            Text.textAlign(TextAlign.Center);
            Text.margin({ right: 5 });
            Text.onClick(() => router.back());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("我的收藏");
            Text.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(31:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // 顶部标题栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.favoriteList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("暂无收藏，快去首页逛逛吧");
                        Text.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(44:9)", "entry");
                        Text.fontColor(Color.Gray);
                        Text.margin({ top: 100 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create({ space: 10 });
                        List.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(46:9)", "entry");
                        List.width('95%');
                        List.layoutWeight(1);
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
                                    ListItem.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(48:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(49:15)", "entry");
                                        Row.padding(10);
                                        Row.backgroundColor(Color.White);
                                        Row.borderRadius(10);
                                        Row.onClick(() => {
                                            router.pushUrl({ url: 'pages/ProductDetailPage', params: item });
                                        });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Image.create(item.image_url);
                                        Image.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(50:17)", "entry");
                                        Image.width(80);
                                        Image.height(80);
                                        Image.borderRadius(8);
                                        Image.objectFit(ImageFit.Cover);
                                    }, Image);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(53:17)", "entry");
                                        Column.alignItems(HorizontalAlign.Start);
                                        Column.margin({ left: 15 });
                                        Column.layoutWeight(1);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(54:19)", "entry");
                                        Text.fontSize(16);
                                        Text.maxLines(1);
                                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`¥${item.price.toFixed(2)}`);
                                        Text.debugLine("entry/src/main/ets/pages/MyFavoritesPage.ets(55:19)", "entry");
                                        Text.fontColor(Color.Red);
                                        Text.fontSize(18);
                                        Text.margin({ top: 10 });
                                    }, Text);
                                    Text.pop();
                                    Column.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.favoriteList, forEachItemGenFunction);
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
    static getEntryName(): string {
        return "MyFavoritesPage";
    }
}
registerNamedRoute(() => new MyFavoritesPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/MyFavoritesPage", pageFullPath: "entry/src/main/ets/pages/MyFavoritesPage", integratedHsp: "false", moduleType: "followWithHap" });
