class LocationModel {
  final String state;
  final String district;
  final String tehsil;

  LocationModel({
    required this.state,
    required this.district,
    required this.tehsil,
  });

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'district': district,
      'tehsil': tehsil,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      tehsil: map['tehsil'] ?? '',
    );
  }

  String get fullAddress => '$tehsil, $district, $state';
}
