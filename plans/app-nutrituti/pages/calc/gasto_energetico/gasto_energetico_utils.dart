// Project imports:
import 'model/gasto_energetico_model.dart';

class GastoEnergeticoUtils {
  static const Map<String, double> _valorMET = {
    'dormir': 0.95,
    'deitado': 1.2,
    'sentado': 1.5,
    'emPe': 2.0,
    'caminhando': 3.5,
    'exercicio': 7.0,
  };

  static double calcularTMB(double peso, double altura, int idade, int genero) {
    if (genero == 1) {
      return 88.362 + (13.397 * peso) + (4.799 * altura) - (5.677 * idade);
    } else {
      return 447.593 + (9.247 * peso) + (3.098 * altura) - (4.330 * idade);
    }
  }

  static double calcularGastoAtividade(
      String atividade, double horas, double tmbPorHora) {
    final met = _valorMET[atividade] ?? 1.0;
    return tmbPorHora * met * horas;
  }

  static double calcularTotalHoras(Map<String, double> horasPorAtividade) {
    return horasPorAtividade.values.fold(0, (total, horas) => total + horas);
  }

  static bool verificarTotalHoras(Map<String, double> horasPorAtividade) {
    final totalHoras = calcularTotalHoras(horasPorAtividade);
    return (totalHoras >= 23.5 && totalHoras <= 24.5);
  }

  static String gerarTextoCompartilhamento(GastoEnergeticoModel modelo) {
    final Map<String, String> atividadesNomes = {
      'dormir': 'Dormindo',
      'deitado': 'Deitado acordado',
      'sentado': 'Sentado',
      'emPe': 'Em pé / Atividades leves',
      'caminhando': 'Caminhando',
      'exercicio': 'Exercício intenso',
    };
    final genero = modelo.generoSelecionado == 1 ? 'Masculino' : 'Feminino';
    final peso = modelo.peso.toString().replaceAll('.', ',');
    final altura = modelo.altura.toString();
    final idade = modelo.idade.toString();
    final tmb = modelo.tmb.round().toString();
    final gastoTotal = modelo.gastoTotal.round().toString();
    final detalhamento = modelo.gastosPorAtividade.entries.map((entry) {
      final nomeAtividade = atividadesNomes[entry.key] ?? entry.key;
      final gastoAtividade = entry.value.round().toString();
      return '- $nomeAtividade: $gastoAtividade kcal';
    }).join('\n');
    return '''📊 RESULTADO DO CÁLCULO DE GASTO ENERGÉTICO 📊\n\n🧑‍🦰 Dados Pessoais:\n- Gênero: $genero\n- Peso: $peso kg\n- Altura: $altura cm\n- Idade: $idade anos\n\n📝 Resultados:\n- Taxa Metabólica Basal (TMB): $tmb kcal/dia\n- Gasto Energético Total (GET): $gastoTotal kcal/dia\n\n📋 Detalhamento por Atividade:\n$detalhamento\n\n📌 Recomendações:\n- Para manter o peso: Consuma aproximadamente $gastoTotal kcal/dia\n- Para perder peso: Consuma menos calorias que o valor calculado\n- Para ganhar peso: Consuma mais calorias que o valor calculado\n\n🔎 Calculado pelo aplicativo NutriTuti\n''';
  }
}
