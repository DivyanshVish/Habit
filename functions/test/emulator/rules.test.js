"use strict";
// Runs against the Firestore emulator:
//   npm run emulators:test
const { before, after, beforeEach, test } = require("node:test");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-habitry",
    firestore: {
      rules: readFileSync(join(__dirname, "../../../firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

after(async () => env.cleanup());
beforeEach(async () => env.clearFirestore());

test("a user can read and write their own habits", async () => {
  const db = env.authenticatedContext("alice").firestore();
  await assertSucceeds(
    db.doc("users/alice/habits/h1").set({ name: "Read", points: 10 }),
  );
  await assertSucceeds(db.doc("users/alice/habits/h1").get());
});

test("a user cannot read another user's habits", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc("users/alice/habits/h1").set({ name: "Read" });
  });
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(db.doc("users/alice/habits/h1").get());
  await assertFails(db.doc("users/alice/habits/h1").set({ name: "x" }));
});

test("unauthenticated users are denied everywhere", async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(db.doc("users/alice/habits/h1").get());
  await assertFails(db.doc("groups/g1").get());
});

test("unknown top-level collections are denied by default", async () => {
  const db = env.authenticatedContext("alice").firestore();
  await assertFails(db.doc("something/else").get());
  await assertFails(db.doc("something/else").set({ a: 1 }));
});
