import 'module.dart';

class ModuleResponse {
  ModuleResponse({
      this.count, 
      this.next, 
      this.previous, 
      this.results,});

  ModuleResponse.fromJson(dynamic json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Module.fromJson(v));
      });
    }
  }
  int? count;
  dynamic next;
  dynamic previous;
  List<Module>? results;

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

class Results {
  Results({
      this.id, 
      this.name, 
      this.order, 
      this.path, 
      this.logo, 
      this.description, 
      this.status, 
      this.score,});

  Results.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    order = json['order'];
    path = json['path'];
    logo = json['logo'];
    description = json['description'];
    status = json['status'];
    score = json['score'];
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