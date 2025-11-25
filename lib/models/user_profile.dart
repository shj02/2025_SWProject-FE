class UserProfile {
  final String name;
  final String phoneNumber;
  final String gender;
  final String birthdate;
  final String nationality;
  final String email; // 이메일은 예시이며, 실제 서버 응답에 따라 추가/삭제
  final List<String> travelStyles;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.birthdate,
    required this.nationality,
    required this.email,
    required this.travelStyles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      gender: json['gender'] ?? '',
      birthdate: json['birthdate'] ?? '',
      nationality: json['nationality'] ?? '',
      email: json['email'] ?? '', // 서버 응답에 email이 없다면 이 부분은 삭제해야 합니다.
      travelStyles: List<String>.from(json['travelStyles'] ?? []),
    );
  }
}
