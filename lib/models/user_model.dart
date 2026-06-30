// lib/models/user_model.dart

class UserModel {
  final String uid;       // Firebase UID
  final String email;
  final String name;
  String nim;
  String prodi;
  String? photoPath;       // path lokal foto profil (dari kamera)

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.nim = '',
    this.prodi = '',
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'nim': nim,
      'prodi': prodi,
      'photoPath': photoPath,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      nim: map['nim'] ?? '',
      prodi: map['prodi'] ?? '',
      photoPath: map['photoPath'],
    );
  }

  UserModel copyWith({
    String? name,
    String? nim,
    String? prodi,
    String? photoPath,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      prodi: prodi ?? this.prodi,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
