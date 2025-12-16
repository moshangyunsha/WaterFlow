if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface WaterFlowComponent_Params {
    bottomRectHeight?: number;
    productList?: ProductItem[];
    dataSource?: WaterFlowDataSource;
}
import type ProductItem from '../viewmodel/ProductItem';
import FlowItemComponent from "@bundle:com.huawei.waterflow/entry/ets/view/FlowItemComponent";
import { WaterFlowDataSource } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/WaterFlowDataSource";
import { CommonConstants as Const } from "@bundle:com.huawei.waterflow/entry/ets/common/constants/CommonConstants";
export default class WaterFlowComponent extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__bottomRectHeight = this.createStorageLink('bottomRectHeight', 0, "bottomRectHeight");
        this.__productList = new SynchedPropertyObjectOneWayPU(params.productList, this, "productList");
        this.dataSource = new WaterFlowDataSource();
        this.setInitiallyProvidedValue(params);
        this.declareWatch("productList", this.onListChange);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: WaterFlowComponent_Params) {
        if (params.dataSource !== undefined) {
            this.dataSource = params.dataSource;
        }
    }
    updateStateVars(params: WaterFlowComponent_Params) {
        this.__productList.reset(params.productList);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__bottomRectHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__productList.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__bottomRectHeight.aboutToBeDeleted();
        this.__productList.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __bottomRectHeight: ObservedPropertyAbstractPU<number>;
    get bottomRectHeight() {
        return this.__bottomRectHeight.get();
    }
    set bottomRectHeight(newValue: number) {
        this.__bottomRectHeight.set(newValue);
    }
    private __productList: SynchedPropertySimpleOneWayPU<ProductItem[]>;
    get productList() {
        return this.__productList.get();
    }
    set productList(newValue: ProductItem[]) {
        this.__productList.set(newValue);
    }
    private dataSource: WaterFlowDataSource;
    onListChange() {
        this.dataSource.setDataArray(this.productList);
        this.dataSource.notifyDataReload();
    }
    aboutToAppear() {
        this.dataSource.setDataArray(this.productList);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.productList.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create("暂无数据");
                        Text.fontColor(Color.Gray);
                        Text.margin({ top: 50 });
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        WaterFlow.create({ footer: (): void => this.itemFoot() });
                        WaterFlow.layoutWeight(Const.WATER_FLOW_LAYOUT_WEIGHT);
                        WaterFlow.columnsTemplate(Const.WATER_FLOW_COLUMNS_TEMPLATE);
                        WaterFlow.columnsGap({ "id": 16777285, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        WaterFlow.rowsGap({ "id": 16777288, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        WaterFlow.padding({ left: 10, right: 10, bottom: 80 });
                    }, WaterFlow);
                    {
                        const __lazyForEachItemGenFunction = _item => {
                            const item = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                FlowItem.create();
                            }, FlowItem);
                            {
                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                    if (isInitialRender) {
                                        let componentCall = new FlowItemComponent(this, { item: item }, undefined, elmtId, () => { }, { page: "entry/src/main/ets/view/WaterFlowComponent.ets", line: 32, col: 15 });
                                        ViewPU.create(componentCall);
                                        let paramsLambda = () => {
                                            return {
                                                item: item
                                            };
                                        };
                                        componentCall.paramsGenerator_ = paramsLambda;
                                    }
                                    else {
                                        this.updateStateVarsOfChildByElmtId(elmtId, {
                                            item: item
                                        });
                                    }
                                }, { name: "FlowItemComponent" });
                            }
                            FlowItem.pop();
                        };
                        const __lazyForEachItemIdFunc = (item: ProductItem) => item.id.toString();
                        LazyForEach.create("1", this, this.dataSource, __lazyForEachItemGenFunction, __lazyForEachItemIdFunc);
                        LazyForEach.pop();
                    }
                    WaterFlow.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    itemFoot(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
            Column.create();
            // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
            Column.width('100%');
            // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
            Column.justifyContent(FlexAlign.Center);
            // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
            Column.alignItems(HorizontalAlign.Center);
            // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
            Column.padding({ bottom: this.getUIContext().px2vp(this.bottomRectHeight) });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("—— 到底了 ——");
            Text.fontColor('#999999');
            Text.fontSize(12);
            Text.textAlign(TextAlign.Center);
            Text.margin({ top: 10, bottom: 10 });
        }, Text);
        Text.pop();
        // 优化 2 & 3: 使用 Flex 布局确保绝对居中，并根据系统导航栏适配高度
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
