---
title: "SIIJAPIN Mobile — Login/Register Feature Continuation Record"
document_type: "feature-continuation-record"
status: "Active Development Handoff"
scope: "Authentication, Login, Register, App Router integration, Splash/Home/Profile seams"
agent_discovery: "Listed in Development Documentation README.md"
source_of_truth_note: "This record extends project documentation; AGENTS.md and authoritative specifications remain higher priority."
---

> **AI Agent Discovery Notice**
> This file is the active continuation record for the SIIJAPIN Mobile Login/Register implementation.
> Before modifying `lib/core/routing/`, `lib/features/auth/`, Login/Register, authentication navigation, or the related Splash/Home/Profile integration seams, read this document after `AGENTS.md` and the Development Documentation `README.md`.
> Do not create a second handoff/continuation document for this same scope unless explicitly instructed. Update this record when the work continues.

# SIIJAPIN Mobile --- Login/Register Change Documentation & Teammate Handoff

**Project:** SIIJAPIN Mobile --- RSUP Dr. Sitanala Tangerang\
**Scope:** Login + Register implementation\
**Comparison:** `sijapin_mobile-flutter.old.zip` → current
`sijapin_mobile-flutter(1).zip`\
**Purpose:** Preserve the work already completed, explain the affected
structure, and give teammate AI agents a clear integration contract
without creating a competing architecture or workflow.

------------------------------------------------------------------------

## 1. Source Comparison Result

Two Flutter archives were compared:

-   **Old baseline:** `sijapin_mobile-flutter.old.zip`
-   **Current implementation:** `sijapin_mobile-flutter(1).zip`

The comparison was performed at the extracted-file level.

### Substantive source changes

The following areas changed:

``` text
lib/main.dart
lib/core/theme/app_theme.dart
lib/core/routing/app_router.dart                    [new]

lib/features/auth/data/...                          [new]
lib/features/auth/domain/...                        [new]
lib/features/auth/presentation/...                  [new]

test/widget_test.dart
test/core/routing/app_router_test.dart              [new]
test/features/auth/...                              [new]

.gitignore
```

### Generated differences excluded from the development change record

The two archives contain differences under:

``` text
android/.gradle/
```

These are Gradle-generated/cache artifacts and are not treated as
intentional SIIJAPIN application-development changes.

------------------------------------------------------------------------

# 2. Development Goal

The implemented unit was intentionally limited to:

-   Login View
-   Register View
-   Login ↔ Register navigation
-   centralized application routing
-   reusable authentication UI components
-   authentication state/controller boundary
-   domain use-case/repository boundary
-   isolated dummy authentication
-   temporary Home/Profile integration placeholders
-   tests for the affected areas

The following were intentionally **not** implemented:

-   real CI3 authentication requests
-   backend changes
-   database changes
-   real Home implementation
-   real Profile implementation
-   unrelated application features
-   a second router
-   a second application architecture

------------------------------------------------------------------------

# 3. Architecture After the Change

The application composition is now:

``` text
main.dart
    ↓
ProviderScope
    ↓
SiijapinApp
    ↓
MaterialApp.router
    ↓
AppRouter
    ├── /splash
    ├── /home
    ├── /profile
    ├── /login
    └── /register
```

Authentication itself follows:

``` text
Login/Register View
        ↓
Auth Controller (Riverpod)
        ↓
Use Case
        ↓
AuthRepository contract
        ↓
FakeAuthRepository
```

The repository boundary is intentionally ready for a future real CI3
adapter:

``` text
AuthRepository
        ↓
Future CI3 Repository Implementation
        ↓
Dio / CookieJar / CSRF / API contract
```

The real backend contract was not invented because the API-contract
documentation referenced by the project workflow was not present in the
supplied Development Documents package.

------------------------------------------------------------------------

# 4. Directory and File Responsibilities

## 4.1 `lib/main.dart`

### Purpose

Application bootstrap and root composition.

### What changed

The previous root used:

``` text
MaterialApp
    ↓
home: SplashScreen
```

It now uses:

``` text
MaterialApp.router
    ↓
AppRouter
```

The root application remains responsible only for application
composition.

### Important teammate rule

Do not create another root application widget or another router.

If Home/Profile are implemented by another teammate, integrate their
routes through the existing `AppRouter`.

------------------------------------------------------------------------

# 5. `lib/core/routing/`

## `lib/core/routing/app_router.dart`

### Purpose

This is the **central application navigation layer**.

