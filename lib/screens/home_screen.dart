import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../app/bootstrap.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_transitions.dart';
import '../widgets/org_tree_view.dart';
import 'add_member_screen.dart';
import 'profile_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _highlightedMemberId;
  int _highlightFocusToken = 0;
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        backgroundColor: AppTheme.bgAbyss,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.headerGradient.createShader(bounds),
          child: Text(
            'Org Chart',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.bootstrap.demoMode
                      ? Colors.orange.withValues(alpha: 0.12)
                      : Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: widget.bootstrap.demoMode
                        ? Colors.orange.withValues(alpha: 0.35)
                        : Colors.green.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  widget.bootstrap.demoMode ? 'Demo' : 'Live',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.bootstrap.demoMode
                            ? Colors.orange.shade200
                            : Colors.green.shade200,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Consumer<MemberProvider>(
            builder: (context, provider, _) {
              final bootstrapWarning = widget.bootstrap.hasWarning
                  ? _ErrorBanner(message: widget.bootstrap.message!)
                  : null;
              final errorBanner = provider.errorMessage == null
                  ? null
                  : _ErrorBanner(message: provider.errorMessage!);

              if (provider.isLoading) {
                return Column(
                  children: [
                    if (bootstrapWarning != null) ...[
                      const SizedBox(height: 4),
                      bootstrapWarning,
                    ],
                    if (errorBanner != null) ...[
                      const SizedBox(height: 8),
                      errorBanner,
                    ],
                    const SizedBox(height: 8),
                    const Expanded(child: _HomeLoadingSkeleton()),
                  ],
                );
              }

              final isTablet = MediaQuery.sizeOf(context).width >= 900;
              final selectedMember = _resolveSelectedMember(provider.members);

              final treeArea = _TreeArea(
                members: provider.members,
                highlightedMemberId: _highlightedMemberId,
                highlightedMemberFocusToken: _highlightFocusToken,
                onAddRequested: () async {
                  await Navigator.of(context).push<bool>(
                    buildScaleFadeRoute<bool>(const AddMemberScreen()),
                  );
                },
                onMemberTap: (member) {
                  if (isTablet) {
                    setState(() {
                      _selectedMemberId = member.id;
                      _highlightedMemberId = member.id;
                      _highlightFocusToken++;
                    });
                    return;
                  }

                  showMemberProfileSheet(context, member, provider.members);
                },
              );

              if (!isTablet) {
                return Column(
                  children: [
                    if (bootstrapWarning != null) ...[
                      const SizedBox(height: 4),
                      bootstrapWarning,
                    ],
                    if (errorBanner != null) ...[
                      const SizedBox(height: 8),
                      errorBanner,
                    ],
                    const SizedBox(height: 8),
                    Expanded(child: treeArea),
                  ],
                );
              }

              return Column(
                children: [
                  if (bootstrapWarning != null) ...[
                    const SizedBox(height: 4),
                    bootstrapWarning,
                  ],
                  if (errorBanner != null) ...[
                    const SizedBox(height: 8),
                    errorBanner,
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: treeArea),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _TabletProfilePanel(
                            member: selectedMember,
                            members: provider.members,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          backgroundColor: AppTheme.violet,
          elevation: 8,
          onPressed: () async {
            await Navigator.of(context).push<bool>(
              buildScaleFadeRoute<bool>(const AddMemberScreen()),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Member? _resolveSelectedMember(List<Member> members) {
    final selectedMemberId = _selectedMemberId;
    if (selectedMemberId == null) {
      return members.isEmpty ? null : members.first;
    }

    for (final member in members) {
      if (member.id == selectedMemberId) return member;
    }

    return members.isEmpty ? null : members.first;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tree area
// ─────────────────────────────────────────────────────────────────────────────

class _TreeArea extends StatelessWidget {
  const _TreeArea({
    required this.members,
    required this.highlightedMemberId,
    required this.highlightedMemberFocusToken,
    required this.onAddRequested,
    required this.onMemberTap,
  });

  final List<Member> members;
  final String? highlightedMemberId;
  final int highlightedMemberFocusToken;
  final VoidCallback onAddRequested;
  final ValueChanged<Member> onMemberTap;

  @override
  Widget build(BuildContext context) {
    return OrgTreeView(
      members: members,
      onAddRequested: onAddRequested,
      highlightedMemberId: highlightedMemberId,
      highlightedMemberFocusToken: highlightedMemberFocusToken,
      onMemberTap: onMemberTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet panel
// ─────────────────────────────────────────────────────────────────────────────

class _TabletProfilePanel extends StatelessWidget {
  const _TabletProfilePanel({required this.member, required this.members});

  final Member? member;
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: const Center(
          child: Text(
            'Select a member to view details',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    final manager = members
        .where((c) => c.id == member!.managerId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.violet.withValues(alpha: 0.16),
            child: Text(
              member!.name.isEmpty ? '?' : member!.name[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            member!.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            member!.role,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _ProfileRow(label: 'Department', value: member!.department),
          _ProfileRow(label: 'Team', value: member!.team),
          _ProfileRow(
            label: 'Reports to',
            value: manager == null ? 'Root node' : manager.name,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  showMemberProfileSheet(context, member!, members),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Full profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.red.shade100),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(height: 100),
        const SizedBox(height: 14),
        _SkeletonBox(height: 52),
        const SizedBox(height: 14),
        _SkeletonBox(height: 24, width: 140),
        const SizedBox(height: 8),
        _SkeletonBox(height: 16, width: 280),
        const SizedBox(height: 14),
        Expanded(child: _SkeletonBox(height: double.infinity)),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1200.ms,
          color: AppTheme.bgElevated.withValues(alpha: 0.5),
        );
  }
}
