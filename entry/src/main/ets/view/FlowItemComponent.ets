/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ProductItem from '../viewmodel/ProductItem';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import router from '@ohos.router';

/**
 * 瀑布流商品卡片组件，实现独占悬停、点击跳转和长按浮层操作。
 */
@Component
export default struct FlowItemComponent {
  @Prop item: ProductItem; // 父组件传入的商品数据

  // 使用 @StorageLink 链接全局悬停 ID，实现多卡片独占悬停效果
  @StorageLink('hoveringItemId') currentHoverId: string = '';

  @State scaleVal: number = 1; // 卡片缩放值，用于悬停动画
  @State isShowPopup: boolean = false; // 是否显示长按浮层

  private readonly HOVER_SCALE: number = 1.02; // 悬停时的放大比例

  // 资源定义
  private readonly SHADOW_RADIUS_RESOURCE: Resource = $r('app.float.card_shadow_radius');
  private readonly FOCUS_COLOR_RESOURCE: Resource = $r('app.color.focus_color');
  private readonly FIXED_IMAGE_HEIGHT: Length = $r('app.float.product_image_size');

  // 计算属性：判断当前组件的 item.name 是否等于全局悬停 ID，用于驱动阴影变化
  private get isSelfHovering(): boolean {
    return this.item?.name === this.currentHoverId;
  }

  /**
   * 长按弹出菜单构建器
   */
  @Builder
  PopupBuilder() {
    Row({ space: 10 }) {
      Button($r('app.string.collect_text'))
        .fontSize(12)
        .backgroundColor(Color.White)
        .fontColor('#333333')
        .border({ width: 1, color: '#EEEEEE' })
        .width($r('app.float.quick_action_button_width'))
        .height(32)
        .onClick(() => {
          this.isShowPopup = false;
          Logger.info('FlowItemComponent', '长按浮层：点击了收藏');
        })

      Button($r('app.string.compare_text'))
        .fontSize(12)
        .backgroundColor($r('app.color.focus_color'))
        .fontColor(Color.White)
        .width($r('app.float.quick_action_button_width'))
        .height(32)
        .onClick(() => {
          this.isShowPopup = false;
          Logger.info('FlowItemComponent', '长按浮层：点击了对比');
        })
    }
    .padding($r('app.float.product_layout_margin'))
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 10, color: '#00000030' })
  }

  build() {
    Column() {
      // --- 商品图片区域 ---
      Image(this.item?.image_url)
        .width(this.FIXED_IMAGE_HEIGHT)
        .height(this.FIXED_IMAGE_HEIGHT)
        .objectFit(ImageFit.Contain)
        .margin({
          top: $r('app.float.water_flow_image_top'),
          bottom: $r('app.float.water_flow_image_bottom')
        })

      // --- 商品名称和描述 ---
      Text(this.item?.name)
        .fontSize($r('app.float.small_font_size'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Normal)
        .alignSelf(ItemAlign.Start)

      Text(this.item?.discount)
        .fontSize($r('app.float.smaller_font_size'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Normal)
        .opacity(Const.SIXTY_OPACITY)
        .alignSelf(ItemAlign.Start)
        .margin({
          bottom: $r('app.float.discount_text_bottom')
        })

      // --- 商品价格 ---
      Text(this.item?.price)
        .fontSize($r('app.float.middle_font_size'))
        .fontColor($r('app.color.focus_color')) // 焦点颜色突出价格
        .fontWeight(FontWeight.Normal)
        .alignSelf(ItemAlign.Start)
        .lineHeight($r('app.float.piece_line_height'))

      // --- 促销标签区域 ---
      Row() {
        if (this.item?.promotion) {
          Text(`${this.item?.promotion}`)
            .height($r('app.float.promotion_text_height'))
            .fontSize($r('app.float.promotion_font_size'))
            .fontColor(Color.White)
            .borderRadius($r('app.float.promotion_radius'))
            .backgroundColor($r('app.color.focus_color'))
            .padding({
              left: $r('app.float.promotion_padding_left'),
              right: $r('app.float.promotion_padding_right')
            })
            .margin({
              top: $r('app.float.promotion_margin_top'),
              right: $r('app.float.promotion_margin_right')
            })
        }
        if (this.item?.bonus_points) {
          Text(`${this.item?.bonus_points}`)
            .height($r('app.float.promotion_text_height'))
            .fontSize($r('app.float.promotion_font_size'))
            .fontColor($r('app.color.focus_color'))
            .borderRadius($r('app.float.promotion_radius'))
            .borderWidth($r('app.float.bonus_points_radius_width'))
            .borderColor($r('app.color.focus_color'))
            .padding({
              left: $r('app.float.bonus_points_padding_left'),
              right: $r('app.float.bonus_points_padding_right')
            })
            .margin({ top: $r('app.float.bonus_points_margin_top') })
        }
      }
      .width(Const.FULL_WIDTH)
      .justifyContent(FlexAlign.Start)
    }
    // --- 容器基础样式 ---
    .borderRadius($r('app.float.product_layout_radius'))
    .backgroundColor(Color.White)
    .padding({
      left: $r('app.float.product_layout_margin_left'),
      right: $r('app.float.product_layout_margin_right'),
      bottom: $r('app.float.product_layout_margin_bottom')
    })

    // --- 交互功能实现 ---
    .scale({ x: this.scaleVal, y: this.scaleVal })
    // 根据 Getter 属性判断是否应用悬停阴影 (红色高亮)
    .shadow(this.isSelfHovering ? {
      radius: this.SHADOW_RADIUS_RESOURCE,
      color: this.FOCUS_COLOR_RESOURCE,
      offsetX: 0,
      offsetY: 5
    } : ShadowStyle.OUTER_DEFAULT_XS)

    // 全局动画配置：确保缩放和阴影变化平滑过渡
    .animation({ duration: 200, curve: Curve.EaseInOut })

    // 悬停事件处理 (独占逻辑)
    .onHover((isHover: boolean) => {
      // 鼠标进入
      if (isHover) {
        this.currentHoverId = this.item?.name; // 设置全局 ID，清除其他组件的悬停状态
        // 触发缩放放大动画
        animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.scaleVal = this.HOVER_SCALE;
        });
      }
      // 鼠标离开 (仅当当前组件是独占状态时才清空 ID)
      else if (this.currentHoverId === this.item?.name) {
        this.currentHoverId = ''; // 清空 ID
        // 触发缩放回弹动画
        animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.scaleVal = 1.0;
        });
      }
    })

    // 点击事件处理 (带回弹动画和路由跳转)
    .onClick(() => {
      this.currentHoverId = ''; // 点击时清除悬停状态

      // 快速缩小/回弹动画
      animateTo({ duration: 100, curve: Curve.Friction }, () => {
        this.scaleVal = 0.95;
      });
      setTimeout(() => {
        animateTo({ duration: 100, curve: Curve.Friction }, () => {
          this.scaleVal = 1.0;
        });

        // 路由跳转到详情页
        try {
          router.pushUrl({
            url: 'pages/ProductDetailPage',
            params: this.item
          });
        } catch (err) {
          Logger.error('FlowItemComponent', `Router failed to push URL. Cause: ${JSON.stringify(err)}`);
        }
      }, 100);
    })

    // 长按手势处理 (弹出操作浮层)
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.isShowPopup = true;
        })
    )
    .bindPopup(this.isShowPopup, {
      builder: this.PopupBuilder,
      placement: Placement.Top,
      mask: false,
      enableArrow: true,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.isShowPopup = false;
        }
      }
    })
  }
}