// WCAG 2.1 contrast check for foreground/background pairs, in both modes.
// Run after build: npm run check  (exits 1 if any pair fails)
import { readFile } from 'node:fs/promises';

const { collections } = JSON.parse(await readFile('build/figma/variables.json', 'utf8'));
const all = Object.fromEntries(
  Object.entries(collections).flatMap(([c, col]) => col.variables.map((v) => [`${c}:${v.name}`, { c, v }]))
);
const resolve = (c, name, mode) => {
  const { v } = all[`${c}:${name}`];
  const val = v.values[mode] ?? v.values.Value ?? v.values.Light;
  return val.alias ? resolve(val.alias.collection, val.alias.name, mode) : val;
};
const lum = (hex) => {
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(hex.slice(1).slice(i, i + 2), 16) / 255)
    .map((x) => (x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((m, n) => n - m); return (x + 0.05) / (y + 0.05); };

// [foreground, background, minimum] — 4.5 body text, 3.0 large text / UI components
const S = 'Semantic', C = 'Components';
const PAIRS = [
  [[S, 'text/primary'], [S, 'bg/primary'], 4.5],
  [[S, 'text/primary'], [S, 'bg/elevated'], 4.5],
  [[S, 'text/secondary'], [S, 'bg/primary'], 4.5],
  [[S, 'text/secondary'], [S, 'bg/secondary'], 4.5],
  [[S, 'text/tertiary'], [S, 'bg/primary'], 4.5],
  [[S, 'text/link'], [S, 'bg/primary'], 4.5],
  [[C, 'button/primary/foreground'], [C, 'button/primary/background'], 4.5],
  [[C, 'button/outline/foreground'], [S, 'bg/primary'], 4.5],
  [[C, 'chat/userText'], [C, 'chat/userBubble'], 4.5],
  [[C, 'chat/assistantText'], [C, 'chat/assistantBubble'], 4.5],
  [[C, 'field/placeholder'], [S, 'bg/primary'], 4.5],
  [[C, 'tabBar/active'], [C, 'tabBar/background'], 3.0],
  [[C, 'tabBar/inactive'], [C, 'tabBar/background'], 4.5],
  [[S, 'icon/secondary'], [S, 'bg/elevated'], 3.0],
  [[S, 'status/success'], [S, 'status/successSubtle'], 4.5],
  [[S, 'status/warning'], [S, 'status/warningSubtle'], 3.0],
  [[S, 'status/error'], [S, 'status/errorSubtle'], 4.5],
  [[S, 'status/info'], [S, 'status/infoSubtle'], 4.5],
  [[S, 'border/strong'], [S, 'bg/primary'], 3.0],
];

let fails = 0;
for (const mode of ['Light', 'Dark']) {
  console.log(`\n${mode}`);
  for (const [[fc, fn], [bc, bn], min] of PAIRS) {
    const r = ratio(resolve(fc, fn, mode), resolve(bc, bn, mode));
    const ok = r >= min;
    if (!ok) fails++;
    console.log(`  ${ok ? 'pass' : 'FAIL'}  ${r.toFixed(2).padStart(5)} (min ${min})  ${fn} on ${bn}`);
  }
}
console.log(fails ? `\n${fails} pair(s) below WCAG AA` : '\nAll pairs meet WCAG AA');
process.exit(fails ? 1 : 0);
