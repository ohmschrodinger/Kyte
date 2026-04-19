# UI Design Specification
## Organizational Relationship Mapping App
### Flutter Mobile — Visual & Interaction Design Guide

---

## 🎨 Design Direction: "Corporate Neural"

**Concept:** The app feels like you're looking at a **living neural network of people** — not a boring org chart. Think mission-control dashboard meets modern SaaS. Dark, data-dense, but incredibly readable. Every tap feels satisfying. Every transition feels intentional.

**Tone:** Refined dark-tech. Premium. Confident. The kind of UI that makes people go "who built this?"

**The one thing users remember:** The glowing, animated tree of people nodes that pulses like a live system — not a static diagram.

---

## 🎨 Color System

```dart
// === PASTE THIS INTO YOUR theme/colors.dart ===

// Backgrounds
const Color bgDeep      = Color(0xFF080C14);  // near-black, main background
const Color bgCard      = Color(0xFF0F1724);  // card surfaces
const Color bgElevated  = Color(0xFF161F30);  // elevated cards, modals
const Color bgInput     = Color(0xFF1A2236);  // text fields

// Primary Accent
const Color accentBlue  = Color(0xFF3B82F6);  // electric blue — primary CTA
const Color accentGlow  = Color(0xFF60A5FA);  // lighter blue for glow effects

// Secondary Accents (for department color coding)
const Color deptEng     = Color(0xFF6366F1);  // indigo — Engineering
const Color deptMkt     = Color(0xFF10B981);  // emerald — Marketing
const Color deptHR      = Color(0xFFF59E0B);  // amber — HR
const Color deptOps     = Color(0xFFEF4444);  // red — Operations
const Color deptProduct = Color(0xFFEC4899);  // pink — Product

// Text
const Color textPrimary   = Color(0xFFF1F5F9);  // near-white
const Color textSecondary = Color(0xFF94A3B8);  // slate
const Color textMuted     = Color(0xFF475569);  // dim

// Node States
const Color nodeDefault   = Color(0xFF0F1724);
const Color nodeSelected  = Color(0xFF1E3A5F);  // deep selected blue
const Color nodeBorderDef = Color(0xFF1E293B);
const Color nodeBorderSel = Color(0xFF3B82F6);

// Status
const Color success = Color(0xFF10B981);
const Color danger  = Color(0xFFEF4444);
const Color warning = Color(0xFFF59E0B);
```

**Usage rule:** `bgDeep` is always the scaffold background. Cards use `bgCard`. Modals use `bgElevated`. Never use a white or light background anywhere.

---

## 🔤 Typography

```dart
// === PASTE THIS INTO pubspec.yaml under google_fonts ===
// Use: google_fonts package (already in dependencies)

// Display / Headers → Sora
// Body / Labels     → DM Sans
// Monospace / IDs   → JetBrains Mono

// Usage in code:
GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary)
GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary)
GoogleFonts.jetBrainsMono(fontSize: 11, color: textMuted)
```

### Type Scale

| Token | Font | Size | Weight | Use |
|---|---|---|---|---|
| `displayLg` | Sora | 28sp | 700 | Screen titles |
| `displayMd` | Sora | 22sp | 600 | Card headers, names |
| `displaySm` | Sora | 18sp | 600 | Section headers |
| `bodyLg` | DM Sans | 16sp | 400 | Primary body text |
| `bodyMd` | DM Sans | 14sp | 400 | Labels, descriptions |
| `bodySm` | DM Sans | 12sp | 400 | Supporting text |
| `chip` | DM Sans | 11sp | 500 | Tags, badges |
| `mono` | JetBrains Mono | 11sp | 400 | IDs, codes |

---

## 📐 Spacing & Layout System

