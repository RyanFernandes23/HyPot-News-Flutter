import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

// ── Genre data ─────────────────────────────────────────────────────────────
class _Genre {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  const _Genre(this.label, this.icon, this.color, this.bg);
}

const _genres = [
  _Genre('International', Icons.public_outlined,
      AppColors.blue600,   AppColors.blue50),
  _Genre('Finance',       Icons.trending_up_outlined,
      AppColors.teal600,   AppColors.teal50),
  _Genre('Regional',      Icons.location_on_outlined,
      AppColors.purple600, AppColors.purple50),
  _Genre('Good News',     Icons.sentiment_satisfied_outlined,
      AppColors.amber400,  AppColors.amber50),
  _Genre('Hot Topics',    Icons.local_fire_department_outlined,
      AppColors.coral600,  AppColors.coral50),
];

const _volumes = [10, 20, 30];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedGenre  = 'International';
  int    _selectedVolume = 10;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s8),

            // ── Top bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                        style: AppText.bodySm.copyWith(
                          color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text('HyPot News',
                        style: AppText.h2.copyWith(
                          color: AppColors.teal600)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.full_,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.person_outline,
                        size: 18,
                        color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Genre heading ──────────────────────────────────
                    Text('Choose a genre',
                      style: AppText.h4),
                    const SizedBox(height: AppSpacing.s2),
                    Text('What do you want to hear today?',
                      style: AppText.body.copyWith(
                        color: AppColors.textMuted)),

                    const SizedBox(height: AppSpacing.s5),

                    // ── Genre grid ─────────────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.s3,
                      mainAxisSpacing: AppSpacing.s3,
                      childAspectRatio: 1.6,
                      children: _genres.map((g) {
                        final selected = _selectedGenre == g.label;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedGenre = g.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selected
                                  ? g.color
                                  : AppColors.surface,
                              borderRadius: AppRadius.lg_,
                              border: Border.all(
                                color: selected
                                    ? g.color
                                    : AppColors.border,
                                width: selected ? 0 : 1,
                              ),
                              boxShadow: selected
                                  ? AppShadow.md
                                  : AppShadow.sm,
                            ),
                            padding: const EdgeInsets.all(
                                AppSpacing.s4),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                            .withOpacity(0.2)
                                        : g.bg,
                                    borderRadius: AppRadius.sm_,
                                  ),
                                  child: Icon(g.icon,
                                    size: 18,
                                    color: selected
                                        ? Colors.white
                                        : g.color),
                                ),
                                Text(g.label,
                                  style: AppText.label.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.s8),

                    // ── Volume heading ─────────────────────────────────
                    Text('Stories to hear',
                      style: AppText.h4),
                    const SizedBox(height: AppSpacing.s2),
                    Text('How many headlines in this session?',
                      style: AppText.body.copyWith(
                        color: AppColors.textMuted)),

                    const SizedBox(height: AppSpacing.s5),

                    // ── Volume pills ───────────────────────────────────
                    Row(
                      children: _volumes.map((v) {
                        final selected = _selectedVolume == v;
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: AppSpacing.s3),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedVolume = v),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              width: 80,
                              height: 48,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.teal600
                                    : AppColors.surface,
                                borderRadius: AppRadius.md_,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.teal600
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text('$v',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    )),
                                  Text('stories',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: selected
                                          ? Colors.white
                                              .withOpacity(0.8)
                                          : AppColors.textMuted,
                                    )),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.s10),

                    // ── Start button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => context.push('/briefing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal600,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.lg_,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.headphones,
                              size: 20,
                              color: Colors.white),
                            const SizedBox(width: AppSpacing.s3),
                            Text(
                              'Start $_selectedGenre · $_selectedVolume stories',
                              style: AppText.button,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
