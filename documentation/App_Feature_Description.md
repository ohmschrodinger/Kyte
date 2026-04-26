# Kyte App Feature Description (Code-Based)

Last reviewed: 2026-04-25

This document describes what the app currently does based on the implementation in the project source code.
It focuses on implemented behavior, runtime modes, constraints, and screen-level flows.

---

## 1) What This App Is

Kyte is a Flutter app for managing and visualizing an organizational hierarchy.

Core value:
- Maintain people records (name, role, department, team, manager, optional photo URL).
- View relationships as an interactive, collapsible organization tree.
- Open detailed member profiles from both list and tree views.
- Keep data live-synced through Firestore streams, with automatic fallback to local demo data if backend connectivity fails.

The app is a Firebase + Flutter direct client implementation (no custom backend server).

---

## 2) Runtime Modes and Boot Flow

### 2.1 Startup sequence
- `main.dart` initializes Flutter bindings.
- `AppBootstrap.initialize()` attempts:
	- optional `.env` load (`flutter_dotenv`)
	- Firebase initialization using `DefaultFirebaseOptions.currentPlatform`
- If Firebase init succeeds:
	- `firebaseReady = true`
	- `demoMode = false` (live mode)
- If Firebase init fails:
	- `firebaseReady = false`
	- `demoMode = true` (demo fallback)
	- warning message is retained and displayed in UI where relevant.

### 2.2 Data mode behavior
- Live mode uses Firestore reads/writes and snapshots.
- Demo mode uses in-memory seeded list from `demo_member_seed.dart`.
- If stream errors are transient (e.g. unavailable/deadline exceeded), provider can switch to local fallback dynamically.

---

## 3) Data Model

Single domain model: `Member`

Fields:
- `id` (string)
- `name` (string)
- `role` (string)
- `department` (string)
- `team` (string)
- `managerId` (nullable string)
- `photoUrl` (nullable string)

Behavior notes:
- `hasManager` checks `managerId` presence.
- Firestore mapping is explicit via `fromFirestore`, `fromMap`, and `toMap`.

---

## 4) App Navigation and Screen Structure

Primary shell: `MainNavigationScreen` with persistent floating bottom navigation.

Tabs:
1. Home (Dashboard)
2. Users
3. Org Chart
4. Add Member

Implemented as `IndexedStack`, so tab states are preserved when switching.

---

## 5) Detailed Feature Breakdown

## 5.1 Dashboard (Home tab)

Purpose:
- Give a high-level organization summary.

Implemented features:
- Greeting based on current time of day.
- Environment badge: `Demo` or `Live`.
- Stats cards:
	- total members
	- number of departments
	- number of root nodes (members without manager)
- Department breakdown:
	- sorted by count descending
	- animated progress bars proportional to total members
- Quick action cards:
	- "View Org Chart"
	- "Add Member"
	- currently visual only (onTap placeholders, no tab switch wired).
- Loading skeleton when provider is loading.

Animation and style:
- Heavy use of `flutter_animate` for staged entrances and shimmer skeletons.

## 5.2 Users Screen

Purpose:
- Browse all members as cards, with search and role filtering.

Implemented features:
- Search across multiple fields (case-insensitive):
	- name
	- role
	- department
	- team
- Role filter bottom sheet:
	- includes "All roles" option
	- dynamic role list from current members
- View mode toggle:
	- grouped by department
	- flat list
- Active filter chip with one-tap clear.
- Result count display with singular/plural handling.
- Error banner if provider has an error message.
- Empty state for no matches.
- Tap any user card to open full profile bottom sheet.

Card behavior:
- Avatar shows network image when `photoUrl` exists; otherwise initials.
- Department color and gradient badges are derived from utility mapping.

## 5.3 Org Chart Screen

Purpose:
- Visualize reporting hierarchy with interaction.

Implemented features:
- Interactive tree rendering from flat member list using `buildTree()`.
- Supports multiple roots.
- Handles orphans (members with missing manager) by promoting them to roots and tagging them.
- InteractiveViewer support:
	- pan
	- zoom (0.3x to 3.0x)
