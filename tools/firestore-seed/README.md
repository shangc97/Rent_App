# Firestore Seed Script

This folder contains a local script for inserting sample data into your Firebase Firestore project.

## What It Seeds

- `users`
- `properties`
- `rentalRequests`
- `shortlistProperties`

The JSON data lives in `sample-data/`, so you can edit records without touching the script.

## First-Time Setup

1. In Firebase Console, open your project.
2. Go to `Project settings` -> `Service accounts`.
3. Click `Generate new private key`.
4. Download the JSON file.
5. Rename it to `service-account.json`.
6. Move it into:

```text
tools/firestore-seed/credentials/service-account.json
```

You can also keep the JSON somewhere else and set:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
```

## Install Dependencies

Run this once:

```bash
cd /Users/shangc/Desktop/3-Advanced\ iOS/Project/Rent_Project/tools/firestore-seed
npm install
```

## Seed Firestore

Upsert the sample data:

```bash
npm run seed
```

Delete the seeded collections first, then re-insert everything:

```bash
npm run seed:reset
```

Seed only specific collections:

```bash
npm run seed -- --only=users,properties
```

## Notes

- The script uses fixed document IDs, so rerunning `npm run seed` updates the same documents instead of creating duplicates.
- `npm run seed:reset` clears only the four seeded collections in this tool.
- The credential JSON inside `credentials/` is ignored by git.
- This script uses the Firebase Admin SDK, so Firestore security rules do not block it.
