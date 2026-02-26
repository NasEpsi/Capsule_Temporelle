class User {
  final int id;
  final String name;
  final String? email;
  final String? status;

  User({
    required this.id,
    required this.name,
    this.email,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String?,
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'status': status,
  };
}