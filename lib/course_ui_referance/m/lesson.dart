class Lesson {
  Lesson({
    this.id,
    this.type,
    this.name,
    this.status,
    this.rating,
  });

  Lesson.fromJson(dynamic json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    status = json['status'].toString();
    rating = json['rating'];
  }
  int? id;
  String? type;
  String? name;
  String? status;
  dynamic rating;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['type'] = type;
    map['name'] = name;
    map['status'] = status;
    map['rating'] = rating;
    return map;
  }
}
