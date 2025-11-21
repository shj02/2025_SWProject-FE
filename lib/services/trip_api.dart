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

  // --- Trip Management (방 생성, 참여, 목록, 삭제) ---

  Future<TripCreationInfo> createTrip(String tripName, String destination) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/trips');
    final body = {'name': tripName, 'destination': destination}; // 백엔드 DTO 필드명('name')에 맞춤
    _log('🚀 여행 방 생성 요청: POST $url\n   - Body: ${jsonEncode(body)}');

    final response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(body));
    _log('✅ 여행 방 생성 응답: ${response.statusCode}');

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return TripCreationInfo.fromJson(data);
    } else {
      throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> joinTrip(String inviteCode) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/trips/join/$inviteCode');
    _log('🚀 여행 참여 요청: POST $url');

    final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 여행 참여 응답: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('실패: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<List<TripSummary>> getMyTrips() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/users/me/trips');
    _log('🚀 내 여행 목록 요청: GET $url');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 내 여행 목록 응답: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => TripSummary.fromJson(json)).toList();
    } else {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  Future<void> deleteTrip(int tripId) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');

    final url = Uri.parse('$baseUrl/api/trips/$tripId');
    _log('🚀 여행 방 삭제 요청: DELETE $url');

    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 여행 방 삭제 응답: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  // --- Date Planning ---

  Future<DateStatus> getDateStatus(int tripId) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');
    final url = Uri.parse('$baseUrl/api/trips/$tripId/date-status');
    _log('🚀 날짜 합의 현황 요청: GET $url');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 날짜 합의 현황 응답: ${response.statusCode}');
    if (response.statusCode == 200) {
      return DateStatus.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  Future<void> updateAvailableDates(int tripId, List<Map<String, String>> dates) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');
    final url = Uri.parse('$baseUrl/api/trips/$tripId/available-dates');
    final body = {'availableDateRequests': dates};
    _log('🚀 가능 날짜 수정 요청: PUT $url\n   - Body: ${jsonEncode(body)}');
    final response = await http.put(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(body));
    _log('✅ 가능 날짜 수정 응답: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  Future<void> confirmDate(int tripId, String startDate, String endDate) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('인증 토큰이 없습니다.');
    final url = Uri.parse('$baseUrl/api/trips/$tripId/date-confirm');
    final body = {'startDate': startDate, 'endDate': endDate};
    _log('🚀 여행 날짜 확정 요청: PUT $url\n   - Body: ${jsonEncode(body)}');
    final response = await http.put(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(body));
    _log('✅ 여행 날짜 확정 응답: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  // --- Itinerary ---

  Future<List<Itinerary>> getItinerary(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/itinerary');
    _log('🚀 일정표 조회 요청: GET $url');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 일정표 조회 응답: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> itineraryList = data['itineraries'] ?? [];
      return itineraryList.map((json) => Itinerary.fromJson(json)).toList();
    } else {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  Future<void> createItineraryItem(int tripId, Map<String, dynamic> itemData) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/itinerary');
    _log('🚀 새 일정 추가 요청: POST $url\n   - Body: ${jsonEncode(itemData)}');
    final response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(itemData));
    _log('✅ 새 일정 추가 응답: ${response.statusCode}');
    if (response.statusCode != 201) throw Exception('실패: ${response.statusCode}');
  }

  Future<void> updateItineraryItem(int itemId, Map<String, dynamic> itemData) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/itinerary/$itemId');
    _log('🚀 일정 수정 요청: PUT $url\n   - Body: ${jsonEncode(itemData)}');
    final response = await http.put(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(itemData));
    _log('✅ 일정 수정 응답: ${response.statusCode}');
    if (response.statusCode != 200) throw Exception('실패: ${response.statusCode}');
  }

  Future<void> deleteItineraryItem(int itemId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/itinerary/$itemId');
    _log('🚀 일정 삭제 요청: DELETE $url');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 일정 삭제 응답: ${response.statusCode}');
    if (response.statusCode != 204) throw Exception('실패: ${response.statusCode}');
  }

  // --- Checklist ---

  Future<Checklist> getChecklists(int tripId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/checklists');
    _log('🚀 체크리스트 조회 요청: GET $url');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 체크리스트 조회 응답: ${response.statusCode}');
    if (response.statusCode == 200) {
      return Checklist.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('실패: ${response.statusCode}');
    }
  }

  Future<void> createChecklistItem(int tripId, Map<String, dynamic> itemData) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/trips/$tripId/checklists');
    _log('🚀 체크리스트 항목 추가 요청: POST $url\n   - Body: ${jsonEncode(itemData)}');
    final response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(itemData));
    _log('✅ 체크리스트 항목 추가 응답: ${response.statusCode}');
    if (response.statusCode != 201) throw Exception('실패: ${response.statusCode}');
  }

  Future<void> toggleChecklistCompletion(int itemId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/checklists/$itemId/toggle');
    _log('🚀 체크리스트 토글 요청: PUT $url');
    final response = await http.put(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 체크리스트 토글 응답: ${response.statusCode}');
    if (response.statusCode != 200) throw Exception('실패: ${response.statusCode}');
  }

  Future<void> deleteChecklistItem(int itemId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/api/checklists/$itemId');
    _log('🚀 체크리스트 항목 삭제 요청: DELETE $url');
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    _log('✅ 체크리스트 항목 삭제 응답: ${response.statusCode}');
    if (response.statusCode != 204) throw Exception('실패: ${response.statusCode}');
  }
}
