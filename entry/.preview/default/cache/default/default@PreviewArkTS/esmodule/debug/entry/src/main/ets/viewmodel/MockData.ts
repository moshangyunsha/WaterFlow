/**
 * 1. 定义原始数据接口
 * 必须显式定义接口，解决 "Object literal must correspond to some explicitly declared class or interface" 报错
 */
export interface RawProductData {
    imageKey: string;
    name: string;
    discount: string;
    price: string;
    promotion: string;
    bonus_points: string;
    description: string;
    category: string;
}
/**
 * 2. 导出模拟数据
 * 必须加上类型注解 : RawProductData[]，解决 "Array literals..." 报错
 */
export const MOCK_PRODUCTS: RawProductData[] = [
    {
        imageKey: 'ic_holder_50e',
        name: 'XXX50E 5G手机',
        discount: '',
        price: '¥4088',
        promotion: '',
        bonus_points: '',
        description: '【超长续航】XXX50E 搭载 6000mAh 大电池...',
        category: '电子物品'
    },
    {
        imageKey: 'ic_holder_xs2',
        name: 'XXXPadMate Xs 2 \n8GB+256GB （雅黑）',
        discount: '',
        price: '¥9999',
        promotion: '限时',
        bonus_points: '',
        description: '【折叠旗舰】超轻薄折叠设计...',
        category: '电子物品'
    },
    {
        imageKey: 'ic_holder_computer',
        name: 'XX高性能笔记本 16英寸',
        discount: '限时省200',
        price: '¥10099',
        promotion: '商品',
        bonus_points: '',
        description: '【生产力工具】搭载最新一代高性能处理器...',
        category: '电子物品'
    },
    {
        imageKey: 'ic_holder_mouse',
        name: '无线静音鼠标 二代',
        discount: '限时省20',
        price: '¥199',
        promotion: '',
        bonus_points: '',
        description: '【静音办公】人体工学设计...',
        category: '电子物品' // 鼠标算电子
    },
    // --- 演示数据：修改以下商品的分类以展示筛选功能 ---
    {
        imageKey: 'ic_holder_pad',
        name: 'XXXPad Pro 11英寸 (绘图版)',
        discount: '',
        price: '¥3499',
        promotion: '',
        bonus_points: '',
        description: '【创造力平板】120Hz 高刷全面屏...',
        category: '图书文娱' // 假装这是绘画工具
    },
    {
        imageKey: 'ic_holder_mate50',
        name: 'XXXMate 50 8GB+256GB',
        discount: '',
        price: '¥5499',
        promotion: '',
        bonus_points: '',
        description: '【影像新生】XMAGE 影像品牌...',
        category: '电子物品'
    },
    {
        imageKey: 'ic_holder_60pro',
        name: 'XXX60 Pro 遥遥领先',
        discount: '限时省200',
        price: '¥6999',
        promotion: '限时',
        bonus_points: '',
        description: '【再续传奇】玄武架构...',
        category: '电子物品'
    },
    {
        imageKey: 'ic_holder_50e',
        name: '智能运动手表 X1',
        discount: '',
        price: '¥4088',
        promotion: '',
        bonus_points: '',
        description: '专业运动监测，GPS定位。',
        category: '运动户外' // 演示运动分类
    },
    {
        imageKey: 'ic_holder_xs2',
        name: '时尚手包 (锦白)',
        discount: '限时省200',
        price: '¥9999',
        promotion: '限时',
        bonus_points: '',
        description: '白色版本更加优雅，特殊的立体皮纹工艺。',
        category: '衣物首饰' // 演示衣物
    },
    {
        imageKey: 'ic_holder_computer',
        name: '乐高积木 跑车系列',
        discount: '限时省200',
        price: '¥1099',
        promotion: '商品',
        bonus_points: '',
        description: '专为收藏家打造，还原真实机械结构。',
        category: '玩具乐器' // 演示玩具
    }
    // ... 其他可以保留原样
];
