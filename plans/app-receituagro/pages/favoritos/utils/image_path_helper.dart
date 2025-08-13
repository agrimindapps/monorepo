class ImagePathHelper {
  static String getPragaImagePath(String nomeCientifico) {
    final sanitizedName = _sanitizeName(nomeCientifico);
    return 'assets/imagens/pragas/$sanitizedName.jpg';
  }

  static String getDiagnosticoImagePath(String nomeCientifico) {
    final sanitizedName = _sanitizeName(nomeCientifico);
    return 'assets/imagens/diagnosticos/$sanitizedName.jpg';
  }

  static String _sanitizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .trim();
  }
}