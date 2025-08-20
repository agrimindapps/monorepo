// Project imports:
import 'normalize.dart';

class CustomClass {
  String? field;
  String? name;
  String? type;
  String? value;

  CustomClass({
    this.field,
    this.name,
    this.type,
    this.value,
  });

  Map<String, dynamic> toMap(CustomClass reg) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field'] = reg.field;
    data['name'] = reg.name;
    data['type'] = reg.type;
    data['value'] = reg.value;
    return data;
  }

  // Função para converter um documento em um objeto CustomClass
  CustomClass documentToClass(Map<String, dynamic> doc) {
    final data = doc;

    return CustomClass(
      field: normalize(data, 'field'),
      name: normalize(data, 'name'),
      type: normalize(data, 'type'),
      value: normalize(data, 'value'),
    );
  }
}
