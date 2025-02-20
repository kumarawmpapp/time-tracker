class Project {
  final String id;
  final String name;
  final bool isDefault; // To identify if it's a system default or user-added

  Project({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

   factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],    
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,  
    };
  }
}