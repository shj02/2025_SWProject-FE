import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sw_project_fe/config/api_config.dart';
import 'package:sw_project_fe/models/user_profile.dart';
import 'package:sw_project_fe/screens/login_screen.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void _log(String message) {
    debugPrint('[AuthService] $message');
  }

  Future<void> _handleUnauthorized(BuildContext context) async {
    await deleteToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<LoginResponse> loginWithKakao(String kakaoAccessToken) async {
    final url = Uri.parse('$baseUrl/api/auth/kakao');
    _log('🚀 카카오 로그인 요청: POST $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': kakaoAccessToken}),
      );

      _log('✅ 카카오 로그인 응답: ${response.statusCode}');
      _log('   - Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final loginResponse = LoginResponse.fromJson(data);
        await _saveToken(loginResponse.token);
        _log('   -> JWT 토큰 저장 완료, isRegistered: ${loginResponse.isRegistered}');
        return loginResponse;
      } else {
        throw Exception('카카오 로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 카카오 로그인 중 오류: $e');
      rethrow;
    }
  }

  Future<void> signUp(Map<String, String> profileData) async {
    final token = await getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/users/me/profile/initial');
    _log('🚀 회원가입 요청: POST $url');
    _log('   - Body: ${jsonEncode(profileData)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(profileData),
      );
      _log('✅ 회원가입 응답: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
      }
      _log('   -> 회원가입 성공');
    } catch(e) {
      _log('❌ 회원가입 중 오류: $e');
      rethrow;
    }
  }

  Future<void> completeStyles(List<String> styles) async {
    final token = await getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/users/me/styles/complete');
    _log('🚀 여행 스타일 저장 요청: PUT $url');
    _log('   - Body: ${jsonEncode({'travelStyles': styles})}');
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'travelStyles': styles}),
      );
      _log('✅ 여행 스타일 저장 응답: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
      }
      _log('   -> 여행 스타일 저장 성공');
    } catch(e) {
      _log('❌ 여행 스타일 저장 중 오류: $e');
      rethrow;
    }
  }

  Future<UserProfile> getProfile(BuildContext context) async {
    final token = await getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/users/me');
    _log('🚀 프로필 정보 요청: GET $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      _log('✅ 프로필 정보 응답: ${response.statusCode}');
      _log('   - Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        _log('   -> 프로필 파싱 성공');
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        _log('❌ 프로필 정보 요청 실패: 401 Unauthorized');
        await _handleUnauthorized(context);
        throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('실패: ${response.statusCode}');
      }
    } catch(e) {
      _log('❌ 프로필 정보 요청 중 오류: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(BuildContext context, Map<String, String> profileData) async {
    final token = await getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/users/me/profile');
    _log('🚀 프로필 수정 요청: PUT $url');
    _log('   - Body: ${jsonEncode(profileData)}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(profileData),
      );
      _log('✅ 프로필 수정 응답: ${response.statusCode}');
      if (response.statusCode == 401) {
        _log('❌ 프로필 수정 실패: 401 Unauthorized');
        await _handleUnauthorized(context);
        throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
      } else if (response.statusCode != 200) {
        throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
      }
      _log('   -> 프로필 수정 성공');
    } catch(e) {
      _log('❌ 프로필 수정 중 오류: $e');
      rethrow;
    }
  }
  
  Future<void> clearSession() async {
    final token = await getToken();
    if (token != null) {
      final url = Uri.parse('$baseUrl/api/auth/logout');
      _log('🚀 로그아웃 요청 (세션 정리): POST $url');
      try {
        await http.post(url, headers: {'Authorization': 'Bearer $token'});
        _log('✅ 서버 로그아웃 성공 (세션 정리)');
      } catch (e) {
        _log('❌ 서버 로그아웃 실패 (무시함): $e');
      }
    }
    await deleteToken(); // 클라이언트 토큰 삭제
  }


  Future<void> logout(BuildContext context) async {
    await clearSession(); // 세션 정리
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _saveToken(String token) async {
    if (token.isEmpty) {
      _log('❌ 저장하려는 JWT 토큰이 비어있습니다. 백엔드 응답을 확인해주세요.');
      throw Exception('서버로부터 유효한 토큰을 받지 못했습니다.');
    }
    await _storage.write(key: 'jwt_token', value: token);
    _log('🔑 JWT 토큰이 SecureStorage에 저장되었습니다.');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
    _log('🔑 SecureStorage의 JWT 토큰이 삭제되었습니다.');
  }
}

class LoginResponse {
  final String token;
  final int userId;
  final bool isRegistered;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.isRegistered,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? 0,
      isRegistered: json['registered'] ?? false,
    );
  }
}
