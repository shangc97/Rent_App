# Rent_App

Rent_App is an iOS rental marketplace prototype built with SwiftUI for an Advanced iOS course project.

The current version focuses on Module 1: building the app foundation, role-based navigation, and a maintainable feature structure for future development.

## Current Scope

- Shared app entry flow with loading, logged out, and guest modes
- Role-based routing for guest, tenant, and landlord experiences
- Modular SwiftUI feature folders for auth, browse, tenant, landlord, profile, and property detail flows
- Tab-based home screens for each user role
- Reusable shared views such as loading, empty state, and property search
- Preview helpers for testing screens in different session states

## Tech Stack

- Swift
- SwiftUI
- Xcode project structure
- Observation-based app state

## Project Structure

```text
Rent_Project/
├── Rent_Project/
│   ├── App/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Repositories/
│   │   └── Services/
│   ├── Features/
│   │   ├── Auth/
│   │   ├── Browse/
│   │   ├── Landlord/
│   │   ├── Profile/
│   │   ├── PropertyDetail/
│   │   └── Tenant/
│   └── Shared/
│       ├── Utilities/
│       └── Views/
└── Rent_Project.xcodeproj
```

## Main Flows in Module 1

### Authentication and Root Navigation

- `RootView` decides whether the app shows loading, auth, guest, tenant, or landlord content
- `AuthLandingView` is the shared entry point for log in, registration, and guest access
- `LoginView` and `RegisterView` currently use demo session switching to shape the flow

### Guest Experience

- Browse sample property listings
- Search properties through a shared search screen
- Navigate to registration from the guest home flow

### Tenant Experience

- Open a tenant tab layout for shortlist, requests, search, and profile
- Preview property details and tenant-specific actions

### Landlord Experience

- Open a landlord tab layout for listings, requests, search, and profile
- Preview property details and landlord-specific actions

## How to Run

1. Open `Rent_Project.xcodeproj` in Xcode.
2. Select the `Rent_Project` scheme.
3. Run the app on an iOS Simulator.

## Notes

- Module 1 uses mock data and demo state transitions to establish navigation and screen structure.
- Firebase authentication, Firestore data, and persistent user actions are not part of the current module scope.