It prevents feature screens from directly owning the application's
global navigation structure.

Current routes:

``` text
/splash
/home
/profile
/login
/register
```

It also contains temporary integration placeholders for Home and Profile
and a generic route-not-found screen.

### Why this exists

Before this change, `main.dart` directly selected the splash screen.

The authentication feature needed a stable navigation seam so:

``` text
Login
    ↕
Register
```

and future:

``` text
Home
    → Profile
    → Login
    → Register
```

can coexist without embedding concrete teammate implementations inside
authentication screens.

### Teammate integration contract

**Preserve `AppRouter`.**

When replacing a placeholder:

``` text
/home
/profile
```

replace the placeholder implementation/route target rather than
creating:

``` text
AnotherRouter
FeatureRouter
HomeRouter
ProfileRouter
```

unless the project architecture is explicitly changed later through the
established workflow.

The authentication routes should remain stable unless there is an
explicit architecture decision to change them.

------------------------------------------------------------------------

# 6. `lib/features/auth/`

This is the new Feature-First authentication module.

Its responsibility is only authentication/account-entry functionality.

It is divided into:

``` text
auth/
├── data/
├── domain/
└── presentation/
```

This follows the project's Feature-First Clean Architecture rather than
putting all authentication code into one file.

------------------------------------------------------------------------

# 7. `lib/features/auth/data/`

## `data/repositories/fake_auth_repository.dart`

### Purpose

Temporary development repository.

It allows Login/Register UI and use cases to operate without requiring
the real CI3 backend.

### Behavior

The dummy implementation returns successful `AuthResult` values after a
short simulated delay.

It does not:

-   call the network;
-   call CI3;
-   store passwords;
-   store patient information;
-   define backend payloads.

### Future replacement

The fake repository is intended to be replaced or complemented by the
real repository implementation once the documented CI3 API contract is
available.

The UI should not need to know whether the repository is fake or real.

------------------------------------------------------------------------

# 8. `lib/features/auth/domain/`

The domain layer defines authentication contracts without depending on
Flutter UI.

## `domain/entities/auth_result.dart`

### Purpose

Represents the result of an authentication operation.

Current information is intentionally minimal:

``` text
success
message
```

No credentials, tokens, patient records, or backend-specific response
structures are stored here.

------------------------------------------------------------------------

## `domain/repositories/auth_repository.dart`

### Purpose

Defines the authentication repository contract.

It exposes:

``` text
login(...)
register(...)
```

This is the important abstraction between authentication logic and its
data source.

### Future backend integration

The real CI3 implementation should implement this contract rather than
making the Login/Register widgets call Dio directly.

------------------------------------------------------------------------

## `domain/usecases/login_usecase.dart`

### Purpose

Encapsulates the Login operation.

The Login View does not directly invoke the repository.

Flow:

``` text
LoginView
    ↓
AuthController
    ↓
LoginUseCase
    ↓
AuthRepository
```

------------------------------------------------------------------------

## `domain/usecases/register_usecase.dart`

### Purpose

Encapsulates the Register operation.

Flow:

``` text
RegisterView
    ↓
AuthController
    ↓
RegisterUseCase
    ↓
AuthRepository
```

------------------------------------------------------------------------

# 9. `lib/features/auth/presentation/`

This contains Flutter-specific authentication UI and state management.

------------------------------------------------------------------------

## `presentation/controllers/auth_controller.dart`

### Purpose

Riverpod state/controller layer for authentication submission.

Responsibilities include:

-   Login submission state
-   Register submission state
-   loading state
-   success state
-   error state
-   invoking the appropriate use case
-   preventing raw exceptions from being exposed to the UI

The controller keeps submission logic out of the widget implementation.

### Important boundary

The controller should not become a place for:

-   database access
-   direct HTTP requests
-   hard-coded CI3 payload construction
-   unrelated application navigation logic

------------------------------------------------------------------------

# 10. `presentation/views/login_view.dart`

### Purpose

The complete Login screen.

Responsibilities:

-   render Login UI;
-   collect identifier and password;
-   remember-me state;
-   local form validation;
-   invoke authentication controller;
-   display submission errors;
-   display loading state;
-   navigate to Register;
-   navigate through the central router after successful dummy
    authentication.

### Responsive behavior

The screen uses:

``` text
SafeArea
    ↓
LayoutBuilder
    ↓
SingleChildScrollView
    ↓
Constrained content
```

