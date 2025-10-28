import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0; // Figma 기준 폭
    final double scale = screenSize.width / designWidth;

    return Container(
      width: double.infinity,
      height: 88 * scale,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF), // 흰색 배경 #ffffff
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000), // 10% 투명도의 검은색
            offset: Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _NavbarItem(
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            iconPath: 'assets/icons/home.png',
            label: 'Home',
            scale: scale,
          ),
          _NavbarItem(
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
            iconPath: 'assets/icons/tripPlan.png',
            label: 'TripPlan',
            scale: scale,
          ),
          _NavbarItem(
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
            iconPath: 'assets/icons/community.png',
            label: 'Community',
            scale: scale,
          ),
          _NavbarItem(
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
            iconPath: 'assets/icons/profile.png',
            label: 'Profile',
            scale: scale,
          ),
        ],
      ),
    );
  }
}

class _NavbarItem extends StatelessWidget {
  const _NavbarItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.iconPath,
    required this.label,
    required this.scale,
  });

  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final String iconPath;
  final String label;
  final double scale;

  bool get isSelected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          // 이 Container는 배경만 관리하며, 둥근 모서리가 적용된 바는 Column의 자식으로 분리됩니다.
          height: 88 * scale,

          child: Column(
            children: [
              // 1. 둥근 모서리가 적용된 빨간색 상단 바
              if (isSelected)
                Container(
                  width: double.infinity,
                  height: 6 * scale, // Figma Rectangle 3 높이: 6px
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC5858), // 빨간색 #fc5858
                    // ************************************************
                    // 이 Container의 배경색(빨간색 바)에 둥근 모서리 적용
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8 * scale),
                      bottomRight: Radius.circular(8 * scale),
                    ),
                    // ************************************************
                  ),
                ),

              // 2. 탭 콘텐츠 (아이콘 + 텍스트)
              // Expanded를 사용하여 남은 수직 공간을 채우고, 내용을 중앙 정렬합니다.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 남은 공간 내에서 중앙 정렬
                  children: [
                    // 아이콘
                    Container(
                      width: 24 * scale,
                      height: 24 * scale,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? const Color(0xFFFC5858) // 선택된 상태: #fc5858
                              : const Color(0xFF0C0C0C), // 기본 상태: #0c0c0c
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          iconPath,
                          width: 24 * scale,
                          height: 24 * scale,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 4 * scale), // 아이콘과 텍스트 사이 간격

                    // 텍스트
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 14 * scale,
                        color: isSelected
                            ? const Color(0xFFFC5858) // 선택된 상태: #fc5858
                            : const Color(0xFF0C0C0C), // 기본 상태: #0c0c0c
                        height: 17.066 / 14,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 네비게이션 인덱스 상수
class NavbarIndex {
  static const int home = 0;
  static const int tripPlan = 1;
  static const int community = 2;
  static const int profile = 3;
}