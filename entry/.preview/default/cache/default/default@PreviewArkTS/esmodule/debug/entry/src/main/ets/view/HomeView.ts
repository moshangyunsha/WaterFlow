if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface HomeView_Params {
    topRectHeight?: number;
    productList?: ProductItem[];
}
import { CommonConstants as Const } from "@bundle:com.huawei.waterflow/entry/ets/common/constants/CommonConstants";
import ClassifyComponent from "@bundle:com.huawei.waterflow/entry/ets/view/ClassifyComponent";
import SearchComponent from "@bundle:com.huawei.waterflow/entry/ets/view/SearchComponent";
import SwiperComponent from "@bundle:com.huawei.waterflow/entry/ets/view/SwiperComponent";
import WaterFlowComponent from "@bundle:com.huawei.waterflow/entry/ets/view/WaterFlowComponent";
import router from "@ohos:router";
import ProductService from "@bundle:com.huawei.waterflow/entry/ets/service/ProductService";
import type ProductItem from '../viewmodel/ProductItem';
export class HomeView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.__productList = new ObservedPropertyObjectPU([], this, "productList");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: HomeView_Params) {
        if (params.productList !== undefined) {
            this.productList = params.productList;
        }
    }
    updateStateVars(params: HomeView_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__productList.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__topRectHeight.aboutToBeDeleted();
        this.__productList.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    // 瀑布流的数据源
    private __productList: ObservedPropertyObjectPU<ProductItem[]>;
    get productList() {
        return this.__productList.get();
    }
    set productList(newValue: ProductItem[]) {
        this.__productList.set(newValue);
    }
    async handleCategoryChange(category: string): Promise<void> {
        // 调用 Service 层根据分类筛选数据
        this.productList = await ProductService.getProductsByCategory(category);
    }
    // 处理搜索逻辑
    async handleSearch(keyword: string): Promise<void> {
        if (!keyword || keyword.trim() === '')
            return;
        try {
            await router.pushUrl({
                url: 'pages/SearchResultPage',
                params: { keyword: keyword }
            });
        }
        catch (err) {
            console.error(`HomePage jump failed: ${JSON.stringify(err)}`);
        }
    }
    // [修改] onPageShow -> aboutToAppear
    async aboutToAppear(): Promise<void> {
        // 确保数据已初始化
        await ProductService.initData();
        // 默认加载所有商品
        this.productList = await ProductService.getAllProducts();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.Top });
            Stack.debugLine("entry/src/main/ets/view/HomeView.ets(45:5)", "entry");
            Stack.width('100%');
            Stack.height('100%');
            Stack.backgroundColor({ "id": 16777236, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 背景图
            Image.create({ "id": 16777295, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Image.debugLine("entry/src/main/ets/view/HomeView.ets(47:7)", "entry");
            // 背景图
            Image.width(Const.FULL_WIDTH);
            // 背景图
            Image.height({ "id": 16777252, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            // 背景图
            Image.objectFit(ImageFit.Cover);
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/HomeView.ets(52:7)", "entry");
            Column.padding({
                left: { "id": 16777250, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
                right: { "id": 16777251, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
                // 适配沉浸式状态栏的高度
                top: this.getUIContext().px2vp(this.topRectHeight)
            });
        }, Column);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 1. 搜索栏
                    SearchComponent(this, {
                        onSearch: (val: string) => this.handleSearch(val)
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/HomeView.ets", line: 54, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            onSearch: (val: string) => this.handleSearch(val)
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "SearchComponent" });
        }
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 2. 分类栏
                    ClassifyComponent(this, {
                        onCategoryChange: (cat: string) => this.handleCategoryChange(cat)
                    }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/HomeView.ets", line: 59, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            onCategoryChange: (cat: string) => this.handleCategoryChange(cat)
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "ClassifyComponent" });
        }
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 3. 轮播图
                    SwiperComponent(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/HomeView.ets", line: 64, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {};
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {});
                }
            }, { name: "SwiperComponent" });
        }
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            __Common__.create();
            __Common__.layoutWeight(1);
        }, __Common__);
        {
            this.observeComponentCreation2((elmtId, isInitialRender) => {
                if (isInitialRender) {
                    let componentCall = new 
                    // 4. 瀑布流列表
                    WaterFlowComponent(this, { productList: this.productList }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/HomeView.ets", line: 67, col: 9 });
                    ViewPU.create(componentCall);
                    let paramsLambda = () => {
                        return {
                            productList: this.productList
                        };
                    };
                    componentCall.paramsGenerator_ = paramsLambda;
                }
                else {
                    this.updateStateVarsOfChildByElmtId(elmtId, {
                        productList: this.productList
                    });
                }
            }, { name: "WaterFlowComponent" });
        }
        __Common__.pop();
        Column.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
