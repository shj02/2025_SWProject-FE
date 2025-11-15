import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final double scale;
  final List<Map<String, dynamic>> tripList;
  final VoidCallback onHideSidebar;
  final VoidCallback onCreateNewPlan;
  final Function(String) onEnterTripRoom;
  final Function(String) onShowDeleteModal;

  const Sidebar({
    super.key,
    required this.scale,
    required this.tripList,
    required this.onHideSidebar,
    required this.onCreateNewPlan,
    required this.onEnterTripRoom,
    required this.onShowDeleteModal,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 314 * scale,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF5F5),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              Padding(
                padding: EdgeInsets.only(
                  top: 34 * scale,
                  left: 24 * scale,
                  right: 24 * scale,
                  bottom: 20 * scale,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                       '나의 여행',
                       style: TextStyle(
                         fontSize: 32 * scale,
                         color: const Color(0xFF1A0802),
                         fontWeight: FontWeight.w400,
                       ),
                     ),
                    GestureDetector(
                      onTap: onHideSidebar,
                      child: Image.asset(
                        'assets/icons/menu.png',
                        width: 35 * scale,
                        height: 35 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 여행 목록 (스크롤 가능)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(), // iOS 스타일 스크롤
                    itemCount: tripList.length,
                    itemBuilder: (context, index) {
                      final trip = tripList[index];
                      return _buildTripCard(trip, scale);
                    },
                  ),
                ),
              ),
              
              // 새로운 계획 만들기 버튼
              Padding(
                padding: EdgeInsets.all(24 * scale),
                child: GestureDetector(
                  onTap: () {
                    onHideSidebar();
                    onCreateNewPlan();
                  },
                  child: Container(
                    width: 274 * scale,
                    height: 65 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8282),
                      borderRadius: BorderRadius.circular(12 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x40000000), // 25% 투명도의 검은색
                          offset: Offset(4, 4 * scale), // 아래쪽으로만 그림자
                          blurRadius: 4 * scale, // 더 부드러운 그림자
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                        BoxShadow(
                          color: const Color(0x1A000000), // 10% 투명도의 검은색 (추가 그림자)
                          offset: Offset(0, 2 * scale),
                          blurRadius: 4 * scale,
                          spreadRadius: 0,
                        ),
                      ],
                    ),

                    child: Center(
                      child:
                      Text(
                         '새로운 계획 만들기',
                         style: TextStyle(
                           fontSize: 24 * scale,
                           color: Colors.white,
                           fontWeight: FontWeight.w400,
                         ),
                       ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 여행 카드 위젯
  Widget _buildTripCard(Map<String, dynamic> trip, double scale) {
    return GestureDetector(
      onTap: () => onEnterTripRoom(trip['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: const Color(0xFF1A0802).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 여행 정보 헤더 (제목과 휴지통)
            Padding(
              padding: EdgeInsets.only(top: 14 * scale, left: 13 * scale, right: 13 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      trip['name'],
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: const Color(0xFF1A0802),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onShowDeleteModal(trip['id']),
                    child: Image.asset(
                      'assets/icons/trash.png',
                      width: 20 * scale,
                      height: 20 * scale,
                    ),
                  ),
                ],
              ),
            ),

            // 날짜 및 참가자 정보
            Padding(
              padding: EdgeInsets.only(
                top: 6 * scale,
                left: 13 * scale,
                right: 13 * scale,
              ),
              child: Row(
                children: [
                  Container(
                    child: Image.asset(
                      'assets/icons/date.png',
                      width: 20 * scale,
                      height: 20 * scale,
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    trip['date'],
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 20 * scale),
                  Container(
                    child: Image.asset(
                      'assets/icons/group.png',
                      width: 20 * scale,
                      height: 20 * scale,
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    '${trip['participants']}명',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  // 방 코드
                  Text(
                    trip['code'],
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 진행률 정보
            Padding(
              padding: EdgeInsets.only(
                top: 7 * scale,
                left: 13 * scale,
                right: 13 * scale,
              ),
              child: Row(
                children: [
                  Text(
                    '여행 계획 진행률',
                    style: TextStyle(
                      fontSize: 11.6 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trip['progress']}%',
                    style: TextStyle(
                      fontSize: 11.6 * scale,
                      color: const Color(0xFF1A0802),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            // 진행률 바 (메인화면과 동일한 스타일)
            Padding(
              padding: EdgeInsets.only(
                top: 6 * scale,
                left: 13 * scale,
                right: 13 * scale,
                bottom: 13 * scale,
              ),
              // Stack을 사용하여 배경과 진행률 바를 겹치도록 수정합니다.
              child: Stack(
                children: [
                  // 1. 배경 바 (색상: F0F3F8)
                  Container(
                    height: 9.7 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F8), // 요청하신 배경색입니다.
                      borderRadius: BorderRadius.circular(2.3 * scale),
                      border: Border.all(
                        color: const Color(0xFF979797).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  // 2. 실제 진행률을 나타내는 바
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    // 진행률이 0일 때 0.01 (1%)로, 그 외에는 실제 값으로 설정
                    widthFactor: (trip['progress'] == 0) ? 0.01 : (trip['progress'] / 100),
                    child: Container(
                      height: 9.7 * scale, // 배경과 동일한 높이
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8282),
                        borderRadius: BorderRadius.circular(2.3 * scale),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
