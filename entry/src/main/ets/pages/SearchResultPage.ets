import router from '@ohos.router';
import ProductItem from '../viewmodel/ProductItem';
import ProductService from '../service/ProductService';
import SearchComponent from '../view/SearchComponent';
// 移除未使用的 User 引用
import Logger from '../common/utils/Logger'; // 建议引入 Logger 用于打印错误，或者直接用 console

@Entry
@Component
struct SearchResultPage {
  @State keyword: string = '';
  @State resultList: ProductItem[] = [];
  @State isLoading: boolean = false;

  @StorageLink('topRectHeight') topRectHeight: number = 0;

  async aboutToAppear() {
    // 1. 获取首页传来的关键字 (增加空值安全检查)
    const params = router.getParams() as Record<string, string>;
    if (params && params['keyword']) {
      this.keyword = params['keyword'];
      await this.doSearch();
    }
  }

  async doSearch() {
    this.isLoading = true;
    // 调用 Service 搜索
    this.resultList = await ProductService.searchProducts(this.keyword);
    this.isLoading = false;
  }

  build() {
    Column() {
      // 1. 顶部搜索区
      Row() {
        // 返回按钮
        Text("<")
          .fontSize(24)
          .width(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            try {
              router.back();
            } catch (err) {
              console.error(`Router back failed: ${JSON.stringify(err)}`);
            }
          })

        // 搜索组件 (占比 1)
        // ✅ 修复：直接使用 Row 包裹 SearchComponent 来承载 layoutWeight
        // 这样避免了在自定义组件上直接使用属性可能导致的编译器困惑
        Row() {
          SearchComponent({
            onSearch: (val: string) => {
              this.keyword = val;
              this.doSearch();
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: this.getUIContext().px2vp(this.topRectHeight) }) // 适配状态栏
      .backgroundColor(Color.White)

      // 2. 搜索结果列表
      if (this.isLoading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 })
      } else if (this.resultList.length === 0) {
        Column() {
          Image($r('app.media.ic_holder_computer')).width(100).height(100).opacity(0.5)
          Text(`未找到与 "${this.keyword}" 相关的商品`).fontColor(Color.Gray).margin({ top: 10 })
        }.margin({ top: 100 })
      } else {
        List({ space: 12 }) {
          ForEach(this.resultList, (item: ProductItem) => {
            ListItem() {
              // --- 列表项布局：左图右文 ---
              Row() {
                // 左侧图片
                Image(item.image_url)
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                  .backgroundColor('#F5F5F5')

                // 右侧信息
                Column() {
                  Text(item.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 描述 (如果有)
                  Text(item.description)
                    .fontSize(12)
                    .fontColor(Color.Gray)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 4 })

                  Blank() // 撑开空间

                  // 价格区域
                  Row() {
                    Text('¥').fontSize(12).fontColor(Color.Red).baselineOffset(-2)
                    Text(item.price.toFixed(2)).fontSize(18).fontColor(Color.Red).fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                }
                .layoutWeight(1)
                .height(100)
                .padding({ left: 10, top: 2, bottom: 2 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .onClick(() => {
                // 点击跳转详情 (捕获异常)
                try {
                  router.pushUrl({ url: 'pages/ProductDetailPage', params: item });
                } catch (err) {
                  console.error(`Router push failed: ${JSON.stringify(err)}`);
                }
              })
            }
          })
        }
        .width('100%') // ✅ 修复：显式设置宽度
        .layoutWeight(1) // 占满剩余高度
        .padding({ left: 12, right: 12, top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}