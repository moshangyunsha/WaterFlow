import ProductItem from '../viewmodel/ProductItem';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import router from '@ohos.router';

@Component
export default struct FlowItemComponent {
  // 监听 item 变化
  @Prop @Watch('onItemChange') item: ProductItem;
  @StorageLink('hoveringItemId') currentHoverId: string = '';
  @State scaleVal: number = 1;
  @State isShowPopup: boolean = false;

  @State currentImage: ResourceStr = $r('app.media.loading');

  private readonly HOVER_SCALE: number = 1.02;

  // 移除固定高度，改为动态计算
  // private readonly FIXED_IMAGE_HEIGHT: Length = $r('app.float.product_image_size');

  aboutToAppear() { this.updateImage(); }
  onItemChange() { this.updateImage(); }

  private updateImage() {
    // 增加空值校验
    this.currentImage = this.item?.image_url || $r('app.media.loading');
  }

  private get isSelfHovering(): boolean { return this.item?.name === this.currentHoverId; }

  @Builder PopupBuilder() {
    Row({ space: 10 }) {
      Button($r('app.string.collect_text')).fontSize(12).backgroundColor(Color.White).fontColor('#333333').height(32).onClick(() => this.isShowPopup = false)
      Button($r('app.string.compare_text')).fontSize(12).backgroundColor($r('app.color.focus_color')).fontColor(Color.White).height(32).onClick(() => this.isShowPopup = false)
    }
    .padding(10).backgroundColor(Color.White).borderRadius(8).shadow({ radius: 10, color: '#00000030' })
  }

  build() {
    Column() {
      // --- 图片区域 ---
      Image(this.currentImage)
        .width('100%') // 宽度撑满
        // 核心修改：利用后端返回的宽高计算比例，实现真正的瀑布流交错效果
        // 如果没有宽高数据，默认 1:1
        .aspectRatio(this.item.width > 0 && this.item.height > 0 ? this.item.width / this.item.height : 1)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: $r('app.float.product_layout_radius'), topRight: $r('app.float.product_layout_radius') })
        // 移除固定的 margin，让图片紧贴顶部，更好看
        .onError(() => {
          Logger.error('FlowItem', `Image load failed for ${this.item.name}, fallback to default.`);
          this.currentImage = $r('app.media.ic_app_background');
        })

      // --- 内容区域 ---
      Column() {
        // 标题
        Text(this.item?.name)
          .fontSize($r('app.float.small_font_size'))
          .fontColor(Color.Black)
          .alignSelf(ItemAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超出两行显示省略号

        // 折扣信息 (可选)
        if (this.item?.discount) {
          Text(this.item?.discount)
            .fontSize($r('app.float.smaller_font_size'))
            .opacity(Const.SIXTY_OPACITY)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })
        }

        // 价格 (核心修改：处理 number 类型)
        Text(`¥${this.item?.price?.toFixed(2) || '0.00'}`)
          .fontSize($r('app.float.middle_font_size'))
          .fontColor($r('app.color.focus_color'))
          .alignSelf(ItemAlign.Start)
          .lineHeight($r('app.float.piece_line_height'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: 4 })

        // 标签栏
        Row() {
          if (this.item?.promotion) {
            Text(`${this.item?.promotion}`)
              .fontSize($r('app.float.promotion_font_size'))
              .fontColor(Color.White)
              .borderRadius(2)
              .backgroundColor($r('app.color.focus_color'))
              .padding({ left: 4, right: 4 })
              .margin({ right: 4 })
          }
          if (this.item?.bonus_points) {
            Text(`${this.item?.bonus_points}`)
              .fontSize($r('app.float.promotion_font_size'))
              .fontColor($r('app.color.focus_color'))
              .borderRadius(2)
              .borderWidth(1)
              .borderColor($r('app.color.focus_color'))
              .padding({ left: 4, right: 4 })
          }
        }
        .width(Const.FULL_WIDTH)
        .justifyContent(FlexAlign.Start)
        .margin({ top: 6 })
      }
      .padding(10) // 内容区域留白
    }
    .borderRadius($r('app.float.product_layout_radius'))
    .backgroundColor(Color.White)
    // 移除内边距，让图片边缘对齐
    .clip(true)
    .scale({ x: this.scaleVal, y: this.scaleVal })
    .shadow(this.isSelfHovering ? { radius: 10, color: $r('app.color.focus_color'), offsetY: 5 } : ShadowStyle.OUTER_DEFAULT_XS)
    .animation({ duration: 200 })
    .onHover((isHover) => {
      if (isHover) {
        this.currentHoverId = this.item?.name;
        animateTo({ duration: 200 }, () => this.scaleVal = this.HOVER_SCALE);
      } else if (this.currentHoverId === this.item?.name) {
        this.currentHoverId = '';
        animateTo({ duration: 200 }, () => this.scaleVal = 1.0);
      }
    })
    .onClick(() => {
      this.currentHoverId = '';
      animateTo({ duration: 100 }, () => this.scaleVal = 0.95);
      setTimeout(() => {
        animateTo({ duration: 100 }, () => this.scaleVal = 1.0);
        // 传递整个 item 对象给详情页
        router.pushUrl({ url: 'pages/ProductDetailPage', params: this.item });
      }, 100);
    })
    .gesture(LongPressGesture({ repeat: false }).onAction(() => this.isShowPopup = true))
    .bindPopup(this.isShowPopup, {
      builder: this.PopupBuilder,
      placement: Placement.Top,
      mask: false,
      onStateChange: (e) => { if (!e.isVisible) this.isShowPopup = false; }
    })
  }
}