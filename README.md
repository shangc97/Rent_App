# 4Rent

4Rent is a SwiftUI rental marketplace app built for an Advanced iOS course project. The app supports three user roles: guest, tenant, and landlord. It uses Firebase Authentication for account management and Cloud Firestore for persistent app data.

## Implemented Features

### Guest User

- Browse all property listings
- Search rental properties by keyword, city, or address
- View property details

### Tenant User

- Create an account and sign in with FirebaseAuth
- Browse and search rental properties
- View full property details
- Share property details
- Add or remove properties from a shortlist
- View shortlisted properties
- Submit rental requests
- Withdraw submitted rental requests
- View request history by status
- View and edit personal profile information

### Landlord User

- Create an account and sign in with FirebaseAuth
- Browse and search rental properties
- View property details
- Add new property listings
- Edit owned property details
- List and unlist owned properties
- View owned listings by status
- Receive rental requests for owned properties
- Approve or deny submitted rental requests
- View and edit personal profile information

## Authentication and Session Behavior

- Firebase Authentication is used for registration, sign in, and sign out
- User roles are resolved from Firestore profile documents
- The app routes authenticated users to the correct tenant or landlord flow
- A guest flow is available without signing in
- Remember Me pre-fills saved email and password on the next app launch without automatically submitting login

## Data Persistence

Cloud Firestore is used to persist user-generated data across multiple root-level collections:

- `users`
- `properties`
- `rentalRequests`
- `shortlistProperties`

## Tech Stack

- Swift
- SwiftUI
- Observation
- FirebaseAuth
- Cloud Firestore

## Project Structure

```text
Rent_Project/
├── README.md
├── Rent_Project.xcodeproj
└── Rent_Project/
    ├── App/
    ├── Core/
    │   ├── Models/
    │   ├── Repositories/
    │   └── Stores/
    ├── Features/
    │   ├── Auth/
    │   ├── Browse/
    │   ├── Guest/
    │   ├── Landlord/
    │   ├── Profile/
    │   ├── PropertyDetails/
    │   └── Tenant/
    ├── Shared/
    │   └── Views/
    ├── Assets.xcassets/
    ├── GoogleService-Info.plist
    └── Rent_ProjectApp.swift
```

## How to Run

1. Open `Rent_Project.xcodeproj` in Xcode.
2. Select the `Rent_Project` scheme.
3. Make sure the included Firebase configuration file is present.
4. Run the app on an iOS Simulator or physical device.

## Architecture Notes

- `App/` manages root session state and flow coordination
- `Core/Models/` defines the main app entities
- `Core/Repositories/` handles Firebase read and write operations
- `Core/Stores/` holds observable in-memory state for the UI layer
- `Features/` contains role-based screens and business flows
- `Shared/Views/` contains reusable UI building blocks
