import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';
import RdbUtil from '../common/utils/RdbUtil';

export default class EntryAbility extends UIAbility {
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {

    // 【核心】必须死等数据库初始化完成
    console.info('EntryAbility: Start initializing DB...');
    try {
      await RdbUtil.initDB(this.context);
      console.info('EntryAbility: DB Initialized successfully.');
    } catch (e) {
      console.error(`EntryAbility: DB Init FAILED: ${JSON.stringify(e)}`);
    }

    windowStage.loadContent('pages/HomePage', (err, data) => {
      if (err.code) {
        Logger.error('Failed to load content', JSON.stringify(err));
        return;
      }

      // 沉浸式导航栏设置
      try {
        let windowClass: window.Window = windowStage.getMainWindowSync();
        windowClass.setWindowLayoutFullScreen(true);

        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
        let avoidArea = windowClass.getWindowAvoidArea(type);
        AppStorage.setOrCreate('bottomRectHeight', avoidArea.bottomRect.height);

        type = window.AvoidAreaType.TYPE_SYSTEM;
        avoidArea = windowClass.getWindowAvoidArea(type);
        AppStorage.setOrCreate('topRectHeight', avoidArea.topRect.height);
      } catch (error) {}
    });
  }
}