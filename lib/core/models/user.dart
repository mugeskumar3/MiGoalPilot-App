class User {
  final String id;
  final String name;
  final String email;
  final String? partnerId;
  final String? phone;
  final String? country;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.partnerId,
    this.phone,
    this.country,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? partnerId,
    String? phone,
    String? country,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      partnerId: partnerId ?? this.partnerId,
      phone: phone ?? this.phone,
      country: country ?? this.country,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      partnerId: json['partnerId'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'partnerId': partnerId,
        'phone': phone,
        'country': country,
      };
}
