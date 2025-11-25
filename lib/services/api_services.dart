import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sw_project_fe/models/post.dart';
import 'package:sw_project_fe/models/post_detail.dart';
import 'package:sw_project_fe/services/auth_api.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void _log(String message) {
    debugPrint('[ApiService] $message');
  }

  /// 전체 게시글 목록을 가져오는 API
  Future<List<Post>> getPosts() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/community/posts'); // 수정된 실제 주소
    _log('🚀 전체 게시글 목록 요청: GET $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
      );
      _log('✅ 전체 게시글 목록 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 백엔드 응답이 PostListResponse 형태이므로, 'posts' 키에서 목록을 추출해야 함
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> postList = data['posts'] ?? [];
        _log('   -> 게시글 ${postList.length}개 수신 성공');
        return postList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('게시글 목록 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 전체 게시글 목록 요청 중 오류: $e');
      rethrow;
    }
  }

  /// 특정 ID의 게시글 상세 정보를 가져오는 API
  Future<PostDetail> getPostDetail(int postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/community/posts/$postId'); // 수정된 실제 주소
    _log('🚀 게시글 상세 정보 요청: GET $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
      );
      _log('✅ 게시글 상세 정보 응답: ${response.statusCode}');
      _log('   - Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        _log('   -> 게시글 상세 정보 파싱 성공');
        return PostDetail.fromJson(data);
      } else {
        throw Exception('게시글 상세 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 게시글 상세 정보 요청 중 오류: $e');
      rethrow;
    }
  }

  /// 새로운 게시글을 생성하는 API
  Future<void> createPost(String title, String content) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/community/posts'); // 수정된 실제 주소
    final body = {'title': title, 'content': content};
    _log('🚀 게시글 생성 요청: POST $url');
    _log('   - Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      _log('✅ 게시글 생성 응답: ${response.statusCode}');
      if (response.statusCode != 201) {
        throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
      }
      _log('   -> 게시글 생성 성공');
    } catch (e) {
      _log('❌ 게시글 생성 중 오류: $e');
      rethrow;
    }
  }

  /// 게시글 좋아요 토글 API
  Future<void> toggleLike(int postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/community/posts/$postId/like'); // 수정된 실제 주소
    _log('🚀 게시글 좋아요 토글 요청: POST $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
      );
      _log('✅ 게시글 좋아요 토글 응답: ${response.statusCode}');
      _log('   - Response Body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('실패: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 게시글 좋아요 토글 중 오류: $e');
      rethrow;
    }
  }

  /// 새로운 댓글을 작성하는 API
  Future<void> createComment(int postId, String content) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/community/posts/$postId/comments'); // 수정된 실제 주소
    final body = {'content': content};
    _log('🚀 댓글 작성 요청: POST $url');
    _log('   - Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      _log('✅ 댓글 작성 응답: ${response.statusCode}');
      if (response.statusCode != 201) {
        throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
      }
      _log('   -> 댓글 작성 성공');
    } catch (e) {
      _log('❌ 댓글 작성 중 오류: $e');
      rethrow;
    }
  }
}