```dart
// Base unit = 4dp
const double sp4  = 4.0;
const double sp8  = 8.0;
const double sp12 = 12.0;
const double sp16 = 16.0;
const double sp20 = 20.0;
const double sp24 = 24.0;
const double sp32 = 32.0;
const double sp48 = 48.0;

// Border Radius
const double radiusSm  = 8.0;   // chips, small elements
const double radiusMd  = 12.0;  // cards, input fields
const double radiusLg  = 16.0;  // bottom sheets, modals
const double radiusXl  = 24.0;  // FAB, large cards
const double radiusFull = 999.0; // pills, avatars

// Card Elevation Shadow
BoxShadow cardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.4),
  blurRadius: 16,
  offset: Offset(0, 4),
);

BoxShadow glowShadow = BoxShadow(
  color: accentBlue.withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 2,
);
```

---

## ✨ Motion & Animation Principles

- **Duration:** Fast = 150ms, Normal = 250ms, Slow = 400ms
- **Curve:** Always use `Curves.easeOutCubic` for entrances, `Curves.easeInCubic` for exits
- **Rule:** Every state change animates. Nothing pops in without transition.
- **Stagger:** Lists and nodes stagger-reveal at 50ms intervals

### Required Animations

| Element | Animation | Duration |
|---|---|---|
| App load | Nodes fade + slide up staggered | 400ms each, 50ms stagger |
| Node tap | Scale pulse (1.0 → 1.05 → 1.0) | 150ms |
| Node selected | Border glow animates in | 250ms |
| Bottom sheet | Slides up with spring physics | 350ms |
| FAB | Rotation + scale on tap | 200ms |
| Search result | Node pulses with ring ripple | 400ms |
| Delete confirm | Card shakes horizontally | 300ms |
| Form submit success | Checkmark draws + fades | 400ms |

```dart
// Staggered list animation pattern
AnimationController _controller = AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 600),
);

// Per item:
Animation<double> itemAnim = Tween(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Interval(index * 0.1, (index * 0.1) + 0.4, curve: Curves.easeOutCubic),
  ),
);

// Apply as FadeTransition + SlideTransition
```

---

## 📱 SCREEN 1 — Main Screen (Tree + Search)

### Layout Structure
```
┌─────────────────────────────┐
│  [≡]  OrgMapper    [🔍] [+] │  ← AppBar (blurred, not solid)
├─────────────────────────────┤
│                             │
│   ┌──┐                      │
│   │  │ ← root node          │
│   └─┬┘                      │
│   ┌─┴──┐  ┌────┐            │
│   │    │  │    │            │
│   └────┘  └────┘            │
│     (interactive tree)      │
│         [pan / zoom]        │
│                             │
├─────────────────────────────┤
│  ● Eng  ● HR  ● Product ... │  ← Department legend strip
└─────────────────────────────┘
```

### AppBar Design
```dart
// Frosted glass AppBar — NOT a solid color
AppBar(
  backgroundColor: Colors.transparent,
  flexibleSpace: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(color: bgDeep.withOpacity(0.7)),
    ),
  ),
  title: Row(children: [
    // Animated logo mark — a small glowing node icon
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentBlue.withOpacity(0.15),
        border: Border.all(color: accentBlue, width: 1.5),
        boxShadow: [glowShadow],
      ),
      child: Icon(Icons.hub_rounded, size: 14, color: accentBlue),
    ),
    SizedBox(width: 10),
    Text('OrgMapper', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
  ]),
  actions: [
    // Search icon — tapping reveals an animated search bar sliding down
    IconButton(icon: Icon(Icons.search_rounded, color: textSecondary), onPressed: ...),
  ],
)
```

### Search Bar (Animated, Slides Down on Tap)
```dart
// AnimatedContainer that expands from 0 height to ~56 when search is active
AnimatedContainer(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeOutCubic,
  height: _searchActive ? 56 : 0,
  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: bgInput,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: accentBlue.withOpacity(0.4)),
    ),
    child: TextField(
      style: GoogleFonts.dmSans(color: textPrimary),
      decoration: InputDecoration(
        hintText: 'Search by name...',
        hintStyle: GoogleFonts.dmSans(color: textMuted),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 18),
        suffixIcon: _query.isNotEmpty
          ? IconButton(icon: Icon(Icons.close, size: 16, color: textMuted), onPressed: ...)
          : null,
      ),
    ),
  ),
)
```

