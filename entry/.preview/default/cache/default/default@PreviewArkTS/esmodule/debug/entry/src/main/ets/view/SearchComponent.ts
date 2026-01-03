if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SearchComponent_Params {
    // 定义一个回调函数，当用户提交搜索时调用
    // 这里的 onSearch 是父组件传进来的方法
    onSearch?: (value: string) => void;
}
import { CommonConstants as Const } from "@bundle:com.huawei.waterflow/entry/ets/common/constants/CommonConstants";
export default class SearchComponent extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.onSearch = (value: string): void => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SearchComponent_Params) {
        if (params.onSearch !== undefined) {
            this.onSearch = params.onSearch;
        }
    }
    updateStateVars(params: SearchComponent_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 定义一个回调函数，当用户提交搜索时调用
    // 这里的 onSearch 是父组件传进来的方法
    private onSearch: (value: string) => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/view/SearchComponent.ets(30:5)", "entry");
            Row.width(Const.FULL_WIDTH);
            Row.margin({ top: { "id": 16777276, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" } });
            Row.padding({ left: { "id": 16777274, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }, right: { "id": 16777275, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" } });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Search.create({ placeholder: '搜索商品...' });
            Search.debugLine("entry/src/main/ets/view/SearchComponent.ets(31:7)", "entry");
            Search.searchButton('搜索');
            Search.width(Const.FULL_WIDTH);
            Search.height({ "id": 16777278, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Search.backgroundColor(Color.White);
            Search.placeholderColor(Color.Gray);
            Search.placeholderFont({ size: { "id": 16777280, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" } });
            Search.onSubmit((value: string) => {
                // 触发回调
                this.onSearch(value);
            });
            Search.onChange((value: string) => {
                // 可选：如果想做实时搜索，也可以在这里调用
                if (value === '') {
                    this.onSearch(''); // 清空时恢复
                }
            });
        }, Search);
        Search.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
