import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/member.dart';
import '../screens/profile_sheet.dart';
import '../utils/app_theme.dart';
import '../utils/department_colors.dart';
import '../utils/tree_builder.dart';
import 'tap_scale.dart';

class OrgTreeView extends StatefulWidget {
  const OrgTreeView({
    super.key,
    required this.members,
    required this.onAddRequested,
    this.onMemberTap,
    this.highlightedMemberId,
    this.highlightedMemberFocusToken = 0,
  });

  final List<Member> members;
  final VoidCallback onAddRequested;
  final ValueChanged<Member>? onMemberTap;
  final String? highlightedMemberId;
  final int highlightedMemberFocusToken;

  @override
  State<OrgTreeView> createState() => _OrgTreeViewState();
}

class _OrgTreeViewState extends State<OrgTreeView>
    with SingleTickerProviderStateMixin {
  final Set<String> _collapsedNodeIds = <String>{};
  final Map<String, GlobalKey> _nodeKeys = <String, GlobalKey>{};
  final GlobalKey _viewerKey = GlobalKey();
  final GlobalKey _sceneKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  late final AnimationController _focusAnimationController;
  Animation<Matrix4>? _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _focusAnimationController.addListener(() {
      final animation = _focusAnimation;
      if (animation != null) {
        _transformationController.value = animation.value;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusHighlightedMember();
    });
  }

  @override
  void didUpdateWidget(covariant OrgTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final highlightChanged =
        oldWidget.highlightedMemberId != widget.highlightedMemberId;
    final focusRequested =
        oldWidget.highlightedMemberFocusToken !=
        widget.highlightedMemberFocusToken;
    final memberListChanged = oldWidget.members != widget.members;

    if (highlightChanged || focusRequested || memberListChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusHighlightedMember();
      });
    }
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _openProfile(Member member) {
    final onMemberTap = widget.onMemberTap;
    if (onMemberTap != null) {
      onMemberTap(member);
      return;
    }

    showMemberProfileSheet(context, member, widget.members);
  }

  @override
  Widget build(BuildContext context) {
    _syncNodeKeys();
    _expandAncestorsForHighlight();

    final tree = buildTree(widget.members);

    if (tree.isEmpty) {
      return _EmptyTreeState(onAddRequested: widget.onAddRequested);
    }

    return InteractiveViewer(
      key: _viewerKey,
      transformationController: _transformationController,
      constrained: false,
      minScale: 0.3,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(200),
      child: ConstrainedBox(
        key: _sceneKey,
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 32,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tree.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _TreeBranch(
                    node: tree[i],
                    collapsedNodeIds: _collapsedNodeIds,
                    onToggleCollapsed: _toggleNode,
                    onNodeTap: _openProfile,
                    nodeKeys: _nodeKeys,
                    highlightedMemberId: widget.highlightedMemberId,
                    depth: 0,
                    animationIndex: i,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncNodeKeys() {
    final existingIds = widget.members.map((member) => member.id).toSet();
    _nodeKeys.removeWhere((id, _) => !existingIds.contains(id));

    for (final member in widget.members) {
      _nodeKeys.putIfAbsent(member.id, () => GlobalKey());
    }
  }

  void _expandAncestorsForHighlight() {
    final highlightedMemberId = widget.highlightedMemberId;
    if (highlightedMemberId == null || highlightedMemberId.isEmpty) {
      return;
    }

    final membersById = <String, Member>{
      for (final member in widget.members) member.id: member,
    };

    var current = membersById[highlightedMemberId];
    while (current != null && current.managerId != null) {
      _collapsedNodeIds.remove(current.managerId!);
      current = membersById[current.managerId!];
    }
  }

  void _focusHighlightedMember() {
    final highlightedMemberId = widget.highlightedMemberId;
    if (highlightedMemberId == null || highlightedMemberId.isEmpty) {
      return;
    }

    final targetContext = _nodeKeys[highlightedMemberId]?.currentContext;
    final sceneContext = _sceneKey.currentContext;
    final viewerContext = _viewerKey.currentContext;

    if (targetContext == null ||
        sceneContext == null ||
        viewerContext == null) {
      return;
    }

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final sceneBox = sceneContext.findRenderObject() as RenderBox?;
    final viewerBox = viewerContext.findRenderObject() as RenderBox?;

    if (targetBox == null || sceneBox == null || viewerBox == null) {
      return;
    }

    final sceneCenter = targetBox.localToGlobal(
      targetBox.size.center(Offset.zero),
      ancestor: sceneBox,
    );

    final currentScale = _transformationController.value.storage[0];
    final targetScale = currentScale < 0.75 ? 0.75 : currentScale;

    final targetMatrix = Matrix4.identity()
      ..translateByDouble(
        viewerBox.size.width / 2 - sceneCenter.dx * targetScale,
        viewerBox.size.height / 2 - sceneCenter.dy * targetScale,
        0.0,
        0.0,
      )
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);

    _focusAnimationController.stop();
    _focusAnimationController.reset();

    _focusAnimation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: targetMatrix,
        ).animate(
          CurvedAnimation(
            parent: _focusAnimationController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _focusAnimationController.forward();
  }

  void _toggleNode(String nodeId) {
    setState(() {
      if (_collapsedNodeIds.contains(nodeId)) {
        _collapsedNodeIds.remove(nodeId);
      } else {
        _collapsedNodeIds.add(nodeId);
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tree Branch (recursive)
// ─────────────────────────────────────────────────────────────────────────────

class _TreeBranch extends StatelessWidget {
  const _TreeBranch({
    required this.node,
    required this.collapsedNodeIds,
    required this.onToggleCollapsed,
    required this.onNodeTap,
    required this.nodeKeys,
    required this.highlightedMemberId,
    this.depth = 0,
    this.animationIndex = 0,
  });

  final TreeNode node;
  final Set<String> collapsedNodeIds;
  final ValueChanged<String> onToggleCollapsed;
  final ValueChanged<Member> onNodeTap;
  final Map<String, GlobalKey> nodeKeys;
  final String? highlightedMemberId;
  final int depth;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final isCollapsed = collapsedNodeIds.contains(node.member.id);
    final hasChildren = node.hasChildren;
    final children = node.children;
    final childCount = _countAllDescendants(node);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Node card ────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: depth * 22.0),
          child: _TreeNodeCard(
            key: nodeKeys[node.member.id],
            member: node.member,
            hasChildren: hasChildren,
            isCollapsed: isCollapsed,
            isOrphan: node.isOrphan,
            depth: depth,
            childCount: childCount,
            onTap: () => onNodeTap(node.member),
            onToggleCollapsed: hasChildren
                ? () => onToggleCollapsed(node.member.id)
                : null,
            isHighlighted: highlightedMemberId == node.member.id,
          ),
        ),

        // ── Children ─────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topLeft,
          child: hasChildren && !isCollapsed
              ? Padding(
                  padding: EdgeInsets.only(left: depth * 22.0 + 20),
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      childCount: children.length,
                      childSpacing: 78,
                      color: departmentBadgeColor(node.member.department)
                          .withValues(alpha: 0.3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          for (var i = 0; i < children.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _TreeBranch(
                                node: children[i],
                                collapsedNodeIds: collapsedNodeIds,
                                onToggleCollapsed: onToggleCollapsed,
                                onNodeTap: onNodeTap,
                                nodeKeys: nodeKeys,
                                highlightedMemberId: highlightedMemberId,
                                depth: depth + 1,
                                animationIndex: i,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  int _countAllDescendants(TreeNode node) {
    var count = node.children.length;
    for (final child in node.children) {
      count += _countAllDescendants(child);
    }
    return count;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connector Lines — CustomPainter with curved Bézier lines
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.childCount,
    required this.childSpacing,
    required this.color,
  });

  final int childCount;
  final double childSpacing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (childCount == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startX = 0.0;
    const endX = 16.0;
    const curveRadius = 10.0;

    // Draw vertical trunk
    final firstChildY = 8.0 + 35;
    final lastChildY = 8.0 + (childCount - 1) * childSpacing + 35;

    if (childCount > 1) {
      canvas.drawLine(
        Offset(startX, firstChildY - curveRadius),
        Offset(startX, lastChildY - curveRadius),
        paint,
      );
    }

    // Draw horizontal branches with rounded corner
    for (var i = 0; i < childCount; i++) {
      final childY = 8.0 + i * childSpacing + 35;
      final path = Path();

      if (childCount == 1) {
        // Single child — simple L-shape
        path.moveTo(startX, 0);
        path.lineTo(startX, childY - curveRadius);
        path.quadraticBezierTo(
          startX, childY,
          startX + curveRadius, childY,
        );
        path.lineTo(endX, childY);
      } else {
        // Branch from trunk
        path.moveTo(startX, childY - curveRadius);
        path.quadraticBezierTo(
          startX, childY,
          startX + curveRadius, childY,
        );
        path.lineTo(endX, childY);
      }

      canvas.drawPath(path, paint);
    }

    // Vertical line from top to first branch
    if (childCount > 0) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX, firstChildY - curveRadius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.childCount != childCount ||
      oldDelegate.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tree Node Card
// ─────────────────────────────────────────────────────────────────────────────

class _TreeNodeCard extends StatelessWidget {
  const _TreeNodeCard({
    super.key,
    required this.member,
    required this.hasChildren,
    required this.isCollapsed,
    required this.isOrphan,
    required this.depth,
    required this.childCount,
    required this.onTap,
    required this.isHighlighted,
    this.onToggleCollapsed,
  });

  final Member member;
  final bool hasChildren;
  final bool isCollapsed;
  final bool isOrphan;
  final int depth;
  final int childCount;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback? onToggleCollapsed;

  double get _cardScale {
    if (depth == 0) return 1.0;
    if (depth == 1) return 0.95;
    return 0.90;
  }

  @override
  Widget build(BuildContext context) {
    final deptColor = departmentBadgeColor(member.department);

    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        constraints: BoxConstraints(
          minWidth: depth == 0 ? 260 : 220,
          maxWidth: depth == 0 ? 340 : 300,
        ),
        transform: Matrix4.identity()..scaleByDouble(_cardScale, _cardScale, 1.0, 1.0),
        transformAlignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isHighlighted
                  ? AppTheme.violet.withValues(alpha: 0.2)
                  : AppTheme.bgCard,
              isHighlighted
                  ? AppTheme.violet.withValues(alpha: 0.1)
                  : AppTheme.bgElevated.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? AppTheme.violet.withValues(alpha: 0.6)
                : AppTheme.borderSubtle,
            width: isHighlighted ? 1.5 : 1,
          ),
          boxShadow: [
            ...AppTheme.subtleShadow,
            if (isHighlighted) ...AppTheme.glowShadow,
            if (depth == 0)
              BoxShadow(
                color: deptColor.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Left accent stripe
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: departmentGradientColors(member.department),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with gradient ring for highlighted
                        _NodeAvatar(
                          member: member,
                          isHighlighted: isHighlighted,
                          depth: depth,
                        ),
                        const SizedBox(width: 10),

                        // Name + role
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: depth == 0 ? 16 : 14,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // Collapse toggle
                        if (hasChildren && onToggleCollapsed != null) ...[
                          const SizedBox(width: 6),
                          _CollapseButton(
                            isCollapsed: isCollapsed,
                            childCount: childCount,
                            onTap: onToggleCollapsed!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Badge(
                          label: member.department,
                          color: deptColor,
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          label: member.team,
                          color: AppTheme.textSecondary,
                          isSubtle: true,
                        ),
                      ],
                    ),

                    if (isOrphan)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _Badge(
                          label: '⚠ Manager missing',
                          color: const Color(0xFFFF8A65),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar with optional gradient ring
// ─────────────────────────────────────────────────────────────────────────────

class _NodeAvatar extends StatelessWidget {
  const _NodeAvatar({
    required this.member,
    required this.isHighlighted,
    required this.depth,
  });

  final Member member;
  final bool isHighlighted;
  final int depth;

  double get _radius => depth == 0 ? 20.0 : 16.0;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: _radius,
      backgroundColor: departmentBadgeColor(member.department)
          .withValues(alpha: 0.18),
      backgroundImage:
          member.photoUrl != null && member.photoUrl!.isNotEmpty
              ? NetworkImage(member.photoUrl!)
              : null,
      child: member.photoUrl != null && member.photoUrl!.isNotEmpty
          ? null
          : Text(
              member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: _radius * 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
    );

    if (!isHighlighted) return avatar;

    // Gradient ring for highlighted nodes
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.headerGradient,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.bgCard,
        ),
        child: avatar,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapse button with animated rotation + child count
// ─────────────────────────────────────────────────────────────────────────────

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({
    required this.isCollapsed,
    required this.childCount,
    required this.onTap,
  });

  final bool isCollapsed;
  final int childCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$childCount',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              turns: isCollapsed ? 0.0 : 0.5,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
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
        border: isSubtle
            ? null
            : Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSubtle ? AppTheme.textSecondary : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyTreeState extends StatelessWidget {
  const _EmptyTreeState({required this.onAddRequested});

  final VoidCallback onAddRequested;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.accentGlowSubtle,
            ),
            child: Icon(
              Icons.hub_outlined,
              size: 48,
              color: AppTheme.violet.withValues(alpha: 0.7),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          const SizedBox(height: 20),
          Text(
            'No members yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add the first person to build your org chart',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAddRequested,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add member'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms);
  }
}
