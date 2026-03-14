import 'package:creditscoring/services/local_storage_service.dart';
import 'package:creditscoring/viewmodels/language_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  test('default language is English', () {
    final vm = LanguageViewModel();

    expect(vm.isVietnamese, isFalse);
    expect(vm.locale.languageCode, 'en');
  });

  test('can switch language to Vietnamese and persist it', () async {
    final vm = LanguageViewModel();

    await vm.setLanguage('vi');

    expect(vm.isVietnamese, isTrue);
    expect(vm.locale.languageCode, 'vi');
    expect(LocalStorageService.getAppLanguage(), 'vi');
  });
}