This prevents the implementation from depending on the dimensions of the
supplied screenshot.

It is intended to remain usable when:

-   the keyboard is visible;
-   the screen is small;
-   text is scaled;
-   safe-area insets are present.

------------------------------------------------------------------------

# 11. `presentation/views/register_view.dart`

### Purpose

The complete Register screen.

It handles the fields represented by the supplied registration
reference:

-   full name
-   WhatsApp / phone
-   email
-   birth date
-   gender
-   password
-   password confirmation
-   privacy/terms agreement

### Additional behavior

-   date picker for birth date;
-   password visibility controls;
-   confirmation-password validation;
-   agreement validation;
-   scrollable layout for small screens/keyboard states;
-   submission through `AuthController`.

### Backend boundary

The fields used here represent the current UI/domain slicing.

They must **not** automatically be interpreted as a confirmed CI3 API
contract.

Real API field names and backend behavior must come from the project's
API documentation.

------------------------------------------------------------------------

# 12. `presentation/widgets/auth_widgets.dart`

### Purpose

Reusable authentication-specific UI components.

Current components include:

``` text
AuthBackButton
AuthTextField
AuthPasswordField
AuthPrimaryButton
AuthSecurityBadge
AuthFormCard
AuthStatusMessage
```

### Why these are shared

Login and Register have repeated visual patterns.

For example:

``` text
AuthTextField
    ├── Login identifier
    ├── Register name
    ├── Register phone
    ├── Register email
    └── Register birth date

AuthPasswordField
    ├── Login password
    ├── Register password
    └── Register confirmation password
```

This avoids duplicated widget styling.

### Important teammate rule

Reuse these components where they fit the authentication design.

Do not create another authentication field/button system under a
different directory unless the existing component genuinely cannot
satisfy the new requirement.

------------------------------------------------------------------------

# 13. Login Inline Registration Navigation

The Login footer was specifically adjusted to make:

``` text
Belum memiliki akun? Daftar di sini
```

appear on one baseline.

The current implementation uses:

``` text
Row
  ├── normal Text
  └── TextButton
```

with baseline alignment and a reduced button tap target.

This is intentional because the requirement is that only:

``` text
Daftar di sini
```

is clickable.

Do not revert this to a `Wrap` with a forced `48 x 48` button if the
visual requirement is to keep the text inline.

------------------------------------------------------------------------

# 14. `lib/core/theme/app_theme.dart`

### Purpose

Application-wide Material theme.

The current implementation adds/extends:

-   Plus Jakarta Sans as the theme font family;
-   InputDecoration styling;
-   rounded authentication input borders;
-   focused/error input borders;
-   primary button defaults;
-   filled-button defaults.

The existing SIIJAPIN color tokens remain the source for colors.

### Design relationship

The implementation combines:

``` text
DESIGN.md
    +
Login/Register UI references
```

`DESIGN.md` supplies the design-system foundation.

The screenshots supply authentication-specific composition and
hierarchy.

Neither source is discarded.

------------------------------------------------------------------------

# 15. Tests

## `test/core/routing/app_router_test.dart`

### Purpose

Verifies the centralized router can bootstrap at the splash integration
point.

------------------------------------------------------------------------

## `test/features/auth/domain/login_usecase_test.dart`

### Purpose

Verifies LoginUseCase can execute against the fake repository without
network access.

------------------------------------------------------------------------

## `test/features/auth/domain/register_usecase_test.dart`

### Purpose

Verifies RegisterUseCase can execute against the fake repository without
network access.

------------------------------------------------------------------------

## `test/features/auth/presentation/login_view_test.dart`

### Purpose

Smoke-tests required Login UI elements.

------------------------------------------------------------------------

## `test/features/auth/presentation/register_view_test.dart`

### Purpose

Smoke-tests required Register UI elements.

------------------------------------------------------------------------

## `test/widget_test.dart`

### Purpose

Application bootstrap smoke test.

It was updated to account for the router-based application composition
and current splash integration point.

------------------------------------------------------------------------

# 16. `.gitignore`

The current archive also contains `.gitignore` additions for local
packaging scripts:

``` text
zip_ai_workflow.sh
zip_all.sh
```

This prevents local packaging helpers from becoming tracked application
source.

This is packaging/development hygiene, not part of the Login/Register
architecture.

------------------------------------------------------------------------

# 17. Dependency Changes

No `pubspec.yaml` dependency change was detected between the old and
current Flutter archives.

