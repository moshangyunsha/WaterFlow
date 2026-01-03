if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface FlowItemComponent_Params {
    item?: ProductItem;
    currentHoverId?: string;
    scaleVal?: number;
    isShowPopup?: boolean;
    currentImage?: ResourceStr;
    HOVER_SCALE?: number;
}
import type ProductItem from '../viewmodel/ProductItem';
import { CommonConstants as Const } from "@bundle:com.huawei.waterflow/entry/ets/common/constants/CommonConstants";
import Logger from "@bundle:com.huawei.waterflow/entry/ets/common/utils/Logger";
import router from "@ohos:router";
export default class FlowItemComponent extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__item = new SynchedPropertyObjectOneWayPU(params.item, this, "item");
        this.__currentHoverId = this.createStorageLink('hoveringItemId', '', "currentHoverId");
        this.__scaleVal = new ObservedPropertySimplePU(1, this, "scaleVal");
        this.__isShowPopup = new ObservedPropertySimplePU(false, this, "isShowPopup");
        this.__currentImage = new ObservedPropertyObjectPU({ "id": 16777293, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }, this, "currentImage");
        this.HOVER_SCALE = 1.02;
        this.setInitiallyProvidedValue(params);
        this.declareWatch("item", this.onItemChange);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FlowItemComponent_Params) {
        if (params.scaleVal !== undefined) {
            this.scaleVal = params.scaleVal;
        }
        if (params.isShowPopup !== undefined) {
            this.isShowPopup = params.isShowPopup;
        }
        if (params.currentImage !== undefined) {
            this.currentImage = params.currentImage;
        }
        if (params.HOVER_SCALE !== undefined) {
            this.HOVER_SCALE = params.HOVER_SCALE;
        }
    }
    updateStateVars(params: FlowItemComponent_Params) {
        this.__item.reset(params.item);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__item.purgeDependencyOnElmtId(rmElmtId);
        this.__currentHoverId.purgeDependencyOnElmtId(rmElmtId);
        this.__scaleVal.purgeDependencyOnElmtId(rmElmtId);
        this.__isShowPopup.purgeDependencyOnElmtId(rmElmtId);
        this.__currentImage.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__item.aboutToBeDeleted();
        this.__currentHoverId.aboutToBeDeleted();
        this.__scaleVal.aboutToBeDeleted();
        this.__isShowPopup.aboutToBeDeleted();
        this.__currentImage.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 监听 item 变化
    private __item: SynchedPropertySimpleOneWayPU<ProductItem>;
    get item() {
        return this.__item.get();
    }
    set item(newValue: ProductItem) {
        this.__item.set(newValue);
    }
    private __currentHoverId: ObservedPropertyAbstractPU<string>;
    get currentHoverId() {
        return this.__currentHoverId.get();
    }
    set currentHoverId(newValue: string) {
        this.__currentHoverId.set(newValue);
    }
    private __scaleVal: ObservedPropertySimplePU<number>;
    get scaleVal() {
        return this.__scaleVal.get();
    }
    set scaleVal(newValue: number) {
        this.__scaleVal.set(newValue);
    }
    private __isShowPopup: ObservedPropertySimplePU<boolean>;
    get isShowPopup() {
        return this.__isShowPopup.get();
    }
    set isShowPopup(newValue: boolean) {
        this.__isShowPopup.set(newValue);
    }
    private __currentImage: ObservedPropertyObjectPU<ResourceStr>;
    get currentImage() {
        return this.__currentImage.get();
    }
    set currentImage(newValue: ResourceStr) {
        this.__currentImage.set(newValue);
    }
    private readonly HOVER_SCALE: number;
    // 移除固定高度，改为动态计算
    // private readonly FIXED_IMAGE_HEIGHT: Length = $r('app.float.product_image_size');
    aboutToAppear() { this.updateImage(); }
    onItemChange() { this.updateImage(); }
    private updateImage() {
        // 增加空值校验
        this.currentImage = this.item?.image_url || { "id": 16777293, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
    }
    PopupBuilder(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 10 });
            Row.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(32:5)", "entry");
            Row.padding(10);
            Row.backgroundColor(Color.White);
            Row.borderRadius(8);
            Row.shadow({ radius: 10, color: '#00000030' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel({ "id": 16777300, "type": 10003, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Button.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(33:7)", "entry");
            Button.fontSize(12);
            Button.backgroundColor(Color.White);
            Button.fontColor('#333333');
            Button.height(32);
            Button.onClick(() => this.isShowPopup = false);
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel({ "id": 16777301, "type": 10003, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Button.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(34:7)", "entry");
            Button.fontSize(12);
            Button.backgroundColor({ "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Button.fontColor(Color.White);
            Button.height(32);
            Button.onClick(() => this.isShowPopup = false);
        }, Button);
        Button.pop();
        Row.pop();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(40:5)", "entry");
            Context.animation({ duration: 200 });
            Column.borderRadius({ "id": 16777264, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Column.backgroundColor(Color.White);
            Column.clip(true);
            Column.scale({ x: this.scaleVal, y: this.scaleVal });
            Column.shadow(this.isSelfHovering ? { radius: 10, color: { "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }, offsetY: 5 } : ShadowStyle.OUTER_DEFAULT_XS);
            Context.animation(null);
            Column.onHover((isHover) => {
                if (isHover) {
                    this.currentHoverId = this.item?.name;
                    Context.animateTo({ duration: 200 }, () => this.scaleVal = this.HOVER_SCALE);
                }
                else if (this.currentHoverId === this.item?.name) {
                    this.currentHoverId = '';
                    Context.animateTo({ duration: 200 }, () => this.scaleVal = 1.0);
                }
            });
            Column.onClick(() => {
                this.currentHoverId = '';
                Context.animateTo({ duration: 100 }, () => this.scaleVal = 0.95);
                setTimeout(() => {
                    Context.animateTo({ duration: 100 }, () => this.scaleVal = 1.0);
                    // 传递整个 item 对象给详情页
                    router.pushUrl({ url: 'pages/ProductDetailPage', params: this.item });
                }, 100);
            });
            Gesture.create(GesturePriority.Low);
            LongPressGesture.create({ repeat: false });
            LongPressGesture.onAction(() => this.isShowPopup = true);
            LongPressGesture.pop();
            Gesture.pop();
            Column.bindPopup(this.isShowPopup, {
                builder: { builder: this.PopupBuilder.bind(this) },
                placement: Placement.Top,
                mask: false,
                onStateChange: (e) => { if (!e.isVisible)
                    this.isShowPopup = false; }
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // --- 图片区域 ---
            Image.create(this.currentImage);
            Image.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(42:7)", "entry");
            // --- 图片区域 ---
            Image.width('100%');
            // --- 图片区域 ---
            Image.aspectRatio(this.item.width > 0 && this.item.height > 0 ? this.item.width / this.item.height : 1);
            // --- 图片区域 ---
            Image.objectFit(ImageFit.Cover);
            // --- 图片区域 ---
            Image.borderRadius({ topLeft: { "id": 16777264, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }, topRight: { "id": 16777264, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" } });
            // --- 图片区域 ---
            Image.onError(() => {
                Logger.error('FlowItem', `Image load failed for ${this.item.name}, fallback to default.`);
                this.currentImage = { "id": 16777295, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" };
            });
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // --- 内容区域 ---
            Column.create();
            Column.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(56:7)", "entry");
            // --- 内容区域 ---
            Column.padding(10);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题
            Text.create(this.item?.name);
            Text.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(58:9)", "entry");
            // 标题
            Text.fontSize({ "id": 16777280, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            // 标题
            Text.fontColor(Color.Black);
            // 标题
            Text.alignSelf(ItemAlign.Start);
            // 标题
            Text.maxLines(2);
            // 标题
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
        }, Text);
        // 标题
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 折扣信息 (可选)
            if (this.item?.discount) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.item?.discount);
                        Text.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(67:11)", "entry");
                        Text.fontSize({ "id": 16777281, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.opacity(Const.SIXTY_OPACITY);
                        Text.alignSelf(ItemAlign.Start);
                        Text.margin({ top: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            // 价格 (核心修改：处理 number 类型)
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 价格 (核心修改：处理 number 类型)
            Text.create(`¥${this.item?.price?.toFixed(2) || '0.00'}`);
            Text.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(75:9)", "entry");
            // 价格 (核心修改：处理 number 类型)
            Text.fontSize({ "id": 16777253, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            // 价格 (核心修改：处理 number 类型)
            Text.fontColor({ "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            // 价格 (核心修改：处理 number 类型)
            Text.alignSelf(ItemAlign.Start);
            // 价格 (核心修改：处理 number 类型)
            Text.lineHeight({ "id": 16777258, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            // 价格 (核心修改：处理 number 类型)
            Text.fontWeight(FontWeight.Bold);
            // 价格 (核心修改：处理 number 类型)
            Text.margin({ top: 4 });
        }, Text);
        // 价格 (核心修改：处理 number 类型)
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标签栏
            Row.create();
            Row.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(84:9)", "entry");
            // 标签栏
            Row.width(Const.FULL_WIDTH);
            // 标签栏
            Row.justifyContent(FlexAlign.Start);
            // 标签栏
            Row.margin({ top: 6 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.item?.promotion) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.item?.promotion}`);
                        Text.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(86:13)", "entry");
                        Text.fontSize({ "id": 16777265, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.fontColor(Color.White);
                        Text.borderRadius(2);
                        Text.backgroundColor({ "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.padding({ left: 4, right: 4 });
                        Text.margin({ right: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.item?.bonus_points) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(`${this.item?.bonus_points}`);
                        Text.debugLine("entry/src/main/ets/view/FlowItemComponent.ets(95:13)", "entry");
                        Text.fontSize({ "id": 16777265, "type": 10002, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.fontColor({ "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.borderRadius(2);
                        Text.borderWidth(1);
                        Text.borderColor({ "id": 16777235, "type": 10001, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
                        Text.padding({ left: 4, right: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // 标签栏
        Row.pop();
        // --- 内容区域 ---
        Column.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
