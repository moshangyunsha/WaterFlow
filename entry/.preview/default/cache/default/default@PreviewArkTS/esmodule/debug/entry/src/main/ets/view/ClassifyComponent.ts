if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ClassifyComponent_Params {
    titleIndex?: number;
    // ✅ 新增回调：当分类切换时，把分类名称(string)传出去
    onCategoryChange?: (category: string) => void;
}
import { classifyTitle } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/HomeViewModel";
import { CommonConstants as Const } from "@bundle:com.huawei.waterflow/entry/ets/common/constants/CommonConstants";
export default class ClassifyComponent extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__titleIndex = new ObservedPropertySimplePU(0, this, "titleIndex");
        this.onCategoryChange = () => { };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ClassifyComponent_Params) {
        if (params.titleIndex !== undefined) {
            this.titleIndex = params.titleIndex;
        }
        if (params.onCategoryChange !== undefined) {
            this.onCategoryChange = params.onCategoryChange;
        }
    }
    updateStateVars(params: ClassifyComponent_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__titleIndex.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__titleIndex.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __titleIndex: ObservedPropertySimplePU<number>;
    get titleIndex() {
        return this.__titleIndex.get();
    }
    set titleIndex(newValue: number) {
        this.__titleIndex.set(newValue);
    }
    // ✅ 新增回调：当分类切换时，把分类名称(string)传出去
    private onCategoryChange: (category: string) => void;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/view/ClassifyComponent.ets(22:5)", "entry");
            // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
            Scroll.scrollable(ScrollDirection.Horizontal);
            // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
            Scroll.scrollBar(BarState.Off);
            // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
            Scroll.width(Const.FULL_WIDTH);
            // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
            Scroll.margin({ top: { "id": 16777246, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" } });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 20 });
            Row.debugLine("entry/src/main/ets/view/ClassifyComponent.ets(23:7)", "entry");
            Row.padding({ left: 15, right: 15 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 注意：classifyTitle 现在是 string[]，所以 item 类型也是 string
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(item);
                    Text.debugLine("entry/src/main/ets/view/ClassifyComponent.ets(26:11)", "entry");
                    Text.fontSize({ "id": 16777253, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                    Text.opacity(this.titleIndex === index ? Const.FULL_OPACITY : Const.EIGHTY_OPACITY);
                    Text.fontWeight(this.titleIndex === index ? Const.FONT_WEIGHT_FIVE : FontWeight.Normal);
                    Text.fontColor(Color.White);
                    Text.onClick(() => {
                        if (this.titleIndex !== index) {
                            this.titleIndex = index;
                            // ✅ 核心逻辑：触发回调，通知首页刷新数据
                            this.onCategoryChange(item);
                        }
                    });
                }, Text);
                Text.pop();
            };
            this.forEachUpdateFunction(elmtId, classifyTitle, forEachItemGenFunction, (item: string) => item, true, false);
        }, ForEach);
        // 注意：classifyTitle 现在是 string[]，所以 item 类型也是 string
        ForEach.pop();
        Row.pop();
        // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
        Scroll.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
