import type ProductItem from './ProductItem';
/**
 * Water flow data source implementation.
 * 瀑布流数据源，实现了 IDataSource 接口，用于 LazyForEach 高性能加载
 */
export class WaterFlowDataSource implements IDataSource {
    // 数据容器
    private dataArray: ProductItem[] = [];
    // 监听器容器
    private listeners: DataChangeListener[] = [];
    /**
     * 构造函数 (兼容两种用法)
     * @param data 可选的初始数据
     */
    constructor(data: ProductItem[] = []) {
        this.dataArray = data;
    }
    /**
     * Set water flow data array and refresh.
     * 设置新的数据集 (用于全量刷新，如数据库加载完成)
     * @param {ProductItem[]} productDataArray Displaying water flow Data.
     */
    public setDataArray(productDataArray: ProductItem[]): void {
        this.dataArray = productDataArray;
        // 可以在这里直接调用 notifyDataReload，也可以由外部调用
        // 目前 WaterFlowComponent 外部调用了，这里只负责赋值
    }
    /**
     * Get the total number of data records.
     * 获取数据总数
     */
    public totalCount(): number {
        return this.dataArray.length;
    }
    /**
     * Get the data corresponding to the index.
     * 获取指定索引的数据
     * @param {number} index Data index.
     * @returns Return ProductItem.
     */
    public getData(index: number): ProductItem {
        return this.dataArray[index];
    }
    /**
     * Add data to specific index.
     * 在指定位置添加数据 (来自代码1，用于扩展)
     */
    public addData(index: number, data: ProductItem): void {
        this.dataArray.splice(index, 0, data);
        this.notifyDataAdd(index);
    }
    /**
     * Push data to the end.
     * 在末尾追加数据 (来自代码1，用于上拉加载更多)
     */
    public pushData(data: ProductItem): void {
        this.dataArray.push(data);
        this.notifyDataAdd(this.dataArray.length - 1);
    }
    /**
     * Register a controller that changes data.
     * 注册监听器
     * @param {DataChangeListener} listener Data change listener
     */
    registerDataChangeListener(listener: DataChangeListener): void {
        if (this.listeners.indexOf(listener) < 0) {
            this.listeners.push(listener);
        }
    }
    /**
     * Unregister a controller that changes data.
     * 注销监听器
     * @param {DataChangeListener} listener Data change listener
     */
    unregisterDataChangeListener(listener: DataChangeListener): void {
        const pos = this.listeners.indexOf(listener);
        if (pos >= 0) {
            this.listeners.splice(pos, 1);
        }
    }
    // --- Notification Methods (通知 LazyForEach 刷新的关键) ---
    /**
     * Notify that all data has been reloaded.
     * 通知全量刷新
     */
    notifyDataReload(): void {
        this.listeners.forEach(listener => {
            listener.onDataReloaded();
        });
    }
    /**
     * Notify that data has been added.
     * 通知数据添加
     */
    notifyDataAdd(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDataAdd(index);
        });
    }
    /**
     * Notify that data has been changed.
     * 通知数据变更
     */
    notifyDataChange(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDataChange(index);
        });
    }
    /**
     * Notify that data has been deleted.
     * 通知数据删除
     */
    notifyDataDelete(index: number): void {
        this.listeners.forEach(listener => {
            listener.onDataDelete(index);
        });
    }
    /**
     * Notify that data has been moved.
     * 通知数据移动
     */
    notifyDataMove(from: number, to: number): void {
        this.listeners.forEach(listener => {
            listener.onDataMove(from, to);
        });
    }
}
