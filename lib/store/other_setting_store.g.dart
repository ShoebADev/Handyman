// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_setting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OtherSettingStore on _OtherSettingStore, Store {
  late final _$maintenanceModeEnableAtom =
      Atom(name: '_OtherSettingStore.maintenanceModeEnable', context: context);

  @override
  int get maintenanceModeEnable {
    _$maintenanceModeEnableAtom.reportRead();
    return super.maintenanceModeEnable;
  }

  @override
  set maintenanceModeEnable(int value) {
    _$maintenanceModeEnableAtom.reportWrite(value, super.maintenanceModeEnable,
        () {
      super.maintenanceModeEnable = value;
    });
  }

  late final _$_OtherSettingStoreActionController =
      ActionController(name: '_OtherSettingStore', context: context);

  @override
  void setMaintenanceModeEnable(int val) {
    final _$actionInfo = _$_OtherSettingStoreActionController.startAction(
        name: '_OtherSettingStore.setMaintenanceModeEnable');
    try {
      return super.setMaintenanceModeEnable(val);
    } finally {
      _$_OtherSettingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
maintenanceModeEnable: ${maintenanceModeEnable}
    ''';
  }
}
