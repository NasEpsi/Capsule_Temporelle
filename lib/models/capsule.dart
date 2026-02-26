class Capsule {
  final int id;
  final int creatorUserId;
  final String title;
  final String? description;
  final DateTime unlockAt;
  final String requiredSky;
  final String? memberRole;

  Capsule({
    required this.id,
    required this.creatorUserId,
    required this.title,
    this.description,
    required this.unlockAt,
    required this.requiredSky,
    this.memberRole
  });

  factory Capsule.fromJson(Map<String, dynamic> json) => Capsule(
    id: json['id'] as int,
    creatorUserId: json['creator_user_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    unlockAt: DateTime.parse(json['unlock_at'] as String),
    requiredSky: json['required_sky'] as String,
    memberRole: json['member_role'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator_user_id': creatorUserId,
    'title': title,
    'description': description,
    'unlock_at': unlockAt.toIso8601String(),
    'required_sky': requiredSky,
    'member_role':memberRole
  };

  bool get canWrite => memberRole != "BENEFICIARY";

  String get roleLabelFr {
    switch (memberRole) {
      case "OWNER":
        return "créateur";
      case "CONTRIBUTOR":
        return "contributeur";
      case "BENEFICIARY":
        return "bénéficiaire";
      default:
        return "membre";
    }
  }
}