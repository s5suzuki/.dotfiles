#!/usr/bin/env python3
import bisect
import json
import os
import re
import sys
from collections import Counter

SLASH = {
    'rs', 'c', 'h', 'cpp', 'cxx', 'cc', 'hpp', 'hxx', 'cs', 'ts', 'tsx', 'js',
    'jsx', 'mjs', 'cjs', 'java', 'go', 'swift', 'kt', 'kts', 'scala', 'sv',
    'svh', 'v', 'vh', 'proto', 'glsl', 'wgsl', 'php', 'dart', 'zig', 'mm',
    'css', 'scss', 'less',
}
HASH = {
    'py', 'sh', 'bash', 'zsh', 'fish', 'rb', 'pl', 'pm', 'toml', 'yaml', 'yml',
    'tf', 'tfvars', 'cmake', 'jl', 'nix', 'ex', 'exs', 'gradle', 'ps1',
}
DASH = {'lua', 'sql', 'hs', 'elm', 'vhd', 'vhdl', 'ada', 'adb', 'ads'}
NAMED = {
    'makefile': 'hash', 'dockerfile': 'hash', 'cmakelists.txt': 'hash',
    'justfile': 'hash', '.gitignore': None,
}

NESTED_BLOCK = {'rs', 'swift', 'kt', 'kts', 'scala', 'dart'}
MULTILINE_DOUBLE_QUOTE = {'rs'}
TRIPLE_DOUBLE_QUOTE = {'cs', 'java', 'kt', 'kts', 'swift', 'scala', 'dart'}
SINGLE_QUOTE_STRING = {
    'ts', 'tsx', 'js', 'jsx', 'mjs', 'cjs', 'php', 'dart', 'css', 'scss', 'less',
}
SINGLE_QUOTE_IS_NOT_A_QUOTE = {'sv', 'svh', 'v', 'vh'}
BACKTICK_STRING = {'ts', 'tsx', 'js', 'jsx', 'mjs', 'cjs', 'go'}
NO_LINE_COMMENT = {'css'}
URL_FUNCTION = {'css', 'scss', 'less'}
SHELL = {'sh', 'bash', 'zsh', 'fish'}
YAML = {'yaml', 'yml'}
HASH_NEEDS_WORD_START = SHELL | YAML | {'pl', 'pm'}
TRIPLE_QUOTE_HASH = {'py', 'toml'}
DASH_SINGLE_QUOTE_STRING = {'lua', 'sql'}

