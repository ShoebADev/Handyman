import 'package:mobx/mobx.dart';

part 'other_setting_store.g.dart';

class OtherSettingStore = _OtherSettingStore with _$OtherSettingStore;

abstract class _OtherSettingStore with Store {
  @observable
  int maintenanceModeEnable = 0;

  @action
  void setMaintenanceModeEnable(int val) {
    maintenanceModeEnable = val;
  }
}
