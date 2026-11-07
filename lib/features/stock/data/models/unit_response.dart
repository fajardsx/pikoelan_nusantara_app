class UnitResponse {
  final int id;
  final String name;

  UnitResponse({required this.id, required this.name});

  factory UnitResponse.fromJson(Map<String, dynamic> json) => UnitResponse(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}