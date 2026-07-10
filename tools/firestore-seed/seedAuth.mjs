import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

import {
  applicationDefault,
  cert,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const localCredentialPath = path.join(
  __dirname,
  "credentials",
  "service-account.json"
);
const usersFilePath = path.join(__dirname, "sample-data", "users.json");
const passwordsFilePath = path.join(
  __dirname,
  "credentials",
  "auth-passwords.json"
);

async function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    printHelp();
    return;
  }

  const app = await initializeFirebase();
  const auth = getAuth(app);
  const users = await loadUsers();
  const selectedUsers = getSelectedUsers(users, options.only);
  const passwordRecords = await loadPasswordRecords();
  const authUsers = prepareAuthUsers(selectedUsers, passwordRecords);

  console.log("Starting Firebase Auth seed...");
  console.log(`Users: ${authUsers.length}`);
  console.log(`Mode: ${options.check ? "validate only" : "upsert"}`);

  let createdCount = 0;
  let updatedCount = 0;
  let validatedCount = 0;

  for (const authUser of authUsers) {
    const result = options.check
      ? await validateAuthUser(auth, authUser)
      : await upsertAuthUser(auth, authUser);

    if (result === "created") {
      createdCount += 1;
    } else if (result === "updated") {
      updatedCount += 1;
    } else {
      validatedCount += 1;
    }

    console.log(`${result.toUpperCase()}: ${authUser.uid} (${authUser.email})`);
  }

  console.log("Firebase Auth seed finished successfully.");
  console.log(
    `Summary: created=${createdCount}, updated=${updatedCount}, validated=${validatedCount}`
  );
}

function parseArgs(args) {
  const options = {
    help: false,
    check: false,
    only: null,
  };

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];

    if (arg === "--help" || arg === "-h") {
      options.help = true;
      continue;
    }

    if (arg === "--check") {
      options.check = true;
      continue;
    }

    if (arg === "--only") {
      options.only = args[index + 1] ?? "";
      index += 1;
      continue;
    }

    if (arg.startsWith("--only=")) {
      options.only = arg.slice("--only=".length);
      continue;
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return options;
}

function printHelp() {
  console.log(
    `
Usage:
  npm run seed:auth
  npm run seed:auth -- --check
  npm run seed:auth -- --only=Mx4Jq8Ls2Vn6Pw1Rb7Tc,Ua2Pe7Rw4Ty9Ik3Lm6No

Required files:
  sample-data/users.json
  credentials/auth-passwords.json

Credential resolution order:
  1. GOOGLE_APPLICATION_CREDENTIALS
  2. tools/firestore-seed/credentials/service-account.json
`.trim()
  );
}

function getSelectedUsers(users, onlyValue) {
  if (!onlyValue) {
    return users;
  }

  const requestedIds = onlyValue
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);

  if (requestedIds.length === 0) {
    throw new Error("The --only option was provided, but no user IDs were found.");
  }

  const selectedUsers = users.filter((user) => requestedIds.includes(user.userId));

  if (selectedUsers.length !== requestedIds.length) {
    const availableIds = users.map((user) => user.userId).join(", ");
    throw new Error(
      `Unknown userId in --only. Valid options: ${availableIds}`
    );
  }

  return selectedUsers;
}

async function initializeFirebase() {
  if (getApps().length > 0) {
    return getApps()[0];
  }

  const credential = await resolveCredential();
  return initializeApp({ credential });
}

async function resolveCredential() {
  const environmentCredentialPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (environmentCredentialPath) {
    await ensureFileExists(
      environmentCredentialPath,
      `The GOOGLE_APPLICATION_CREDENTIALS file was not found at ${environmentCredentialPath}`
    );
    return applicationDefault();
  }

  if (await fileExists(localCredentialPath)) {
    const credentialFile = await fs.readFile(localCredentialPath, "utf8");
    return cert(JSON.parse(credentialFile));
  }

  throw new Error(
    [
      "No Firebase Admin credential file was found.",
      "Add your service account JSON to:",
      `  ${localCredentialPath}`,
      "or set GOOGLE_APPLICATION_CREDENTIALS to the downloaded JSON file path.",
    ].join("\n")
  );
}

async function loadUsers() {
  const fileContents = await fs.readFile(usersFilePath, "utf8");
  const parsed = JSON.parse(fileContents);

  if (!Array.isArray(parsed)) {
    throw new Error("users.json must contain a JSON array.");
  }

  return parsed;
}

async function loadPasswordRecords() {
  await ensureFileExists(
    passwordsFilePath,
    `The Auth passwords file was not found at ${passwordsFilePath}`
  );

  const fileContents = await fs.readFile(passwordsFilePath, "utf8");
  const parsed = JSON.parse(fileContents);

  if (parsed === null || Array.isArray(parsed) || typeof parsed !== "object") {
    throw new Error("auth-passwords.json must contain a JSON object.");
  }

  return parsed;
}

