if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ProductDetail_Params {
    product?: ProductItem;
    topRectHeight?: number;
    currentUser?: User;
    isAddedToCart?: boolean;
}
import router from "@ohos:router";
import ProductItem from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/ProductItem";
import promptAction from "@ohos:promptAction";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import { MOCK_PRODUCTS } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/MockData";
import type { RawProductData } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/MockData";
class ProductDetail extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__product = new ObservedPropertyObjectPU(new ProductItem({
            id: 0,
            merchantId: 0,
            image_url: { "id": 16777293, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
            name: '加载中...',
            price: 0,
            width: 0,
            height: 0
        }), this, "product");
        this.__topRectHeight = this.createStorageLink('topRectHeight', 0, "topRectHeight");
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.__isAddedToCart = new ObservedPropertySimplePU(false, this, "isAddedToCart");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ProductDetail_Params) {
        if (params.product !== undefined) {
            this.product = params.product;
        }
        if (params.isAddedToCart !== undefined) {
            this.isAddedToCart = params.isAddedToCart;
        }
    }
    updateStateVars(params: ProductDetail_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__product.purgeDependencyOnElmtId(rmElmtId);
        this.__topRectHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
        this.__isAddedToCart.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__product.aboutToBeDeleted();
        this.__topRectHeight.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
        this.__isAddedToCart.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __product: ObservedPropertyObjectPU<ProductItem>;
    get product() {
        return this.__product.get();
    }
    set product(newValue: ProductItem) {
        this.__product.set(newValue);
    }
    private __topRectHeight: ObservedPropertyAbstractPU<number>;
    get topRectHeight() {
        return this.__topRectHeight.get();
    }
    set topRectHeight(newValue: number) {
        this.__topRectHeight.set(newValue);
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    private __isAddedToCart: ObservedPropertySimplePU<boolean>;
    get isAddedToCart() {
        return this.__isAddedToCart.get();
    }
    set isAddedToCart(newValue: boolean) {
        this.__isAddedToCart.set(newValue);
    }
    async aboutToAppear() {
        const params = router.getParams();
        if (params) {
            let currentItem = params as ProductItem;
            if (!currentItem.description) {
                const mockData: RawProductData | undefined = MOCK_PRODUCTS.find((item: RawProductData) => item.name === currentItem.name);
                currentItem.description = mockData?.description || '暂无详细介绍';
            }
            this.product = new ProductItem(currentItem);
            if (this.currentUser.id) {
                this.isAddedToCart = await RdbUtil.hasCartItem(this.currentUser.id, this.product.id);
            }
        }
    }
    async handleAddToCart() {
        if (!this.currentUser || this.currentUser.id === 0) {
            promptAction.showToast({ message: '请先登录' });
            return;
        }
        if (this.isAddedToCart) {
            promptAction.showToast({ message: '该商品已在购物车中' });
            return;
        }
        let success = await RdbUtil.addToCart(this.currentUser.id, this.product.id);
        if (success) {
            promptAction.showToast({ message: '已加入购物车' });
            this.isAddedToCart = true;
        }
        else {
            promptAction.showToast({ message: '加入失败' });
        }
    }
    // --- 立即购买逻辑 ---
    async handleBuy() {
        if (!this.currentUser || this.currentUser.id === 0) {
            promptAction.showToast({ message: '请先登录' });
            return;
        }
        // 确定图片 Key
        let imgForDb: string;
        if (typeof this.product.image_url === 'string') {
            imgForDb = this.product.image_url;
        }
        else {
            imgForDb = 'ic_holder_computer';
        }
        // [修改] 传递 merchantId
        let code = await RdbUtil.createOrder(this.currentUser.id, this.product.name, this.product.price, imgForDb, this.product.merchantId // 传入商家ID
        );
        if (code === 1) {
            this.currentUser.balance -= this.product.price;
            promptAction.showToast({ message: '购买成功' });
        }
        else if (code === -1) {
            promptAction.showToast({ message: '余额不足，请充值' });
        }
        else {
            promptAction.showToast({ message: '系统错误' });
        }
    }
    async handleFav() {
        if (!this.currentUser || this.currentUser.id === 0) {
            promptAction.showToast({ message: '请先登录' });
            return;
        }
        await RdbUtil.addFavorite(this.currentUser.id, this.product.id);
        promptAction.showToast({ message: '已加入收藏' });
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.Bottom });
            Stack.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(106:5)", "entry");
            Stack.width('100%');
            Stack.height('100%');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(107:7)", "entry");
            Scroll.width('100%');
            Scroll.height('100%');
            Scroll.align(Alignment.Top);
            Scroll.backgroundColor('#F5F5F5');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(108:9)", "entry");
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.BottomEnd });
            Stack.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(109:11)", "entry");
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(this.product.image_url);
            Image.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(110:13)", "entry");
            Image.width('100%');
            Image.height(350);
            Image.objectFit(ImageFit.Contain);
            Image.backgroundColor(Color.White);
        }, Image);
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(117:11)", "entry");
            Column.padding(16);
            Column.backgroundColor(Color.White);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(118:13)", "entry");
            Row.width('100%');
            Row.alignItems(VerticalAlign.Bottom);
            Row.margin({ bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('¥');
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(119:15)", "entry");
            Text.fontSize(16);
            Text.fontColor('#FF5000');
            Text.baselineOffset(-4);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.product.price.toFixed(2));
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(120:15)", "entry");
            Text.fontSize(28);
            Text.fontColor('#FF5000');
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ right: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.product.discount) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.product.discount);
                        Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(127:17)", "entry");
                        Text.fontSize(12);
                        Text.fontColor('#FF5000');
                        Text.backgroundColor('#FFE4D0');
                        Text.padding({ left: 4, right: 4, top: 1, bottom: 1 });
                        Text.borderRadius(2);
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
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(136:13)", "entry");
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('价格 ¥' + (this.product.price * 1.2).toFixed(0));
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(137:15)", "entry");
            Text.fontSize(12);
            Text.fontColor('#999');
            Text.decoration({ type: TextDecorationType.LineThrough });
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(147:11)", "entry");
            Divider.strokeWidth(1);
            Divider.color('#F5F5F5');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(149:11)", "entry");
            Column.padding(16);
            Column.backgroundColor(Color.White);
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.product.name);
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(150:13)", "entry");
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.maxLines(2);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
            Text.lineHeight(24);
            Text.margin({ bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.product.description);
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(158:13)", "entry");
            Text.fontSize(14);
            Text.fontColor('#666');
            Text.margin({ top: 15 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(168:11)", "entry");
            Blank.height(80);
        }, Blank);
        Blank.pop();
        Column.pop();
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(177:7)", "entry");
            Row.width('100%');
            Row.padding({ top: 10, bottom: 10, left: 15, right: 15 });
            Row.backgroundColor(Color.White);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(178:9)", "entry");
            Column.justifyContent(FlexAlign.Center);
            Column.width(50);
            Column.onClick(() => this.handleFav());
            Column.backgroundColor(Color.White);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("★");
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(179:11)", "entry");
            Text.fontSize(20);
            Text.fontColor(Color.Orange);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create("收藏");
            Text.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(180:11)", "entry");
            Text.fontSize(10);
            Text.fontColor(Color.Gray);
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isAddedToCart ? "已在购物车" : "加入购物车");
            Button.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(187:9)", "entry");
            Button.type(ButtonType.Normal);
            Button.backgroundColor(this.isAddedToCart ? '#FFCC99' : '#FF9900');
            Button.fontColor(Color.White);
            Button.layoutWeight(1);
            Button.height(40);
            Button.borderRadius({ topLeft: 20, bottomLeft: 20 });
            Button.margin({ left: 10 });
            Button.enabled(!this.isAddedToCart);
            Button.onClick(() => this.handleAddToCart());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel("立即购买");
            Button.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(198:9)", "entry");
            Button.type(ButtonType.Normal);
            Button.backgroundColor('#FF5000');
            Button.fontColor(Color.White);
            Button.layoutWeight(1);
            Button.height(40);
            Button.borderRadius({ topRight: 20, bottomRight: 20 });
            Button.onClick(() => this.handleBuy());
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(211:7)", "entry");
            Row.position({ x: 16, y: 16 + this.getUIContext().px2vp(this.topRectHeight) });
            Row.zIndex(10);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('<');
            Button.debugLine("entry/src/main/ets/pages/ProductDetailPage.ets(212:9)", "entry");
            Button.type(ButtonType.Circle);
            Button.backgroundColor('#80000000');
            Button.fontColor(Color.White);
            Button.fontSize(18);
            Button.width(32);
            Button.height(32);
            Button.onClick(() => { router.back(); });
        }, Button);
        Button.pop();
        Row.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "ProductDetail";
    }
}
registerNamedRoute(() => new ProductDetail(undefined, {}), "", { bundleName: "com.huawei.waterflow", moduleName: "entry", pagePath: "pages/ProductDetailPage", pageFullPath: "entry/src/main/ets/pages/ProductDetailPage", integratedHsp: "false", moduleType: "followWithHap" });
