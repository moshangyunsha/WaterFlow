if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SearchResultPage_Params {
    keyword?: string;
    resultList?: ProductItem[];
    isLoading?: boolean;
    topRectHeight?: number;
}
import router from "@ohos:router";
import type ProductItem from '../viewmodel/ProductItem';
import ProductService from "@bundle:com.huawei.waterflow/entry/ets/service/ProductService";
import SearchComponent from "@bundle:com.huawei.waterflow/entry/ets/view/SearchComponent";
class SearchResultPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__keyword = new ObservedPropertySimplePU('', this, "keyword");
        this.__resultList = new ObservedPropertyObjectPU([], this, "resultList");
        this.__isLoading = new ObservedPropertySimplePU(false, this, "isLoading");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SearchResultPage_Params) {
        if (params.keyword !== undefined) {
            this.keyword = params.keyword;
        }
        if (params.resultList !== undefined) {
            this.resultList = params.resultList;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
    }
    updateStateVars(params: SearchResultPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__keyword.purgeDependencyOnElmtId(rmElmtId);
        this.__resultList.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__keyword.aboutToBeDeleted();
        this.__resultList.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __keyword: ObservedPropertySimplePU<string>;
    get keyword() {
        return this.__keyword.get();
    }
    set keyword(newValue: string) {
        this.__keyword.set(newValue);
    }
    private __resultList: ObservedPropertyObjectPU<ProductItem[]>;
    get resultList() {
        return this.__resultList.get();
    }
    set resultList(newValue: ProductItem[]) {
        this.__resultList.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    async aboutToAppear() {
        // 1. 获取首页传来的关键字 (增加空值安全检查)
        const params = router.getParams() as Record<string, string>;
        if (params && params['keyword']) {
            this.keyword = params['keyword'];
            await this.doSearch();
        }
    }
    async doSearch() {
        this.isLoading = true;
        // 调用 Service 搜索
        this.resultList = await ProductService.searchProducts(this.keyword);
        this.isLoading = false;
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(34:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 1. 顶部搜索区
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(36:7)", "entry");
            // 1. 顶部搜索区
            Row.width('100%');
            // 1. 顶部搜索区
            Row.padding({ top: this.getUIContext().px2vp(this.topRectHeight) });
            // 1. 顶部搜索区
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 返回按钮
            Text.create("<");
            Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(38:9)", "entry");
            // 返回按钮
            Text.fontSize(24);
            // 返回按钮
            Text.width(40);
            // 返回按钮
            Text.textAlign(TextAlign.Center);
            // 返回按钮
            Text.onClick(() => {
                try {
                    router.back();
                }
                catch (err) {
                    console.error(`Router back failed: ${JSON.stringify(err)}`);
                }
            });
        }, Text);
        // 返回按钮
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 搜索组件 (占比 1)
            // ✅ 修复：直接使用 Row 包裹 SearchComponent 来承载 layoutWeight
            // 这样避免了在自定义组件上直接使用属性可能导致的编译器困惑
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(53:9)", "entry");
            // 搜索组件 (占比 1)
            // ✅ 修复：直接使用 Row 包裹 SearchComponent 来承载 layoutWeight
            // 这样避免了在自定义组件上直接使用属性可能导致的编译器困惑
            Row.layoutWeight(1);
        }, Row);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new SearchComponent(this, {
                        onSearch: (val: string) => {
                            this.keyword = val;
                            this.doSearch();
                        }
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/SearchResultPage.ets", line: 54, col: 11 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            onSearch: (val: string) => {
                                this.keyword = val;
                                this.doSearch();
                            }
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "SearchComponent" });
        }
        // 搜索组件 (占比 1)
        // ✅ 修复：直接使用 Row 包裹 SearchComponent 来承载 layoutWeight
        // 这样避免了在自定义组件上直接使用属性可能导致的编译器困惑
        Row.pop();
        // 1. 顶部搜索区
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 2. 搜索结果列表
            if (this.isLoading) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(69:9)", "entry");
                        LoadingProgress.width(50);
                        LoadingProgress.height(50);
                        LoadingProgress.margin({ top: 100 });
                    }, LoadingProgress);
                });
            }
            else if (this.resultList.length === 0) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(71:9)", "entry");
                        Column.margin({ top: 100 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Image.create({ "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Image.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(72:11)", "entry");
                        Image.width(100);
                        Image.height(100);
                        Image.opacity(0.5);
                    }, Image);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`未找到与 "${this.keyword}" 相关的商品`);
                        Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(73:11)", "entry");
                        Text.fontColor(Color.Gray);
                        Text.margin({ top: 10 });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create({ space: 12 });
                        List.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(76:9)", "entry");
                        List.width('100%');
                        List.layoutWeight(1);
                        List.padding({ left: 12, right: 12, top: 10 });
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
                                    ListItem.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(78:13)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // --- 列表项布局：左图右文 ---
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(80:15)", "entry");
                                        // --- 列表项布局：左图右文 ---
                                        Row.width('100%');
                                        // --- 列表项布局：左图右文 ---
                                        Row.padding(10);
                                        // --- 列表项布局：左图右文 ---
                                        Row.backgroundColor(Color.White);
                                        // --- 列表项布局：左图右文 ---
                                        Row.borderRadius(12);
                                        // --- 列表项布局：左图右文 ---
                                        Row.onClick(() => {
                                            // 点击跳转详情 (捕获异常)
                                            try {
                                                router.pushUrl({ url: 'pages/ProductDetailPage', params: item });
                                            }
                                            catch (err) {
                                                console.error(`Router push failed: ${JSON.stringify(err)}`);
                                            }
                                        });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 左侧图片
                                        Image.create(item.image_url);
                                        Image.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(82:17)", "entry");
                                        // 左侧图片
                                        Image.width(100);
                                        // 左侧图片
                                        Image.height(100);
                                        // 左侧图片
                                        Image.objectFit(ImageFit.Cover);
                                        // 左侧图片
                                        Image.borderRadius(8);
                                        // 左侧图片
                                        Image.backgroundColor('#F5F5F5');
                                    }, Image);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 右侧信息
                                        Column.create();
                                        Column.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(90:17)", "entry");
                                        // 右侧信息
                                        Column.layoutWeight(1);
                                        // 右侧信息
                                        Column.height(100);
                                        // 右侧信息
                                        Column.padding({ left: 10, top: 2, bottom: 2 });
                                        // 右侧信息
                                        Column.alignItems(HorizontalAlign.Start);
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(91:19)", "entry");
                                        Text.fontSize(16);
                                        Text.fontWeight(FontWeight.Bold);
                                        Text.maxLines(2);
                                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 描述 (如果有)
                                        Text.create(item.description);
                                        Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(98:19)", "entry");
                                        // 描述 (如果有)
                                        Text.fontSize(12);
                                        // 描述 (如果有)
                                        Text.fontColor(Color.Gray);
                                        // 描述 (如果有)
                                        Text.maxLines(1);
                                        // 描述 (如果有)
                                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                                        // 描述 (如果有)
                                        Text.margin({ top: 4 });
                                    }, Text);
                                    // 描述 (如果有)
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                        Blank.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(105:19)", "entry");
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 价格区域
                                        Row.create();
                                        Row.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(108:19)", "entry");
                                        // 价格区域
                                        Row.width('100%');
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create('¥');
                                        Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(109:21)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor(Color.Red);
                                        Text.baselineOffset(-2);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.price.toFixed(2));
                                        Text.debugLine("entry/src/main/ets/pages/SearchResultPage.ets(110:21)", "entry");
                                        Text.fontSize(18);
                                        Text.fontColor(Color.Red);
                                        Text.fontWeight(FontWeight.Bold);
                                    }, Text);
                                    Text.pop();
                                    // 价格区域
                                    Row.pop();
                                    // 右侧信息
                                    Column.pop();
                                    // --- 列表项布局：左图右文 ---
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.resultList, forEachItemGenFunction);
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
        return "SearchResultPage";
    }
}
registerNamedRoute(() => new SearchResultPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/SearchResultPage", pageFullPath: "entry/src/main/ets/pages/SearchResultPage", integratedHsp: "false", moduleType: "followWithHap" });
