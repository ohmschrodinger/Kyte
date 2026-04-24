import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../utils/app_theme.dart';
import '../utils/department_colors.dart';
import '../widgets/tap_scale.dart';
import 'profile_sheet.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  static const String _allRolesFilter = '__all_roles__';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  String _roleFilter = _allRolesFilter;
  bool _groupByDepartment = true;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Consumer<MemberProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.violet),
                );
              }

              final errorMessage = provider.errorMessage;
              final filteredMembers = _filterMembers(provider.members);
              final roles =
                  provider.members.map((m) => m.role).toSet().toList()..sort();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title row ────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Users',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const Spacer(),
                      _ViewToggle(
                        isGrouped: _groupByDepartment,
                        onChanged: (value) =>
                            setState(() => _groupByDepartment = value),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.05, end: 0, duration: 400.ms),
                  const SizedBox(height: 16),

                  // ── Search + filter ──────────────────────────────
                  _SearchFilterRow(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    isFocused: _searchFocus.hasFocus,
                    query: _query,
                    roleFilter: _roleFilter,
                    roles: roles,
                    onQueryChanged: (value) =>
                        setState(() => _query = value),
                    onClear: () {
                      setState(() {
                        _query = '';
                        _searchController.clear();
                      });
                    },
                    onRoleChanged: (value) =>
                        setState(() => _roleFilter = value),
                  ),

                  // ── Active filter chip ───────────────────────────
                  if (_roleFilter != _allRolesFilter) ...[
                    const SizedBox(height: 10),
                    _ActiveFilterChip(
                      label: _roleFilter,
                      onRemove: () =>
                          setState(() => _roleFilter = _allRolesFilter),
                    ),
                  ],

                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    _ErrorBanner(message: errorMessage),
                  ],

                  const SizedBox(height: 12),

                  // ── Count ────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${filteredMembers.length} user${filteredMembers.length == 1 ? '' : 's'}',
                      key: ValueKey(filteredMembers.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── List ─────────────────────────────────────────
                  Expanded(
                    child: filteredMembers.isEmpty
                        ? _EmptyState()
                        : _groupByDepartment
                            ? _GroupedUserList(
                                members: filteredMembers,
                                allMembers: provider.members,
                              )
                            : _FlatUserList(
                                members: filteredMembers,
                                allMembers: provider.members,
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Member> _filterMembers(List<Member> members) {
    final normalizedQuery = _query.trim().toLowerCase();

    return members.where((member) {
      final roleMatches =
          _roleFilter == _allRolesFilter || member.role == _roleFilter;
      if (!roleMatches) return false;
      if (normalizedQuery.isEmpty) return true;

      return member.name.toLowerCase().contains(normalizedQuery) ||
          member.role.toLowerCase().contains(normalizedQuery) ||
          member.department.toLowerCase().contains(normalizedQuery) ||
          member.team.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View Toggle (flat / grouped)
// ─────────────────────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isGrouped, required this.onChanged});

  final bool isGrouped;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            icon: Icons.view_list_rounded,
            isActive: !isGrouped,
            onTap: () => onChanged(false),
          ),
          _ToggleChip(
            icon: Icons.workspaces_rounded,
            isActive: isGrouped,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.violet.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? AppTheme.violet : AppTheme.textMuted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search + Filter Row
// ─────────────────────────────────────────────────────────────────────────────

class _SearchFilterRow extends StatelessWidget {
  const _SearchFilterRow({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.query,
    required this.roleFilter,
    required this.roles,
    required this.onQueryChanged,
    required this.onClear,
    required this.onRoleChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String query;
  final String roleFilter;
  final List<String> roles;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.cyan.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onQueryChanged,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search users…',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isFocused ? AppTheme.cyan : AppTheme.textMuted,
                ),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        TapScale(
          onTap: () => _showRoleFilter(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: roleFilter != '__all_roles__'
                  ? AppTheme.violet
                  : AppTheme.textMuted,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms);
  }

  void _showRoleFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Filter by Role',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RoleFilterChip(
                      label: 'All roles',
                      isSelected: roleFilter == '__all_roles__',
                      onTap: () {
                        onRoleChanged('__all_roles__');
                        Navigator.pop(ctx);
                      },
                    ),
                    ...roles.map((role) => _RoleFilterChip(
                          label: role,
                          isSelected: roleFilter == role,
                          onTap: () {
                            onRoleChanged(role);
                            Navigator.pop(ctx);
                          },
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.violet.withValues(alpha: 0.2)
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.violet.withValues(alpha: 0.5)
                : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isSelected ? AppTheme.violet : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.violet.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.violet.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.violet,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppTheme.violet.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grouped User List (by department)
// ─────────────────────────────────────────────────────────────────────────────

class _GroupedUserList extends StatelessWidget {
  const _GroupedUserList({
    required this.members,
    required this.allMembers,
  });

  final List<Member> members;
  final List<Member> allMembers;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Member>>{};
    for (final member in members) {
      groups.putIfAbsent(member.department, () => []).add(member);
    }
    final sortedDepts = groups.keys.toList()..sort();

    var globalIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedDepts.length,
      itemBuilder: (context, deptIndex) {
        final dept = sortedDepts[deptIndex];
        final deptMembers = groups[dept]!;
        final deptColor = departmentBadgeColor(dept);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (deptIndex > 0) const SizedBox(height: 20),
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: deptColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dept,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: deptColor,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: deptColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${deptMembers.length}',
                      style: TextStyle(
                        color: deptColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppTheme.borderSubtle,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: deptIndex * 60),
                    duration: 300.ms),
            // Members
            ...deptMembers.map((member) {
              final idx = globalIndex++;
              return _UserCard(
                member: member,
                allMembers: allMembers,
                index: idx,
              );
            }),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flat User List
// ─────────────────────────────────────────────────────────────────────────────

class _FlatUserList extends StatelessWidget {
  const _FlatUserList({
    required this.members,
    required this.allMembers,
  });

  final List<Member> members;
  final List<Member> allMembers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _UserCard(
          member: members[index],
          allMembers: allMembers,
          index: index,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Card
// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.member,
    required this.allMembers,
    required this.index,
  });

  final Member member;
  final List<Member> allMembers;
  final int index;

  @override
  Widget build(BuildContext context) {
    final deptColor = departmentBadgeColor(member.department);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TapScale(
        onTap: () => showMemberProfileSheet(context, member, allMembers),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Row(
            children: [
              // Avatar with gradient ring
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: departmentGradientColors(member.department),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bgCard,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: deptColor.withValues(alpha: 0.15),
                    backgroundImage: member.photoUrl != null &&
                            member.photoUrl!.isNotEmpty
                        ? NetworkImage(member.photoUrl!)
                        : null,
                    child: member.photoUrl != null &&
                            member.photoUrl!.isNotEmpty
                        ? null
                        : Text(
                            _initials(member.name),
                            style: TextStyle(
                              color: deptColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      member.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Chip(
                          label: member.department,
                          color: deptColor,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: member.team,
                          color: AppTheme.textMuted,
                          isSubtle: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 30 * (index.clamp(0, 15))),
          duration: 350.ms,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          delay: Duration(milliseconds: 30 * (index.clamp(0, 15))),
          duration: 350.ms,
        );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.isSubtle = false,
  });

  final String label;
  final Color color;
  final bool isSubtle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSubtle
            ? AppTheme.bgSurface.withValues(alpha: 0.5)
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSubtle ? AppTheme.textSecondary : color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No users match your filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.28)),
      ),
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.red.shade200),
      ),
    );
  }
}
