class Capsule {
  final int id;
  final int creatorUserId;
  final String title;
  final String? description;
  final DateTime unlockAt;
  final String requiredSky;

  Capsule({
    required this.id,
    required this.creatorUserId,
    required this.title,
    this.description,
    required this.unlockAt,
    required this.requiredSky,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) => Capsule(
    id: json['id'] as int,
    creatorUserId: json['creator_user_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    unlockAt: DateTime.parse(json['unlock_at'] as String),
    requiredSky: json['required_sky'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator_user_id': creatorUserId,
    'title': title,
    'description': description,
    'unlock_at': unlockAt.toIso8601String(),
    'required_sky': requiredSky,
  };
}