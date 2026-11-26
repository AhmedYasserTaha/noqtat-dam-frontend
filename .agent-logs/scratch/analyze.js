const fs = require('fs');
const arContent = fs.readFileSync('D:/js/damy/lib/l10n/app_ar.arb', 'utf-8');
const enContent = fs.readFileSync('D:/js/damy/lib/l10n/app_en.arb', 'utf-8');

// Extract top-level keys (strings followed by ":) at line start or after whitespace)
const arKeyRegex = /^\s*"([^"]+)":/gm;
const enKeyRegex = /^\s*"([^"]+)":/gm;

let arMatch, enMatch;
const arKeys = new Set();
const enKeys = new Set();

// Extract AR keys
while ((arMatch = arKeyRegex.exec(arContent)) !== null) {
  arKeys.add(arMatch[1]);
}

// Extract EN keys
while ((enMatch = enKeyRegex.exec(enContent)) !== null) {
  enKeys.add(enMatch[1]);
}

console.log('AR keys: ' + arKeys.size);
console.log('EN keys: ' + enKeys.size);

// Keys only in AR
const arOnly = [...arKeys].filter(k => !enKeys.has(k));
console.log('Only in AR (' + arOnly.length + '):');
arOnly.sort().forEach(k => console.log('  ' + k));

// Keys only in EN
const enOnly = [...enKeys].filter(k => !arKeys.has(k));
console.log('Only in EN (' + enOnly.length + '):');
enOnly.sort().forEach(k => console.log('  ' + k));

// Common keys
const common = [...arKeys].filter(k => enKeys.has(k));
console.log('Common keys: ' + common.length);

// Save results
fs.writeFileSync('D:/js/damy/ar_keys.txt', [...arKeys].sort().join('\n'));
fs.writeFileSync('D:/js/damy/en_keys.txt', [...enKeys].sort().join('\n'));
fs.writeFileSync('D:/js/damy/ar_only.txt', arOnly.sort().join('\n'));
fs.writeFileSync('D:/js/damy/en_only.txt', enOnly.sort().join('\n'));
console.log('Results saved.');