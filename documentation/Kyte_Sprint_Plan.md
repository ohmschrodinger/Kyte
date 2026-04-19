# Kyte – Sprint Planning Document
**Relationship Mapping App | Flutter + Firebase Firestore | 8 Sprints · 16 Weeks**

---

## Project Overview

Kyte is a Flutter-based mobile application for visualizing and managing organizational hierarchy using Firebase Firestore as its real-time backend. This document outlines the complete 8-sprint delivery plan, broken into 2-week iterations, each with detailed user stories, acceptance criteria, story points, and priorities.

### Technology Stack
- **Frontend:** Flutter (Dart)
- **Backend / Database:** Firebase Cloud Firestore
- **State Management:** Provider or Riverpod
- **Image Storage:** Firebase Storage (optional for photos)
- **Testing:** flutter_test, integration_test, Firebase Emulator Suite

---

## Sprint Timeline Summary

| Sprint | Focus Area | Key Deliverable | Weeks | Story Points |
|--------|-----------|-----------------|-------|-------------|
| Sprint 1 | Project Setup & Firebase Integration | Runnable app skeleton with Firestore read/write verified | Week 1–2 | 34 |
| Sprint 2 | Member CRUD – Add & View | Add Member screen functional; Profile popup shows all fields | Week 3–4 | 36 |
| Sprint 3 | Member CRUD – Edit & Delete | Edit and Delete flows complete with confirmation dialogs | Week 5–6 | 35 |
| Sprint 4 | Tree Hierarchy Visualization – Core | Scrollable, zoomable org-chart tree rendered from live Firestore data | Week 7–8 | 40 |
| Sprint 5 | Search Functionality & Node Highlighting | Functional search bar with highlight and auto-scroll to matched node | Week 9–10 | 30 |
| Sprint 6 | UI Polish & Responsive Design | Pixel-perfect UI consistent across Android and iOS devices | Week 11–12 | 28 |
| Sprint 7 | Real-Time Updates, Error Handling & Edge Cases | App handles network loss, Firestore errors, and unusual data states gracefully | Week 13–14 | 32 |
| Sprint 8 | Testing, Performance & Demo Release | APK/IPA demo build; README with setup guide; all tests passing | Week 15–16 | 30 |

**Total Story Points: 265**

---

## Sprint 1: Project Setup & Firebase Integration
**Duration:** Week 1–2 (14 days)
**Goal:** Establish the foundational Flutter project structure and connect to Firebase Firestore.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 34 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter, Firebase Core, Cloud Firestore, flutter_dotenv |
| Deliverable | Runnable app skeleton with Firestore read/write verified |
| Dependencies | Flutter SDK installed, Firebase project created in console |
| Risk | Firebase config mismatch across platforms (Android / iOS) |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S1-T01 | As a dev, I want Firebase connected to Flutter | Add Firebase Core, Firestore, and configure google-services.json / GoogleService-Info.plist for Android and iOS respectively. | App runs without crash; firebase_core initialised in main(); Firestore read test passes. | 5 | 🔴 High | Lead Dev |
| S1-T02 | As a dev, I want a clean folder structure | Scaffold project folders: /models, /services, /screens, /widgets, /providers, /utils. Add barrel export files. | Folders exist; barrel files compile; no unused imports. | 3 | 🔴 High | Lead Dev |
| S1-T03 | As a dev, I want a Member data model | Create Member class with fields: id, name, role, department, team, managerId (nullable). Add fromFirestore() and toMap() methods. | Unit tests pass for serialisation/deserialisation from Firestore snapshot. | 5 | 🔴 High | Lead Dev |
| S1-T04 | As a dev, I want a Firestore service layer | Create FirestoreService class with methods: getMembers(), addMember(), updateMember(), deleteMember(). Wrap Firestore calls; expose streams. | getMembers() returns Stream<List<Member>>; CRUD methods tested manually in Firestore console. | 8 | 🔴 High | Lead Dev |
| S1-T05 | As a dev, I want state management set up | Integrate Provider or Riverpod. Create MemberProvider that exposes member list and loading/error states. | MemberProvider notifies widgets on data change; no setState() in business logic. | 5 | 🔴 High | Lead Dev |
| S1-T06 | As a dev, I want environment variables managed safely | Add flutter_dotenv. Store Firebase config keys outside code. Add .env to .gitignore. | .env loads on startup; no API keys visible in source control. | 3 | 🟡 Medium | Lead Dev |
| S1-T07 | As a dev, I want CI lint checks | Add analysis_options.yaml with recommended Dart rules. Configure flutter analyze to pass with zero warnings. | flutter analyze returns 0 issues on main branch. | 3 | 🟢 Low | Lead Dev |
| S1-T08 | As a dev, I want seed data in Firestore | Write a one-time seed script (Dart or Node.js) that populates 10–15 demo members with realistic roles, departments, and managerId chains. | Firestore console shows members with correct managerId references; tree can be manually traced. | 2 | 🟡 Medium | Lead Dev |

