"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const L = require("../../lib/src/logic");

const streakFixtures = JSON.parse(
  readFileSync(join(__dirname, "../../../test/fixtures/streak_history_cases.json"), "utf8"),
);

for (const c of streakFixtures.cases) {
  test(`streak: ${c.name}`, () => {
    const actual = L.calculateStreak(c.done, c.start, c.today, c.weekdays ?? L.ALL_WEEKDAYS);
    assert.deepEqual({ ...actual }, c.expect);
  });
}

// ---- date keys ----------------------------------------------------------------

test("addDays crosses month, year and leap day", () => {
  assert.equal(L.addDays("2026-10-31", 1), "2026-11-01");
  assert.equal(L.addDays("2026-12-31", 1), "2027-01-01");
  assert.equal(L.addDays("2028-02-28", 1), "2028-02-29");
  assert.equal(L.addDays("2027-02-28", 1), "2027-03-01");
  assert.equal(L.addDays("2026-03-01", -1), "2026-02-28");
});

test("parseDateKey rejects impossible dates", () => {
  assert.throws(() => L.parseDateKey("2026-02-30"));
  assert.throws(() => L.parseDateKey("26-1-1"));
});

test("weekdayOf: Monday is 1 and Sunday is 7", () => {
  assert.equal(L.weekdayOf("2026-10-05"), 1);
  assert.equal(L.weekdayOf("2026-10-11"), 7);
});

test("activeDateKeys returns every date that is today somewhere", () => {
  // 12:00 UTC: UTC-12 is 00:00 same day, UTC+14 is 02:00 next day -> 2 keys.
  assert.deepEqual(L.activeDateKeys(Date.parse("2026-10-18T12:00:00Z")), [
    "2026-10-18",
    "2026-10-19",
  ]);
  // 05:00 UTC: UTC-12 is 17:00 the day before -> 2 keys.
  assert.deepEqual(L.activeDateKeys(Date.parse("2026-10-18T05:00:00Z")), [
    "2026-10-17",
    "2026-10-18",
  ]);
  // 23:00 UTC: UTC+14 is 13:00 next day, UTC-12 is 11:00 same day -> 2 keys.
  assert.deepEqual(L.activeDateKeys(Date.parse("2026-10-18T23:00:00Z")), [
    "2026-10-18",
    "2026-10-19",
  ]);
});

test("a cycle closes at 00:00 UTC two days after its date key", () => {
  assert.equal(L.cycleCloseAtMs("2026-10-18"), Date.parse("2026-10-20T00:00:00Z"));
  assert.equal(L.isCycleClosable("2026-10-18", Date.parse("2026-10-19T23:59:59Z")), false);
  assert.equal(L.isCycleClosable("2026-10-18", Date.parse("2026-10-20T00:00:00Z")), true);
});

test("the close time matches the rules' write window", () => {
  // The rules accept key D until UTC day D+1 ends, i.e. until D+2 00:00 UTC.
  const key = "2026-10-18";
  const lastWritable = Date.parse("2026-10-19T23:59:59Z");
  assert.equal(L.dateKeyFromUtc(lastWritable - 86_400_000), "2026-10-18"); // yesterday
  assert.equal(L.isCycleClosable(key, lastWritable), false);
});

// ---- schedules --------------------------------------------------------------------

test("normalizeWeekdays falls back to every day and drops junk", () => {
  assert.deepEqual(L.normalizeWeekdays(undefined), [1, 2, 3, 4, 5, 6, 7]);
  assert.deepEqual(L.normalizeWeekdays([]), [1, 2, 3, 4, 5, 6, 7]);
  assert.deepEqual(L.normalizeWeekdays([5, 1, 1, 9, "x"]), [1, 5]);
  assert.deepEqual(L.normalizeWeekdays([0, 8]), [1, 2, 3, 4, 5, 6, 7]);
});

// ---- cycle aggregates -----------------------------------------------------------------

test("aggregateCycle ignores members who were not eligible", () => {
  const agg = L.aggregateCycle(["a", "b", "c"], ["a", "b", "late-joiner"], []);
  assert.equal(agg.completedCount, 2);
  assert.deepEqual(agg.visibleCompletedUids, ["a", "b"]);
});

test("aggregateCycle still counts a member who left after the snapshot", () => {
  // 'c' left mid-cycle but is in the snapshot, so the completion counts.
  const agg = L.aggregateCycle(["a", "b", "c"], ["c"], []);
  assert.equal(agg.completedCount, 1);
});

test("aggregateCycle hides private members from the visible list but counts them", () => {
  const agg = L.aggregateCycle(["a", "b", "c"], ["a", "b", "c"], ["b"]);
  assert.equal(agg.completedCount, 3);
  assert.deepEqual(agg.visibleCompletedUids, ["a", "c"]);
});

test("aggregateCycle is idempotent and order independent", () => {
  const one = L.aggregateCycle(["a", "b", "c"], ["c", "a", "a", "b"], []);
  const two = L.aggregateCycle(["a", "b", "c"], ["a", "b", "c"], []);
  assert.deepEqual(one, two);
});

