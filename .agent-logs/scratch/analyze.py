import re

def extract_keys(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    # Match "key": patterns at start of lines or after whitespace
    keys = re.findall(r'^\s*"([^"]+)":', content, re.MULTILINE)
    # Also match "@key": patterns for locale metadata
    keys.extend(re.findall(r'^\s*"@([^"]+)":', content, re.MULTILINE))
    return sorted(set(keys))

ar_keys = extract_keys('D:/js/damy/lib/l10n/app_ar.arb')
en_keys = extract_keys('D:/js/damy/lib/l10n/app_en.arb')

print(f'AR keys: {len(ar_keys)}')
print(f'EN keys: {len(en_keys)}')

ar_only = set(ar_keys) - set(en_keys)
en_only = set(en_keys) - set(ar_keys)

print(f'\nOnly in AR ({len(ar_only)}):')
for k in sorted(ar_only):
    print(f'  {k}')

print(f'\nOnly in EN ({len(en_only)}):')
for k in sorted(en_only):
    print(f'  {k}')