#!/usr/bin/env node
// reconcile.mjs: flag drift between the variables code generates and the variables in Figma.
//
// Usage: node scripts/reconcile.mjs [expected] [snapshot] [--json]
//   expected  build/figma/variables.json (written by `npm run build`; code is the source of truth)
//   snapshot  figma-snapshot.json (the DellKit Figma file's local variables, read by Claude Code via
//             the Figma MCP and saved in the same shape as variables.json)
// Exit code 0 = in sync, 1 = drift found, 2 = bad input.
//
// Checks, per variable and per mode:
//   missing        in code, not in Figma
//   extra          in Figma, not in code (one-off variables someone added by hand)
//   type           COLOR vs FLOAT disagree
//   unbound        code expects an alias, Figma holds a raw value (the alias chain was broken)
//   alias          both alias, but to different variables
//   value          both raw, but the values differ (hex compared case-insensitively, numbers to 0.01)
//   mode           a mode (Light, Dark, Value) exists on one side only

import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const asJson = args.includes('--json');
const [expectedPath = 'build/figma/variables.json', snapshotPath = 'figma-snapshot.json'] = args.filter((a) => !a.startsWith('--'));

const load = (p) => {
  try { return JSON.parse(readFileSync(p, 'utf8')); }
  catch (e) { console.error(`reconcile: cannot read ${p}: ${e.message}`); process.exit(2); }
};
const expected = load(expectedPath);
const snapshot = load(snapshotPath);

const index = (doc) => {
  const m = new Map();
  for (const [collection, c] of Object.entries(doc.collections ?? {}))
    for (const v of c.variables ?? []) m.set(`${collection}/${v.name}`, { ...v, collection });
  return m;
};
const code = index(expected);
const figma = index(snapshot);

const ref = (a) => `${a.collection}/${a.name}`;
const isAlias = (x) => x && typeof x === 'object' && x.alias;
const same = (a, b) =>
  typeof a === 'number' && typeof b === 'number' ? Math.abs(a - b) < 0.01 : String(a).toLowerCase() === String(b).toLowerCase();

const f = { missing: [], extra: [], type: [], unbound: [], alias: [], value: [], mode: [] };

for (const [key, c] of code) {
  const g = figma.get(key);
  if (!g) { f.missing.push(key); continue; }
  if (c.type !== g.type) f.type.push({ variable: key, code: c.type, figma: g.type });
  const modes = new Set([...Object.keys(c.values ?? {}), ...Object.keys(g.values ?? {})]);
  for (const mode of modes) {
    const cv = c.values?.[mode], gv = g.values?.[mode];
    if (cv === undefined || gv === undefined) { f.mode.push({ variable: key, mode, onlyIn: cv === undefined ? 'figma' : 'code' }); continue; }
    if (isAlias(cv) && !isAlias(gv)) f.unbound.push({ variable: key, mode, expected: ref(cv.alias), figma: gv });
    else if (isAlias(cv) && isAlias(gv) && ref(cv.alias) !== ref(gv.alias)) f.alias.push({ variable: key, mode, code: ref(cv.alias), figma: ref(gv.alias) });
    else if (!isAlias(cv) && isAlias(gv)) f.value.push({ variable: key, mode, code: cv, figma: `alias ${ref(gv.alias)}` });
    else if (!isAlias(cv) && !same(cv, gv)) f.value.push({ variable: key, mode, code: cv, figma: gv });
  }
}
for (const key of figma.keys()) if (!code.has(key)) f.extra.push(key);

const total = Object.values(f).reduce((n, list) => n + list.length, 0);
if (asJson) { console.log(JSON.stringify({ drift: total, findings: f }, null, 2)); process.exit(total ? 1 : 0); }

const label = {
  missing: 'In code, missing from Figma', extra: 'In Figma, not in code', type: 'Type mismatch',
  unbound: 'Alias broken in Figma (raw value)', alias: 'Aliased to a different variable', value: 'Value differs', mode: 'Mode on one side only',
};
const line = (x) => typeof x === 'string' ? x
  : `${x.variable}${x.mode ? ` [${x.mode}]` : ''}: ` +
    Object.entries(x).filter(([k]) => !['variable', 'mode'].includes(k)).map(([k, v]) => `${k} ${v}`).join(', ');

console.log(`DellKit reconcile: ${code.size} variables in code, ${figma.size} in Figma`);
for (const [k, list] of Object.entries(f)) {
  if (!list.length) continue;
  console.log(`\n  ${label[k]} (${list.length})`);
  for (const x of list) console.log(`    - ${line(x)}`);
}
console.log(total ? `\n${total} drift finding(s). Code is the source of truth: fix Figma, or change the token and rebuild.` : '\nNo drift. Figma matches code.');
process.exit(total ? 1 : 0);
