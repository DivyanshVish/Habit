"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { computeProgress, isValidRule } = require("../../lib/src/engine");

const fixtures = JSON.parse(
  readFileSync(
    join(__dirname, "../../../test/fixtures/completion_engine_cases.json"),
    "utf8",
  ),
);

for (const c of fixtures.progress) {
  test(`engine: ${c.name}`, () => {
    assert.deepEqual({ ...computeProgress(c.rule, c.eligible, c.completed) }, c.expect);
  });
}

test("isValidRule accepts and rejects values", () => {
  assert.equal(isValidRule({ type: "majority" }), true);
  assert.equal(isValidRule({ type: "fixed", value: 3 }), true);
  assert.equal(isValidRule({ type: "fixed", value: 0 }), false);
  assert.equal(isValidRule({ type: "fixed" }), false);
  assert.equal(isValidRule({ type: "percentage", value: 80 }), true);
  assert.equal(isValidRule({ type: "percentage", value: 101 }), false);
  assert.equal(isValidRule({ type: "percentage", value: 12.5 }), false);
  assert.equal(isValidRule({ type: "bogus" }), false);
});
