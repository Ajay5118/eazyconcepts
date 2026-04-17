import 'package:threedotspiano/ui/courses/m/chapter.dart';

import 'module.dart';

class ChapterResponse {
  ChapterResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  ChapterResponse.fromJson(dynamic json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Chapter.fromJson(v));
      });
    }
  }

  int? count;
  dynamic next;
  dynamic previous;
  List<Chapter>? results;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    map['next'] = next;
    map['previous'] = previous;
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// ✅ NOTE: This Results class appears to be unused
// The actual Chapter model is in chapter.dart
// If you need this class, consider renaming it to avoid confusion
class Results {
  Results({
    this.id,
    this.name,
    this.order,
    this.path,
    this.logo,
    this.description,
    this.status,
    this.score,
  });

  Results.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    order = json['order'];
    path = json['path'];
    logo = json['logo'];
    description = json['description'];
    status = json['status'];
    score = json['score'];  // Already correct here
  }

  int? id;
  String? name;
  int? order;
  int? path;
  dynamic logo;
  String? description;
  String? status;
  dynamic score;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['order'] = order;
    map['path'] = path;
    map['logo'] = logo;
    map['description'] = description;
    map['status'] = status;
    map['score'] = score;
    return map;
  }
}