// ---- group streak -------------------------------------------------------------------------

test("group streak grows on reached cycles and resets on a miss", () => {
  let s = { current: 0, best: 0, lastDateKey: null };
  s = L.applyClosedCycle(s, "2026-10-01", true, true);
  s = L.applyClosedCycle(s, "2026-10-02", true, true);
  s = L.applyClosedCycle(s, "2026-10-03", true, true);
  assert.deepEqual(s, { current: 3, best: 3, lastDateKey: "2026-10-03" });
  s = L.applyClosedCycle(s, "2026-10-04", true, false);
  assert.deepEqual(s, { current: 0, best: 3, lastDateKey: "2026-10-04" });
  s = L.applyClosedCycle(s, "2026-10-05", true, true);
  assert.deepEqual(s, { current: 1, best: 3, lastDateKey: "2026-10-05" });
});

test("closing the same cycle twice changes nothing", () => {
  const s = { current: 2, best: 2, lastDateKey: "2026-10-02" };
  assert.deepEqual(L.applyClosedCycle(s, "2026-10-02", true, false), s);
  assert.deepEqual(L.applyClosedCycle(s, "2026-10-01", true, false), s);
});

test("habits without a target never build a group streak", () => {
  const s = L.applyClosedCycle({ current: 0, best: 0, lastDateKey: null }, "2026-10-01", false, false);
  assert.deepEqual(s, { current: 0, best: 0, lastDateKey: "2026-10-01" });
});

// ---- invitations --------------------------------------------------------------------------------

test("generated codes use the safe alphabet and hash consistently", () => {
  const code = L.generateCode();
  assert.match(code, /^[A-HJ-NP-Z2-9]{8}$/);
  assert.equal(L.hashCode(code), L.hashCode(code.toLowerCase()));
  assert.equal(L.hashCode("ab-cd 12"), L.hashCode("ABCD12"));
  assert.notEqual(L.hashCode("AAAA1111"), L.hashCode("AAAA1112"));
});

test("invitationProblem covers revoked, expired, exhausted, used", () => {
  const now = 1_000_000;
  const ok = { status: "pending", expiresAtMs: now + 1, uses: 0, maxUses: 1 };
  assert.equal(L.invitationProblem(ok, now), null);
  assert.equal(L.invitationProblem({ ...ok, status: "revoked" }, now), "revoked");
  assert.equal(L.invitationProblem({ ...ok, expiresAtMs: now }, now), "expired");
  assert.equal(L.invitationProblem({ ...ok, uses: 1 }, now), "used");
  assert.equal(L.invitationProblem({ ...ok, uses: 5, maxUses: 5 }, now), "exhausted");
  assert.equal(L.invitationProblem({ ...ok, status: "declined" }, now), "not-pending");
});

// ---- rate limiting -------------------------------------------------------------------------------------

test("takeToken allows up to the limit and then resets with the window", () => {
  let state;
  for (let i = 0; i < 3; i++) {
    const r = L.takeToken(state, 1000, 3, 60_000);
    assert.equal(r.allowed, true);
    state = r.next;
  }
  const blocked = L.takeToken(state, 2000, 3, 60_000);
  assert.equal(blocked.allowed, false);
  const later = L.takeToken(blocked.next, 61_000, 3, 60_000);
  assert.equal(later.allowed, true);
  assert.equal(later.next.count, 1);
});

// ---- notifications --------------------------------------------------------------------------------------------

test("quiet hours handle ranges that wrap past midnight", () => {
  const start = 22 * 60;
  const end = 7 * 60;
  assert.equal(L.inQuietHours(23 * 60, start, end), true);
  assert.equal(L.inQuietHours(3 * 60, start, end), true);
  assert.equal(L.inQuietHours(7 * 60, start, end), false);
  assert.equal(L.inQuietHours(12 * 60, start, end), false);
  assert.equal(L.inQuietHours(12 * 60, 13 * 60, 14 * 60), false);
  assert.equal(L.inQuietHours(13 * 60 + 30, 13 * 60, 14 * 60), true);
  assert.equal(L.inQuietHours(5, 600, 600), false); // empty window
});

test("local time helpers respect the time zone", () => {
  const now = Date.parse("2026-10-18T22:30:00Z");
  assert.equal(L.localMinutes(now, "UTC"), 22 * 60 + 30);
  assert.equal(L.localMinutes(now, "Asia/Kolkata"), 4 * 60); // 04:00 next day
  assert.equal(L.localDateKey(now, "Asia/Kolkata"), "2026-10-19");
  assert.equal(L.localDateKey(now, "America/Los_Angeles"), "2026-10-18");
});

test("dedupe keys are stable and distinct", () => {
  assert.equal(L.dedupeKey("invite", "x", "u1"), L.dedupeKey("invite", "x", "u1"));
  assert.notEqual(L.dedupeKey("invite", "x", "u1"), L.dedupeKey("invite", "x", "u2"));
  assert.equal(L.dedupeKey("a", "b").length, 40);
});