### Definition of Done – Sprint 1
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 2: Member CRUD – Add & View
**Duration:** Week 3–4 (14 days)
**Goal:** Allow users to create new members and view complete member profiles.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 36 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter Forms, Firestore, Provider |
| Deliverable | Add Member screen functional; Profile popup shows all fields |
| Dependencies | Sprint 1 complete; FirestoreService CRUD layer ready |
| Risk | Form validation edge cases (empty name, duplicate roles) |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S2-T01 | As a user, I want to open an Add Member screen | Create AddMemberScreen as a full-screen route. Include AppBar with 'Add Member' title and back navigation. | Screen accessible via FAB on main screen; back button returns to main. | 3 | 🔴 High | Frontend Dev |
| S2-T02 | As a user, I want to fill in member details | Add TextFormField widgets for Name (mandatory), Role (dropdown from predefined list), Department (text), Team (text). | All fields render; Name shows error if empty on submit; Role dropdown shows all predefined roles. | 5 | 🔴 High | Frontend Dev |
| S2-T03 | As a user, I want to select a manager from a dropdown | Add manager selection dropdown that fetches existing members from Firestore. Show member name in dropdown. Map selected member to managerId. | Dropdown lists all members by name; selected manager's ID saved to managerId field; null allowed (root node). | 8 | 🔴 High | Frontend Dev |
| S2-T04 | As a user, I want to upload a profile photo | Add optional profile photo upload using image_picker. Store image as Base64 or upload to Firebase Storage and save URL in member doc. | User can pick image from gallery; photo previews in form; URL persisted in Firestore doc. | 5 | 🟡 Medium | Frontend Dev |
| S2-T05 | As a user, I want to submit the new member | On form submit, validate all mandatory fields, call FirestoreService.addMember(), show loading indicator, then navigate back. | New member appears in Firestore; success SnackBar shown; loading spinner visible during save. | 5 | 🔴 High | Frontend Dev |
| S2-T06 | As a user, I want to view a member's full profile | Create ProfileSheet (bottom sheet or popup dialog). Display avatar, name, role, department, team, manager name (resolved from managerId). | Tapping a member node opens profile; all fields displayed; managerId resolved to manager name. | 5 | 🔴 High | Frontend Dev |
| S2-T07 | As a user, I want to see placeholder if no photo | Show initials-based circular avatar when no photo is uploaded. | Avatar shows first letter of name on dark background when photoUrl is null. | 2 | 🟢 Low | Frontend Dev |
| S2-T08 | As a dev, I want form state preserved on rotation | Wrap form in a RestorationMixin or use a Controller so form values survive device rotation. | Rotate device mid-form; all typed values remain intact. | 3 | 🟡 Medium | Frontend Dev |

