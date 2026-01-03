if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface MerchantUploadPage_Params {
    currentUser?: User;
    topRectHeight?: number;
    imageUri?: string;
    name?: string;
    price?: string;
    description?: string;
    selectedCategory?: string;
}
import router from "@ohos:router";
import promptAction from "@ohos:promptAction";
import picker from "@ohos:file.picker";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import { CATEGORY_LIST } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/HomeViewModel";
class MerchantUploadPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.__imageUri = new ObservedPropertySimplePU('', this, "imageUri");
        this.__name = new ObservedPropertySimplePU('', this, "name");
        this.__price = new ObservedPropertySimplePU('', this, "price");
        this.__description = new ObservedPropertySimplePU('', this, "description");
        this.__selectedCategory = new ObservedPropertySimplePU(CATEGORY_LIST.length > 1 ? CATEGORY_LIST[1] : '电子物品', this, "selectedCategory");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: MerchantUploadPage_Params) {
        if (params.imageUri !== undefined) {
            this.imageUri = params.imageUri;
        }
        if (params.name !== undefined) {
            this.name = params.name;
        }
        if (params.price !== undefined) {
            this.price = params.price;
        }
        if (params.description !== undefined) {
            this.description = params.description;
        }
        if (params.selectedCategory !== undefined) {
            this.selectedCategory = params.selectedCategory;
        }
    }
    updateStateVars(params: MerchantUploadPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__imageUri.purgeDependencyOnElmtId(rmElmtId);
        this.__name.purgeDependencyOnElmtId(rmElmtId);
        this.__price.purgeDependencyOnElmtId(rmElmtId);
        this.__description.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedCategory.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__currentUser.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        this.__imageUri.aboutToBeDeleted();
        this.__name.aboutToBeDeleted();
        this.__price.aboutToBeDeleted();
        this.__description.aboutToBeDeleted();
        this.__selectedCategory.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    // [修复] 1. 获取状态栏高度
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    private __imageUri: ObservedPropertySimplePU<string>;
    get imageUri() {
        return this.__imageUri.get();
    }
    set imageUri(newValue: string) {
        this.__imageUri.set(newValue);
    }
    private __name: ObservedPropertySimplePU<string>;
    get name() {
        return this.__name.get();
    }
    set name(newValue: string) {
        this.__name.set(newValue);
    }
    private __price: ObservedPropertySimplePU<string>;
    get price() {
        return this.__price.get();
    }
    set price(newValue: string) {
        this.__price.set(newValue);
    }
    private __description: ObservedPropertySimplePU<string>;
    get description() {
        return this.__description.get();
    }
    set description(newValue: string) {
        this.__description.set(newValue);
    }
    private __selectedCategory: ObservedPropertySimplePU<string>;
    get selectedCategory() {
        return this.__selectedCategory.get();
    }
    set selectedCategory(newValue: string) {
        this.__selectedCategory.set(newValue);
    }
    async selectImage() {
        try {
            const photoPicker = new picker.PhotoViewPicker();
            const result = await photoPicker.select({
                MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
                maxSelectNumber: 1
            });
            if (result.photoUris.length > 0) {
                this.imageUri = result.photoUris[0];
            }
        }
        catch (e) {
            console.error('Select image failed', e);
        }
    }
    async handlePublish() {
        if (!this.selectedCategory) {
            promptAction.showToast({ message: '请选择分类' });
            return;
        }
        if (!this.imageUri) {
            promptAction.showToast({ message: '请选择商品图片' });
            return;
        }
        if (!this.name) {
            promptAction.showToast({ message: '请输入商品名称' });
            return;
        }
        if (!this.price) {
            promptAction.showToast({ message: '请输入价格' });
            return;
        }
        const priceNum = parseFloat(this.price);
        if (isNaN(priceNum)) {
            promptAction.showToast({ message: '价格格式不正确' });
            return;
        }
        await RdbUtil.addProduct(this.currentUser.id, this.name, priceNum, this.imageUri, 300, 300 + Math.random() * 100, this.description, this.selectedCategory);
        promptAction.showToast({ message: '发布成功' });
        this.name = '';
        this.price = '';
        this.description = '';
        this.imageUri = '';
        setTimeout(() => { router.back(); }, 500);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(67:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // [修复] 2. 为标题栏添加 Padding
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(69:7)", "entry");
            // [修复] 2. 为标题栏添加 Padding
            Row.width('100%');
            // [修复] 2. 为标题栏添加 Padding
            Row.padding({
                top: 15 + this.getUIContext().px2vp(this.topRectHeight),
                left: 15,
                right: 15,
                bottom: 15
            });
            // [修复] 2. 为标题栏添加 Padding
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('<');
            Text.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(70:9)", "entry");
            Text.width(40);
            Text.height(40);
            Text.textAlign(TextAlign.Center);
            Text.onClick(() => router.back());
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('上架新商品');
            Text.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(74:9)", "entry");
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ left: 10 });
        }, Text);
        Text.pop();
        // [修复] 2. 为标题栏添加 Padding
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(85:7)", "entry");
            Scroll.layoutWeight(1);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 15 });
            Column.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(86:9)", "entry");
            Column.padding(15);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 1. 图片上传区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(88:11)", "entry");
            // 1. 图片上传区
            Column.width('100%');
            // 1. 图片上传区
            Column.alignItems(HorizontalAlign.Center);
            // 1. 图片上传区
            Column.margin({ top: 20 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.imageUri) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Image.create(this.imageUri);
                        Image.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(90:15)", "entry");
                        Image.width(150);
                        Image.height(150);
                        Image.objectFit(ImageFit.Cover);
                        Image.borderRadius(10);
                        Image.onClick(() => this.selectImage());
                    }, Image);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(94:15)", "entry");
                        Column.width(150);
                        Column.height(150);
                        Column.backgroundColor('#F5F5F5');
                        Column.borderRadius(10);
                        Column.justifyContent(FlexAlign.Center);
                        Column.onClick(() => this.selectImage());
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('+');
                        Text.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(95:17)", "entry");
                        Text.fontSize(40);
                        Text.fontColor('#999');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('上传图片');
                        Text.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(96:17)", "entry");
                        Text.fontSize(14);
                        Text.fontColor('#999');
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
        }, If);
        If.pop();
        // 1. 图片上传区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '商品名称', text: this.name });
            TextInput.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(105:11)", "entry");
            TextInput.height(50);
            TextInput.backgroundColor(Color.White);
            TextInput.borderRadius(8);
            TextInput.padding({ left: 15 });
            TextInput.onChange((val) => this.name = val);
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '价格 (¥)', text: this.price });
            TextInput.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(109:11)", "entry");
            TextInput.height(50);
            TextInput.type(InputType.Number);
            TextInput.backgroundColor(Color.White);
            TextInput.borderRadius(8);
            TextInput.padding({ left: 15 });
            TextInput.onChange((val) => this.price = val);
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(113:11)", "entry");
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("商品分类");
            Text.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(114:13)", "entry");
            Text.fontSize(14);
            Text.fontColor(Color.Gray);
            Text.margin({ bottom: 5 });
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Select.create(CATEGORY_LIST.filter(c => c !== '全部').map((c) => {
                return { value: c } as SelectOption;
            }));
            Select.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(115:13)", "entry");
            Select.selected(0);
            Select.value(this.selectedCategory);
            Select.font({ size: 16 });
            Select.fontColor(Color.Black);
            Select.selectedOptionFont({ size: 16 });
            Select.optionFont({ size: 16 });
            Select.height(50);
            Select.width('100%');
            Select.backgroundColor(Color.White);
            Select.borderRadius(8);
            Select.onSelect((index: number, value: string) => { this.selectedCategory = value; });
        }, Select);
        Select.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextArea.create({ placeholder: '请输入详细的商品介绍（选填）...', text: this.description });
            TextArea.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(128:11)", "entry");
            TextArea.height(120);
            TextArea.backgroundColor(Color.White);
            TextArea.borderRadius(8);
            TextArea.padding(15);
            TextArea.onChange((val) => this.description = val);
        }, TextArea);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('立即发布');
            Button.debugLine("entry/src/main/ets/pages/MerchantUploadPage.ets(132:11)", "entry");
            Button.width('90%');
            Button.height(50);
            Button.backgroundColor('#FF5000');
            Button.margin({ top: 30 });
            Button.onClick(() => this.handlePublish());
        }, Button);
        Button.pop();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "MerchantUploadPage";
    }
}
registerNamedRoute(() => new MerchantUploadPage(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/MerchantUploadPage", pageFullPath: "entry/src/main/ets/pages/MerchantUploadPage", integratedHsp: "false", moduleType: "followWithHap" });
