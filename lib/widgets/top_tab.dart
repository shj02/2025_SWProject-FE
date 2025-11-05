import 'package:flutter/material.dart';

class TopTab extends StatelessWidget {
  final String title;
  final int participantCount;
  final String dDay;
  final Color? backgroundColor;
  final Color? dDayBackgroundColor;

  const TopTab({
    Key? key,
    required this.title,
    required this.participantCount,
    required this.dDay,
    this.backgroundColor,
    this.dDayBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    const double containerHeight = 135;

    return Container(
      width: double.infinity,
      height: containerHeight * scale,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(),
      ),
      child: Stack(
        children: [
          // D-Day 배경
          Positioned(
            left: (402 - 99 - 15) * scale,
            top: ((containerHeight - 52) / 2) * scale,
            child: Container(
              width: 100 * scale,
              height: 52 * scale,
              decoration: ShapeDecoration(
                color: const Color(0xFFFFC9C9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25 * scale),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(4, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
            ),
          ),
          // D-Day 텍스트
          Positioned(
            left: (402 - 99 - 15) * scale,
            top: 0,
            right: 15 * scale,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                dDay,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 37.71 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // --- 제목과 참여인원 (수정된 부분) ---
          Positioned.fill(
            left: 15 * scale,
            right: (99 + 15) * scale, // D-Day 영역을 침범하지 않도록 오른쪽 여백 설정
            top: ((containerHeight - 70) / 2) * scale,
            child: Align(
              alignment: Alignment.centerLeft, // 좌측 정렬을 기준으로 중앙에 배치
              child: Column(
                mainAxisSize: MainAxisSize.min, // Column의 높이를 자식들의 높이만큼만 차지하도록 설정
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트들을 왼쪽으로 정렬
                children: [
                  // 여행 제목
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // 참여 인원
                  Text(
                    '참여인원 ${participantCount}명',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
