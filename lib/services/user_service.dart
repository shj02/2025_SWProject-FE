import 'dart:convert';
import 'package:http/http.dart' as http;

// --- 💡 Base URL 설정 ---
// 에뮬레이터일 때: const baseUrl = 'http://10.0.2.2:8080';
// 물리 기기(실제 휴대폰)일 때: PC IP로 바꿔야 함!! 예: 192.168.0.10
// const String baseUrl = 'http://10.0.2.2:8080'; // 에뮬레이터 쓸 땐 이대로
const String baseUrl = 'http://192.168.0.23:8080';


class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _userName;
  String? get userName => _userName;

  void setUserName(String name) {
    _userName = name;
  }

  void clearUserName() {
    _userName = null;
  }

  /// 소셜 로그인 시, 백엔드 서버에 accessToken 전송
  Future<bool> attemptSocialLogin(String provider, String token) async {
    late final Uri url;

    if (provider == 'KAKAO') {
      url = Uri.parse('$baseUrl/api/auth/kakao');
    } else if (provider == 'NAVER') {
      url = Uri.parse('$baseUrl/api/auth/naver');
    } else {
      print('[UserService] Unknown provider: $provider');
      return false;
    }

    print('[UserService] POST $url');
    print('[UserService] body: {"accessToken": "$token"}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accessToken': token,
        }),
      );

      print('[UserService] status: ${response.statusCode}');
      print('[UserService] response: ${response.body}');

      if (response.statusCode == 200) {
        // TODO: 여기서 응답(JSON)을 파싱해서 JWT/userId/isRegistered 저장 가능
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('[UserService] 네트워크 오류: $e');
      return false;
    }
  }
}
