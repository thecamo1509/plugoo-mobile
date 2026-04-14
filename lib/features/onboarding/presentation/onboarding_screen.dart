import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_router.dart';
import '../data/onboarding_repository_impl.dart';
import '../../../core/di/providers.dart';
import 'providers/onboarding_provider.dart';

/// Data model for a single onboarding page.
class _OnboardingPageData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const _OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });
}

const _pages = [
  _OnboardingPageData(
    emoji: '⚡',
    title: 'Cargá tu auto\ndonde quieras',
    subtitle:
        'Encontrá cargadores eléctricos cerca tuyo, en tiempo real. Nuestra comunidad pone a disposición su infraestructura para que nunca te quedes sin carga.',
    backgroundColor: AppColors.primaryContainer,
  ),
  _OnboardingPageData(
    emoji: '🤝',
    title: 'Economía\ncolaborativa',
    subtitle:
        'Compartí tu cargador con la comunidad y generá ingresos extra. Juntos construimos la red de carga más grande de Argentina.',
    backgroundColor: AppColors.secondaryContainer,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final repo = OnboardingRepositoryImpl(
      ref.read(sharedPreferencesProvider),
    );
    await repo.completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.auth);
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ────────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                key: const Key('onboarding_skip'),
                onPressed: _finish,
                child: Text(
                  'Saltar',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),

            // ── PageView ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),

            // ── Dot indicator ──────────────────────────────────────────────
            _DotIndicator(
              count: _pages.length,
              current: _currentPage,
            ),
            const SizedBox(height: 24),

            // ── Primary CTA ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: Key(isLast ? 'onboarding_start' : 'onboarding_next'),
                  onPressed: _next,
                  child: Text(isLast ? 'Empezar' : 'Siguiente'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.grey900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.grey700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
