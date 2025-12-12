class DepartmentModel {
  final String id;
  final String name;
  final String icon; // Material icon name or emoji

  DepartmentModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🏥',
    );
  }
}
