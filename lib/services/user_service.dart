// lib/services/user_service.dart

class UserService {
  // 싱글톤
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // ---------------------------
  // 1) 백엔드 인증 관련 (기존 기능)
  // ---------------------------

  String? _jwtToken;   // 서버에서 내려준 JWT
  int? _userId;        // 서버 DB의 숫자 userId

  void setAuthToken(String token) {
    _jwtToken = token;
  }

  String? get authToken => _jwtToken;

  void setUserId(int id) {
    _userId = id;
  }

  int? get userId => _userId;

  // -----------------------------------
  // 2) 앱에서 표시용으로 쓰는 프로필 정보 (프론트 전용)
  // -----------------------------------

  // "아이디" (이메일처럼 보이는 값) - 서버와는 전혀 안 묶임
  String? _accountId;

  // 이름 / 전화번호 / 생년월일 / 국적
  String? _userName;
  String? _phoneNumber;
  String? _birthdate;
  String? _nationality;

  // 마이페이지 이메일 (카카오 이메일 X, 사용자가 직접 입력한 값)
  String? _email;

  // ---- accountId / 이메일(아이디) ----
  void setAccountId(String? id) {
    _accountId = id;
  }

  String? get accountId => _accountId;

  void setEmail(String? email) {
    _email = email;
  }

  String? get email => _email;

  // ---- 이름 / 전화번호 / 생년월일 / 국적 ----
  void setUserName(String name) {
    _userName = name;
  }

  String? get userName => _userName;

  void setPhoneNumber(String? phone) {
    _phoneNumber = phone;
  }

  String? get phoneNumber => _phoneNumber;

  void setBirthdate(String? birth) {
    _birthdate = birth;
  }

  String? get birthdate => _birthdate;

  void setNationality(String? nation) {
    _nationality = nation;
  }

  String? get nationality => _nationality;

  // ---------------------------
  // 3) 전체 리셋 (로그아웃 시)
  // ---------------------------

  void clear() {
    _jwtToken = null;
    _userId = null;

    _accountId = null;
    _userName = null;
    _phoneNumber = null;
    _birthdate = null;
    _nationality = null;
    _email = null;
  }
}