function prepareAuthUsers(users, passwordRecords) {
  const seenUserIds = new Set();
  const seenEmails = new Set();

  return users.map((user) => {
    validateSeedUser(user, seenUserIds, seenEmails);

    const passwordRecord = passwordRecords[user.userId];

    if (passwordRecord == null) {
      throw new Error(
        `No password entry was found in auth-passwords.json for userId ${user.userId}.`
      );
    }

    const resolvedPasswordRecord =
      typeof passwordRecord === "string"
        ? { email: user.email, password: passwordRecord }
        : passwordRecord;

    if (
      resolvedPasswordRecord === null ||
      Array.isArray(resolvedPasswordRecord) ||
      typeof resolvedPasswordRecord !== "object"
    ) {
      throw new Error(
        `The password entry for userId ${user.userId} must be either a string password or an object.`
      );
    }

    const password = resolvedPasswordRecord.password;
    const passwordEmail = resolvedPasswordRecord.email ?? user.email;

    if (typeof password !== "string" || password.length < 6) {
      throw new Error(
        `The password entry for userId ${user.userId} must be a string with at least 6 characters.`
      );
    }

    if (typeof passwordEmail !== "string" || passwordEmail.trim().length === 0) {
      throw new Error(
        `The password entry for userId ${user.userId} must include a non-empty email.`
      );
    }

    if (passwordEmail !== user.email) {
      throw new Error(
        `Email mismatch for userId ${user.userId}: users.json has ${user.email}, but auth-passwords.json has ${passwordEmail}.`
      );
    }

    const displayName =
      typeof user.fullName === "string" && user.fullName.trim().length > 0
        ? user.fullName.trim()
        : user.email;

    return {
      uid: user.userId,
      email: user.email,
      password,
      displayName,
    };
  });
}

function validateSeedUser(user, seenUserIds, seenEmails) {
  if (typeof user.userId !== "string" || user.userId.trim().length === 0) {
    throw new Error("Each user record in users.json must include a non-empty userId.");
  }

  if (typeof user.email !== "string" || user.email.trim().length === 0) {
    throw new Error(
      `The user record ${user.userId} in users.json must include a non-empty email.`
    );
  }

  if (seenUserIds.has(user.userId)) {
    throw new Error(`Duplicate userId found in users.json: ${user.userId}`);
  }

  if (seenEmails.has(user.email)) {
    throw new Error(`Duplicate email found in users.json: ${user.email}`);
  }

  seenUserIds.add(user.userId);
  seenEmails.add(user.email);
}

async function upsertAuthUser(auth, authUser) {
  await ensureEmailOwnership(auth, authUser.email, authUser.uid);

  const existingUser = await findUserByUid(auth, authUser.uid);

  if (existingUser) {
    await auth.updateUser(authUser.uid, {
      email: authUser.email,
      password: authUser.password,
      displayName: authUser.displayName,
    });
    return "updated";
  }

  await auth.createUser({
    uid: authUser.uid,
    email: authUser.email,
    password: authUser.password,
    displayName: authUser.displayName,
  });
  return "created";
}

async function validateAuthUser(auth, authUser) {
  await ensureEmailOwnership(auth, authUser.email, authUser.uid);

  const existingUser = await findUserByUid(auth, authUser.uid);

  if (!existingUser) {
    throw new Error(
      `Auth user ${authUser.uid} (${authUser.email}) does not exist yet. Run without --check to create it.`
    );
  }

  return "validated";
}

async function ensureEmailOwnership(auth, email, expectedUid) {
  const emailUser = await findUserByEmail(auth, email);

  if (emailUser && emailUser.uid !== expectedUid) {
    throw new Error(
      [
        `Email conflict for ${email}.`,
        `Authentication already has this email under uid ${emailUser.uid},`,
        `but users.json expects uid ${expectedUid}.`,
        "Delete or migrate the conflicting Auth user before seeding again.",
      ].join(" ")
    );
  }
}

async function findUserByUid(auth, uid) {
  try {
    return await auth.getUser(uid);
  } catch (error) {
    if (isUserNotFoundError(error)) {
      return null;
    }

    throw error;
  }
}

async function findUserByEmail(auth, email) {
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    if (isUserNotFoundError(error)) {
      return null;
    }

    throw error;
  }
}

function isUserNotFoundError(error) {
  return error?.code === "auth/user-not-found";
}

async function ensureFileExists(filePath, errorMessage) {
  if (!(await fileExists(filePath))) {
    throw new Error(errorMessage);
  }
}

async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

main().catch((error) => {
  console.error("\nFirebase Auth seed failed.");
  console.error(error.message);
  process.exitCode = 1;
});