This is important:

The Login/Register implementation reused dependencies that were already
available in the project.

Therefore, there is no new package that teammates need to add merely to
reproduce this implementation.

------------------------------------------------------------------------

# 18. Teammate AI Agent Integration Contract

The following rules should be treated as the handoff contract for future
AI agents working on the same Flutter source.

## Rule 1 --- Preserve App Router

There is already one centralized router:

``` text
lib/core/routing/app_router.dart
```

Do not create a competing router.

Future features should add or modify routes in the existing application
routing structure according to the project's established architecture.

------------------------------------------------------------------------

## Rule 2 --- Preserve Auth Feature Boundaries

Authentication currently follows:

``` text
presentation
    ↓
domain
    ↓
data
```

Future authentication work should extend these boundaries instead of
putting API calls directly into:

``` text
LoginView
RegisterView
Auth widgets
```

------------------------------------------------------------------------

## Rule 3 --- Do Not Duplicate Auth Components

Before creating a new authentication widget, inspect:

``` text
lib/features/auth/presentation/widgets/auth_widgets.dart
```

Reuse or extend an existing component when appropriate.

------------------------------------------------------------------------

## Rule 4 --- Do Not Rebuild Home/Profile

The current Home/Profile screens are integration placeholders.

They are deliberately temporary.

A teammate implementing Home or Profile should replace the placeholder
through the existing routing seam.

Do not duplicate Home/Profile implementations inside:

``` text
features/auth/
```

------------------------------------------------------------------------

## Rule 5 --- Do Not Remove Login/Register Routes

The following are existing authentication integration points:

``` text
/login
/register
```

Preserve them unless an explicit project architecture decision changes
the route contract.

------------------------------------------------------------------------

## Rule 6 --- Do Not Couple Auth to Home

Login/Register should not contain direct dependencies such as:

``` text
LoginView → HomeView
```

Navigation should go through the centralized router.

This allows the Home implementation to change independently.

------------------------------------------------------------------------

## Rule 7 --- Do Not Invent the Backend Contract

The current authentication implementation is deliberately dummy.

Do not replace it with guessed API behavior.

Before implementing real authentication, inspect the project's
authoritative API-contract documentation.

If the contract is missing, report the missing documentation instead of
guessing.

------------------------------------------------------------------------

## Rule 8 --- Preserve the Current UI Direction

For Login/Register:

``` text
DESIGN.md
    +
Login_UI-UX.png
    +
Register_UI-UX.png
```

must continue to be treated as the combined visual source of truth.

Do not replace the implementation with a generic Flutter authentication
template.

------------------------------------------------------------------------

## Rule 9 --- Inspect Before Editing Shared Files

Before modifying:

``` text
main.dart
app_router.dart
app_theme.dart
auth_widgets.dart
```

inspect their current contents and usages.

Do not overwrite these files wholesale simply because a feature agent
wants a different structure.

------------------------------------------------------------------------

## Rule 10 --- Minimize Merge Conflicts

Feature agents should prefer:

``` text
new feature directory
    +
small route addition
```

rather than large changes to:

``` text
main.dart
app_router.dart
app_theme.dart
```

Keep application-level edits focused.

------------------------------------------------------------------------

# 19. What Future Agents Should NOT Recreate

Do not create another:

``` text
AppRouter
AuthController
AuthRepository interface
LoginUseCase
RegisterUseCase
AuthTextField
AuthPasswordField
AuthPrimaryButton
```

without first determining that the existing implementation is
insufficient.

Do not create:

``` text
features/login/
features/register/
```

as competing top-level features unless the architecture is explicitly
changed.

Login and Register currently belong to:

``` text
features/auth/
```

------------------------------------------------------------------------

# 20. Future Real Authentication Integration

The intended evolution is:

``` text
CURRENT

Login/Register
      ↓
AuthController
      ↓
UseCase
      ↓
AuthRepository
      ↓
FakeAuthRepository


FUTURE

Login/Register
      ↓
AuthController
      ↓
UseCase
      ↓
AuthRepository
      ↓
CI3 Repository
      ↓
Remote Data Source
      ↓
Dio + CookieJar + CSRF
      ↓
RSUP Dr. Sitanala CI3 backend
```

The UI should not need to know whether the underlying repository is fake
or remote.

When real integration begins, use the authoritative API contract and
existing network/storage infrastructure.

------------------------------------------------------------------------

# 21. Current Known State

At the time of this comparison:

