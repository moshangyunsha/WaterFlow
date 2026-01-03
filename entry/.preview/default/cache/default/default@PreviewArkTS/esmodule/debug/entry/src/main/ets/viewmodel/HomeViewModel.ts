import type { IProductItem } from './ProductItem';
// 定义分类常量，供 UploadPage 和 HomePage 使用
export const CATEGORY_LIST: string[] = [
    '全部',
    '电子物品',
    '衣物首饰',
    '美妆护肤',
    '图书文娱',
    '玩具乐器',
    '运动户外'
];
/**
 * 首页分类标题
 */
const classifyTitle: string[] = CATEGORY_LIST;
/**
 * 首页轮播图
 */
const swiperImage: Resource[] = [
    { "id": 16777306, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    { "id": 16777219, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
    { "id": 16777218, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" }
];
/**
 * 首页瀑布流数据 (带详细介绍 + 类型修复)
 */
// ✅ 关键：指定类型 IProductItem[]，解决 ArkTS 报错
const waterFlowData: IProductItem[] = [
    {
        id: 1, merchantId: 1, width: 300, height: 400,
        image_url: { "id": 16777305, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXX50E 5G手机',
        discount: '',
        price: 4088,
        promotion: '',
        bonus_points: '',
        // ✅ 找回了详细介绍
        description: '【超长续航】XXX50E 搭载 6000mAh 大电池，告别电量焦虑。配备 5000 万像素超清影像系统，记录生活美好瞬间。轻薄机身设计，手感舒适。',
        detailImages: []
    },
    {
        id: 2, merchantId: 1, width: 300, height: 350,
        image_url: { "id": 16777302, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXPadMate Xs 2 \n8GB+256GB （雅黑）',
        discount: '',
        price: 9999,
        promotion: '限时',
        bonus_points: '',
        description: '【折叠旗舰】超轻薄折叠设计，展开即是沉浸大屏。独创双旋鹰翼铰链，屏幕平整如镜。支持北斗卫星消息，无地面网络也能发送信息。',
        detailImages: []
    },
    {
        id: 3, merchantId: 2, width: 300, height: 420,
        image_url: { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XX高性能笔记本 16英寸',
        discount: '限时省200',
        price: 10099,
        promotion: '商品',
        bonus_points: '',
        description: '【生产力工具】搭载最新一代高性能处理器，32GB大内存，轻松运行大型软件。2.5K高分辨率屏幕，色彩还原准确，设计师的不二之选。',
        detailImages: []
    },
    {
        id: 4, merchantId: 2, width: 300, height: 300,
        image_url: { "id": 16777292, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: '无线静音鼠标 二代',
        discount: '限时省20',
        price: 199,
        promotion: '',
        bonus_points: '',
        description: '【静音办公】人体工学设计，贴合手掌曲线，久用不累。按键静音处理，图书馆、办公室使用不打扰他人。支持蓝牙/2.4G双模连接。',
        detailImages: []
    },
    {
        id: 5, merchantId: 1, width: 300, height: 380,
        image_url: { "id": 16777304, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXPad Pro 11英寸',
        discount: '',
        price: 3499,
        promotion: '',
        bonus_points: '',
        description: '【创造力平板】120Hz 高刷全面屏，搭配手写笔，书写体验如纸般流畅。内置专业笔记软件，学习办公效率倍增。',
        detailImages: []
    },
    {
        id: 6, merchantId: 1, width: 300, height: 400,
        image_url: { "id": 16777303, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXMate 50 8GB+256GB',
        discount: '',
        price: 5499,
        promotion: '',
        bonus_points: '',
        description: '【影像新生】XMAGE 影像品牌首发之作，物理光圈十档可调，夜景拍摄更清晰。昆仑玻璃面板，耐摔能力提升10倍。',
        detailImages: []
    },
    {
        id: 7, merchantId: 1, width: 300, height: 450,
        image_url: { "id": 16777221, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXX60 Pro 遥遥领先',
        discount: '限时省200',
        price: 6999,
        promotion: '限时',
        bonus_points: '',
        description: '【再续传奇】玄武架构，超可靠机身。卫星通话功能，时刻保持连接。鸿蒙操作系统4.0，流畅体验再升级。',
        detailImages: []
    },
    // --- 重复数据用于演示滚动效果 ---
    {
        id: 8, merchantId: 1, width: 300, height: 400,
        image_url: { "id": 16777305, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXX50E (备用机推荐)',
        discount: '',
        price: 4088,
        promotion: '',
        bonus_points: '',
        description: '作为主力机的完美搭档，超长待机是它的杀手锏。老人、学生使用也非常合适，界面简洁大字体。',
        detailImages: []
    },
    {
        id: 9, merchantId: 1, width: 300, height: 350,
        image_url: { "id": 16777302, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXPadMate Xs 2 (锦白)',
        discount: '限时省200',
        price: 9999,
        promotion: '限时',
        bonus_points: '',
        description: '白色版本更加优雅，特殊的立体皮纹工艺，手感温润。折叠无痕，体验无缝。',
        detailImages: []
    },
    {
        id: 10, merchantId: 2, width: 300, height: 420,
        image_url: { "id": 16777298, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XX游戏本 满血版',
        discount: '限时省200',
        price: 10099,
        promotion: '商品',
        bonus_points: '',
        description: '专为电竞玩家打造，独立显卡直连，帧率稳定。RGB背光键盘，氛围感拉满。',
        detailImages: []
    },
    {
        id: 11, merchantId: 2, width: 300, height: 300,
        image_url: { "id": 16777292, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: '送给亲人 快速购买！',
        discount: '限时省50',
        price: 199,
        promotion: '限时',
        bonus_points: '赠送积分',
        description: '礼盒包装版本，送人更有面子。包含备用电池和鼠标垫。',
        detailImages: []
    },
    {
        id: 12, merchantId: 1, width: 300, height: 380,
        image_url: { "id": 16777304, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXPad Pro 教育优惠版',
        discount: '限时省200',
        price: 3499,
        promotion: '',
        bonus_points: '赠送积分',
        description: '凭学生证可享受教育优惠。不论是上网课还是画画，它都是你的好帮手。',
        detailImages: []
    },
    {
        id: 13, merchantId: 1, width: 300, height: 400,
        image_url: { "id": 16777303, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXXMate 50 昆仑霞光',
        discount: '',
        price: 5499,
        promotion: '',
        bonus_points: '',
        description: '素皮材质，橙色外观充满活力。IP68级防尘抗水，无惧风雨。',
        detailImages: []
    },
    {
        id: 14, merchantId: 1, width: 300, height: 450,
        image_url: { "id": 16777221, "type": 20000, params: [], "bundleName": "com.huawei.waterflow", "moduleName": "entry" },
        name: 'XXX60 Pro (白色)',
        discount: '限时省200',
        price: 6999,
        promotion: '限时',
        bonus_points: '',
        description: '洛可可白，每一块背板的纹理都独一无二。',
        detailImages: []
    }
];
export { classifyTitle, swiperImage, waterFlowData };
