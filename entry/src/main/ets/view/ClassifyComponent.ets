/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

import { classifyTitle } from '../viewmodel/HomeViewModel';
import { CommonConstants as Const } from '../common/constants/CommonConstants';

/**
 * Classify component.
 * Usage: Directly reference ClassifyComponent().
 */
@Component
export default struct ClassifyComponent {
  @State titleIndex: number = 0;
  // ✅ 新增回调：当分类切换时，把分类名称(string)传出去
  onCategoryChange: (category: string) => void = () => {};

  build() {
    // ✅ 修改：使用 Scroll 包裹 Row 实现横向滚动，防止分类过多显示不下
    Scroll() {
      Row({ space: 20 }) {
        // 注意：classifyTitle 现在是 string[]，所以 item 类型也是 string
        ForEach(classifyTitle, (item: string, index: number) => {
          Text(item)
            .fontSize($r('app.float.middle_font_size'))
            // 选中时全不透明，未选中时半透明
            .opacity(this.titleIndex === index ? Const.FULL_OPACITY : Const.EIGHTY_OPACITY)
            // 选中时加粗
            .fontWeight(this.titleIndex === index ? Const.FONT_WEIGHT_FIVE : FontWeight.Normal)
            .fontColor(Color.White)
            .onClick(() => {
              if (this.titleIndex !== index) {
                this.titleIndex = index;
                // ✅ 核心逻辑：触发回调，通知首页刷新数据
                this.onCategoryChange(item);
              }
            })
        }, (item: string) => item)
      }
      .padding({ left: 15, right: 15 }) // 给左右一点边距
    }
    .scrollable(ScrollDirection.Horizontal) // 允许横向滚动
    .scrollBar(BarState.Off) // 隐藏滚动条
    .width(Const.FULL_WIDTH)
    .margin({ top: $r('app.float.classify_title_margin') })
  }
}