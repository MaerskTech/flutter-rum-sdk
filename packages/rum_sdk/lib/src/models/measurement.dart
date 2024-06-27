class Measurement {
  Map<String,dynamic>?  values;
  String type="";

  Measurement(this.values,this.type);

  Measurement.fromJson(dynamic json) {
    values = json['values'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['values'] = values;
    map['type'] = type;
    return map;
  }
}
