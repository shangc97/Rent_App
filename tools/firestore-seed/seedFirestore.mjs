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
import { getFirestore } from "firebase-admin/firestore";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const localCredentialPath = path.join(
  __dirname,
  "credentials",
  "service-account.json"
);

const collections = [
  {
    name: "users",
    fileName: "users.json",
    idField: "userId",
  },
  {
    name: "properties",
    fileName: "properties.json",
    idField: "propertyId",
  },
  {
    name: "rentalRequests",
    fileName: "rentalRequests.json",
    idField: "requestId",
  },
  {
    name: "shortlistProperties",
    fileName: "shortlistProperties.json",
    idField: "shortlistPropertyId",
  },
];

async function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    printHelp();
    return;
  }

  const selectedCollections = getSelectedCollections(options.only);
  const app = await initializeFirebase();
  const db = getFirestore(app);

  console.log("Starting Firestore seed...");
  console.log(
    `Collections: ${selectedCollections.map((collection) => collection.name).join(", ")}`
  );
  console.log(`Mode: ${options.reset ? "reset and reseed" : "upsert"}`);

  if (options.reset) {
    for (const collection of selectedCollections) {
      const deletedCount = await deleteCollectionDocuments(db, collection.name);
      console.log(`Cleared ${deletedCount} document(s) from ${collection.name}`);
    }
  }

  for (const collection of selectedCollections) {
    const records = await loadSeedRecords(collection.fileName);
    await writeCollectionDocuments(db, collection.name, collection.idField, records);
    console.log(`Seeded ${records.length} document(s) into ${collection.name}`);
  }

  console.log("Firestore seed finished successfully.");
}

function parseArgs(args) {
  const options = {
    help: false,
    only: null,
    reset: false,
  };

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];

    if (arg === "--help" || arg === "-h") {
      options.help = true;
      continue;
    }

    if (arg === "--reset") {
      options.reset = true;
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
  console.log(`
Usage:
  npm run seed
  npm run seed -- --reset
  npm run seed -- --only=users,properties

Credential resolution order:
  1. GOOGLE_APPLICATION_CREDENTIALS
  2. tools/firestore-seed/credentials/service-account.json
`.trim());
}

function getSelectedCollections(onlyValue) {
  if (!onlyValue) {
    return collections;
  }

  const requestedNames = onlyValue
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);

  if (requestedNames.length === 0) {
    throw new Error("The --only option was provided, but no collection names were found.");
  }

  const selected = collections.filter((collection) =>
    requestedNames.includes(collection.name)
  );

  if (selected.length !== requestedNames.length) {
    const validNames = collections.map((collection) => collection.name).join(", ");
    throw new Error(`Unknown collection name in --only. Valid options: ${validNames}`);
  }

  return selected;
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

async function loadSeedRecords(fileName) {
  const filePath = path.join(__dirname, "sample-data", fileName);
  const fileContents = await fs.readFile(filePath, "utf8");
  const parsed = JSON.parse(fileContents);

  if (!Array.isArray(parsed)) {
    throw new Error(`${fileName} must contain a JSON array.`);
  }

  return parsed;
}

async function writeCollectionDocuments(db, collectionName, idField, records) {
  for (const record of records) {
    const documentId = record[idField];

    if (typeof documentId !== "string" || documentId.trim().length === 0) {
      throw new Error(
        `Each ${collectionName} record must include a non-empty string ${idField}.`
      );
    }
  }

  for (const chunk of chunkRecords(records, 400)) {
    const batch = db.batch();

    for (const record of chunk) {
      const documentId = record[idField];
      const documentReference = db.collection(collectionName).doc(documentId);
      batch.set(documentReference, record, { merge: true });
    }

    await batch.commit();
  }
}

async function deleteCollectionDocuments(db, collectionName) {
  let deletedCount = 0;

  while (true) {
    const snapshot = await db.collection(collectionName).limit(400).get();

    if (snapshot.empty) {
      return deletedCount;
    }

    const batch = db.batch();
    snapshot.docs.forEach((document) => batch.delete(document.ref));
    await batch.commit();

    deletedCount += snapshot.size;
  }
}

function chunkRecords(records, chunkSize) {
  const chunks = [];

  for (let index = 0; index < records.length; index += chunkSize) {
    chunks.push(records.slice(index, index + chunkSize));
  }

  return chunks;
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
  console.error("\nFirestore seed failed.");
  console.error(error.message);
  process.exitCode = 1;
});
