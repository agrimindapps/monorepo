class ValidationService {
  String? validateLitros(String? value) {
    if (value?.isEmpty ?? true) return 'Campo obrigatório';
    final cleanValue = value!.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);
    if (number == null) return 'Valor inválido';
    if (number <= 0) return 'O valor deve ser maior que zero';
    if (number > 999) return 'O valor máximo é 999 litros';
    return null;
  }

  String? validateValorPorLitro(String? value) {
    if (value?.isEmpty ?? true) return 'Campo obrigatório';
    final cleanValue = value!.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);
    if (number == null) return 'Valor inválido';
    if (number <= 0) return 'O valor deve ser maior que zero';
    return null;
  }

  String? validateOdometro(String? value,
      {double? odometroInicial, double? odometroAtual}) {
    if (value?.isEmpty ?? true) return 'Campo obrigatório';

    final cleanValue = value!.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);

    if (number == null) return 'Valor inválido';
    if (number <= 0) return 'O valor deve ser maior que zero';

    if (odometroInicial != null && number < odometroInicial) {
      return 'O odômetro não pode ser menor que a quilometragem inicial do veículo (${odometroInicial.toStringAsFixed(1).replaceAll('.', ',')} km)';
    }

    if (odometroAtual != null && number < odometroAtual) {
      return 'O odômetro não pode ser menor que ${odometroAtual.toStringAsFixed(1).replaceAll('.', ',')} km';
    }

    return null;
  }

  String? validateTipoCombustivel(Object? value) {
    return value == null ? 'Selecione um combustível' : null;
  }
}
