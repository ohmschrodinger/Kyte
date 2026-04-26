import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../utils/app_theme.dart';
import '../utils/member_roles.dart';
import '../widgets/tap_scale.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.member, this.showHeader = true});

  final Member? member;
  final bool showHeader;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  String? _selectedRole;
  String? _selectedManagerId;
  bool _isSaving = false;
  bool _showSuccess = false;

  // Progressive disclosure
  bool _reportingExpanded = false;
  bool _mediaExpanded = false;

  bool get _isEditMode => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _nameController.text = member.name;
      _departmentController.text = member.department;
      _teamController.text = member.team;
      _photoUrlController.text = member.photoUrl ?? '';
      _selectedRole = member.role;
      _selectedManagerId = member.managerId;
      _reportingExpanded = true;
      _mediaExpanded = member.photoUrl != null && member.photoUrl!.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _teamController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final provider = context.read<MemberProvider>();
    final memberId = widget.member?.id ?? '';

    if (await provider.isCircular(memberId, _selectedManagerId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Circular manager assignment is not allowed'),
        ),
      );
      return;
    }

    final newMember = Member(
      id: memberId,
      name: _nameController.text.trim(),
      role: _selectedRole!.trim(),
      department: _departmentController.text.trim(),
      team: _teamController.text.trim(),
      managerId: _selectedManagerId,
      photoUrl: _photoUrlController.text.trim().isEmpty
          ? null
          : _photoUrlController.text.trim(),
    );

    setState(() => _isSaving = true);

    try {
      if (_isEditMode) {
        await provider.updateMember(newMember);
      } else {
        await provider.addMember(newMember);
      }
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _showSuccess = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      if (widget.showHeader && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else if (!_isEditMode) {
        _formKey.currentState?.reset();
        _nameController.clear();
        _departmentController.clear();
        _teamController.clear();
        _photoUrlController.clear();
        setState(() {
          _selectedRole = null;
          _selectedManagerId = null;
          _showSuccess = false;
          _reportingExpanded = false;
          _mediaExpanded = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add member: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    final member = widget.member;
    final managerOptions = _managerOptions(members, member);

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.showHeader)
                _Header(
                  isEditMode: _isEditMode,
                  onBack: () => Navigator.of(context).pop(),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.showHeader) ...[
                        Text(
                          _isEditMode ? 'Edit Member' : 'Add Member',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Update member details'
                              : 'Create a new member and connect to the org',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Section 1: Member Details (always expanded) ──
                      _SectionCard(
                        index: 0,
                        title: 'Member Details',
                        subtitle: 'Basic information about the member',
                        icon: Icons.person_outline_rounded,
                        isExpanded: true,
                        canCollapse: false,
                        child: Column(
                          children: [
                            _StyledField(
                              label: 'Full Name',
                              controller: _nameController,
                              hintText: 'e.g. Aarav Sharma',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            _RoleSelector(
                              selectedRole: _selectedRole,
                              onChanged: (value) =>
                                  setState(() => _selectedRole = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Role is required';
                                }
                                return null;
                              },
                            ),
                            _StyledField(
                              label: 'Department',
                              controller: _departmentController,
                              hintText: 'e.g. Engineering',
                              icon: Icons.apartment_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Department is required';
                                }
                                return null;
                              },
                            ),
                            _StyledField(
                              label: 'Team',
                              controller: _teamController,
                              hintText: 'e.g. Platform',
                              icon: Icons.groups_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Team is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Section 2: Reporting Line (collapsible) ──
                      _SectionCard(
                        index: 1,
                        title: 'Reporting Line',
                        subtitle: 'Who does this member report to?',
                        icon: Icons.account_tree_outlined,
                        isExpanded: _reportingExpanded,
                        canCollapse: true,
                        onToggle: () => setState(
                          () => _reportingExpanded = !_reportingExpanded,
                        ),
                        child: _ManagerSelector(
                          selectedManagerId: _selectedManagerId,
                          members: members,
                          currentMember: member,
                          managerOptions: managerOptions,
                          onChanged: (value) =>
                              setState(() => _selectedManagerId = value),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Section 3: Profile Media (collapsible) ──
                      _SectionCard(
                        index: 2,
                        title: 'Profile Media',
                        subtitle: 'Optional photo URL',
                        icon: Icons.image_outlined,
                        isExpanded: _mediaExpanded,
                        canCollapse: true,
                        onToggle: () =>
                            setState(() => _mediaExpanded = !_mediaExpanded),
                        child: _StyledField(
                          label: 'Photo URL',
                          controller: _photoUrlController,
                          hintText: 'https://...',
                          icon: Icons.link_rounded,
                          validator: (_) => null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Submit Button ──────────────────────────────
                      _SubmitButton(
                        isEditMode: _isEditMode,
                        isSaving: _isSaving,
                        showSuccess: _showSuccess,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String?> _managerOptions(List<Member> members, Member? currentMember) {
    final options = <String?>[null];
    for (final member in members) {
      if (currentMember != null && member.id == currentMember.id) continue;
      options.add(member.id);
    }

    final currentManagerId = currentMember?.managerId;
    if (currentManagerId != null &&
        currentManagerId.isNotEmpty &&
        !options.contains(currentManagerId)) {
      options.add(currentManagerId);
    }

    return options;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isEditMode, required this.onBack});

  final bool isEditMode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.violet.withValues(alpha: 0.15),
                AppTheme.bgAbyss,
              ],
            ),
            border: const Border(
              bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TapScale(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.headerGradient.createShader(bounds),
                child: Text(
                  isEditMode ? 'Edit Member' : 'Add Member',
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEditMode
                    ? 'Update details and keep the hierarchy valid'
                    : 'Create a new profile and connect to the org chart',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.03, end: 0, duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card with expand/collapse
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isExpanded,
    required this.child,
    this.canCollapse = false,
    this.onToggle,
  });

  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isExpanded;
  final bool canCollapse;
  final Widget child;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderSubtle),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              GestureDetector(
                onTap: canCollapse ? onToggle : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.violet.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 16, color: AppTheme.violet),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (canCollapse)
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          turns: isExpanded ? 0.5 : 0.0,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: isExpanded
                    ? AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: child,
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 + index * 100),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: 80 + index * 100),
          duration: 400.ms,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled Field
// ─────────────────────────────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Selector (bottom sheet picker)
// ─────────────────────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
    required this.validator,
  });

  final String? selectedRole;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormField<String>(
        initialValue: selectedRole,
        validator: validator,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showRolePicker(context, state),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(
                      Icons.work_outline_rounded,
                      size: 18,
                    ),
                    errorText: state.errorText,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                    ),
                  ),
                  child: Text(
                    selectedRole ?? 'Select a role',
                    style: TextStyle(
                      color: selectedRole != null
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRolePicker(BuildContext context, FormFieldState<String> state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgDeep,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
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
                    'Select Role',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the role for this member',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: memberRoles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final role = memberRoles[index];
                        final isActive = role == selectedRole;
                        return TapScale(
                          onTap: () {
                            onChanged(role);
                            state.didChange(role);
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.violet.withValues(alpha: 0.15)
                                  : AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? AppTheme.violet.withValues(alpha: 0.5)
                                    : AppTheme.borderSubtle,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  size: 18,
                                  color: isActive
                                      ? AppTheme.violet
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    role,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: isActive
                                              ? AppTheme.violet
                                              : AppTheme.textPrimary,
                                        ),
                                  ),
                                ),
                                if (isActive)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppTheme.violet,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manager Selector
// ─────────────────────────────────────────────────────────────────────────────

class _ManagerSelector extends StatelessWidget {
  const _ManagerSelector({
    required this.selectedManagerId,
    required this.members,
    required this.currentMember,
    required this.managerOptions,
    required this.onChanged,
  });

  final String? selectedManagerId;
  final List<Member> members;
  final Member? currentMember;
  final List<String?> managerOptions;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selectedManagerId,
      isExpanded: true,
      menuMaxHeight: 320,
      dropdownColor: AppTheme.bgElevated,
      decoration: const InputDecoration(
        labelText: 'Manager',
        hintText: 'No manager (root node)',
        prefixIcon: Icon(Icons.account_tree_outlined, size: 18),
      ),
      items: managerOptions.map((value) {
        if (value == null) {
          return const DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'No manager (root node)',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        final manager = members.firstWhere(
          (m) => m.id == value,
          orElse: () => const Member(
            id: '',
            name: 'Unknown manager',
            role: '',
            department: '',
            team: '',
          ),
        );

        return DropdownMenuItem<String?>(
          value: value,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.violet.withValues(alpha: 0.16),
                child: Text(
                  manager.name.isEmpty ? '?' : manager.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      manager.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    if (manager.department.isNotEmpty)
                      Text(
                        manager.department,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (_) => null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit Button with gradient + success state
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isEditMode,
    required this.isSaving,
    required this.showSuccess,
    required this.onPressed,
  });

  final bool isEditMode;
  final bool isSaving;
  final bool showSuccess;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: showSuccess
                  ? const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    )
                  : AppTheme.headerGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (showSuccess ? const Color(0xFF059669) : AppTheme.violet)
                          .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isSaving || showSuccess ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: showSuccess
                    ? const Icon(Icons.check_rounded, key: ValueKey('check'))
                    : isSaving
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditMode ? 'Save Changes' : 'Add Member',
                        key: const ValueKey('text'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 350.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 350.ms, duration: 400.ms);
  }
}
