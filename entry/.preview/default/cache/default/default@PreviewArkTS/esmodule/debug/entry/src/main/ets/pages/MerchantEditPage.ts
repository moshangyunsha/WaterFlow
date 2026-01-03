if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MerchantEditPage_Params {
    productId?: number;
    title?: string;
    price?: string;
    imageUri?: string;
    topRectHeight?: number;
}
import router from "@ohos:router";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import type ProductItem from '../viewmodel/ProductItem';
import promptAction from "@ohos:promptAction";
import picker from "@ohos:file.picker";
class MerchantEditPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__productId = new ObservedPropertySimplePU(0, this, "productId");
        this.__title = new ObservedPropertySimplePU('', this, "title");
        this.__price = new ObservedPropertySimplePU('', this, "price");
        this.__imageUri = new ObservedPropertySimplePU('', this, "imageUri");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MerchantEditPage_Params) {
        if (params.productId !== undefined) {
            this.productId = params.productId;
        }
        if (params.title !== undefined) {
            this.title = params.title;
        }
        if (params.price !== undefined) {
            this.price = params.price;
        }
        if (params.imageUri !== undefined) {
            this.imageUri = params.imageUri;
        }
    }
    updateStateVars(params: MerchantEditPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__productId.purgeDependencyOnElmtId(rmElmtId);
        this.__title.purgeDependencyOnElmtId(rmElmtId);
        this.__price.purgeDependencyOnElmtId(rmElmtId);
        this.__imageUri.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__productId.aboutToBeDeleted();
        this.__title.aboutToBeDeleted();
        this.__price.aboutToBeDeleted();
        this.__imageUri.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __productId: ObservedPropertySimplePU<number>;
    get productId() {
        return this.__productId.get();
    }
    set productId(newValue: number) {
        this.__productId.set(newValue);
    }
    private __title: ObservedPropertySimplePU<string>;
    get title() {
        return this.__title.get();
    }
    set title(newValue: string) {
        this.__title.set(newValue);
    }
    private __price: ObservedPropertySimplePU<string>;
    get price() {
        return this.__price.get();
    }
    set price(newValue: string) {
        this.__price.set(newValue);
    }
    private __imageUri: ObservedPropertySimplePU<string>;
    get imageUri() {
        return this.__imageUri.get();
    }
    set imageUri(newValue: string) {
        this.__imageUri.set(newValue);
    }
    // [修复] 1. 获取状态栏高度
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    aboutToAppear() {
        const params = router.getParams() as ProductItem;
        if (params) {
            this.productId = params.id;
            this.title = params.name;
            this.price = params.price.toString();
            this.imageUri = params.image_url as string;
        }
    }
    async selectImage() {
        try {
            let photoPicker = new picker.PhotoViewPicker();
            let result = await photoPicker.select({
                MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
                maxSelectNumber: 1
            });
            if (result.photoUris.length > 0) {
                this.imageUri = result.photoUris[0];
            }
        }
        catch (e) {
            console.error("Select image failed", e);
        }
    }
    async submit() {
        if (!this.title || !this.price || !this.imageUri) {
            promptAction.showToast({ message: '请补全信息' });
            return;
        }
        let success = await RdbUtil.updateProduct(this.productId, this.title, parseFloat(this.price), this.imageUri);
        if (success) {
            promptAction.showToast({ message: '修改成功' });
            setTimeout(() => { router.back(); }, 500);
        }
        else {
            promptAction.showToast({ message: '修改失败' });
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(59:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(Color.White);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // [修复] 2. 为标题栏添加 Padding
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(61:7)", "entry");
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
            Text.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(62:9)", "entry");
            Text.fontSize(24);
            Text.width(40);
            Text.height(40);
            Text.textAlign(TextAlign.Center);
            Text.onClick(() => router.back());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("编辑商品");
            Text.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(67:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        // [修复] 2. 为标题栏添加 Padding
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 图片区域
            Image.create(this.imageUri || { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" });
            Image.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(79:7)", "entry");
            // 图片区域
            Image.width(200);
            // 图片区域
            Image.height(200);
            // 图片区域
            Image.objectFit(ImageFit.Contain);
            // 图片区域
            Image.margin({ top: 20, bottom: 10 });
            // 图片区域
            Image.onClick(() => this.selectImage());
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("点击图片更换");
            Text.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(84:7)", "entry");
            Text.fontSize(12);
            Text.fontColor(Color.Gray);
            Text.margin({ bottom: 20 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ text: this.title, placeholder: '标题' });
            TextInput.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(86:7)", "entry");
            TextInput.onChange(v => this.title = v);
            TextInput.margin(10);
            TextInput.width('90%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ text: this.price, placeholder: '价格' });
            TextInput.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(89:7)", "entry");
            TextInput.type(InputType.Number);
            TextInput.onChange(v => this.price = v);
            TextInput.margin(10);
            TextInput.width('90%');
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel("保存修改");
            Button.debugLine("entry/src/main/ets/pages/MerchantEditPage.ets(93:7)", "entry");
            Button.width('90%');
            Button.margin({ top: 20 });
            Button.onClick(() => this.submit());
        }, Button);
        Button.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MerchantEditPage";
    }
}
registerNamedRoute(() => new MerchantEditPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/MerchantEditPage", pageFullPath: "entry/src/main/ets/pages/MerchantEditPage", integratedHsp: "false", moduleType: "followWithHap" });