### Tree Node Design
```dart
// Each node in the GraphView renders this widget
Widget buildNode(Member member, bool isSelected) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    width: 120,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isSelected ? nodeSelected : nodeDefault,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(
        color: isSelected ? nodeBorderSel : nodeBorderDef,
        width: isSelected ? 1.5 : 1,
      ),
      boxShadow: isSelected ? [glowShadow] : [cardShadow],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar circle with department color ring
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: deptColor(member.department).withOpacity(0.15),
            border: Border.all(color: deptColor(member.department), width: 2),
          ),
          child: Center(
            child: Text(
              member.name[0].toUpperCase(),
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: deptColor(member.department),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        // Name
        Text(
          member.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 2),
        // Role
        Text(
          member.role,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(fontSize: 9, color: textMuted),
        ),
        SizedBox(height: 4),
        // Department pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: deptColor(member.department).withOpacity(0.12),
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          child: Text(
            member.department,
            style: GoogleFonts.dmSans(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: deptColor(member.department),
            ),
          ),
        ),
      ],
    ),
  );
}
```

### Department Legend Strip
```dart
// Horizontal scrollable strip at the bottom of the tree screen
Container(
  height: 36,
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: uniqueDepartments.map((dept) =>
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: deptColor(dept),
              boxShadow: [BoxShadow(color: deptColor(dept).withOpacity(0.5), blurRadius: 6)],
            ),
          ),
          SizedBox(width: 6),
          Text(dept, style: GoogleFonts.dmSans(fontSize: 12, color: textSecondary)),
        ]),
      )
    ).toList(),
  ),
)
```

### FAB (Floating Action Button)
```dart
FloatingActionButton(
  backgroundColor: accentBlue,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: accentBlue.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
      ],
    ),
    child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
  ),
  onPressed: ...,
)
```

---

## 📱 SCREEN 2 — Profile Bottom Sheet

