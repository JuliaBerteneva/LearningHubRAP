# Learning & Growth Hub — ABAP RAP

A dashboard for tracking employees' personal development progress: course completion, skill growth, and team structure, built on SAP's RESTful Application Programming Model (RAP).

## What it does

The system gives employees a single place to enroll in courses, track completion and skill progress, and rate what they've taken. Managers get a structured view of team composition and skill coverage. All three applications sit on the same data model, so course completion, skill development, and reporting stay in sync automatically.

## Applications

**Learning Hub** — course catalog and administration. Create, update, and release courses; attach materials; assign skill categories; control who can publish what through role-based authorization.

**My Courses** — an employee's personal learning view: enrolled courses, completion status, and progress, scoped strictly to the current user at the data layer.

**Analytics / Skills** — skill catalogs, self-assignment, proficiency tracking, and team/leadership structure, giving managers visibility into skill coverage across their reports.

## Architecture

The system follows the standard RAP layering:

- **Database tables** persist courses, materials, skills, user-course and user-skill assignments, and (as of the latest iteration) user relationships for team structure.
- **CDS views** provide data access: root views (`zlh_r_*`) expose transactional data with associations and calculated fields; consumption views (`zlh_c_*`) add UI annotations and app-specific projections.
- **Behavior definitions** (`.bdef.asbdef`) declare create/update/delete operations, validations, determinations, and authorization rules.
- **Implementation classes** (`zbp_lh_r_*` for behavior, `zcl_lh_*` for utilities) hold the business logic — validations, calculated fields, actions.
- **Fiori Elements** generates the UI from the data model and behavior definitions, so changes to the model propagate to the interface without manual UI work.

## Key features

- **Course lifecycle management** — from creation and material assignment through release, with business rules enforcing data consistency (e.g. duration calculated from materials, release gated on content completeness).
- **Progress and feedback tracking** — employees track their enrollment and completion status, and rate completed courses, feeding into course-level quality metrics.
- **Skill development** — a browsable skill catalog with self-assignment and proficiency tracking, giving employees a clear view of their growing capabilities.
- **Team and reporting structure** — a relationship model surfaces reporting lines, giving managers visibility into their team's skill and learning progress.
- **Data-level authorization** — personal views like My Courses and My Skills are scoped to the current user at the query layer, not just in the UI.
- **Draft-based editing** — all managed entities support draft mode with validation before activation and optimistic locking.

## Tech stack

| Layer | Technology |
|---|---|
| Business objects | ABAP RAP (managed) |
| Data access | CDS views |
| Business logic | Behavior definitions + ABAP implementation classes |
| UI | Fiori Elements (List Report, Object Page, Analytical Page) |
| Frontend | SAP UI5 |
| Navigation | Fiori Launchpad |

## Project structure

```
LearningHubRAP/
└── src/
    ├── ABAP classes (zbp_*, zcl_*)     — behavior implementations, helpers, tests
    ├── CDS views (zlh_*.ddls.asddls)   — root, consumption, and query views
    ├── Behavior definitions (*.bdef.asbdef)
    ├── Database tables (*.tabl.xml)
    └── UI applications (zul_*.wapa)    — UI5 apps per module
```

## 🔗 Author

[Julia Lopina](https://julialopina.com/it_blog)

ABAP Developer | SAP Professional
