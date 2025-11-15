import 'package:flutter/material.dart';

class TabNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const TabNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double designWidth = 402.0;
    final double scale = screenSize.width / designWidth;

    final List<Map<String, String>> tabs = [
      {
        'label': '날짜',
        'icon': 'Date_range',
      },
      {
        'label': '후보지',
        'icon': 'Subtract',
      },
      {
        'label': '일정표',
        'icon': 'notebook',
      },
      {
        'label': '예산',
        'icon': 'wallet',
      },
      {
        'label': '체크리스트',
        'icon': 'checklist',
      },
    ];

    return Container(
      height: 40 * scale,
      margin: EdgeInsets.symmetric(horizontal: 12 * scale),
      // Row를 SingleChildScrollView로 변경하여 가로 스크롤을 가능하게 합니다.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 1. 가로 스크롤 설정
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            int index = entry.key;
            String tabLabel = entry.value['label']!;
            String iconName = entry.value['icon']!;
            bool isSelected = index == selectedIndex;

            String iconPath = isSelected
                ? 'assets/icons/${iconName}_light.png'
                : 'assets/icons/$iconName.png';

            // 2. Expanded를 제거하고, 각 탭이 스스로의 크기를 갖도록 합니다.
            //    대신 GestureDetector와 Container를 직접 사용합니다.
            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                height: double.infinity,
                // 3. 각 탭의 좌우 여백을 padding으로 변경하여 터치 영역을 확보합니다.
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                margin: EdgeInsets.only(right: 2 * scale), // 탭 사이의 간격
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFA0A0)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: isSelected
                      ? null
                      : Border.all(
                    color: const Color(0x401A0802),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x3D000000), // 그림자 색 (투명도 24%)
                      blurRadius: 3 * scale,       // 흐림 효과 반경
                      spreadRadius: 0,                 // 그림자 확산 범위
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      iconPath,
                      width: 24 * scale,
                      height: 24 * scale,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        if (isSelected) {
                          return Image.asset(
                            'assets/icons/$iconName.png',
                            width: 24 * scale,
                            height: 24 * scale,
                            fit: BoxFit.contain,
                            color: Colors.white,
                            colorBlendMode: BlendMode.srcIn,
                          );
                        }
                        return SizedBox(
                          width: 24 * scale,
                          height: 24 * scale,
                        );
                      },
                    ),
                    SizedBox(width: 8 * scale), // 아이콘과 텍스트 사이 간격 조정
                    Text(
                      tabLabel,
                      style: TextStyle(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.black,
                        height: 27.5 / 22,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


