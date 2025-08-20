class Passo {
  final String passo;
  final bool opcional;

  Passo({
    required this.passo,
    this.opcional = false,
  });

  Passo.fromJson(Map<String, dynamic> json)
      : passo = json['passo'] as String,
        opcional = json['opcional'] as bool;

  @override
  String toString() {
    return '${opcional ? '•' : ''} $passo';
  }
}