// Utilitários para cálculo de densidade de nutrientes

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../model/densidade_nutrientes_model.dart';

class DensidadeNutrientesUtils {
  static final List<NutrienteModel> nutrientes = [
    const NutrienteModel(id: 1, text: 'Proteína (g)', unidade: 'g'),
    const NutrienteModel(id: 2, text: 'Fibra (g)', unidade: 'g'),
    const NutrienteModel(id: 3, text: 'Vitamina A (μg)', unidade: 'μg'),
    const NutrienteModel(id: 4, text: 'Vitamina C (mg)', unidade: 'mg'),
    const NutrienteModel(id: 5, text: 'Cálcio (mg)', unidade: 'mg'),
    const NutrienteModel(id: 6, text: 'Ferro (mg)', unidade: 'mg'),
    const NutrienteModel(id: 7, text: 'Potássio (mg)', unidade: 'mg'),
    const NutrienteModel(id: 8, text: 'Magnésio (mg)', unidade: 'mg'),
  ];

  static final numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  static double calcularDensidadeNutrientes(double nutriente, double calorias) {
    double densidade = (nutriente / calorias) * 1000;
    return double.parse(densidade.toStringAsFixed(2));
  }

  static String getAvaliacaoDensidade(
      double densidadeNutrientes, int nutrienteSelecionado) {
    switch (nutrienteSelecionado) {
      case 1:
        if (densidadeNutrientes < 30) return 'Baixa';
        if (densidadeNutrientes >= 30 && densidadeNutrientes < 50) {
          return 'Moderada';
        }
        return 'Alta';
      case 2:
        if (densidadeNutrientes < 10) return 'Baixa';
        if (densidadeNutrientes >= 10 && densidadeNutrientes < 14) {
          return 'Moderada';
        }
        return 'Alta';
      case 3:
        if (densidadeNutrientes < 300) return 'Baixa';
        if (densidadeNutrientes >= 300 && densidadeNutrientes < 600) {
          return 'Moderada';
        }
        return 'Alta';
      case 4:
        if (densidadeNutrientes < 30) return 'Baixa';
        if (densidadeNutrientes >= 30 && densidadeNutrientes < 60) {
          return 'Moderada';
        }
        return 'Alta';
      case 5:
        if (densidadeNutrientes < 400) return 'Baixa';
        if (densidadeNutrientes >= 400 && densidadeNutrientes < 600) {
          return 'Moderada';
        }
        return 'Alta';
      case 6:
        if (densidadeNutrientes < 4) return 'Baixa';
        if (densidadeNutrientes >= 4 && densidadeNutrientes < 8) {
          return 'Moderada';
        }
        return 'Alta';
      case 7:
        if (densidadeNutrientes < 1000) return 'Baixa';
        if (densidadeNutrientes >= 1000 && densidadeNutrientes < 2000) {
          return 'Moderada';
        }
        return 'Alta';
      case 8:
        if (densidadeNutrientes < 120) return 'Baixa';
        if (densidadeNutrientes >= 120 && densidadeNutrientes < 160) {
          return 'Moderada';
        }
        return 'Alta';
      default:
        return 'Não avaliado';
    }
  }

  static String getComentarioDensidade(
      String avaliacao, NutrienteModel nutriente) {
    String nutrienteNome = nutriente.nome;
    switch (avaliacao) {
      case 'Baixa':
        return 'Este alimento tem uma baixa densidade de $nutrienteNome em relação às suas calorias. Considere combiná-lo com outros alimentos mais ricos neste nutriente.';
      case 'Moderada':
        return 'Este alimento tem uma densidade moderada de $nutrienteNome em relação às suas calorias, o que o torna uma opção razoável para obter este nutriente.';
      case 'Alta':
        return 'Este alimento tem uma alta densidade de $nutrienteNome em relação às suas calorias, sendo uma excelente escolha para aumentar a ingestão deste nutriente.';
      default:
        return '';
    }
  }

  static String textoCompartilhamento(DensidadeNutrientesResultado resultado) {
    StringBuffer t = StringBuffer();
    t.writeln('Cálculo de Densidade de Nutrientes');
    t.writeln();
    t.writeln('Dados do Alimento');
    t.writeln('Calorias: ${resultado.calorias} kcal');
    t.writeln('${resultado.nutrienteSelecionado.text}: ${resultado.nutriente}');
    t.writeln();
    t.writeln('Resultados');
    t.writeln(
        'Densidade de nutrientes: ${numberFormat.format(resultado.densidadeNutrientes)} por 1000 kcal');
    t.writeln('Avaliação: ${resultado.avaliacao}');
    t.writeln();
    t.writeln('Comentário');
    t.writeln(resultado.comentario);
    t.writeln();
    t.writeln(
        'Observação: A densidade de nutrientes é uma medida que avalia a quantidade de nutrientes por caloria em um alimento, ajudando a identificar alimentos nutricionalmente densos.');
    return t.toString();
  }
}
