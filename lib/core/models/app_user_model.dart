import 'dart:convert';

class AppUserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  const AppUserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'lastActive': DateTime.now().toIso8601String(),
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    final email = (map['email'] as String?) ?? '';
    final defaultName = email.isNotEmpty ? email.split('@').first : 'User';

    return AppUserModel(
      uid: (map['uid'] as String?) ?? id ?? '',
      displayName: (map['displayName'] as String?)?.isNotEmpty == true
          ? map['displayName'] as String
          : defaultName,
      email: email,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUserModel.fromJson(String source) =>
      AppUserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