-   Login/Register source exists.
-   Centralized App Router exists.
-   Dummy authentication exists.
-   Home/Profile remain placeholders.
-   API authentication is not implemented.
-   The Flutter archive contains generated Android Gradle artifacts.
-   The project documentation package still contains the existing
    `README.md` and `DESIGN.md`.
-   No new backend contract was invented.
-   No application dependency addition was detected.

The development environment used for the earlier implementation did not
have the Flutter/Dart executable available, so the previous
implementation could not truthfully claim a successful `flutter analyze`
or `flutter test` execution in that environment.

A teammate running the project in a proper Flutter environment should
execute the project's normal quality gates before further merging.

------------------------------------------------------------------------

# 22. Recommended Handoff Workflow for AI Agents

When a teammate AI agent starts work:

``` text
1. Read AGENTS.md
       ↓
2. Read Development Documentation
       ↓
3. Read this Login/Register handoff document
       ↓
4. Inspect current Flutter source
       ↓
5. Inspect AppRouter before modifying navigation
       ↓
6. Determine whether the requested feature overlaps Auth
       ↓
7. Reuse existing infrastructure
       ↓
8. Make the smallest isolated change
       ↓
9. Test affected feature
       ↓
10. Run project quality gates
       ↓
11. Report changed files and integration points
```

The teammate agent should treat this document as a **handoff record**,
not as a replacement for `AGENTS.md`, the Development Documentation, or
the source code.

------------------------------------------------------------------------

# 23. Source-of-Truth Priority

For future work, use this order:

``` text
1. Project AI workflow / AGENTS.md
2. Authoritative Development Documentation
3. Current Flutter source
4. Auth handoff documentation
5. Login/Register UI references
6. General assumptions
```

If two project sources conflict:

-   do not silently choose one;
-   identify the conflict;
-   follow the project's established approval process.

------------------------------------------------------------------------

# 24. Summary

The Login/Register implementation introduced a **single authentication
feature** while preserving the project's Feature-First Clean
Architecture.

The most important architectural change is the introduction of:

``` text
lib/core/routing/app_router.dart
```

which establishes a centralized application routing seam.

Authentication is isolated under:

``` text
lib/features/auth/
```

with:

``` text
presentation
domain
data
```

boundaries.

The implementation uses dummy authentication intentionally so no
undocumented CI3 API behavior is invented.

For teammates, the critical rule is:

> **Preserve the existing App Router and Auth feature boundaries.
> Replace the temporary Home/Profile placeholders through the existing
> routing seam instead of creating duplicate navigation or
> authentication infrastructure.**

This document records the implementation state so future AI agents can
continue the work without unnecessarily recreating or conflicting with
the existing Login/Register structure.

------------------------------------------------------------------------

# 25. Verified Revised-Flow Merge --- 2026-09-28

This section records the **post-revision state actually present in the
current merged Flutter archive**.

## 25.1 Verification Basis

The current uploaded Flutter implementation was inspected from:

``` text
sijapin_mobile-flutter(1).zip
```

It was compared against the immediately preceding revised package:

``` text
sijapin_mobile-flutter-revised.zip
```

The comparison shows **no substantive application-source differences**
between those two packages.

The only differences found are generated Android Gradle state under:

``` text
android/.gradle/
```

Those generated/cache differences are not treated as intentional feature
changes.

The current archive contains the complete Login/Register implementation
plus the revised splash → Home → Login flow.

------------------------------------------------------------------------

# 26. Current Application Flow --- Verified

The current implementation is now:

``` text
Open App
    ↓
Splash / Loading
    ↓
automatic transition
    ↓
Dummy Home
    ↓
[Login]
    ↓
Login View
    ↓
[Daftar di sini]
    ↓
Register View
```

The application starts with:

``` text
initialLocation: /splash
```

The splash automatically navigates to:

``` text
/home
```

after a minimum display duration of:

``` text
1200 ms
```

There is no longer a:

``` text
Lanjut ke Aplikasi
```

button.

------------------------------------------------------------------------

# 27. `lib/core/routing/app_router.dart` --- Current Responsibility

This remains the **central application router** and must be preserved.

Current routes:

``` text
/splash
/home
/profile
/login
/register
```

## `/splash`

Displays:

-   SIIJAPIN Mobile branding;
-   RSUP Dr. Sitanala Tangerang label;
-   loading indicator;
-   `Memuat aplikasi...`.

After the minimum splash duration, it executes:

