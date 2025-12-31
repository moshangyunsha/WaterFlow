/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants as Const } from '../common/constants/CommonConstants';

/**
 * Search component.
 *
 * Usage: Directly reference SearchComponent().
 */
@Component
export default struct SearchComponent {
  // 定义一个回调函数，当用户提交搜索时调用
  // 这里的 onSearch 是父组件传进来的方法
  onSearch: (value: string) => void = (value: string): void => {};

  build() {
    Row() {
      Search({ placeholder: '搜索商品...' })
        .searchButton('搜索')
        .width(Const.FULL_WIDTH)
        .height($r('app.float.search_swiper_height'))
        .backgroundColor(Color.White)
        .placeholderColor(Color.Gray)
        .placeholderFont({ size: $r('app.float.small_font_size') })
        .onSubmit((value: string) => {
          // 触发回调
          this.onSearch(value);
        })
        .onChange((value: string) => {
          // 可选：如果想做实时搜索，也可以在这里调用
          if(value === '') {
            this.onSearch(''); // 清空时恢复
          }
        })
    }
    .width(Const.FULL_WIDTH)
    // 保持原有的外边距布局
    .margin({ top: $r('app.float.search_margin_top') })
    .padding({ left: $r('app.float.search_margin_left'), right: $r('app.float.search_margin_right') })
  }
}