### Definition of Done – Sprint 2
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 3: Member CRUD – Edit & Delete
**Duration:** Week 5–6 (14 days)
**Goal:** Allow users to fully edit member data and safely delete members with subtree removal.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 35 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter, Firestore batch writes, recursive deletion logic |
| Deliverable | Edit and Delete flows complete with confirmation dialogs |
| Dependencies | Sprint 2 complete; ProfileSheet in place |
| Risk | Recursive subtree deletion may hit Firestore batch limits (500 docs) |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S3-T01 | As a user, I want an Edit button on the profile | Add Edit icon/button in ProfileSheet. Navigate to EditMemberScreen pre-filled with current member data. | Edit screen opens with all fields pre-populated from selected member's Firestore doc. | 3 | 🔴 High | Frontend Dev |
| S3-T02 | As a user, I want to update member details | Reuse AddMemberScreen as EditMemberScreen (or use isEdit flag). On save, call FirestoreService.updateMember() with changed fields. | Updated values visible in Firestore immediately after save; UI refreshes via stream. | 5 | 🔴 High | Frontend Dev |
| S3-T03 | As a user, I want to change a member's manager | Manager dropdown in edit form allows selecting a different manager. Validate: cannot assign self as manager; cannot create circular chain. | Manager changed in Firestore; circular assignment shows error toast; self-assignment blocked. | 8 | 🔴 High | Backend/Logic Dev |
| S3-T04 | As a user, I want a Delete button on the profile | Add Delete (trash) icon in ProfileSheet. Show confirmation dialog: 'This will also delete all subordinates. Confirm?' | Dialog appears with member name; Cancel aborts; Confirm triggers deletion. | 3 | 🔴 High | Frontend Dev |
| S3-T05 | As a dev, I want recursive subtree deletion | Implement deleteSubtree(memberId) in FirestoreService. Use BFS/DFS to collect all descendant IDs, then batch-delete using Firestore WriteBatch (chunked to ≤500 per batch). | Deleting root deletes entire tree; Firestore shows no orphan records; tested with 3-level deep tree. | 8 | 🔴 High | Backend/Logic Dev |
| S3-T06 | As a user, I want a success/failure notification after delete | Show SnackBar with member name after successful deletion. Show error SnackBar if Firestore write fails. | SnackBar appears within 500ms of deletion; error state shown on network failure. | 2 | 🟡 Medium | Frontend Dev |
| S3-T07 | As a dev, I want validation to prevent circular relationships | Implement isCircular(memberId, newManagerId) utility that traverses managerId chain upward. Called before any manager assignment save. | Assigning grandparent as manager blocked; unit tests cover direct cycle and indirect cycle. | 5 | 🔴 High | Backend/Logic Dev |
| S3-T08 | As a dev, I want unit tests for deletion and validation | Write widget/unit tests for: subtree deletion logic, circular check, edit form field validation. | Tests pass with flutter test; coverage >80% for service layer methods. | 1 | 🟡 Medium | QA / Lead Dev |

### Definition of Done – Sprint 3
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 4: Tree Hierarchy Visualization – Core
**Duration:** Week 7–8 (14 days)
**Goal:** Build the interactive hierarchical tree view that is the centrepiece of the application.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 40 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter CustomPainter or graphview/flutter_treeview package, InteractiveViewer |
| Deliverable | Scrollable, zoomable org-chart tree rendered from live Firestore data |
| Dependencies | Sprint 1 & 3 complete; Member model and Firestore service stable |
| Risk | Performance with large trees; choosing between custom painter vs third-party package |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S4-T01 | As a dev, I want a tree builder algorithm | Write buildTree(List<Member>) that identifies root nodes (managerId==null), recursively links children, returns List<TreeNode>. | Unit tested with flat list; produces correct parent-child nesting; handles multiple roots gracefully. | 8 | 🔴 High | Lead Dev |
| S4-T02 | As a user, I want to see the org chart on the main screen | Render tree using InteractiveViewer wrapping a custom layout widget or graphview package. Each member shown as a node card (avatar + name + role). | Tree renders all seeded members; root at top; lines connect parent to children. | 8 | 🔴 High | Frontend Dev |
| S4-T03 | As a user, I want to zoom and pan the tree | Wrap tree in InteractiveViewer with pinch-zoom and drag-pan. Set min/max scale (0.3x – 3.0x). | Pinch zoom works on device; pan works with one finger; bounds prevent going off-screen. | 5 | 🔴 High | Frontend Dev |
| S4-T04 | As a user, I want node cards with member info | Design TreeNodeCard widget: circular avatar (photo or initial), member name (bold), role (subtitle). Card has rounded corners and elevation shadow. | Card renders for each member; photo shown if available; initials fallback correct. | 5 | 🔴 High | Frontend Dev |
| S4-T05 | As a user, I want to expand/collapse subtrees | Add expand/collapse toggle (chevron icon) on each node that has children. Collapsed node hides all descendants. | Toggling collapse hides children; toggling expand shows them; animation is smooth (AnimatedOpacity or similar). | 8 | 🔴 High | Frontend Dev |
| S4-T06 | As a user, I want to tap a node to open the profile | Tapping a TreeNodeCard opens the ProfileSheet (built in Sprint 2) for that member. | Tap triggers ProfileSheet with correct member data; no delay >300ms. | 3 | 🔴 High | Frontend Dev |
| S4-T07 | As a dev, I want the tree to auto-refresh from Firestore | Tree widget subscribes to MemberProvider stream. On any Firestore change, tree rebuilds automatically. | Add/edit/delete member in Firestore console; tree updates within 2 seconds without manual refresh. | 3 | 🔴 High | Lead Dev |

