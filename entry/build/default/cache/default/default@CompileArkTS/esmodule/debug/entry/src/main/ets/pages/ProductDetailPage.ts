if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ProductDetail_Params {
    product?: ProductItem;
    currentUser?: User;
}
import router from "@ohos:router";
import ProductItem from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/ProductItem";
import promptAction from "@ohos:promptAction";
import { User } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/User";
import RdbUtil from "@bundle:com.huawei.waterflow/entry/ets/common/utils/RdbUtil";
import { MOCK_PRODUCTS } from "@bundle:com.huawei.waterflow/entry/ets/viewmodel/MockData";
class ProductDetail extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__product = new ObservedPropertyObjectPU(new ProductItem({
            id: 0,
            merchantId: 0,
            image_url: { "id": 16777305, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
            name: '加载中...',
            price: 0,
            width: 0,
            height: 0
        }), this, "product");
        this.__currentUser = this.createStorageLink('currentUser', new User(0, '', 0, 0, ""), "currentUser");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ProductDetail_Params) {
        if (params.product !== undefined) {
            this.product = params.product;
        }
    }
    updateStateVars(params: ProductDetail_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__product.purgeDependencyOnElmtId(rmElmtId);
        this.__currentUser.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__product.aboutToBeDeleted();
        this.__currentUser.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // ✅ 修复：构造函数现在只需要传一个对象，完美匹配
    private __product: ObservedPropertyObjectPU<ProductItem>;
    get product() {
        return this.__product.get();
    }
    set product(newValue: ProductItem) {
        this.__product.set(newValue);
    }
    private __currentUser: ObservedPropertyAbstractPU<User>;
    get currentUser() {
        return this.__currentUser.get();
    }
    set currentUser(newValue: User) {
        this.__currentUser.set(newValue);
    }
    aboutToAppear() {
        const params = router.getParams();
        if (params) {
            // 1. 获取传递过来的商品对象
            let currentItem = params as ProductItem;
            // 2. 【核心修复】如果不包含 description (或者为空)，尝试从 MockData 补全
            // 这是为了解决旧数据库数据缺失的问题
            if (!currentItem.description) {
                // 根据名字在 MOCK_PRODUCTS 里找对应的原始数据
                const mockData = MOCK_PRODUCTS.find(item => item.name === currentItem.name);
                if (mockData && mockData.description) {
                    console.info('ProductDetail: 补全缺失的描述信息');
                    currentItem.description = mockData.description;
                }
                else {
                    currentItem.description = '暂无详细介绍';
                }
            }
            // 3. 赋值给状态变量，触发 UI 刷新
            this.product = new ProductItem(currentItem);
        }
    }
    async handleBuy() {
        if (!this.currentUser || this.currentUser.id === 0) {
            promptAction.showToast({ message: '请先登录' });
            return;
        }
        let imgForDb: string = "";
        if (typeof this.product.image_url === 'string') {
            imgForDb = this.product.image_url;
        }
        else {
            const mockItem = MOCK_PRODUCTS.find(item => item.name === this.product.name);
            if (mockItem) {
                // MockData 里的 imageKey 是 Resource，这里为了存数据库
                // 我们需要约定好 MockData 的图片存入策略。
                // 简化处理：如果是 Mock 商品，给一个固定标识，ProductService 会处理
                imgForDb = 'ic_holder_computer'; // 兜底
            }
            else {
                imgForDb = 'ic_holder_computer';
            }
        }
        let code = await RdbUtil.createOrder(this.currentUser.id, this.product.name, this.product.price, imgForDb);
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
            Stack.width('100%');
            Stack.height('100%');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.width('100%');
            Scroll.height('100%');
            Scroll.align(Alignment.Top);
            Scroll.backgroundColor('#F5F5F5');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.BottomEnd });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create(this.product.image_url);
            Image.width('100%');
            Image.height(350);
            Image.objectFit(ImageFit.Contain);
            Image.backgroundColor(Color.White);
        }, Image);
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.padding(16);
            Column.backgroundColor(Color.White);
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.alignItems(VerticalAlign.Bottom);
            Row.margin({ bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('¥');
            Text.fontSize(16);
            Text.fontColor('#FF5000');
            Text.baselineOffset(-4);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
            Text.create(this.product.price.toFixed(2));
            // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
            Text.fontSize(28);
            // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
            Text.fontColor('#FF5000');
            // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
            Text.fontWeight(FontWeight.Bold);
            // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
            Text.margin({ right: 8 });
        }, Text);
        // ✅ 修复：price 已经是 number，直接 toFixed，无需 replace/parseFloat
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.product.discount) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.product.discount);
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
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('已售 100+');
            Text.fontSize(12);
            Text.fontColor('#999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 原价展示
            Row.create();
            // 原价展示
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ✅ 修复：直接计算
            Text.create('价格 ¥' + (this.product.price * 1.2).toFixed(0));
            // ✅ 修复：直接计算
            Text.fontSize(12);
            // ✅ 修复：直接计算
            Text.fontColor('#999');
            // ✅ 修复：直接计算
            Text.decoration({ type: TextDecorationType.LineThrough });
        }, Text);
        // ✅ 修复：直接计算
        Text.pop();
        // 原价展示
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.strokeWidth(1);
            Divider.color('#F5F5F5');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.padding(16);
            Column.backgroundColor(Color.White);
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.product.name);
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.maxLines(2);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
            Text.lineHeight(24);
            Text.margin({ bottom: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.product.promotion) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.product.promotion);
                        Text.fontSize(10);
                        Text.fontColor('#FF0036');
                        Text.border({ width: 1, color: '#FF0036' });
                        Text.padding(2);
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
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('包邮');
            Text.fontSize(10);
            Text.fontColor('#999');
            Text.backgroundColor('#F0F0F0');
            Text.padding(2);
            Text.borderRadius(2);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 详情描述
            Text.create(this.product.description);
            // 详情描述
            Text.fontSize(14);
            // 详情描述
            Text.fontColor('#666');
            // 详情描述
            Text.margin({ top: 15 });
        }, Text);
        // 详情描述
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.height(80);
        }, Blank);
        Blank.pop();
        Column.pop();
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ top: 10, bottom: 10, left: 15, right: 15 });
            Row.backgroundColor(Color.White);
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel("收藏");
            Button.type(ButtonType.Normal);
            Button.backgroundColor('#FF9900');
            Button.fontColor(Color.White);
            Button.width('40%');
            Button.height(40);
            Button.borderRadius({ topLeft: 20, bottomLeft: 20 });
            Button.onClick(() => { this.handleFav(); });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel("立即购买");
            Button.type(ButtonType.Normal);
            Button.backgroundColor('#FF5000');
            Button.fontColor(Color.White);
            Button.width('40%');
            Button.height(40);
            Button.borderRadius({ topRight: 20, bottomRight: 20 });
            Button.onClick(() => this.handleBuy());
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.position({ x: 16, y: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('<');
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