CHAR_LITERAL = re.compile(r"'(?:\\.[^'\n]*|[^\\'\n])'")
RUST_RAW_STRING = re.compile(r'(?:b|c)?r(#*)"')
SHELL_HEREDOC = re.compile(r"<<-?[ \t]*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
PYTHON_STRING_PREFIX = re.compile(r'^[rRbBuUfF]{0,2}$')


def language_of(path):
    if not path:
        return None, ''
    base = os.path.basename(path).lower()
    if base in NAMED:
        return NAMED[base], ''
    ext = base.rsplit('.', 1)[-1] if '.' in base else ''
    if ext in SLASH:
        return 'slash', ext
    if ext in HASH:
        return 'hash', ext
    if ext in DASH:
        return 'dash', ext
    return None, ext


class Hits:
    def __init__(self, text):
        self.text = text
        self.starts = [0] + [m.end() for m in re.finditer('\n', text)]
        self.items = []

    def line_index(self, pos):
        return bisect.bisect_right(self.starts, pos) - 1

    def line_start(self, pos):
        return self.starts[self.line_index(pos)]

    def add(self, start, end):
        first = self.line_index(start)
        last = self.line_index(max(start, end - 1))
        for k in range(first, last + 1):
            lo = self.starts[k]
            hi = self.starts[k + 1] if k + 1 < len(self.starts) else len(self.text)
            piece = self.text[max(start, lo):min(end, hi)].strip()
            if piece:
                self.items.append((k + 1, piece))


def end_of_line(text, i):
    end = text.find('\n', i)
    return len(text) if end < 0 else end


def skip_quoted(text, i, quote, escapes, multiline):
    n = len(text)
    i += len(quote)
    while i < n:
        ch = text[i]
        if escapes and ch == '\\':
            i += 2
            continue
        if ch == '\n' and not multiline:
            return i
        if text.startswith(quote, i):
            return i + len(quote)
        i += 1
    return n


def block_comment_end(text, i, nested):
    n = len(text)
    if not nested:
        end = text.find('*/', i + 2)
        return n if end < 0 else end + 2
    depth = 0
    while i < n:
        if text.startswith('/*', i):
            depth += 1
            i += 2
        elif text.startswith('*/', i):
            depth -= 1
            i += 2
            if depth == 0:
                return i
        else:
            i += 1
    return n


def is_identifier_char(ch):
    return ch.isalnum() or ch == '_'


def scan_slash(text, ext, hits):
    n = len(text)
    i = 0
    while i < n:
        ch = text[i]
        if ch == '\\':
            i += 2
        elif ch == '/' and text.startswith('//', i) and ext not in NO_LINE_COMMENT:
            end = end_of_line(text, i)
            hits.add(i, end)
            i = end
        elif ch == '/' and text.startswith('/*', i):
            end = block_comment_end(text, i, ext in NESTED_BLOCK)
            hits.add(i, end)
            i = end
        elif ch == '"':
            verbatim = ext == 'cs' and '@' in text[max(0, i - 2):i]
            if ext in TRIPLE_DOUBLE_QUOTE and text.startswith('"""', i):
                i = skip_quoted(text, i, '"""', True, True)
            elif verbatim:
                i = skip_quoted(text, i, '"', False, True)
            else:
                i = skip_quoted(text, i, '"', True, ext in MULTILINE_DOUBLE_QUOTE)
        elif ch == "'":
            if ext in SINGLE_QUOTE_STRING:
                i = skip_quoted(text, i, "'", True, False)
            elif ext in SINGLE_QUOTE_IS_NOT_A_QUOTE:
                i += 1
            else:
                m = CHAR_LITERAL.match(text, i)
                i = m.end() if m else i + 1
        elif ch == '`' and ext in BACKTICK_STRING:
            i = skip_quoted(text, i, '`', ext != 'go', True)
        elif ext == 'rs' and ch in 'rbc' and not (i and is_identifier_char(text[i - 1])):
            m = RUST_RAW_STRING.match(text, i)
            if m:
                close = '"' + m.group(1)
                end = text.find(close, m.end())
                i = n if end < 0 else end + len(close)
            else:
                i += 1
        elif ch == 'u' and ext in URL_FUNCTION and text.startswith('url(', i):
            end = text.find(')', i)
            i = n if end < 0 else end + 1
        else:
            i += 1


def is_bare_string_statement(text, hits, start, end):
    line_start = hits.line_start(start)
    if not PYTHON_STRING_PREFIX.match(text[line_start:start].strip()):
        return False
    if text[max(0, line_start - 2):line_start] == '\\\n':
        return False
    rest = text[end:end_of_line(text, end)].strip()
    return not rest or rest.startswith('#')


def skip_shell_heredocs(text, i, delimiters):
    for delimiter in delimiters:
        m = re.compile(r'^[ \t]*' + re.escape(delimiter) + r'[ \t]*$', re.M).search(text, i + 1)
        if m:
            i = m.end()
    return i


def scan_hash(text, ext, hits):
    n = len(text)
    is_python = ext == 'py'
    is_shell = ext in SHELL
    is_yaml = ext in YAML
    i = end_of_line(text, 0) if text.startswith('#!') else 0
    depth = 0
    heredocs = []
    while i < n:
        ch = text[i]
        prev = text[i - 1] if i else '\n'
        if ch == '\\':
            i += 2
        elif ch == '#':
            at_word_start = prev.isspace() or (is_shell and prev in ';|&()')
            if ext in HASH_NEEDS_WORD_START and not at_word_start:
                i += 1
                continue
            end = end_of_line(text, i)
            hits.add(i, end)
            i = end
        elif ch in '"\'':
            if is_yaml and not (prev.isspace() or prev in '[{,:-'):
                i += 1
                continue
            triple = ext in TRIPLE_QUOTE_HASH and text.startswith(ch * 3, i)
            quote = ch * 3 if triple else ch
            escapes = not (ch == "'" and (is_shell or is_yaml or ext == 'toml'))
            end = skip_quoted(text, i, quote, escapes, triple or is_shell)
            if is_python and triple and depth == 0 and is_bare_string_statement(text, hits, i, end):
                hits.add(i, end)
            i = end
        elif is_shell and ch == '<' and text.startswith('<<', i) and not text.startswith('<<<', i):
            m = SHELL_HEREDOC.match(text, i)
            if m:
                heredocs.append(m.group(2))
                i = m.end()
            else:
                i += 2
        elif ch == '\n' and heredocs:
            i = max(i + 1, skip_shell_heredocs(text, i, heredocs))
            heredocs = []
        else:
            if is_python:
                if ch in '([{':
                    depth += 1
                elif ch in ')]}':
                    depth = max(0, depth - 1)
            i += 1


def scan_dash(text, ext, hits):
    n = len(text)
    i = 0
    while i < n:
        ch = text[i]
        if ch == '\\':
            i += 2
        elif ch == '-' and text.startswith('--', i):
            if ext == 'lua' and text.startswith('--[[', i):
                close = text.find(']]', i)
                end = n if close < 0 else close + 2
            else:
                end = end_of_line(text, i)
            hits.add(i, end)
            i = end
        elif ch == '"':
            i = skip_quoted(text, i, '"', ext != 'sql', False)
        elif ch == "'":
            if ext in DASH_SINGLE_QUOTE_STRING:
                i = skip_quoted(text, i, "'", ext != 'sql', False)
            else:
                m = CHAR_LITERAL.match(text, i)
                i = m.end() if m else i + 1
        else:
            i += 1


SCANNERS = {'slash': scan_slash, 'hash': scan_hash, 'dash': scan_dash}


def comments(text, path):
    family, ext = language_of(path)
    if not family:
        return None
    hits = Hits(text or '')
    SCANNERS[family](hits.text, ext, hits)
    return hits.items


def read(path):
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            return f.read()
    except OSError:
        return ''


ANCHOR_MARKER = re.compile(
    r'^(?://|#|--)\s*(?:ANCHOR(?:_END)?:\s*[A-Za-z0-9_.-]+|HIDE(?:_END)?)$'
)

HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1\r?\n")
REDIRECT = re.compile(r">>?\s*(\"[^\"]+\"|'[^']+'|\S+)")


def heredoc_targets(command):
    out = []
    for m in HEREDOC.finditer(command):
        delim = m.group(2)
        body_start = m.end()
        end = re.search(r'^\s*' + re.escape(delim) + r'\s*$', command[body_start:], re.M)
        body = command[body_start:body_start + end.start()] if end else command[body_start:]
        head = command[:m.start()]
        line_start = head.rfind('\n') + 1
        redirs = REDIRECT.findall(head[line_start:])
        if not redirs:
            continue
        target = redirs[-1].strip('\'"')
        out.append((target, body))
    return out


def added_comments(old, new, path):
    new_hits = comments(new, path)
    if not new_hits:
        return []
    remaining = Counter(
        piece for _, piece in comments(old, path) or [] if not ANCHOR_MARKER.match(piece)
    )
    unmatched = []
    for _, piece in new_hits:
        if ANCHOR_MARKER.match(piece):
            continue
        if remaining[piece] > 0:
            remaining[piece] -= 1
        else:
            unmatched.append(piece)
    reworded = sum(remaining.values())
    return unmatched[reworded:]


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    tool = payload.get('tool_name', '')
    ti = payload.get('tool_input') or {}
    pairs = []

    if tool == 'Write':
        path = ti.get('file_path', '')
        pairs.append((path, read(path), ti.get('content', '')))
    elif tool == 'Edit':
        path = ti.get('file_path', '')
        pairs.append((path, ti.get('old_string', ''), ti.get('new_string', '')))
    elif tool == 'MultiEdit':
        path = ti.get('file_path', '')
        edits = ti.get('edits') or []
        pairs.append((
            path,
            '\n'.join(e.get('old_string', '') for e in edits),
            '\n'.join(e.get('new_string', '') for e in edits),
        ))
    elif tool == 'NotebookEdit':
        path = ti.get('notebook_path', '')
        lang = ti.get('cell_type') or 'python'
        if lang == 'code':
            pairs.append(('cell.py', '', ti.get('new_source', '')))
    elif tool == 'Bash':
        for target, body in heredoc_targets(ti.get('command', '')):
            pairs.append((target, read(target), body))
    else:
        return 0

    found = []
    for path, old, new in pairs:
        for piece in added_comments(old, new, path):
            found.append('  {}: {}'.format(os.path.basename(path), piece[:120]))

    if not found:
        return 0

    uniq = []
    for f in found:
        if f not in uniq:
            uniq.append(f)

    reason = (
        'コメントの追加は禁止されています。以下の行を検出しました:\n'
        + '\n'.join(uniq[:20])
        + '\n\nコメント (Doc コメント・SAFETY コメント・docstring を含む) を新たに書かないでください。'
        + '既存のコメント行の文言を書き換えることは許可されますが、コメントの行数を増やすことはできません。'
        + '説明が必要なら識別子名と構造で表現するか、ユーザーへの応答文の中で説明してください。'
        + 'コメントを取り除いた上で同じ編集を再実行してください。'
    )
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'deny',
            'permissionDecisionReason': reason,
        }
    }))
    return 0


if __name__ == '__main__':
    sys.exit(main())
