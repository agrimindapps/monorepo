// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/abastecimento_page_controller.dart';
import '../services/abastecimento_service.dart';
import '../services/currency_formatter_service.dart';
import '../services/date_formatter_service.dart';
import '../services/date_time_helper.dart';

class AbastecimentoPageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbastecimentoService>(() => AbastecimentoService(),
        fenix: true);
    Get.lazyPut<DateFormatterService>(() => DateFormatterService(),
        fenix: true);
    Get.lazyPut<CurrencyFormatterService>(() => CurrencyFormatterService(),
        fenix: true);
    Get.lazyPut<DateTimeHelper>(() => DateTimeHelper(), fenix: true);
    Get.lazyPut<AbastecimentoPageController>(
      () => AbastecimentoPageController(),
      fenix: true,
    );
  }
}