### Definition of Done – Sprint 4
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 5: Search Functionality & Node Highlighting
**Duration:** Week 9–10 (14 days)
**Goal:** Enable users to search for any member by name and navigate the tree to their node.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 30 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter SearchDelegate or custom search bar, ScrollController, AnimationController |
| Deliverable | Functional search bar with highlight and auto-scroll to matched node |
| Dependencies | Sprint 4 complete; tree layout with node positions calculable |
| Risk | Auto-scroll to an arbitrary node in a dynamic tree requires position tracking |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S5-T01 | As a user, I want a search bar at the top of the screen | Add persistent search bar (TextField or SearchBar widget) at the top of the main screen. Accepts text input. | Search bar visible at top; keyboard appears on tap; clear (X) button clears text. | 3 | 🔴 High | Frontend Dev |
| S5-T02 | As a user, I want live search suggestions while typing | Filter member list in real-time as user types. Display matching names in a dropdown overlay below the search bar. | Suggestions update with each keystroke; shows up to 8 results; no results shows 'No member found'. | 5 | 🔴 High | Frontend Dev |
| S5-T03 | As a user, I want case-insensitive name search | Search logic normalises both query and member names to lowercase before comparing. | Searching 'alice', 'Alice', 'ALICE' all return the same result. | 2 | 🔴 High | Frontend Dev |
| S5-T04 | As a user, I want the matched node highlighted in the tree | On selecting a search result, apply a highlight border/color to the matching TreeNodeCard (e.g., amber glow or outline). | Selected node has distinct visual highlight; highlight clears when search is cleared. | 5 | 🔴 High | Frontend Dev |
| S5-T05 | As a user, I want the tree to scroll to the highlighted node | After highlighting, programmatically scroll (and zoom if needed) so the matched node is centred in the viewport. | Tree animates to bring highlighted node into centre view within 600ms; works for deeply nested nodes. | 8 | 🔴 High | Frontend Dev |
| S5-T06 | As a user, I want collapsed ancestors auto-expanded on search | If the matched node's parent chain has collapsed nodes, expand them automatically before scrolling. | Node inside collapsed subtree found by search; all ancestors expand; node highlighted and scrolled into view. | 5 | 🟡 Medium | Frontend Dev |
| S5-T07 | As a user, I want to search by role or department too | Extend search to match on role and department fields in addition to name. Show field matched as a subtitle in suggestion list. | Typing 'SDE I' returns all SDE I members; subtitle shows 'Role match' or 'Dept match'. | 2 | 🟢 Low | Frontend Dev |

### Definition of Done – Sprint 5
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 6: UI Polish & Responsive Design
**Duration:** Week 11–12 (14 days)
**Goal:** Refine visual design, ensure responsiveness across screen sizes, and deliver a polished mobile experience.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 28 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Flutter theming, MediaQuery, LayoutBuilder, Material 3 |
| Deliverable | Pixel-perfect UI consistent across Android and iOS devices |
| Dependencies | All core features (Sprints 1–5) merged and stable |
| Risk | iOS-specific rendering differences; font scaling on accessibility settings |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S6-T01 | As a user, I want a consistent visual theme | Define ThemeData with brand colors, typography (e.g., Inter or Roboto), button styles, card styles. Apply globally via MaterialApp.theme. | All screens use theme colors; no hardcoded hex colors in widgets; dark-mode-ready structure. | 5 | 🔴 High | Frontend Dev |
| S6-T02 | As a user, I want smooth screen transitions | Add page route transitions (slide or fade) for all navigation actions using PageRouteBuilder or go_router. | All navigation transitions animate at 60fps; no janky frame drops on mid-range device. | 3 | 🟡 Medium | Frontend Dev |
| S6-T03 | As a user, I want loading skeletons instead of spinners | Replace CircularProgressIndicator on tree load with shimmer skeleton cards using the shimmer package. | Shimmer animation plays while Firestore data loads; disappears once data arrives. | 5 | 🟡 Medium | Frontend Dev |
| S6-T04 | As a user, I want the app to work on tablet layout | Use LayoutBuilder / MediaQuery to detect tablet width (>600dp). On tablet, show tree on left and profile panel on right simultaneously. | On 10" tablet emulator, tree and profile show side-by-side without overflow. | 5 | 🟡 Medium | Frontend Dev |
| S6-T05 | As a user, I want accessible font sizes | Ensure all text respects system text scale factor. Test with accessibility font size set to largest in device settings. | No text overflow or clipping at 200% text scale; labels wrap gracefully. | 3 | 🟡 Medium | Frontend Dev |
| S6-T06 | As a user, I want color-coded department badges | Add a small colored badge/chip on each TreeNodeCard showing the department. Each department gets a distinct color (map defined in utils). | Badge visible on node card; color is consistent for same department across tree. | 3 | 🟢 Low | Frontend Dev |
| S6-T07 | As a user, I want empty-state illustrations | Show an SVG illustration and friendly message when: tree is empty, search returns no results. | Empty tree shows 'No members yet. Add one!' with illustration; search empty state shows 'No results found'. | 2 | 🟢 Low | Frontend Dev |
| S6-T08 | As a dev, I want pixel-overflow issues fixed | Run flutter test with overflow error detection. Fix all RenderFlex overflow and clipped text issues across all screen sizes. | Zero overflow errors on 4" small phone and 6.7" large phone emulators. | 2 | 🔴 High | Frontend Dev |

