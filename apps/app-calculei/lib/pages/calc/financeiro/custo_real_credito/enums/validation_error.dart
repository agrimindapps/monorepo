/// Enum que representa os diferentes tipos de erro de validação possíveis
enum ValidationError {
  // Erros de campos vazios
  requiredField('Campo obrigatório não preenchido'),
  invalidFormat('Formato inválido'),

  // Erros de valores monetários
  valueTooLow('Valor muito baixo'),
  valueTooHigh('Valor muito alto'),
  invalidCurrency('Valor monetário inválido'),

  // Erros de número de parcelas
  invalidInstallments('Número de parcelas inválido'),
  tooFewInstallments('Número de parcelas muito baixo'),
  tooManyInstallments('Número de parcelas muito alto'),

  // Erros de taxa de investimento
  invalidRate('Taxa de juros inválida'),
  rateTooLow('Taxa de juros muito baixa'),
  rateTooHigh('Taxa de juros muito alta'),

  // Erros de regras de negócio
  installmentValueTooLow(
      'Valor da parcela muito baixo em relação ao valor total'),
  totalValueTooLow('Valor total parcelado menor que valor à vista'),
  unrealisticRate('Taxa de juros fora da realidade do mercado'),
  smallDifference('Diferença entre valores muito pequena para análise'),
  invalidBusinessLogic('Combinação de valores inválida');

  final String message;
  const ValidationError(this.message);
}
