class Cultura {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  // int status;
  String cultura;

  Cultura({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    // required this.status,
    required this.cultura,
  });

  factory Cultura.fromJson(Map<String, dynamic> json) {
    return Cultura(
      objectId: json['objectId'] ?? '',
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) ?? 0 : 0,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) ?? 0 : 0,
      idReg: json['idReg'] ?? '',
      // status: json['Status'] != null ? json['Status'] as int : 0,
      cultura: json['cultura'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      // 'Status': status,
      'cultura': cultura,
    };
  }
}