``` text
context.go('/home')
```

The timer is cancelled during disposal.

### Teammate rule

Do not add a second splash-navigation mechanism elsewhere.

If a future real initialization process replaces the timer, modify the
existing splash/router flow instead of creating another
application-level router.

------------------------------------------------------------------------

## `/home`

Currently points to:

``` text
HomePlaceholderScreen
```

This is deliberately a temporary integration placeholder.

Its only authentication testing action is:

``` text
Login
```

which executes:

``` text
context.push('/login')
```

### Current Dummy Home UI

The Home placeholder **must not be treated as the real Home
implementation**.

It exists only so Login/Register can be tested independently while the
Home feature is owned by another team.

The old actions:

``` text
Buka Profile
Uji Login
```

are no longer present.

------------------------------------------------------------------------

## `/profile`

The Profile route remains registered:

``` text
/profile
```

and still points to:

``` text
ProfilePlaceholderScreen
```

The placeholder currently exposes:

``` text
Masuk ke Akun
Daftar Akun
```

This route is intentionally retained as an **integration seam for
teammate-owned Profile work**.

However, it is no longer part of the Login/Register test path from Dummy
Home.

### Important distinction

Current testing path:

``` text
Home → Login → Register
```

Future teammate-owned application path may become:

``` text
Home → Profile → authentication-state handling
```

The two concerns should not be mixed.

------------------------------------------------------------------------

# 28. Login → Register Integration --- Verified

The Login implementation contains the inline registration navigation:

``` text
Belum memiliki akun? Daftar di sini
```

The implementation uses a baseline-aligned `Row`.

The two elements are:

``` text
Text
TextButton
```

with:

``` text
mainAxisSize: MainAxisSize.min
crossAxisAlignment: CrossAxisAlignment.baseline
textBaseline: TextBaseline.alphabetic
```

The button uses a zero minimum size and a shrink-wrapped tap target so
that only the `Daftar di sini` text acts as the interactive control.

Navigation:

``` text
context.push('/register')
```

### Do not duplicate this implementation

Future agents modifying authentication should inspect the existing Login
footer before creating another inline-registration component.

------------------------------------------------------------------------

# 29. Current `lib/main.dart`

The application root remains:

``` text
ProviderScope
    ↓
SiijapinApp
    ↓
MaterialApp.router
    ↓
AppRouter
```

`SiijapinApp` creates and owns the `AppRouter`.

The router is disposed with the application widget.

### Teammate integration rule

The application root is already router-based.

Do not revert it to:

``` text
MaterialApp(home: ...)
```

and do not introduce a second root-level router.

The preserved composition is:

``` text
main.dart
    ↓
SiijapinApp
    ↓
MaterialApp.router
    ↓
AppRouter
```

------------------------------------------------------------------------

# 30. Current Authentication Structure --- Verified

The following files are present in the current Flutter archive.

## `lib/features/auth/data/repositories/fake_auth_repository.dart`

Purpose:

Temporary authentication data implementation for UI/integration
development.

It is not the CI3 backend implementation.

------------------------------------------------------------------------

## `lib/features/auth/domain/entities/auth_result.dart`

Purpose:

Domain-level authentication result representation.

It intentionally avoids introducing undocumented backend response
structures.

------------------------------------------------------------------------

## `lib/features/auth/domain/repositories/auth_repository.dart`

Purpose:

Authentication repository contract.

This is the boundary that allows the current fake implementation to be
replaced by a real backend implementation later.

------------------------------------------------------------------------

## `lib/features/auth/domain/usecases/login_usecase.dart`

Purpose:

Encapsulates the Login operation.

The Login View should not call the repository directly.

------------------------------------------------------------------------

## `lib/features/auth/domain/usecases/register_usecase.dart`

Purpose:

Encapsulates the Register operation.

The Register View should not call the repository directly.

------------------------------------------------------------------------

## `lib/features/auth/presentation/controllers/auth_controller.dart`

Purpose:

Riverpod authentication state/controller.

It handles the UI-facing submission state and invokes authentication use
cases.

------------------------------------------------------------------------

## `lib/features/auth/presentation/views/login_view.dart`

Purpose:

SIIJAPIN Login screen.

Responsibilities:

-   Login form;
-   validation;
-   loading/error state;
-   authentication submission;
-   Register navigation;
-   responsive layout.

------------------------------------------------------------------------

## `lib/features/auth/presentation/views/register_view.dart`

