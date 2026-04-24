import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../app/bootstrap.dart';
import '../providers/member_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/tap_scale.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      body: SafeArea(
        bottom: false,
        child: Consumer<MemberProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const _DashboardSkeleton();
            }

            final members = provider.members;
            final departments = <String>{};
            final departmentCounts = <String, int>{};
            var rootCount = 0;

            for (final member in members) {
              departments.add(member.department);
              departmentCounts[member.department] =
                  (departmentCounts[member.department] ?? 0) + 1;
              if (!member.hasManager) rootCount++;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────
                  _DashboardHeader(bootstrap: bootstrap),
                  const SizedBox(height: 28),

                  // ── Stats Row ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          index: 0,
                          icon: Icons.people_alt_rounded,
                          label: 'Members',
                          value: '${members.length}',
                          color: AppTheme.violet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          index: 1,
                          icon: Icons.apartment_rounded,
                          label: 'Depts',
                          value: '${departments.length}',
                          color: AppTheme.cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          index: 2,
                          icon: Icons.account_tree_rounded,
                          label: 'Roots',
                          value: '$rootCount',
                          color: const Color(0xFF35C49A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Department Breakdown ────────────────────────
                  Text(
                    'Department Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 14),
                  _DepartmentBreakdown(
                    departmentCounts: departmentCounts,
                    total: members.length,
                  ),
                  const SizedBox(height: 28),

                  // ── Quick Actions ──────────────────────────────
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms),
                  const SizedBox(height: 14),
                  _QuickActions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.bootstrap});

  final AppBootstrap bootstrap;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.headerGradient.createShader(bounds),
                child: Text(
                  '$_greeting ✦',
                  style:
                      Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s your org overview',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bootstrap.demoMode
                ? Colors.orange.withValues(alpha: 0.12)
                : Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: bootstrap.demoMode
                  ? Colors.orange.withValues(alpha: 0.35)
                  : Colors.green.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            bootstrap.demoMode ? 'Demo' : 'Live',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: bootstrap.demoMode
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.05, end: 0, duration: 500.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.index,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final int index;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 + index * 80), duration: 400.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 80 + index * 80),
          duration: 400.ms,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Department Breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _DepartmentBreakdown extends StatelessWidget {
  const _DepartmentBreakdown({
    required this.departmentCounts,
    required this.total,
  });

  final Map<String, int> departmentCounts;
  final int total;

  @override
  Widget build(BuildContext context) {
    final sorted = departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _DepartmentRow(
              department: sorted[i].key,
              count: sorted[i].value,
              total: total,
              index: i,
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms);
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({
    required this.department,
    required this.count,
    required this.total,
    required this.index,
  });

  final String department;
  final int count;
  final int total;
  final int index;

  Color get _color {
    switch (department.trim().toLowerCase()) {
      case 'engineering':
        return const Color(0xFF4F8CFF);
      case 'product':
        return const Color(0xFFFFB84D);
      case 'operations':
        return const Color(0xFF35C49A);
      case 'marketing':
        return const Color(0xFFEC6AA8);
      case 'hr':
      case 'human resources':
        return const Color(0xFFB68DFF);
      default:
        return AppTheme.violet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                department,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction),
            duration: Duration(milliseconds: 600 + index * 100),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: AppTheme.bgSurface,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Action Cards
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TapScale(
            onTap: () {
              // Navigate to org chart tab via bottom nav
            },
            child: _ActionCard(
              icon: Icons.account_tree_rounded,
              label: 'View Org Chart',
              gradient: LinearGradient(
                colors: [
                  AppTheme.violet.withValues(alpha: 0.2),
                  AppTheme.violet.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconColor: AppTheme.violet,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TapScale(
            onTap: () {
              // Navigate to add member tab
            },
            child: _ActionCard(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Add Member',
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyan.withValues(alpha: 0.2),
                  AppTheme.cyan.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconColor: AppTheme.cyan,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.06, end: 0, delay: 400.ms, duration: 400.ms);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Open',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: iconColor,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 12, color: iconColor),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Loader
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 220, height: 32),
          const SizedBox(height: 8),
          _SkeletonBox(width: 160, height: 16),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 110)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 110)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 110)),
            ],
          ),
          const SizedBox(height: 28),
          _SkeletonBox(width: 180, height: 20),
          const SizedBox(height: 14),
          _SkeletonBox(height: 160),
          const SizedBox(height: 28),
          _SkeletonBox(width: 140, height: 20),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 110)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 110)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 20,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1200.ms,
          color: AppTheme.bgElevated.withValues(alpha: 0.5),
        );
  }
}
