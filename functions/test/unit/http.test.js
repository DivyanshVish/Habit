"use strict";
const { test, before } = require("node:test");
const assert = require("node:assert/strict");

let handleCall;

before(() => {
  // Firestore is only constructed here, never contacted.
  const { initializeApp } = require("firebase-admin/app");
  initializeApp({ projectId: "demo-habitry" });
  ({ handleCall } = require("../../lib/src/http"));
});

test("only POST is accepted", async () => {
  const result = await handleCall("GET", "Bearer x", { name: "ping" });
  assert.equal(result.status, 400);
});

test("an unknown function is a 404, including object prototype names", async () => {
  for (const name of ["nope", "constructor", "__proto__", "toString", 5, undefined]) {
    const result = await handleCall("POST", "Bearer x", { name });
    assert.equal(result.status, 404, String(name));
  }
});

test("a call without a token is rejected before anything runs", async () => {
  const none = await handleCall("POST", undefined, { name: "createGroup", data: {} });
  assert.equal(none.status, 401);
  const wrongScheme = await handleCall("POST", "Basic abc", { name: "createGroup", data: {} });
  assert.equal(wrongScheme.status, 401);
});

test("a token that is not a Firebase ID token is rejected", async () => {
  const result = await handleCall("POST", "Bearer not-a-real-token", {
    name: "createGroup",
    data: { name: "x" },
  });
  assert.equal(result.status, 401);
  assert.equal(result.body.error.code, "unauthenticated");
});

test("error bodies never include a stack trace", async () => {
  const result = await handleCall("POST", "Bearer nope", { name: "ping" });
  assert.deepEqual(Object.keys(result.body.error).sort(), ["code", "message"]);
});

test("the registry lists every function the app calls", () => {
  const { handlers } = require("../../lib/src/registry");
  for (const name of [
    "createGroup", "updateGroupSettings", "leaveGroup", "removeMember", "setMemberRole",
    "transferOwnership", "archiveGroup", "createGroupHabit", "updateGroupHabit",
    "archiveGroupHabit", "createSharedHabit", "leaveSharedHabit", "mirrorPersonalCompletion",
    "createInvitation", "previewInvitation", "respondToInvitation", "revokeInvitation",
    "refreshCycle", "syncProfile", "deleteAccount", "migrateAccount", "ping",
    "listInvitablePeople", "reviewJoinRequest",
  ]) {
    assert.equal(typeof handlers[name], "function", name);
  }
});

test("parseRule never produces an undefined value (Firestore rejects it)", () => {
  const { parseRule } = require("../../lib/src/groups");
  const majority = parseRule({ type: "majority" });
  assert.deepEqual(majority, { type: "majority" });
  assert.equal("value" in majority, false);
  assert.deepEqual(parseRule({ type: "percentage", value: 80 }), { type: "percentage", value: 80 });
  assert.deepEqual(parseRule({ type: "fixed", value: 3 }), { type: "fixed", value: 3 });
  assert.deepEqual(parseRule(undefined), { type: "individual" });
  assert.throws(() => parseRule({ type: "fixed" }));
  assert.throws(() => parseRule({ type: "percentage", value: 101 }));
  assert.throws(() => parseRule({ type: "bogus" }));
});

test("parseEmblem accepts only the known icons and colours", () => {
  const { parseEmblem, EMBLEM_ICONS, EMBLEM_COLORS } = require("../../lib/src/groups");
  assert.equal(parseEmblem(undefined), null);
  assert.equal(parseEmblem(null), null);
  assert.deepEqual(parseEmblem({ icon: "run", color: 3 }), { icon: "run", color: 3 });
  for (const icon of EMBLEM_ICONS) {
    assert.deepEqual(parseEmblem({ icon, color: 0 }), { icon, color: 0 });
  }
  assert.deepEqual(parseEmblem({ icon: "run", color: EMBLEM_COLORS - 1 }), {
    icon: "run",
    color: EMBLEM_COLORS - 1,
  });
  for (const bad of [
    { icon: "skull", color: 0 },
    { icon: "run", color: -1 },
    { icon: "run", color: EMBLEM_COLORS },
    { icon: "run", color: 1.5 },
    { icon: "run", color: "1" },
    { icon: 5, color: 1 },
    { color: 1 },
    { icon: "run" },
    "run",
  ]) {
    assert.throws(() => parseEmblem(bad), JSON.stringify(bad));
  }
});

test("the app and the server agree on the emblem icons", () => {
  const { EMBLEM_ICONS } = require("../../lib/src/groups");
  const dart = require("node:fs").readFileSync(
    require("node:path").join(
      __dirname,
      "../../../lib/features/groups/domain/entities/group_entities.dart",
    ),
    "utf8",
  );
  for (const icon of EMBLEM_ICONS) {
    assert.ok(dart.includes(`'${icon}'`), `the app is missing icon "${icon}"`);
  }
});
