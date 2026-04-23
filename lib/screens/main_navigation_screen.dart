import 'package:flutter/material.dart';

import '../app/bootstrap.dart';
import '../utils/app_theme.dart';
import 'add_member_screen.dart';
import 'home_screen.dart';
import 'users_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const _HomeWelcomeTab(),
          const UsersScreen(),
          HomeScreen(bootstrap: widget.bootstrap),
          const AddMemberScreen(showHeader: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home Screen',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree_rounded),
            label: 'Organisation Chart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt_outlined),
            selectedIcon: Icon(Icons.person_add_alt_1_rounded),
            label: 'Add User',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeWelcomeTab extends StatelessWidget {
  const _HomeWelcomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kyte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.accentBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kyte',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Know Your People',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSectionHeader(
                    title: 'The Problem',
                    icon: Icons.report_problem_rounded,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "In large organizations, people struggle to understand who reports to whom, who to approach for what, and where they fit in the bigger picture. There's no single, visual, and real-time source of truth for organizational relationships — leading to onboarding confusion, miscommunication, and wasted time.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _InfoSectionHeader(
                    title: 'How We Built Kyte',
                    icon: Icons.auto_fix_high_rounded,
                  ),
                  const SizedBox(height: 16),
                  const _DesignThinkingStep(
                    step: 'Empathy',
                    description:
                        'We spoke with 7 real users — interns, HR managers, executives, and employees — and discovered that hierarchy confusion isn\'t just inconvenient, it costs productivity and belonging.',
                    icon: Icons.favorite_rounded,
                  ),
                  const _DesignThinkingStep(
                    step: 'Define',
                    description:
                        '"Employees in large organizations cannot efficiently navigate hierarchical relationships due to the absence of a centralized, visual, and interactive mapping system."',
                    icon: Icons.lightbulb_rounded,
                  ),
                  const _DesignThinkingStep(
                    step: 'Ideate',
                    description:
                        'We explored 6 different solution concepts — from AR overlays to chatbots — before converging on an interactive mobile org tree that is simple, scalable, and human.',
                    icon: Icons.psychology_rounded,
                  ),
                  const _DesignThinkingStep(
                    step: 'Prototype',
                    description:
                        'We designed 8 screens in Figma: an org tree, member profiles, smart search, admin controls, and a guided onboarding tour — built for clarity at any organization size.',
                    icon: Icons.draw_rounded,
                  ),
                  const _DesignThinkingStep(
                    step: 'Test',
                    description:
                        '5 users tested Kyte. Every piece of feedback became a design improvement — from color-coded reporting lines to one-tap contact actions.',
                    icon: Icons.checklist_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Switch to "Organisation Chart" to explore the tree',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoSectionHeader extends StatelessWidget {
  const _InfoSectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentBlue),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DesignThinkingStep extends StatelessWidget {
  const _DesignThinkingStep({
    required this.step,
    required this.description,
    required this.icon,
  });

  final String step;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.accentBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
