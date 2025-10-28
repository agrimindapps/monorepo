class Cultura {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String cultura;

  Cultura({
    this.objectId = '',
    this.createdAt = 0,
    this.updatedAt = 0,
    this.idReg = '',
    this.status = 1,
    this.cultura = '',
  });

  factory Cultura.fromJson(Map<String, dynamic> json) {
    return Cultura(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      cultura: json['cultura'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
      'cultura': cultura,
    };
  }
}
