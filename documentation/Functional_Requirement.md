# Relationship Mapping App (Organization) — Functional Requirements Document

---

## 1. Overview

This document defines the functional requirements for a mobile application that manages and visualizes relationships within an organization. The application focuses on employee hierarchy using **manager–employee relationships**, departments, and teams.

**System Stack:**

- **Frontend:** Flutter Mobile App
- **Backend/Database:** Firebase Firestore

---

## 2. Scope

The application will:

- Store and manage employee/member profiles
- Represent organizational hierarchy using a tree structure
- Allow relationship mapping (manager → employee)
- Provide search functionality
- Enable real-time updates using Firebase Firestore

> **Note:** No authentication/signup is included. This is a demo-based usage system.

---

## 3. System Architecture

### Frontend
Flutter Mobile App

### Backend / Database
Firebase Firestore (no separate backend server)

### Data Flow

- The Flutter app reads and writes **directly** to Firestore
- Changes in Firestore are reflected **in real-time** in the app

---

## 4. Functional Requirements

### 4.1 Member Profile Management

The system shall allow users to perform the following operations:

#### Create Member
- **Name** (mandatory)
- Role (e.g., SDE I, Senior Software Engineer, etc.)
- Department
- Team
- Profile Photo (optional)

#### Read / View Member
- Display complete profile details when a node is clicked

#### Update Member
- Edit all fields, including manager assignment

#### Delete Member
- Remove the member from the system
- All subordinates under the deleted member are also removed (**subtree deletion**)

---

### 4.2 Relationship Mapping (Core Logic)

The system shall support:

- Assigning a **single manager** to each member
- A manager can have **multiple subordinates**

**Constraints:**

- Each member can have only one manager
- Circular relationships are not allowed

**System Behavior:**

- If Member A is the manager of Member B, then B is automatically placed under A in the hierarchy

---

### 4.3 Hierarchy Visualization (Tree View)

The system shall:

- Display all members in a **hierarchical tree structure**
- Identify the **root node** — the member with no assigned manager

**Functional Capabilities:**

- Expand and collapse nodes
- Click on a node to view the member's profile details
- Highlight the selected node
- Dynamically update the tree when data changes

---

### 4.4 Search Functionality

The system shall:

- Allow users to search members **by name**
- Highlight the matched member in the tree
- Automatically navigate and focus to that member's node

---

### 4.5 Data Management

The system shall allow:

- Adding new members (with optional manager assignment during creation)
- Updating member details, including manager reassignment
- Deleting members along with their entire subtrees

---

### 4.6 Real-Time Updates (Firestore Integration)

The system shall:

- Fetch data from Firestore using **real-time listeners**
- Automatically update the UI when:
  - A new member is added
  - A member is updated
  - A member is deleted

---

## 5. Role Definitions

The system supports predefined organizational roles for realistic modeling.

> **Note:** Roles define designation only. Actual hierarchy is determined by manager relationships, not role level.

**Supported Roles:**

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

---

## 6. Database Design (Firestore)

### Collection: `members`

Each document in the collection represents a single member.

```json
{
  "id": "string",
  "name": "string",
  "role": "string",
  "department": "string",
  "team": "string",
  "managerId": "string | null"
}
```

### Field Reference

| Field        | Type            | Description                                      |
|--------------|-----------------|--------------------------------------------------|
| `id`         | string          | Auto-generated Firestore document ID             |
| `name`       | string          | Full name of the member (required)               |
| `role`       | string          | Job designation                                  |
| `department` | string          | Department the member belongs to                 |
| `team`       | string          | Team within the department                       |
| `managerId`  | string or null  | ID of the member's manager; `null` = root node   |

**Key Notes:**

- `managerId: null` indicates a **root node** (e.g., CEO or top-level member)
- Relationships between members are derived using `managerId`
- The tree structure is constructed **dynamically on the frontend**

---

## 7. System Workflow

1. App loads → fetches all members from Firestore
2. Identifies root node(s) (members where `managerId` is `null`)
3. Builds the tree using `managerId` relationships
4. Displays the hierarchy in the tree view

**User Action Flows:**

| Action        | Behavior                                         |
|---------------|--------------------------------------------------|
| Add member    | New record stored in Firestore                   |
| Update member | Corresponding Firestore document updated         |
| Delete member | Document removed from Firestore                  |
| Any change    | UI auto-refreshes via real-time Firestore listeners |

---

## 8. Screens

### 8.1 Main Screen

- Hierarchical tree visualization of all members
- Search bar for member lookup

### 8.2 Profile Screen / Popup

- Displays full member profile details
- Options to **edit** or **delete** the member

### 8.3 Add / Edit Member Screen

- Form with input fields for all member details
- Dropdown for **manager selection** from existing members

---

## 9. Constraints

| Constraint              | Details                                              |
|-------------------------|------------------------------------------------------|
| Manager assignment      | Each member can have only one manager                |
| Authentication          | No authentication system is included                 |
| Scale                   | Designed for demo-scale use, not enterprise-level    |

---

## 10. Conclusion

This application provides a simple and efficient system to manage and visualize organizational relationships. It uses **Firebase Firestore** for real-time data handling and **Flutter** for UI rendering. The primary focus is on clarity, usability, and dynamic hierarchy visualization.