### Design
- Opens as a **draggable bottom sheet** (not full-screen push)
- Sheet height: 70% of screen
- Has a drag handle at top
- Background: `bgElevated` with very subtle top border glow

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (_) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    builder: (_, scrollController) => Container(
      decoration: BoxDecoration(
        color: bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accentBlue.withOpacity(0.2), width: 1),
        ),
      ),
      child: ...,
    ),
  ),
)
```

### Profile Sheet Layout
```
┌─────────────────────────────┐
│          ────               │  ← drag handle
│                             │
│   ◉  Priya Sharma           │  ← large avatar (56px) + name
│      Engineering Manager    │  ← role in textSecondary
│      ● Engineering          │  ← dept pill
│                             │
│  ┌──────────────────────┐   │
│  │ 📋 Department   Eng  │   │  ← Info rows
│  │ 👥 Team         Core │   │
│  │ 🔗 Reports To   [Rohit]→ │  ← tappable link
│  └──────────────────────┘   │
│                             │
│  Direct Reports (3)         │  ← section header
│  ┌────┐ ┌────┐ ┌────┐       │  ← horizontal scroll chips
│  │ A  │ │ B  │ │ C  │       │
│  └────┘ └────┘ └────┘       │
│                             │
│  [  ✏️ Edit  ]  [🗑 Delete]  │  ← action buttons
└─────────────────────────────┘
```

### Info Row Widget
```dart
Widget infoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
  return Container(
    margin: EdgeInsets.only(bottom: 2),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: bgCard,
      border: Border(bottom: BorderSide(color: nodeBorderDef, width: 0.5)),
    ),
    child: Row(children: [
      Icon(icon, size: 16, color: textMuted),
      SizedBox(width: 12),
      Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
      Spacer(),
      onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: Row(children: [
              Text(value, style: GoogleFonts.dmSans(fontSize: 13, color: accentBlue, fontWeight: FontWeight.w500)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentBlue),
            ]),
          )
        : Text(value, style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary)),
    ]),
  );
}
```

### Direct Reports Chips (Horizontal Scroll)
```dart
SizedBox(
  height: 72,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: subordinates.length,
    itemBuilder: (_, i) {
      final sub = subordinates[i];
      return GestureDetector(
        onTap: () => openProfile(sub),
        child: Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(radiusMd),
            border: Border.all(color: nodeBorderDef),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 14, backgroundColor: deptColor(sub.department).withOpacity(0.15),
                child: Text(sub.name[0], style: GoogleFonts.sora(fontSize: 12, color: deptColor(sub.department), fontWeight: FontWeight.w700))),
              SizedBox(height: 4),
              Text(sub.name.split(' ')[0], style: GoogleFonts.dmSans(fontSize: 10, color: textSecondary)),
            ],
          ),
        ),
      );
    },
  ),
)
```

### Action Buttons
```dart
Row(children: [
  // Edit
  Expanded(
    child: OutlinedButton.icon(
      icon: Icon(Icons.edit_rounded, size: 16),
      label: Text('Edit', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: accentBlue,
        side: BorderSide(color: accentBlue.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      onPressed: ...,
    ),
  ),
  SizedBox(width: 12),
  // Delete
  Expanded(
    child: OutlinedButton.icon(
      icon: Icon(Icons.delete_outline_rounded, size: 16),
      label: Text('Delete', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: danger,
        side: BorderSide(color: danger.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      onPressed: ...,
    ),
  ),
])
```

### Delete Confirmation Dialog
```dart
// NOT a default AlertDialog — custom styled:
showDialog(
  context: context,
  builder: (_) => Dialog(
    backgroundColor: bgElevated,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Warning icon with red glow
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: danger.withOpacity(0.1),
            border: Border.all(color: danger.withOpacity(0.3)),
          ),
          child: Icon(Icons.warning_amber_rounded, color: danger, size: 28),
        ),
        SizedBox(height: 16),
        Text('Delete Member?', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
        SizedBox(height: 8),
        Text(
          'Deleting ${member.name} will also permanently remove all their subordinates.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary),
        ),
        SizedBox(height: 24),
        Row(children: [
          Expanded(child: TextButton(
            child: Text('Cancel', style: GoogleFonts.dmSans(color: textSecondary, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          )),
          SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
            ),
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700)),
            onPressed: ...,
          )),
        ]),
      ]),
    ),
  ),
)
```

---

## 📱 SCREEN 3 — Add / Edit Member Screen

### Design
- Full screen push (not bottom sheet)
- Top section: large gradient header with screen title
- Form below in a scrollable card container

### Header
```dart
Container(
  padding: EdgeInsets.fromLTRB(20, 60, 20, 24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accentBlue.withOpacity(0.15), bgDeep],
    ),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Back button
    GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: nodeBorderDef),
        ),
        child: Icon(Icons.arrow_back_rounded, color: textSecondary, size: 18),
      ),
    ),
    SizedBox(height: 20),
    Text(
      isEdit ? 'Edit Member' : 'Add Member',
      style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
    ),
    Text(
      isEdit ? 'Update profile details' : 'Add someone to the org',
      style: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
    ),
  ]),
)
```

### Form Field Style
```dart
// All text fields use this unified style
Widget styledField({
  required String label,
  required TextEditingController controller,
  String? hint,
  IconData? icon,
  bool mandatory = false,
}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
      if (mandatory) Text(' *', style: TextStyle(color: danger, fontSize: 12)),
    ]),
    SizedBox(height: 6),
    TextField(
      controller: controller,
      style: GoogleFonts.dmSans(fontSize: 14, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: textMuted),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: textMuted) : null,
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: nodeBorderDef),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: nodeBorderDef),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: danger),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    SizedBox(height: 16),
  ]);
}
```

### Dropdown Style (Role + Manager)
```dart
// Use DropdownButtonFormField with custom decoration:
DropdownButtonFormField<String>(
  value: selectedRole,
  dropdownColor: bgElevated,
  style: GoogleFonts.dmSans(fontSize: 14, color: textPrimary),
  icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
  decoration: InputDecoration(
    filled: true,
    fillColor: bgInput,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: BorderSide(color: nodeBorderDef)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: BorderSide(color: nodeBorderDef)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: BorderSide(color: accentBlue, width: 1.5)),
    prefixIcon: Icon(Icons.work_outline_rounded, size: 18, color: textMuted),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  items: roles.map((r) => DropdownMenuItem(
    value: r,
    child: Text(r, style: GoogleFonts.dmSans(fontSize: 13, color: textPrimary)),
  )).toList(),
  onChanged: ...,
)
```

### Submit Button
```dart
// Full-width, glowing submit button
Container(
  width: double.infinity,
  height: 54,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(radiusMd),
    gradient: LinearGradient(colors: [Color(0xFF2563EB), accentBlue]),
    boxShadow: [BoxShadow(color: accentBlue.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 8))],
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    onPressed: _isLoading ? null : _submit,
    child: _isLoading
      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
      : Text(isEdit ? 'Save Changes' : 'Add Member',
          style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
  ),
)
```

---

## 🔧 Utility: Department → Color Mapper

```dart
Color deptColor(String department) {
  switch (department.toLowerCase()) {
    case 'engineering': return deptEng;
    case 'marketing':   return deptMkt;
    case 'hr':
    case 'human resources': return deptHR;
    case 'operations':  return deptOps;
    case 'product':     return deptProduct;
    default:            return accentBlue;
  }
}
```

---

## 📋 Empty & Loading States

### Loading State (Tree Loading)
```dart
// Shimmer-style placeholder nodes
// Use shimmer package OR manual animated opacity:
AnimatedOpacity(
  opacity: _shimmer ? 0.3 : 0.8,
  duration: Duration(milliseconds: 800),
  child: Container(
    width: 120, height: 80,
    decoration: BoxDecoration(
      color: bgCard,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: nodeBorderDef),
    ),
  ),
)
// Repeat onEnd to create looping shimmer effect
```

### Empty State
```dart
Center(
  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentBlue.withOpacity(0.08),
        border: Border.all(color: accentBlue.withOpacity(0.2)),
      ),
      child: Icon(Icons.hub_outlined, size: 36, color: accentBlue.withOpacity(0.5)),
    ),
    SizedBox(height: 16),
    Text('No members yet', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
    SizedBox(height: 8),
    Text('Tap + to add the first person\nto your organization', textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(fontSize: 14, color: textSecondary)),
  ]),
)
```

### Success SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
    backgroundColor: bgElevated,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: BorderSide(color: success.withOpacity(0.4)),
    ),
    content: Row(children: [
      Icon(Icons.check_circle_rounded, color: success, size: 18),
      SizedBox(width: 10),
      Text(message, style: GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w500)),
    ]),
    duration: Duration(seconds: 2),
  ),
)
```

---

## ✅ UI Implementation Checklist

| Element | Implemented? |
|---|---|
| Dark theme (`bgDeep`) applied to entire app | ☐ |
| Sora + DM Sans fonts loaded via `google_fonts` | ☐ |
| Frosted glass AppBar | ☐ |
| Animated slide-down search bar | ☐ |
| Node cards with avatar initial + dept ring | ☐ |
| Selected node glows blue | ☐ |
| Department color legend at bottom | ☐ |
| Glowing FAB | ☐ |
| Profile as draggable bottom sheet (not push) | ☐ |
| Info rows with icons | ☐ |
| Subordinates horizontal scroll chips | ☐ |
| Custom delete confirmation dialog (not AlertDialog) | ☐ |
| Add/Edit gradient header | ☐ |
| All fields use `styledField` with focus glow | ☐ |
| Submit button has blue glow shadow | ☐ |
| Loading spinner inside submit button | ☐ |
| Empty state with icon | ☐ |
| Success/error SnackBars styled | ☐ |
| All transitions animated (250ms easeOutCubic) | ☐ |

---

*Every color, font, spacing value, and animation in this guide is intentional. Do not substitute with defaults — the quality of the UI comes from the consistency of these decisions applied across every pixel.*
