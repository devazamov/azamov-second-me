/// ═══════════════════════════════════════════════════════════════
/// Onboarding Screen - AZAMOV Second Me
/// Multi-step onboarding to collect user goals, dreams, interests
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ─── Form Data ───
  String _name = '';
  int _age = 18;
  String _gender = '';
  List<String> _selectedGoals = [];
  List<String> _selectedDreams = [];
  List<String> _selectedInterests = [];

  // ─── Available Options ───
  final _goalOptions = [
    'IT bloger bo\'lish',
    'Nemis tilini o\'rganish',
    'Biznes boshlash',
    'Sog\'lom turmush',
    'Kreativ bo\'lish',
    'Moliyaviy erkinlik',
    'Karyera o\'sishi',
    'Yangi ko\'nikmalar',
  ];

  final _dreamOptions = [
    'O\'z kompaniyam bo\'lishi',
    'Dunyoni ko\'rish',
    'Muallif bo\'lish',
    'Texnologiya yaratish',
    'Jamoa boshqarish',
    'Xalqaro loyihalar',
    'Ta\'lim markazi ochish',
    'Ijtimoiy ta\'sir yaratish',
  ];

  final _interestOptions = [
    'Texnologiya',
    'Sport',
    'San\'at',
    'Kitob',
    'Musiqa',
    'Sayohat',
    'Ovqat pishirish',
    'Fotografiya',
    'Dasturlash',
    'Til o\'rganish',
    'Biznes',
    'Fan',
  ];

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    try {
      await firestore.updateOnboarding(
        userId,
        name: _name.isNotEmpty ? _name : 'Foydalanuvchi',
        age: _age,
        gender: _gender,
        goals: _selectedGoals,
        dreams: _selectedDreams,
        interests: _selectedInterests,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Progress Bar ───
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _previousPage,
                          child: const Text(
                            'Orqaga',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                      Text(
                        '${_currentPage + 1} / 5',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      backgroundColor: AppColors.silverLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Page Content ───
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildNamePage(),
                  _buildAgeGenderPage(),
                  _buildGoalsPage(),
                  _buildDreamsPage(),
                  _buildInterestsPage(),
                ],
              ),
            ),

            // ─── Next Button ───
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(
                  _currentPage == 4 ? 'Boshlash' : 'Davom et',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _name.isNotEmpty;
      case 1:
        return _gender.isNotEmpty;
      case 2:
        return _selectedGoals.isNotEmpty;
      case 3:
        return _selectedDreams.isNotEmpty;
      case 4:
        return _selectedInterests.isNotEmpty;
      default:
        return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PAGE BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assalomu alaykum! 👋',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ismingiz nima?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ismingiz',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            onChanged: (value) => setState(() => _name = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGenderPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yoshingiz va jinsingiz',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Shaxsiy ma\'lumotlaringizni kiriting',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // ─── Age Selector ───
          const Text(
            'Yosh',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.silverLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _age > 10
                      ? () => setState(() => _age--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: AppColors.primary,
                ),
                Text(
                  '$_age yosh',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _age < 100
                      ? () => setState(() => _age++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Gender Selector ───
          const Text(
            'Jins',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: 'Erkak',
                  icon: Icons.male_rounded,
                  isSelected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderOption(
                  label: 'Ayol',
                  icon: Icons.female_rounded,
                  isSelected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return _buildMultiSelectPage(
      title: 'Maqsadlaringiz 🎯',
      subtitle: 'Bir nechta maqsadni tanlang',
      options: _goalOptions,
      selected: _selectedGoals,
      onToggle: (option) {
        setState(() {
          if (_selectedGoals.contains(option)) {
            _selectedGoals.remove(option);
          } else {
            _selectedGoals.add(option);
          }
        });
      },
    );
  }

  Widget _buildDreamsPage() {
    return _buildMultiSelectPage(
      title: 'Orzularingiz ✨',
      subtitle: 'Kelajakdagi orzularingizni belgilang',
      options: _dreamOptions,
      selected: _selectedDreams,
      onToggle: (option) {
        setState(() {
          if (_selectedDreams.contains(option)) {
            _selectedDreams.remove(option);
          } else {
            _selectedDreams.add(option);
          }
        });
      },
    );
  }

  Widget _buildInterestsPage() {
    return _buildMultiSelectPage(
      title: 'Qiziqishlaringiz 💡',
      subtitle: 'Sizni qiziqtirgan sohalarni tanlang',
      options: _interestOptions,
      selected: _selectedInterests,
      onToggle: (option) {
        setState(() {
          if (_selectedInterests.contains(option)) {
            _selectedInterests.remove(option);
          } else {
            _selectedInterests.add(option);
          }
        });
      },
    );
  }

  Widget _buildMultiSelectPage({
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selected,
    required Function(String) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return GestureDetector(
                  onTap: () => onToggle(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.silverLight,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Gender Selection Option ───
class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.silverLight,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
