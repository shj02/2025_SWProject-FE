import 'package:flutter/material.dart';
import 'package:sw_project_fe/services/auth_api.dart';

class TravelPreferenceScreen extends StatefulWidget {
  const TravelPreferenceScreen({super.key});

  @override
  State<TravelPreferenceScreen> createState() => _TravelPreferenceScreenState();
}

class _TravelPreferenceScreenState extends State<TravelPreferenceScreen> {
  final Set<String> _selectedPreferences = {};
  bool _isLoading = false;

  final List<PreferenceOption> _preferences = [
    PreferenceOption('🎢', '액티비티'),
    PreferenceOption('🧘', '힐링·휴양'),
    PreferenceOption('🖼️', '문화 탐방'),
    PreferenceOption('🍕', '맛집 탐방'),
    PreferenceOption('🛍️', '쇼핑'),
    PreferenceOption('🌲', '자연·풍경'),
    PreferenceOption('🏙️', '도시 중심형'),
    PreferenceOption('🏡', '로컬 중심형'),
    PreferenceOption('💎', '럭셔리'),
    PreferenceOption('💸', '실속·가성비'),
    PreferenceOption('🎒', '모험·백팩커'),
  ];

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
  }

  Future<void> _onStartPressed() async {
    if (_selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 여행 스타일을 선택해주세요.')),
      );
      return;
    }
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().completeStyles(_selectedPreferences.toList());
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('당신의 여행 스타일을\n알려주세요', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('선호하는 여행 타입을 골라주시면\n더 정확한 플랜을 추천해 드릴게요.', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _preferences.length,
                  itemBuilder: (context, index) {
                    final option = _preferences[index];
                    final isSelected = _selectedPreferences.contains(option.label);
                    return GestureDetector(
                      onTap: () => _togglePreference(option.label),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.pink.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.pink : Colors.grey.shade300),
                        ),
                        child: Center(child: Text('${option.emoji} ${option.label}')),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onStartPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('여행 계획 시작!', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreferenceOption {
  final String emoji;
  final String label;
  const PreferenceOption(this.emoji, this.label);
}
