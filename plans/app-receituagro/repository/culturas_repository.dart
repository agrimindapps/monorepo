// Package imports:
import 'package:get/get.dart';

class CulturaRepository {
  RxList<dynamic> culturasLista = RxList<dynamic>();
  RxBool isLoadingCulturasLista = false.obs;
  RxMap<dynamic, dynamic> cultura = RxMap<dynamic, dynamic>();
  RxBool isLoadingCultura = false.obs;
}
