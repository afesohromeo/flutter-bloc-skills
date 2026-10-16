---
name: flutter-bloc-review
description: Use when reviewing a change, diff, branch or pull request in a Flutter app that uses flutter_bloc or Cubit, or when asked whether a teammate's or agent's work is ready to merge.
metadata:
  source: flutter_bloc_kit _standards/09_normalization_rules.md v2.1.0
---

# Reviewing Changes in flutter_bloc Apps

## Overview

Reviewers find logic bugs on their own. What they miss is the team's rules and the change's scope, and they excuse violations with "the existing code does it too". Check scope, then the team rules, then the logic, and grade each finding by the rules below.

## 1. Scope: read the whole change

`git status`, `git diff`, and every untracked file. For each changed file, ask: does the request need this?

- **Unrelated diffs** (formatting-only changes, regenerated files nobody touched, line-ending noise) → finding: take them out.
- **Shared code changed** (shared widgets, theme, other features, dependencies) → list it under **Needs approval** unless the developer agreed to it, even when it's backward compatible; check every other caller.
- **Request not fully done**: data the API returns and the request implies (amounts, dates, statuses) not shown, page with no way to reach it → finding.
- Extras nobody asked for (screens, entry points, demo data) → finding.

## 2. Team rules: these block a merge

| Rule | Look for |
|---|---|
| One message per known error case, per operation | One `catch (_)` → one message; "Something went wrong" for a 404/409; server text for a known case; `throw Exception('Failed …')` in a repository. **REQUIRED BACKGROUND:** `flutter-bloc-api-errors` |
| Money is `int` minor units + currency code | `double` for an amount; no currency |
| Text | App has localization and a string is hardcoded; app has none and nobody flagged it |
| One feedback style | The app has a helper for showing results (e.g. `DialogUtils`, a toast service) and the change bypasses it with its own SnackBar or dialog; never suggest a style the app doesn't use. A confirm dialog isn't a results helper: with no helper, any one consistent style is fine |
| Building blocks reused | New loading, error, empty, confirm or formatting code next to existing ones |
| Tests per layer | Repository, BLoC (each error case) and page tests for new code |
| No new analyzer issues | Including ones "in the same style as the existing code" |
| Layers | UI calling a repository, BLoC calling a BLoC, logic in a page, `context` after `await` without `mounted` |

"The rest of the app does it too" doesn't lower the grade: report it as blocking for this change and list the old code separately as existing debt.

## 3. Logic

State after a failure (data kept, action reset), an action that succeeds while the refresh after it fails, double taps and parallel events, stale responses, empty and malformed responses, the user leaving mid-request.

## 4. Grades and report

- **Blocking:** breaks a team rule in section 2, wrong behaviour, data loss, security.
- **Needs approval:** scope decisions only the developer can make (shared code changes, extras, deferring localization).
- **Should fix:** fragile code, missing edge-case tests, unclear naming.
- **Nit:** style the analyzer doesn't catch.

For each finding: `file:line`, what's wrong, why it matters, the fix. Then the verdict: **merge**, **merge after fixes** (list the blocking ones and what needs approval), or **don't merge**. Mention what you didn't check (e.g. not run on a device).

## Red flags

- A verdict without having listed every changed file
- "Not blocking, matches the existing code"
- Proposing a SnackBar in an app that has a dialog helper
- Reviewing only the new feature folder, not the edits to shared files
