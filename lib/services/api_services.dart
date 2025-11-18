// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
// 프로젝트 이름: sw_project_fe
import 'package:sw_project_fe/constants/api_config.dart';


class ApiService {

  // 게시글 목록을 가져오는 예시 함수
  Future<Map<String, dynamic>?> fetchPostList() async {
    // 👇 BASE_URL 상수를 사용하여 URL을 만듭니다.
    final url = Uri.parse('$BASE_URL/api/v1/posts');

    try {
      // ⚠️ 이전에 pubspec.yaml에 http 패키지를 추가하고 'flutter pub get'을 실행했는지 확인하세요!
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('연동 성공! 데이터: $data');
        return data;
      } else {
        print('서버 오류 발생: 상태 코드 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('네트워크 연결 실패: $e');
      print('백엔드 서버(IntelliJ)가 실행 중인지 확인해 주세요.');
      return null;
    }
  }
}