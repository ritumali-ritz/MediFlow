import 'location_model.dart';

class ClinicModel {
  final String id;
  final String name;
  final String address;
  final LocationModel location;
  final List<String> doctorIds;
  final String ownerId;
  final List<String> departmentIds;
  final Map<String, List<String>> departmentDoctors; // deptId -> [doctorIds]

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.doctorIds,
    required this.ownerId,
    this.departmentIds = const [],
    this.departmentDoctors = const {},
  });

  factory ClinicModel.fromMap(Map<String, dynamic> map, String id) {
    return ClinicModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      location: map['location'] != null 
          ? LocationModel.fromMap(map['location'])
          : LocationModel(state: '', district: '', tehsil: ''),
      doctorIds: List<String>.from(map['doctorIds'] ?? []),
      ownerId: map['ownerId'] ?? '',
      departmentIds: List<String>.from(map['departmentIds'] ?? []),
      departmentDoctors: Map<String, List<String>>.from(
        (map['departmentDoctors'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'location': location.toMap(),
      'doctorIds': doctorIds,
      'ownerId': ownerId,
      'departmentIds': departmentIds,
      'departmentDoctors': departmentDoctors,
    };
  }
}
