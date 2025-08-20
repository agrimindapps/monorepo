class LembreteValidators {
  static String? validateTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Título deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Título deve ter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipo é obrigatório';
    }
    return null;
  }

  static String? validateDescricao(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Descrição deve ter no máximo 500 caracteres';
    }
    return null;
  }

  static String? validateDataHora(DateTime? value) {
    if (value == null) {
      return 'Data e hora são obrigatórias';
    }
    return null;
  }

  static String? validateDataHoraFutura(DateTime? value) {
    if (value == null) {
      return 'Data e hora são obrigatórias';
    }
    if (value.isBefore(DateTime.now())) {
      return 'Data e hora devem ser futuras';
    }
    return null;
  }

  static String sanitizeInput(String? input) {
    if (input == null) return '';
    return input.trim();
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool hasValidLength(String? text, int minLength, int maxLength) {
    if (text == null) return false;
    final length = text.trim().length;
    return length >= minLength && length <= maxLength;
  }
}