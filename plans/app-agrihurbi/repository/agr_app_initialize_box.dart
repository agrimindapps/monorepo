// Project imports:
import '../controllers/medicoes_controller.dart';
import '../controllers/pluviometros_controller.dart';

class AgrAppInitializeBox {
  void initialize() {
    PluviometrosController.initialize();
    MedicoesController.initialize();
  }
}
