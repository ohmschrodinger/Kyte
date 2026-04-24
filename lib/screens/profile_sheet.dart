import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_transitions.dart';
import '../utils/department_colors.dart';
import '../widgets/tap_scale.dart';
import 'add_member_screen.dart';

Future<void> showMemberProfileSheet(
  BuildContext context,
  Member member,
  List<Member> members,
) {
  final rootContext = context;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final managerName = _resolveManagerName(member, members);
          final directReports = members
              .where((c) => c.managerId == member.id)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          final deptColor = departmentBadgeColor(member.department);

          return Container(
            decoration: BoxDecoration(
              color: AppTheme.bgDeep,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                // ── Drag handle ─────────────────────────────────────
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.5, 1),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 20),

                // ── Avatar + Name ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient ring avatar
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: departmentGradientColors(member.department),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.bgDeep,
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: deptColor.withValues(alpha: 0.15),
                          backgroundImage: member.photoUrl != null &&
                                  member.photoUrl!.isNotEmpty
                              ? NetworkImage(member.photoUrl!)
                              : null,
                          child: member.photoUrl != null &&
                                  member.photoUrl!.isNotEmpty
                              ? null
                              : Text(
                                  member.name.isEmpty
                                      ? '?'
                                      : member.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: deptColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style:
                                Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.role,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Pill(
                                label: member.department,
                                color: deptColor,
                              ),
                              _Pill(
                                label: member.team,
                                color: AppTheme.cyan,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── Info Card ───────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Member ID',
                        value: member.id,
                        index: 0,
                      ),
                      _InfoRow(
                        icon: Icons.apartment_outlined,
                        label: 'Department',
                        value: member.department,
                        index: 1,
                      ),
                      _InfoRow(
                        icon: Icons.groups_rounded,
                        label: 'Team',
                        value: member.team,
                        index: 2,
                      ),
                      _InfoRow(
                        icon: Icons.account_tree_outlined,
                        label: 'Reports to',
                        value: managerName,
                        index: 3,
                        isLast: true,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── Direct Reports ──────────────────────────────────
                Text(
                  'Direct Reports (${directReports.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 12),

                if (directReports.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 18,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'No direct reports yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 300.ms)
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < directReports.length; i++)
                        _ReportChip(
                          label: directReports[i].name,
                          subtitle: directReports[i].role,
                          color: departmentBadgeColor(
                              directReports[i].department),
                          index: i,
                        ),
                    ],
                  ),

                const SizedBox(height: 28),

                // ── Action Buttons ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TapScale(
                        onTap: () {
                          Navigator.of(context).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(rootContext).push(
                              buildScaleFadeRoute<void>(
                                AddMemberScreen(member: member),
                              ),
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: AppTheme.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TapScale(
                        onTap: () async {
                          final shouldDelete = await _showDeleteConfirmation(
                            context: context,
                            member: member,
                          );
                          if (!shouldDelete || !context.mounted) return;

                          await rootContext
                              .read<MemberProvider>()
                              .deleteSubtree(member.id);
                          if (!rootContext.mounted) return;

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(rootContext).showSnackBar(
                            SnackBar(
                              content: Text('${member.name} deleted'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Colors.redAccent.shade100,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.redAccent.shade100,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
              ],
            ),
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _resolveManagerName(Member member, List<Member> members) {
  if (member.managerId == null) return 'Root node';

  for (final candidate in members) {
    if (candidate.id == member.managerId) return candidate.name;
  }
  return 'Manager missing';
}

Future<bool> _showDeleteConfirmation({
  required BuildContext context,
  required Member member,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete member?'),
        content: Text(
          'This will also remove ${member.name} and all subordinates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.index,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 220 + index * 50),
          duration: 300.ms,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          delay: Duration(milliseconds: 220 + index * 50),
          duration: 300.ms,
        );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.index,
  });

  final String label;
  final String subtitle;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.bgCard,
            AppTheme.bgElevated.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 350 + index * 60),
          duration: 300.ms,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 350 + index * 60),
          duration: 300.ms,
        );
  }
}
