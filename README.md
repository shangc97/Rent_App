# 4Rent

4Rent is a SwiftUI rental marketplace prototype for an Advanced iOS course project. The app supports guest, tenant, and landlord flows, and the repository is being built in ordered modules so the UI, data layer, and backend integration stay aligned.

## Development Approach

- The module roadmap is the main source of truth for implementation order.
- Some screens from later modules already exist as local mock prototypes.
- A later-module feature is not considered complete until its data flow, rules, and persistence are finished.

## Current Status

- `Module 1 App Foundation` is complete.
- `Module 2 Data Models` is currently in progress.
- Browse, property detail, tenant, and landlord flows already have local mock prototypes.
- FirebaseAuth, Firestore, persistent profile editing, and Remember Me storage are not connected yet.

## Current Implemented Scope

- Root routing for `loading`, `logged out`, `guest`, `tenant`, and `landlord` app states
- Tab-based home screens for guest, tenant, and landlord users
- Shared mock property browsing and keyword search
- Property detail screen with guest, tenant, and landlord action sections
- Early tenant screens for shortlist and rental requests
- Early landlord screens for listings, add property, and request review
- Reusable shared views for loading, empty state, property rows, and search

## Updated Module Roadmap

| # | Module | Main Goal | Status |
| --- | --- | --- | --- |
| 1 | App Foundation | Set up app structure, root navigation, and role-based entry flows | Complete |
| 2 | Data Models | Define `UserProfile`, `Property`, `RentalRequest`, `ShortlistItem`, and status enums | In Progress |
| 3 | Browse / Search | Build shared property listing and search flows for all roles | Prototype Started |
| 4 | Property Detail | Build the full property details experience and action entry points | Prototype Started |
| 5 | User Profile | Build profile viewing and editing flows | Placeholder |
| 6 | Firebase + Persistence Layer | Add FirebaseAuth, Firestore, and repository/service structure | Not Started |
| 7 | Authentication | Replace demo auth with real registration, login, logout, and role routing | Demo Prototype Only |
| 8 | Remember Me | Save and restore login form values with `UserDefaults` | UI Started |
| 9 | Map / Location | Add coordinates and property map presentation | Not Started |
| 10 | Tenant Features | Complete shortlist, request submission, withdrawal, and sharing | Prototype Started |
| 11 | Landlord Features | Complete listing CRUD and request review actions | Prototype Started |
| 12 | Business Rules | Enforce listing, request, and role-based workflow rules | Early Planning |
| 13 | Shared UI / Reusable Components | Standardize common form, list, card, and state components | In Progress |
| 14 | Error Handling + Validation | Add form validation, permission handling, and data error feedback | Early Partial |
| 15 | Final Polish + Submission Prep | Final cleanup, demo coverage, build check, and submission prep | Not Started |

## Recommended Near-Term Order

1. Finish `Module 2 Data Models` and lock the core objects and enums.
2. Stabilize `Module 3 Browse / Search` on top of those shared models.
3. Strengthen `Module 4 Property Detail` so every property route uses the same data shape.
4. Keep tenant and landlord flows mock-driven until the Firebase and authentication modules begin.

## Tech Stack

- Swift
- SwiftUI
- Observation-based app state
- Xcode project structure
- Local mock data for early feature development

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

## How to Run

1. Open `Rent_Project.xcodeproj` in Xcode.
2. Select the `Rent_Project` scheme.
3. Run the app on an iOS Simulator.

## Notes

- The current repository mixes completed foundation work with in-progress prototypes from later modules.
- Mock data and local state are intentionally being used before backend integration.
- The README should be updated whenever a module moves from prototype to fully implemented.
