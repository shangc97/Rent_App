# 4Rent

4Rent is a SwiftUI rental marketplace that connects guest browsing, tenant applications, and landlord listing management through Firebase-backed, role-specific workflows.

## Project Context and Personal Scope

Chuhan Shang designed and implemented 4Rent as an individual Advanced iOS course project. The project brief required a single Firestore-backed rental system with guest, tenant, and landlord experiences, Firebase Authentication, editable profiles, and remembered sign-in credentials.

Within those requirements, the implementation uses one role-aware iOS app, an Observation-based Model-Repository-Store-View structure, Keychain-protected password storage, coordinated request and listing state changes, and reusable SwiftUI result-state components.

## Key Workflows

- **Role-based entry:** Guests can browse without an account, while tenants and landlords can register, sign in, and enter navigation flows selected from their Firestore profile role.
- **Property discovery:** Users can browse listings by status, search currently listed properties by title, city, or address, and inspect property and landlord details.
- **Tenant shortlist and sharing:** Tenants can persist a shortlist in Firestore, filter saved properties by status, and share a formatted property summary with the system share sheet.
- **Rental request lifecycle:** Tenants can submit and withdraw requests, cannot create duplicate pending requests for the same property, and can review pending, processed, and archived history.
- **Landlord listing management:** Landlords can add and edit owned properties, move listings between listed and unlisted states, and review incoming requests.
- **Request review and profiles:** Landlords can approve or deny requests for their own properties, while authenticated users can view and update their profile or sign out from any role flow.

## Technical Highlights

- **Role-driven app composition:** `AppState` represents loading, logged-out, guest, tenant, and landlord sessions. `RootView` uses that state to select a single top-level flow, while `AppSessionCoordinator` centralizes cross-store sign-in, guest access, and sign-out behavior.
- **Separated state and persistence:** `@MainActor` Observation stores expose loading, error, and domain state to SwiftUI. Repository types isolate Firebase Authentication and Firestore operations so views remain focused on presentation and user interaction.
- **Safer remembered credentials:** Remember Me stores the user ID and email in `UserDefaults`, protects the password with the iOS Keychain, and pre-fills the form without automatically submitting a future login.
- **Coordinated listing updates:** When a landlord unlists an available property, a Firestore batch updates the property and withdraws its submitted requests together. The stores then mirror the successful change in local observable state.
- **Workflow validation:** Request actions validate the active role, ownership, and current status before persistence. The tenant flow also queries existing requests to prevent duplicate pending applications.
- **Reusable result states:** Shared loading, empty-state, filter, result-card, and fixed-control layout components keep browse, shortlist, listing, and request screens consistent.

## Architecture

```text
SwiftUI feature views
        |
AppState + @Observable stores
        |
Repository layer
        |
Firebase Authentication + Cloud Firestore
```

- `App/` owns root session state, role routing, and cross-store session coordination.
- `Core/Models/` defines profiles, properties, shortlist entries, and rental requests.
- `Core/Stores/` manages `@MainActor` UI state and validates domain actions.
- `Core/Repositories/` maps models to Firebase Authentication and Firestore operations.
- `Features/` groups authentication, browse, tenant, landlord, profile, and property-detail workflows.
- `Shared/Views/` contains reusable loading, empty, filtering, layout, and result components.

### Firestore Data Model

| Collection | Model | Purpose |
| --- | --- | --- |
| `users` | `UserProfile` | Account role and editable profile details |
| `properties` | `Property` | Rental listing content, ownership, and listing status |
| `rentalRequests` | `RentalRequest` | Tenant-landlord requests and lifecycle status |
| `shortlistProperties` | `ShortlistProperty` | Tenant-to-property shortlist relationships |

## Tech Stack

| Area | Technology |
| --- | --- |
| Language | Swift 5 |
| UI | SwiftUI |
| State management | Observation with `@Observable` |
| Concurrency | Swift `async`/`await` with main-actor stores |
| Authentication | Firebase Authentication |
| Persistence | Cloud Firestore |
| Secure storage | iOS Security framework and Keychain Services |
| Dependency management | Swift Package Manager |

## Running the Project

### Prerequisites

- macOS with Xcode and iOS 26.5 SDK support; the project currently targets iOS 26.5.
- A Firebase iOS project with Email/Password Authentication and Cloud Firestore enabled.

### Configuration

1. Register an iOS app in Firebase with the bundle identifier `shangc.Rent-Project`.
2. Add the Firebase `GoogleService-Info.plist` file at `Rent_Project/GoogleService-Info.plist`.
3. Configure Firebase Authentication and Firestore access rules for the intended users and collections.

Never commit service-account credentials or other private backend secrets.

### Running

1. Open `Rent_Project.xcodeproj` in Xcode.
2. Allow Swift Package Manager to resolve the Firebase dependencies.
3. Select the `Rent_Project` scheme and an iOS simulator or connected device.
4. Build and run the app.

## Author

**Chuhan Shang**

[GitHub](https://github.com/shangc97)
