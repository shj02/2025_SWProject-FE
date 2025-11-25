import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sw_project_fe/config/api_config.dart';
import 'package:sw_project_fe/models/checklist.dart';
import 'package:sw_project_fe/models/itinerary.dart';
import 'package:sw_project_fe/models/trip.dart';
import 'package:sw_project_fe/models/trip_date.dart';
import 'package:sw_project_fe/services/auth_api.dart';

class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  void _log(String message) {
    debugPrint('[TripService] $message');
  }

  /// =============================
  ///  API 1: 내 여행 목록 조회
  /// =============================
  Future<List<TripSummary>> getMyTrips() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/users/me/trips'); // 🔥 수정됨
    _log('🚀 내 여행 목록 조회 요청: GET $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      _log('✅ 내 여행 목록 조회 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => TripSummary.fromJson(json)).toList();
      } else {
        _log('❌ 내 여행 목록 조회 실패: ${response.body}');
        throw Exception('내 여행 목록을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 내 여행 목록 조회 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 2: 여행 상세 정보 조회
  /// =============================
  Future<TripDetail> getTripById(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId');
    _log('🚀 여행 상세 정보 요청: GET $url');

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      _log('✅ 여행 상세 정보 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        return TripDetail.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load trip details: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 상세 정보 조회 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 3: 여행 생성 (백엔드 기준으로 필드 수정됨)
  /// =============================
  Future<TripCreationInfo> createTrip(String title, String startDate, String endDate) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips');
    _log('🚀 여행 생성 요청: POST $url');

    final body = jsonEncode({
      'name': title, // 🔥 수정됨 (backend: name)
      'destination': '', // 🔥 FE 임시 값 (나중에 목적지 입력기능 연결)
      'startDate': startDate,
      'endDate': endDate,
    });

    _log('   - Body: $body');

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: body);

      _log('✅ 여행 생성 응답: ${response.statusCode}');

      if (response.statusCode == 201) {
        return TripCreationInfo.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        _log('❌ 여행 생성 실패: ${response.body}');
        throw Exception('Failed to create trip: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 생성 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 4: 여행 참여
  /// =============================
  Future<void> joinTrip(String inviteCode) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/join');
    _log('🚀 여행 참가 요청: POST $url');

    final body = jsonEncode({'inviteCode': inviteCode});

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: body);

      _log('✅ 여행 참가 응답: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to join trip: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 참가 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 5: 여행 삭제
  /// =============================
  Future<void> deleteTrip(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId');
    _log('🚀 여행 삭제 요청: DELETE $url');

    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

      _log('✅ 여행 삭제 응답: ${response.statusCode}');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete trip: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 삭제 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 7: 여행 일정 조회
  /// =============================
  Future<List<Itinerary>> getItinerary(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/itineraries');
    _log('🚀 여행 일정 조회 요청: GET $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      _log('✅ 여행 일정 조회 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Itinerary.fromJson(json)).toList();
      } else {
        _log('❌ 여행 일정 조회 실패: ${response.body}');
        throw Exception('여행 일정을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 일정 조회 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 14: 날짜 투표 현황 조회
  /// =============================
  Future<DateStatus> getDateStatus(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/dates/status');
    _log('🚀 날짜 투표 현황 조회 요청: GET $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      _log('✅ 날짜 투표 현황 조회 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        return DateStatus.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        _log('❌ 날짜 투표 현황 조회 실패: ${response.body}');
        throw Exception('날짜 투표 현황을 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 날짜 투표 현황 조회 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 15: 가능한 날짜 업데이트
  /// =============================
  Future<void> updateAvailableDates(int tripId, List<Map<String, String>> dates) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/dates');
    _log('🚀 가능한 날짜 업데이트 요청: POST $url');
    _log('   - Body: ${jsonEncode(dates)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'availableDates': dates}),
      );

      _log('✅ 가능한 날짜 업데이트 응답: ${response.statusCode}');

      if (response.statusCode != 200) {
        _log('❌ 가능한 날짜 업데이트 실패: ${response.body}');
        throw Exception('가능한 날짜 업데이트에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 가능한 날짜 업데이트 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 16: 여행 날짜 확정
  /// =============================
  Future<void> confirmDate(int tripId, String startDate, String endDate) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/dates/confirm');
    _log('🚀 여행 날짜 확정 요청: POST $url');
    _log('   - Body: ${jsonEncode({'startDate': startDate, 'endDate': endDate})}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      _log('✅ 여행 날짜 확정 응답: ${response.statusCode}');

      if (response.statusCode != 200) {
        _log('❌ 여행 날짜 확정 실패: ${response.body}');
        throw Exception('여행 날짜 확정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 여행 날짜 확정 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 17: 체크리스트 조회
  /// =============================
  Future<Checklist> getChecklists(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/checklists');
    _log('🚀 체크리스트 조회 요청: GET $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      _log('✅ 체크리스트 조회 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Checklist.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        _log('❌ 체크리스트 조회 실패: ${response.body}');
        throw Exception('체크리스트를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 체크리스트 조회 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 18: 체크리스트 항목 생성
  /// =============================
  Future<ChecklistItem> createChecklistItem(int tripId, Map<String, dynamic> data) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/checklists');
    _log('🚀 체크리스트 항목 생성 요청: POST $url');
    _log('   - Body: ${jsonEncode(data)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      _log('✅ 체크리스트 항목 생성 응답: ${response.statusCode}');

      if (response.statusCode == 201) {
        return ChecklistItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        _log('❌ 체크리스트 항목 생성 실패: ${response.body}');
        throw Exception('체크리스트 항목 생성에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 체크리스트 항목 생성 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 19: 체크리스트 항목 완료/미완료 처리
  /// =============================
  Future<void> toggleChecklistCompletion(int checklistItemId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/checklists/$checklistItemId');
    _log('🚀 체크리스트 항목 상태 변경 요청: PATCH $url');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('✅ 체크리스트 항목 상태 변경 응답: ${response.statusCode}');

      if (response.statusCode != 200) {
        _log('❌ 체크리스트 항목 상태 변경 실패: ${response.body}');
        throw Exception('체크리스트 항목 상태 변경에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 체크리스트 항목 상태 변경 중 오류: $e');
      rethrow;
    }
  }

  /// =============================
  ///  API 20: 체크리스트 항목 삭제
  /// =============================
  Future<void> deleteChecklistItem(int checklistItemId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/checklists/$checklistItemId');
    _log('🚀 체크리스트 항목 삭제 요청: DELETE $url');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      _log('✅ 체크리스트 항목 삭제 응답: ${response.statusCode}');

      if (response.statusCode != 204) {
        _log('❌ 체크리스트 항목 삭제 실패: ${response.body}');
        throw Exception('체크리스트 항목 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ 체크리스트 항목 삭제 중 오류: $e');
      rethrow;
    }
  }
}
