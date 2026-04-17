class Chapter {
  Chapter({
    this.id,
    this.name,
    this.status,
    this.avgRating,
  });

  Chapter.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    avgRating = json['score'];  // ✅ FIXED: Changed from 'avg_rating' to 'score'
  }

  int? id;
  String? name;
  String? status;
  int  ? avgRating;  // ✅ IMPROVED: Changed from 'dynamic' to 'int?' for type safety

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['status'] = status;
    map['score'] = avgRating;  // ✅ FIXED: Changed from 'avg_rating' to 'score'
    return map;
  }
}