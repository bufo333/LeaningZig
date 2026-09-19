#!/usr/bin/env python3
"""Flag prose that breaks the voice rules: sentence fragments, marketing
language, and stock LLM phrasing. Reads chapters/*.html, ignoring code.

Usage: python3 tools/prose_lint.py [chapter-number-prefix ...]
"""
import re, sys, glob, html, os

SLOGAN = [
    r'\bpowerful\b', r'\bseamless(ly)?\b', r'\bblazing(ly)?\b', r'\bleverage\b',
    r'\bsupercharge', r'\bgame[- ]chang',
    r'\bbest[- ]in[- ]class\b', r'\beffortless(ly)?\b', r'\bdelightful\b',
    r'\bcutting[- ]edge\b', r'\bfirst[- ]class\b', r'\bbattle[- ]tested\b',
    r'\bindustry[- ]standard\b', r'\bsimply put\b', r'\bjust works\b',
    r'\bbeauty of\b', r'\belegant(ly)?\b', r'\bstate of the art\b',
    r'\bmagic(?!\s+number)(?<!no magic)al\b',
]
CLAUDISM = [
    r"\bit'?s not just\b", r'\bis not just\b', r"\bhere'?s the thing\b",
    r'\bthe key insight\b', r"\bthat'?s the (whole|real|entire)\b",
    r'\bthis is where .{0,30} shines\b', r"\blet'?s dive\b", r'\bdive in(to)?\b',
    r'\bat its core\b', r'\bthink of it as\b', r"\bthat'?s it\b",
    r'\bunder the hood\b', r'\bthe bottom line\b', r'\bin a nutshell\b',
    r'\bthe takeaway\b', r'\bwhat this really means\b', r'\bnot only .{0,40} but also\b',
    r'\bit is worth noting\b', r'\bneedless to say\b', r'\bat the end of the day\b',
    r'\bthe (result|catch|payoff|upshot|trick)\?', r'\bwhy does this matter\b',
    r'\bthe good news\b', r'\bthe real (question|answer|reason)\b',
    r'\bwhat makes .{0,30} special\b', r'\bturns out\b',
]
# words that can head an imperative sentence in this book's voice
IMPERATIVE = set('''use run open read write note see try call pass prefer keep avoid do
don't make add compile check remember think start stop give take put look treat
replace return build name pick choose count trim split store copy free print
reveal install confirm reach hold ask'''.split())

def sentences(text):
    text = re.sub(r'<pre.*?</pre>', ' ', text, flags=re.S)      # code blocks
    text = re.sub(r'<strong>.*?</strong>', ' ', text, flags=re.S)   # structural labels
    text = re.sub(r'<summary>.*?</summary>', ' ', text, flags=re.S)
    text = re.sub(r'<t[dh][^>]*>.*?</t[dh]>', ' ', text, flags=re.S)  # table cells
    text = re.sub(r'<h[1-6][^>]*>.*?</h[1-6]>', ' ', text, flags=re.S)
    text = re.sub(r'<p class="file">.*?</p>', ' ', text, flags=re.S)  # file captions
    text = re.sub(r'<code>.*?</code>', ' CODE ', text, flags=re.S)  # inline code
    text = re.sub(r'<[^>]+>', ' ', text)
    text = html.unescape(text)
    text = re.sub(r'\s+', ' ', text)
    for s in re.split(r'(?<=[.!?])\s+', text):
        s = s.strip()
        if s:
            yield s

def check(sent):
    hits = []
    low = sent.lower()
    for p in SLOGAN:
        if re.search(p, low):
            hits.append(('SLOGAN', re.search(p, low).group(0)))
    for p in CLAUDISM:
        if re.search(p, low):
            hits.append(('CLAUDISM', re.search(p, low).group(0)))
    # fragment heuristic: very short, not imperative, no obvious finite verb
    # (skipped for the reference appendices, where terse entries are correct)
    words = re.findall(r"[A-Za-z']+", sent)
    if 1 <= len(words) <= 6 and sent.endswith('.'):
        first = words[0].lower()
        verbs = set('is are was were has have had does do did can will would should '
                    'must may might gives takes returns means comes goes works '
                    'happens exists lives holds costs wins fails runs'.split())
        if first not in IMPERATIVE and not any(w.lower() in verbs for w in words):
            hits.append(('FRAGMENT?', ' '.join(words)))
    return hits

args = sys.argv[1:]
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'chapters'))
files = sorted(glob.glob('*.html'))
if args:
    files = [f for f in files if any(f.startswith(a) for a in args)]

total = {}
for f in files:
    reference = f.startswith(('A1', 'A2', 'A5'))
    for sent in sentences(open(f, encoding='utf-8').read()):
        for kind, what in check(sent):
            if kind == 'FRAGMENT?' and reference:
                continue
            total[kind] = total.get(kind, 0) + 1
            print(f'{f}\t{kind}\t[{what}]\t{sent[:190]}')
print('\n--- totals ---', file=sys.stderr)
for k, v in sorted(total.items()):
    print(f'{k}: {v}', file=sys.stderr)