### Definition of Done – Sprint 6
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 7: Real-Time Updates, Error Handling & Edge Cases
**Duration:** Week 13–14 (14 days)
**Goal:** Harden the app with robust error handling, offline behaviour, and edge case coverage.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 32 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | Firestore offline persistence, Dart error handling, connectivity_plus |
| Deliverable | App handles network loss, Firestore errors, and unusual data states gracefully |
| Dependencies | Sprints 1–6 complete |
| Risk | Firestore offline cache behavior can be unpredictable on first install |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S7-T01 | As a user, I want the app to work offline | Enable Firestore offline persistence (`Settings(persistenceEnabled: true)`). App reads cached data when offline. | Disable device WiFi; app still displays previously loaded tree; banner shows 'Offline mode'. | 5 | 🔴 High | Lead Dev |
| S7-T02 | As a user, I want an offline indicator banner | Use connectivity_plus package to detect network status. Show non-intrusive top banner 'You are offline – showing cached data' when disconnected. | Banner appears within 2 seconds of network loss; disappears on reconnect. | 3 | 🔴 High | Frontend Dev |
| S7-T03 | As a user, I want meaningful error messages | Wrap all Firestore calls in try/catch. Map FirebaseException codes to user-friendly messages. Show via SnackBar or Dialog. | permission-denied shows 'Access denied'; unavailable shows 'Service unavailable, try again'; no raw exceptions shown to user. | 5 | 🔴 High | Lead Dev |
| S7-T04 | As a dev, I want multiple root nodes handled | If Firestore has multiple members with managerId==null, display all as root-level nodes in the tree (forest layout). | Seed two root nodes; both appear at top level of tree; no crash. | 3 | 🟡 Medium | Lead Dev |
| S7-T05 | As a dev, I want orphan nodes handled | If a member's managerId references a deleted member, detect and display orphan at root level with a warning badge. | Manually delete a manager from Firestore; orphan child appears at root with '⚠ Manager missing' badge. | 5 | 🟡 Medium | Lead Dev |
| S7-T06 | As a dev, I want long names and special chars handled | Test member names with 80+ characters, emojis, Arabic/Hindi scripts. Ensure tree layout and profile sheet don't break. | Long names truncate with ellipsis on node card; full name shown in profile sheet. | 3 | 🟡 Medium | QA / Frontend Dev |
| S7-T07 | As a user, I want retry on transient Firestore failures | Implement exponential backoff retry (max 3 attempts) for read/write operations on transient errors (unavailable, deadline-exceeded). | Simulate slow network; app retries silently; user sees loading indicator not error for first 2 attempts. | 5 | 🟡 Medium | Lead Dev |
| S7-T08 | As a dev, I want Firestore security rules set up | Write Firestore security rules allowing read/write to members collection (open for demo; no auth). Deploy to Firebase console. | Rules deployed; app read/write succeeds; rules file committed to repo. | 3 | 🔴 High | Lead Dev |

### Definition of Done – Sprint 7
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded

---

## Sprint 8: Testing, Performance & Demo Release
**Duration:** Week 15–16 (14 days)
**Goal:** Deliver a stable, performant, demo-ready build with full test coverage and documentation.