- Recursive tree cards with custom connector painter.
- Expand/collapse per node.
- Descendant count in collapse badge.
- Profile opening on node tap:
	- phone/smaller layout: opens profile bottom sheet
	- tablet layout: selection + side profile panel
- Highlight support and animated auto-focus to highlighted node via matrix tween.
- Floating action button opens Add Member form.
- Error banners:
	- bootstrap warning (if Firebase init failed)
	- provider errors.
- Empty-tree state with CTA to add first member.

Responsive behavior:
- Tablet breakpoint (`width >= 900`) shows split layout:
	- left: org tree
	- right: profile panel for selected member

## 5.4 Add / Edit Member

Purpose:
- Create and update members while enforcing hierarchy validity.

Implemented features:
- Dual mode:
	- Create (`member == null`)
	- Edit (`member != null`)
- Form sections:
	1. Member Details (required fields)
	2. Reporting Line (collapsible)
	3. Profile Media (collapsible, optional URL)
- Required validation:
	- name
	- role
	- department
	- team
- Role selector via draggable modal picker from predefined role list.
- Manager selector with explicit "No manager (root node)" option.
- Circular hierarchy prevention before submit using provider/service `isCircular`.
- Save flow:
	- add in create mode
	- update in edit mode
- Submit button states:
	- idle
	- loading
	- success check animation
- Post-submit behavior:
	- if navigated as a route and can pop: return `true`
	- if embedded in tab add mode: reset form for next entry.

## 5.5 Member Profile Sheet

Purpose:
- Present full member information and quick actions.

Implemented features:
- Draggable modal bottom sheet.
- Profile header:
	- avatar
	- name
	- role
	- department and team pills
- Info rows:
	- member ID
	- department
	- team
	- reports-to name (or root/missing fallback)
- Direct reports section:
	- count
	- empty state when none
	- animated chips for each report
- Action buttons:
	- Edit (opens Add/Edit in edit mode)
	- Delete (with confirmation dialog)
- Delete behavior:
	- performs subtree delete (selected member + all descendants)
	- shows snackbar confirmation.

---

## 6) Hierarchy and Relationship Logic

### 6.1 Tree construction
`buildTree()` logic:
- build set of valid member IDs
- group children by manager ID
- root criteria:
	- no manager ID
	- or manager ID not found (orphan)
- sort roots and children by name
- recursively construct `TreeNode` list.

### 6.2 Circular dependency check
`isCircular(memberId, newManagerId)`:
- returns false when manager is null/empty
- immediate true when member assigns self as manager
- climbs manager chain upward until root
- detects cycle if target member reappears.

### 6.3 Subtree deletion
`deleteSubtree(rootMemberId)`:
- fetches members once
- builds manager->children lookup
- BFS traversal from root to collect descendants
- deletes all collected IDs:
	- local remove in demo/local mode
	- batched Firestore deletes (chunked up to 500 per batch).

---

## 7) Firestore Service Behavior

The service is resilient and user-friendly:
- persistence enabled where possible
- transient error retry with exponential backoff
- friendly error mapping for common Firebase errors
- optional local fallback enablement when stream layer becomes unavailable.

Supported service operations:
- watch members stream
- one-time member fetch
- fetch member by ID
- add/update/delete member
- delete subtree
- check circular assignment
- seed initial data if Firestore collection is empty.

---

## 8) State Management

`MemberProvider` (ChangeNotifier + Provider):
- owns live list of members
- handles loading and error state
- subscribes to service stream
- keeps members sorted by name
- exposes write actions and validation helpers
- can auto-fallback to local mode after selected stream failures.

---

## 9) UI/UX System

Implemented design stack:
- Custom dark theme (`AppTheme`) with violet/cyan accent strategy.
- Google Fonts integration (`Sora`, `DM Sans`).
- Glassmorphism helper containers.
- Tap-scale press interaction primitive.
- Custom route transitions:
	- fade+slide
	- scale+fade
	- bottom-slide.

Department-aware visual language:
- consistent badge color mapping and gradients by department name.

---

## 10) Security and Access Model

