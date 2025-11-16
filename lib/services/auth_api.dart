import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // 에뮬레이터에서 로컬 서버 쓰면:
  //  - Android: http://10.0.2.2:8080
  //  - iOS 시뮬레이터: http://localhost:8080
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<LoginResponse> loginWithKakao(String kakaoAccessToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/kakao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': kakaoAccessToken}),
    );

    if (res.statusCode != 200) {
      throw Exception('카카오 로그인 실패: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return LoginResponse.fromJson(data);
  }

  static Future<LoginResponse> loginWithNaver(String naverAccessToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/naver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': naverAccessToken}),
    );

    if (res.statusCode != 200) {
      throw Exception('네이버 로그인 실패: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return LoginResponse.fromJson(data);
  }
}

class LoginResponse {
  final String token;        // 백엔드에서 주는 JWT
  final int userId;
  final bool isRegistered;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.isRegistered,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as int,
      isRegistered: json['isRegistered'] as bool,
    );
  }
}