Purpose:

SIIJAPIN Register screen.

Responsibilities:

-   registration form;
-   validation;
-   birth-date selection;
-   gender selection;
-   password/confirmation;
-   privacy agreement;
-   loading/error state;
-   Login navigation.

------------------------------------------------------------------------

## `lib/features/auth/presentation/widgets/auth_widgets.dart`

Purpose:

Reusable authentication UI components shared by Login and Register.

Future authentication work should inspect this file before creating
duplicate input, password, button, security, or form-card components.

------------------------------------------------------------------------

# 31. Current Test Structure --- Verified

The current archive contains:

``` text
test/core/routing/app_router_test.dart

test/features/auth/domain/login_usecase_test.dart
test/features/auth/domain/register_usecase_test.dart

test/features/auth/presentation/login_view_test.dart
test/features/auth/presentation/register_view_test.dart

test/widget_test.dart
```

## `test/core/routing/app_router_test.dart`

Now verifies the complete temporary integration flow:

``` text
Splash
  ↓
Home
  ↓
Login
  ↓
Register
```

It also verifies that Dummy Home does not expose:

``` text
Buka Profile
Uji Login
```

This is important because those controls belonged to the previous
temporary flow and should not silently return.

------------------------------------------------------------------------

# 32. New Files Introduced by Our Work

The following files were introduced as part of the Login/Register
implementation and routing work.

## Application routing

``` text
lib/core/routing/app_router.dart
```

Purpose:

Centralized application navigation.

------------------------------------------------------------------------

## Authentication data

``` text
lib/features/auth/data/repositories/fake_auth_repository.dart
```

Purpose:

Isolated development authentication repository.

------------------------------------------------------------------------

## Authentication domain

``` text
lib/features/auth/domain/entities/auth_result.dart
lib/features/auth/domain/repositories/auth_repository.dart
lib/features/auth/domain/usecases/login_usecase.dart
lib/features/auth/domain/usecases/register_usecase.dart
```

Purpose:

Authentication domain contracts and use cases.

------------------------------------------------------------------------

## Authentication presentation

``` text
lib/features/auth/presentation/controllers/auth_controller.dart
lib/features/auth/presentation/views/login_view.dart
lib/features/auth/presentation/views/register_view.dart
lib/features/auth/presentation/widgets/auth_widgets.dart
```

Purpose:

Authentication state, views, and reusable authentication UI.

------------------------------------------------------------------------

## Authentication tests

``` text
test/features/auth/domain/login_usecase_test.dart
test/features/auth/domain/register_usecase_test.dart
test/features/auth/presentation/login_view_test.dart
test/features/auth/presentation/register_view_test.dart
```

Purpose:

Tests corresponding to the new authentication feature.

------------------------------------------------------------------------

## Routing tests

``` text
test/core/routing/app_router_test.dart
```

Purpose:

Tests centralized routing and the temporary Login/Register integration
path.

------------------------------------------------------------------------

# 33. Existing Files Modified by Our Work

These files existed before the Login/Register implementation and were
extended rather than replaced with duplicate infrastructure.

``` text
lib/main.dart
lib/core/theme/app_theme.dart
test/widget_test.dart
.gitignore
```

## `lib/main.dart`

Changed from direct `home:` composition to centralized router
composition.

## `lib/core/theme/app_theme.dart`

Extended the existing application theme for the authentication UI.

## `test/widget_test.dart`

Updated to reflect the router-based application bootstrap.

## `.gitignore`

Packaging/local-development exclusions were updated as part of the
development environment changes.

------------------------------------------------------------------------

# 34. Files NOT Created for Authentication

To prevent future agents from duplicating the structure, the following
competing structures should **not** be introduced without an explicit
architecture decision:

``` text
lib/features/login/
lib/features/register/
lib/features/authentication/
lib/router/
lib/navigation/
```

The existing structures are:

``` text
lib/core/routing/
lib/features/auth/
```

These are the current architectural locations.

------------------------------------------------------------------------

# 35. Teammate AI Agent Continuation Contract

When another AI agent receives the current Flutter source, it should
interpret the existing implementation as follows.

## Before creating files

First inspect:

``` text
lib/main.dart
lib/core/routing/app_router.dart
lib/features/auth/
lib/core/theme/app_theme.dart
```

Then determine whether the requested feature overlaps any existing
component.

------------------------------------------------------------------------

## Before changing navigation

Inspect:

``` text
lib/core/routing/app_router.dart
```