Current state:
- No authentication or role-based authorization in app.
- Firestore rules allow open read/write access to `members` (demo-style policy).

Implication:
- App is suitable for demo/prototyping, not production without auth/rules hardening.

---

## 11) Seed and Demo Data

`demo_member_seed.dart` provides a realistic starter organization.

It includes:
- top/root member
- multiple departments
- nested reporting chain depth (including grandchild level)
- enough data for tree, users list, and profile flows.

---

## 12) Testing Coverage (What Is Present)

Current test files validate core logic and selected UI behavior:
- `firestore_service_test.dart`
	- sorting
	- CRUD in demo mode
	- streaming behavior
	- circular detection
	- subtree deletion
- `tree_builder_test.dart`
	- nested tree generation
	- orphan promotion to root
- `org_tree_view_test.dart`
	- tapping child node opens profile details
- `home_search_test.dart` and `widget_test.dart`
	- present, but appear to target earlier UI expectations and may not fully match current screen structure.

---

## 13) Implemented vs Planned (Important Clarification)

Some project docs/README mention features that are only partial or currently different in implementation.

Implemented now:
- Users search/filter is active and comprehensive.
- Org tree supports highlight/focus inputs, expand/collapse, pan/zoom.
- Real-time stream model with fallback.
- Subtree deletion and circular validation.

Not fully wired in current UI:
- Dashboard quick action cards do not navigate yet.
- Explicit org-chart search input is not currently present in `HomeScreen` UI (search is concentrated in `UsersScreen`).

Potentially legacy artifacts:
- Both `firebase_options.dart` and `firebase_option.dart` exist; bootstrap imports `firebase_options.dart`.

---

## 14) File-by-File Feature Map (Core App)

### App bootstrap and shell
- `lib/main.dart`: app entry.
- `lib/app/bootstrap.dart`: env + Firebase init + demo fallback flags.
- `lib/app/kyte_app.dart`: Provider and MaterialApp wiring.
- `lib/screens/main_navigation_screen.dart`: 4-tab IndexedStack navigation shell.

### Domain and state
- `lib/models/member.dart`: member entity and serialization.
- `lib/providers/member_provider.dart`: app state and stream orchestration.
- `lib/services/firestore_service.dart`: data access, retry, fallback, subtree/cycle logic.

### Screens
- `lib/screens/dashboard_screen.dart`: summary dashboard and stats.
- `lib/screens/users_screen.dart`: searchable/filterable user directory.
- `lib/screens/home_screen.dart`: org chart screen + tablet panel.
- `lib/screens/add_member_screen.dart`: create/edit member workflow.
- `lib/screens/profile_sheet.dart`: detailed member modal and actions.

### Widgets and rendering primitives
- `lib/widgets/org_tree_view.dart`: recursive org chart renderer and interactions.
- `lib/widgets/glass_container.dart`: frosted reusable container.
- `lib/widgets/tap_scale.dart`: press-scale interaction wrapper.
- `lib/widgets/animated_list_item.dart`: staggered list entrance helper.

### Utilities
- `lib/utils/tree_builder.dart`: flat-to-tree hierarchy builder.
- `lib/utils/department_colors.dart`: department color/gradient mapping.
- `lib/utils/member_roles.dart`: canonical role list.
- `lib/utils/demo_member_seed.dart`: demo org seed data.
- `lib/utils/app_theme.dart`: global theme design system.
- `lib/utils/app_transitions.dart`: custom route transitions.

### Firebase config and rules
- `lib/firebase_options.dart`: FlutterFire-generated platform options in active use.
- `lib/firebase_option.dart`: alternate/legacy options file (not used by bootstrap).
- `firestore.rules`: currently open rule set for `members` collection.

---

## 15) Practical Summary

Kyte already delivers a polished demo-grade org management experience:
- editable people records
- hierarchy-safe relationships
- interactive tree visualization
- detailed profile operations
- resilient data layer with graceful fallback
- modern animated UI for dashboard/list/tree flows.

To make it production-ready, the biggest next layers are auth/authorization, hardened Firestore rules, and completion of minor wiring gaps (like dashboard action navigation).