### Sprint Overview
| Field | Detail |
|-------|--------|
| Total Story Points | 30 |
| Sprint Duration | 2 Weeks (14 Days) |
| Tech Stack | flutter_test, integration_test, flutter_driver, Firebase Emulator |
| Deliverable | APK/IPA demo build; README with setup guide; all tests passing |
| Dependencies | All previous sprints complete and merged to main |
| Risk | Integration tests flaky on CI; iOS signing configuration for build |

### Sprint Backlog

| Task ID | User Story | Description | Acceptance Criteria | Points | Priority | Owner |
|---------|-----------|-------------|---------------------|--------|----------|-------|
| S8-T01 | As a dev, I want unit tests for all service methods | Write unit tests for FirestoreService (mock Firestore), tree builder algorithm, circular check, and subtree deletion logic. | flutter test passes with ≥85% coverage on /services and /utils folders. | 8 | 🔴 High | QA / Lead Dev |
| S8-T02 | As a dev, I want widget tests for key screens | Write widget tests for: AddMemberScreen form validation, ProfileSheet rendering, search bar filtering. | All widget tests pass; pump & settle with no exceptions; golden tests for node card. | 5 | 🔴 High | QA / Lead Dev |
| S8-T03 | As a dev, I want integration tests for the main flow | Write integration_test for the full flow: launch → add member → search → view profile → delete. Use Firebase Emulator Suite. | Integration test completes end-to-end without error on Android emulator. | 5 | 🔴 High | QA / Lead Dev |
| S8-T04 | As a dev, I want tree rendering performance profiled | Use Flutter DevTools to profile tree rendering with 50+ members. Target <16ms frame time. Optimise with const widgets, RepaintBoundary. | DevTools frame chart shows no frames >16ms during tree pan/zoom on release build. | 5 | 🔴 High | Lead Dev |
| S8-T05 | As a dev, I want a release APK and IPA build | Configure release signing for Android (keystore). Build `flutter build apk --release` and `flutter build ios --release`. Verify no debug banners. | APK installs on physical Android device; IPA builds without error; debug banner absent. | 3 | 🔴 High | Lead Dev |
| S8-T06 | As a dev, I want a comprehensive README | Write README.md covering: project overview, prerequisites, Firebase setup steps, how to run (debug and release), folder structure, known limitations. | A new developer follows README and runs app successfully in ≤20 minutes. | 2 | 🟡 Medium | Lead Dev |
| S8-T07 | As a dev, I want demo seed data finalized | Create a realistic 20-member org (4 levels deep) in demo Firestore project. Includes varied roles, departments, photos. | Demo Firestore populated; tree shows full 4-level hierarchy; all features demonstrable. | 2 | 🟡 Medium | Lead Dev |

### Definition of Done – Sprint 8
- [ ] All tasks merged to feature branch; PR reviewed and approved
- [ ] No critical or high-severity bugs open
- [ ] Acceptance criteria verified manually on Android emulator
- [ ] `flutter analyze` returns 0 issues
- [ ] Sprint demo conducted and recorded
- [ ] Release APK distributed to stakeholders

---

## Appendix

### A. Predefined Roles
- Software Development Engineer I (SDE I)
- Software Development Engineer II (SDE II)
- Software Development Engineer III (SDE III)
- Senior Software Engineer
- Principal Software Engineer
- Engineering Manager
- Technical Consultant
- DevOps Engineer
- QA / Test Engineer
- Product Manager

### B. Firestore Member Document Schema

**Collection:** `members`

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated Firestore document ID |
| `name` | string | Full name of the member (mandatory) |
| `role` | string | Job title / designation from predefined list |
| `department` | string | Department the member belongs to |
| `team` | string | Team name within the department |
| `managerId` | string \| null | ID of the manager; null indicates a root node |
| `photoUrl` | string \| null | URL to profile photo in Firebase Storage (optional) |

### C. Story Point Reference

| Points | Complexity | Example |
|--------|-----------|---------|
| 1–2 | Trivial | Add a label, minor UI tweak |
| 3–5 | Small | New screen, form field, simple API call |
| 8 | Medium | Tree algorithm, recursive deletion, complex UI |
| 13+ | Large (split recommended) | Should be broken into smaller tasks |

### D. Priority Legend
- 🔴 **High** – Must be completed within the sprint; blocks other work
- 🟡 **Medium** – Should be completed; can be deferred to next sprint if necessary
- 🟢 **Low** – Nice to have; deferred if sprint capacity is exceeded

---

*Kyte Sprint Planning Document · Version 1.0 · April 2026*