test("isValidTimeZone", () => {
  assert.equal(L.isValidTimeZone("Asia/Kolkata"), true);
  assert.equal(L.isValidTimeZone("Not/AZone"), false);
});

test("zone helpers fall back to the reported UTC offset", () => {
  const now = Date.parse("2026-10-18T22:30:00Z");
  // India is +05:30 and has no IANA name from the app: 04:00 next day.
  assert.equal(L.localMinutesFor(now, { offsetMinutes: 330 }), 4 * 60);
  assert.equal(L.localDateKeyFor(now, { offsetMinutes: 330 }), "2026-10-19");
  // Negative offsets and the default of UTC.
  assert.equal(L.localMinutesFor(now, { offsetMinutes: -480 }), 14 * 60 + 30);
  assert.equal(L.localDateKeyFor(now, { offsetMinutes: -480 }), "2026-10-18");
  assert.equal(L.localMinutesFor(now, {}), 22 * 60 + 30);
});

test("an IANA zone wins over the offset when valid, and an invalid one is ignored", () => {
  const now = Date.parse("2026-10-18T22:30:00Z");
  assert.equal(L.localDateKeyFor(now, { zone: "Asia/Kolkata", offsetMinutes: 0 }), "2026-10-19");
  assert.equal(L.localDateKeyFor(now, { zone: "Not/AZone", offsetMinutes: 0 }), "2026-10-18");
});

test("swapUid replaces once and never duplicates", () => {
  assert.deepEqual(L.swapUid(["a", "b", "c"], "b", "z"), ["a", "z", "c"]);
  assert.deepEqual(L.swapUid(["a", "z", "c"], "b", "z"), ["a", "z", "c"]); // repeat
  assert.deepEqual(L.swapUid(["b", "z"], "b", "z"), ["z"]); // target already there
  assert.deepEqual(L.swapUid([], "b", "z"), []);
  assert.deepEqual(L.swapUid(["a"], "b", "z"), ["a"]);
});

test("renameCompletionId only renames the owner's documents", () => {
  assert.equal(L.renameCompletionId("alice_2026-10-18", "alice", "bob"), "bob_2026-10-18");
  assert.equal(L.renameCompletionId("carol_2026-10-18", "alice", "bob"), "carol_2026-10-18");
  assert.equal(L.renameCompletionId("alice2_2026-10-18", "alice", "bob"), "alice2_2026-10-18");
  assert.equal(L.renameCompletionId("bob_2026-10-18", "alice", "bob"), "bob_2026-10-18"); // repeat
});

test("a reminder fires in exactly one 15 minute window", () => {
  // Set for 18:07: the 18:00 to 18:14 window.
  assert.equal(L.isReminderDue(18 * 60, 18 * 60 + 7), true);
  assert.equal(L.isReminderDue(18 * 60 + 14, 18 * 60 + 7), true);
  assert.equal(L.isReminderDue(18 * 60 + 15, 18 * 60 + 7), false);
  assert.equal(L.isReminderDue(17 * 60 + 59, 18 * 60 + 7), false);
  // Midnight and the last minute of the day.
  assert.equal(L.isReminderDue(0, 0), true);
  assert.equal(L.isReminderDue(23 * 60 + 59, 23 * 60 + 50), true);
  assert.equal(L.isReminderDue(23 * 60 + 44, 23 * 60 + 50), false);
});

test("every minute of the day belongs to exactly one window", () => {
  for (const set of [0, 59, 60, 435, 1439]) {
    let hits = 0;
    for (let now = 0; now < 1440; now++) if (L.isReminderDue(now, set)) hits++;
    assert.equal(hits, 15, `reminder at ${set}`);
  }
});

test("a reminder can only look at its owner's own completion records", () => {
  const { completionPathFor } = L;
  assert.equal(
    completionPathFor({ kind: "personal", itemId: "h1" }, "alice", "2026-10-18"),
    "users/alice/completions/h1_2026-10-18",
  );
  assert.equal(
    completionPathFor({ kind: "shared", sharedId: "s1" }, "alice", "2026-10-18"),
    "sharedHabits/s1/completions/alice_2026-10-18",
  );
  assert.equal(
    completionPathFor({ kind: "group", groupId: "g1", habitId: "h1" }, "alice", "2026-10-18"),
    "groups/g1/habits/h1/completions/alice_2026-10-18",
  );
  // Anything that tries to point elsewhere is ignored.
  for (const bad of [
    { kind: "personal", itemId: "../bob/habits/x" },
    { kind: "personal", itemId: "a/b" },
    { kind: "shared", sharedId: "s1/completions/bob" },
    { kind: "group", groupId: "g1", habitId: "h1/../../x" },
    { kind: "personal" },
    { kind: "other" },
  ]) {
    assert.equal(completionPathFor(bad, "alice", "2026-10-18"), null, JSON.stringify(bad));
  }
});
