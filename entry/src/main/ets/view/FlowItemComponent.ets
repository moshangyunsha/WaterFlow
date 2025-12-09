import ProductItem from '../viewmodel/ProductItem';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import router from '@ohos.router';

@Component
export default struct FlowItemComponent {
  @Prop @Watch('onItemChange') item: ProductItem;
  @StorageLink('hoveringItemId') currentHoverId: string = '';
  @State scaleVal: number = 1;
  @State isShowPopup: boolean = false;

  @State currentImage: ResourceStr = $r('app.media.loading');

  private readonly HOVER_SCALE: number = 1.02;
  private readonly FIXED_IMAGE_HEIGHT: Length = $r('app.float.product_image_size');

  aboutToAppear() { this.updateImage(); }
  onItemChange() { this.updateImage(); }

  private updateImage() {
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
      Image(this.currentImage)
        .width(this.FIXED_IMAGE_HEIGHT)
        .height(this.FIXED_IMAGE_HEIGHT)
        .objectFit(ImageFit.Contain)
        .margin({ top: $r('app.float.water_flow_image_top'), bottom: $r('app.float.water_flow_image_bottom') })
        .onError(() => {
          console.warn('FlowItem', `Image load failed for ${this.item.name}, fallback to default.`);
          this.currentImage = $r('app.media.ic_app_background');
        })

      Text(this.item?.name).fontSize($r('app.float.small_font_size')).fontColor(Color.Black).alignSelf(ItemAlign.Start)
      Text(this.item?.discount).fontSize($r('app.float.smaller_font_size')).opacity(Const.SIXTY_OPACITY).alignSelf(ItemAlign.Start).margin({ bottom: $r('app.float.discount_text_bottom') })
      Text(this.item?.price).fontSize($r('app.float.middle_font_size')).fontColor($r('app.color.focus_color')).alignSelf(ItemAlign.Start).lineHeight($r('app.float.piece_line_height'))

      Row() {
        if (this.item?.promotion) {
          Text(`${this.item?.promotion}`).fontSize($r('app.float.promotion_font_size')).fontColor(Color.White).borderRadius(2).backgroundColor($r('app.color.focus_color')).padding({ left: 4, right: 4 }).margin({ top: 4, right: 4 })
        }
        if (this.item?.bonus_points) {
          Text(`${this.item?.bonus_points}`).fontSize($r('app.float.promotion_font_size')).fontColor($r('app.color.focus_color')).borderRadius(2).borderWidth(1).borderColor($r('app.color.focus_color')).padding({ left: 4, right: 4 }).margin({ top: 4 })
        }
      }
      .width(Const.FULL_WIDTH).justifyContent(FlexAlign.Start)
    }
    .borderRadius($r('app.float.product_layout_radius'))
    .backgroundColor(Color.White)
    .padding({ left: 10, right: 10, bottom: 10 })
    .scale({ x: this.scaleVal, y: this.scaleVal })
    .shadow(this.isSelfHovering ? { radius: 10, color: $r('app.color.focus_color'), offsetY: 5 } : ShadowStyle.OUTER_DEFAULT_XS)
    .animation({ duration: 200 })
    .onHover((isHover) => {
      if (isHover) { this.currentHoverId = this.item?.name; animateTo({ duration: 200 }, () => this.scaleVal = this.HOVER_SCALE); }
      else if (this.currentHoverId === this.item?.name) { this.currentHoverId = ''; animateTo({ duration: 200 }, () => this.scaleVal = 1.0); }
    })
    .onClick(() => {
      this.currentHoverId = '';
      animateTo({ duration: 100 }, () => this.scaleVal = 0.95);
      setTimeout(() => { animateTo({ duration: 100 }, () => this.scaleVal = 1.0); router.pushUrl({ url: 'pages/ProductDetailPage', params: this.item }); }, 100);
    })
    .gesture(LongPressGesture({ repeat: false }).onAction(() => this.isShowPopup = true))
    .bindPopup(this.isShowPopup, { builder: this.PopupBuilder, placement: Placement.Top, mask: false, onStateChange: (e) => { if (!e.isVisible) this.isShowPopup = false; } })
  }
}