There is already one application router.

Extend it.

Do not create another router.

------------------------------------------------------------------------

## Before changing authentication UI

Inspect:

``` text
lib/features/auth/presentation/widgets/auth_widgets.dart
```

Reuse existing authentication UI components when appropriate.

------------------------------------------------------------------------

## Before changing authentication logic

Inspect:

``` text
lib/features/auth/domain/
lib/features/auth/data/
lib/features/auth/presentation/controllers/
```

Do not create a second repository/controller/use-case hierarchy.

------------------------------------------------------------------------

## Before implementing Home

The current:

``` text
HomePlaceholderScreen
```

is temporary.

A Home agent should replace the placeholder through the existing:

``` text
/home
```

route.

It should not create a second Home entry point merely to avoid touching
the router.

------------------------------------------------------------------------

## Before implementing Profile

The current:

``` text
ProfilePlaceholderScreen
```

is temporary.

A Profile agent should replace the placeholder through:

``` text
/profile
```

rather than creating another profile route solely because the
placeholder exists.

------------------------------------------------------------------------

# 36. No Duplication Policy

The current source already provides:

``` text
AppRouter
AuthController
AuthRepository
FakeAuthRepository
LoginUseCase
RegisterUseCase
LoginView
RegisterView
Auth widgets
```

Therefore a future AI agent must not create another equivalent
implementation without first demonstrating why the existing
implementation cannot support the requirement.

Examples of prohibited duplication:

``` text
AnotherAppRouter
AuthRouter
LoginController2
RegisterController2
LoginRepository
RegistrationRepository
GenericAuthWidgets
LoginFeature
RegisterFeature
```

unless an explicit architecture decision changes the current structure.

------------------------------------------------------------------------

# 37. Current Development Boundary

The current implementation intentionally stops at:

``` text
Splash
  ↓
Dummy Home
  ↓
Login
  ↓
Register
```

The following remain outside this implementation:

-   real Home business functionality;
-   real Profile functionality;
-   real backend authentication;
-   patient/account database integration;
-   undocumented API payloads;
-   undocumented API responses.

This boundary should be preserved when teammate features are developed.

------------------------------------------------------------------------

# 38. Real Backend Integration Boundary

The current authentication path remains:

``` text
Login/Register
      ↓
AuthController
      ↓
Use Case
      ↓
AuthRepository
      ↓
FakeAuthRepository
```

Future real backend work should become:

``` text
Login/Register
      ↓
AuthController
      ↓
Use Case
      ↓
AuthRepository
      ↓
CI3 implementation
      ↓
Existing network infrastructure
```

The real implementation must be based on authoritative API-contract
documentation.

Do not infer backend fields from the Flutter form.

------------------------------------------------------------------------

# 39. Verification Status

The current archive was structurally inspected and compared against the
previous revised archive.

Verified:

-   current Flutter archive contains the App Router;
-   current Flutter archive contains Login/Register;
-   current Flutter archive contains the revised splash behavior;
-   current Dummy Home exposes only Login;
-   `Buka Profile` and `Uji Login` are absent from Dummy Home;
-   Profile route remains available;
-   Login → Register navigation remains present;
-   auth architecture remains intact;
-   authentication tests remain present;
-   router integration test reflects the revised flow.

The only archive-level differences between the current merged package
and the previous revised package were generated Android Gradle state
under:

``` text
android/.gradle/
```

No substantive source change was detected between those two packages.

As previously documented, the environment used for this work does not
provide the Flutter/Dart CLI, so this structural verification does not
constitute a successful `flutter analyze` or `flutter test` run.

------------------------------------------------------------------------

# 40. Handoff Summary

The current SIIJAPIN Flutter implementation should now be understood as:

``` text
                 main.dart
                     ↓
              SiijapinApp
                     ↓
              MaterialApp.router
                     ↓
                 AppRouter
          ┌──────────┼──────────┐
          ↓          ↓          ↓
       Splash      Home      Profile
          ↓          ↓
       loading     Login
                     ↓
                  Register
```

Authentication remains isolated:

``` text
Presentation
      ↓
Controller
      ↓
Use Cases
      ↓
Repository Contract
      ↓
Fake Repository
```

The **App Router is preserved as the single navigation authority**.

Home and Profile are temporary integration seams.

Login/Register are the implemented feature.

Future AI agents should extend the existing structures instead of
creating competing routers, authentication modules, or duplicate UI
components.
