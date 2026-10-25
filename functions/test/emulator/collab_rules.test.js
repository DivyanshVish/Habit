"use strict";
// Security rules for shared habits and groups. Runs against the emulator:
//   npm run emulators:test
const { before, after, beforeEach, test } = require("node:test");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { serverTimestamp } = require("firebase/firestore");

let env;

function todayKey(offsetDays = 0) {
  const d = new Date(Date.now() + offsetDays * 86400000);
  return d.toISOString().slice(0, 10);
}

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

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc("sharedHabits/s1").set({
      ownerUid: "alice",
      status: "active",
      participantUids: ["alice", "bob"],
    });
    await db.doc("sharedHabits/s1/participants/alice").set({ status: "active" });
    await db.doc("sharedHabits/s1/cycles/" + todayKey()).set({ completedCount: 1 });
    await db.doc("groups/g1").set({ ownerUid: "alice", status: "active" });
    await db.doc("groups/g1/members/alice").set({ role: "owner", status: "active" });
    await db.doc("groups/g1/members/bob").set({ role: "member", status: "active" });
    await db.doc("groups/g1/members/carl").set({ role: "member", status: "left" });
    await db.doc("groups/g1/habits/h1").set({ name: "Run", status: "active" });
    await db.doc("groups/g1/habits/h2").set({ name: "Old", status: "archived" });
    await db.doc("groups/g1/habits/h1/cycles/" + todayKey()).set({ completedCount: 0 });
    await db.doc("groups/g1/auditLog/a1").set({ action: "x" });
    await db.doc("invitations/i1").set({ code: "hash" });
    await db.doc("joinCodes/c1").set({ groupId: "g1" });
  });
});

function completion(uid, dateKey) {
  return { uid, dateKey, completedAt: serverTimestamp(), clientOpId: "op1" };
}

// ---- shared habits -------------------------------------------------------

test("participants can read a shared habit, outsiders cannot", async () => {
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc("sharedHabits/s1").get());
  await assertFails(env.authenticatedContext("eve").firestore().doc("sharedHabits/s1").get());
  await assertFails(env.unauthenticatedContext().firestore().doc("sharedHabits/s1").get());
});

test("clients can never write a shared habit or its participants", async () => {
  const db = env.authenticatedContext("alice").firestore();
  await assertFails(db.doc("sharedHabits/s1").update({ name: "hacked" }));
  await assertFails(db.doc("sharedHabits/s2").set({ participantUids: ["alice"] }));
  await assertFails(db.doc("sharedHabits/s1/participants/alice").set({ status: "left" }));
});

test("a participant can record their own completion", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  await assertSucceeds(db.doc(`sharedHabits/s1/completions/bob_${key}`).set(completion("bob", key)));
});

test("a participant cannot record a completion for someone else", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(db.doc(`sharedHabits/s1/completions/alice_${key}`).set(completion("alice", key)));
});

test("a wrong document id is rejected", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(db.doc("sharedHabits/s1/completions/random").set(completion("bob", key)));
});

test("a non-participant cannot complete", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("eve").firestore();
  await assertFails(db.doc(`sharedHabits/s1/completions/eve_${key}`).set(completion("eve", key)));
});

test("a date more than one day away is rejected", async () => {
  const key = todayKey(-5);
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(db.doc(`sharedHabits/s1/completions/bob_${key}`).set(completion("bob", key)));
});

test("yesterday and tomorrow are accepted (time zone slack)", async () => {
  const db = env.authenticatedContext("bob").firestore();
  for (const offset of [-1, 1]) {
    const key = todayKey(offset);
    await assertSucceeds(db.doc(`sharedHabits/s1/completions/bob_${key}`).set(completion("bob", key)));
  }
});

test("a repeated completion targets the same document", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  const ref = db.doc(`sharedHabits/s1/completions/bob_${key}`);
  await assertSucceeds(ref.set(completion("bob", key)));
  await assertSucceeds(ref.set(completion("bob", key)));
  const all = await env.withSecurityRulesDisabled(async (ctx) =>
    ctx.firestore().collection("sharedHabits/s1/completions").get(),
  );
  if (all.size !== 1) throw new Error(`expected 1 completion, got ${all.size}`);
});

test("completions are readable only by their owner", async () => {
  const key = todayKey();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc(`sharedHabits/s1/completions/bob_${key}`).set({ uid: "bob", dateKey: key });
  });
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc(`sharedHabits/s1/completions/bob_${key}`).get());
  await assertFails(env.authenticatedContext("alice").firestore().doc(`sharedHabits/s1/completions/bob_${key}`).get());
});

test("a participant can undo only their own completion", async () => {
  const key = todayKey();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc(`sharedHabits/s1/completions/bob_${key}`).set({ uid: "bob", dateKey: key });
  });
  await assertFails(env.authenticatedContext("alice").firestore().doc(`sharedHabits/s1/completions/bob_${key}`).delete());
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc(`sharedHabits/s1/completions/bob_${key}`).delete());
});

test("participants read cycle aggregates, outsiders do not, nobody writes", async () => {
  const path = "sharedHabits/s1/cycles/" + todayKey();
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc(path).get());
  await assertFails(env.authenticatedContext("eve").firestore().doc(path).get());
  await assertFails(env.authenticatedContext("bob").firestore().doc(path).set({ completedCount: 99 }));
});

// ---- groups ---------------------------------------------------------------

test("active members read group data, others cannot", async () => {
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc("groups/g1").get());
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc("groups/g1/members/alice").get());
  await assertSucceeds(env.authenticatedContext("bob").firestore().doc("groups/g1/habits/h1").get());
  await assertFails(env.authenticatedContext("eve").firestore().doc("groups/g1").get());
  await assertFails(env.authenticatedContext("carl").firestore().doc("groups/g1").get()); // left
  await assertFails(env.authenticatedContext("eve").firestore().doc("groups/g1/habits/h1").get());
});

test("clients can never write group, membership or habit documents", async () => {
  const db = env.authenticatedContext("alice").firestore(); // even the owner
  await assertFails(db.doc("groups/g1").update({ name: "x" }));
  await assertFails(db.doc("groups/g1/members/bob").update({ role: "admin" }));
  await assertFails(db.doc("groups/g1/members/eve").set({ role: "member", status: "active" }));
  await assertFails(db.doc("groups/g1/habits/h3").set({ name: "x", status: "active" }));
  await assertFails(db.doc("groups/g1/habits/h1").update({ name: "x" }));
});

test("a member can complete an active group habit", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  await assertSucceeds(db.doc(`groups/g1/habits/h1/completions/bob_${key}`).set(completion("bob", key)));
});

test("an archived group habit rejects new completions", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("bob").firestore();
  await assertFails(db.doc(`groups/g1/habits/h2/completions/bob_${key}`).set(completion("bob", key)));
});

test("a member who left cannot complete", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("carl").firestore();
  await assertFails(db.doc(`groups/g1/habits/h1/completions/carl_${key}`).set(completion("carl", key)));
});

test("a non-member cannot complete a group habit", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("eve").firestore();
  await assertFails(db.doc(`groups/g1/habits/h1/completions/eve_${key}`).set(completion("eve", key)));
});

test("a member cannot complete on behalf of another member", async () => {
  const key = todayKey();
  const db = env.authenticatedContext("alice").firestore(); // admin/owner
  await assertFails(db.doc(`groups/g1/habits/h1/completions/bob_${key}`).set(completion("bob", key)));
});

test("only admins read the audit log", async () => {
  await assertSucceeds(env.authenticatedContext("alice").firestore().doc("groups/g1/auditLog/a1").get());
  await assertFails(env.authenticatedContext("bob").firestore().doc("groups/g1/auditLog/a1").get());
});

// ---- server-only collections ------------------------------------------------

test("invitations, join codes, events and rate limits are server-only", async () => {
  const db = env.authenticatedContext("alice").firestore();
  await assertFails(db.doc("invitations/i1").get());
  await assertFails(db.doc("invitations/i2").set({ code: "x" }));
  await assertFails(db.doc("joinCodes/c1").get());
  await assertFails(db.doc("notificationEvents/e1").set({ a: 1 }));
  await assertFails(db.doc("rateLimits/alice").set({ n: 0 }));
});
