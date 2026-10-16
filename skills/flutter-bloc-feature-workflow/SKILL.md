---
name: flutter-bloc-feature-workflow
description: Use when adding or changing a feature, page, screen or user flow in a Flutter app that uses flutter_bloc or Cubit, especially when the request is short and leaves API details, error cases, money or navigation unspecified.
metadata:
  source: flutter_bloc_kit _standards v2.1.0
---

# Feature Workflow for flutter_bloc Apps

## Overview

A short request ("add an orders page where users can cancel") leaves most decisions open. The developer decides them, the project's existing code sets the style, and nothing outside the feature changes.

**Core principle:** ask before you guess, reuse before you write, touch only what the feature needs.

## 1. Plan first, with the open questions

Read the closest existing feature (copy its layers, naming, state style and test style) and list the app's shared folders. Then present a short plan and **wait for the developer's answer before writing code**:

- Files you will add, layer by layer, following that feature.
- **Open questions.** Always check:

| Unknown | Why it matters |
|---|---|
| Response shape of each endpoint (fields, wrapper, pagination) | Parsing |
| Error cases of each call (status codes and their meaning) | One message per case. **REQUIRED SUB-SKILL:** `flutter-bloc-api-errors` |
| Money: minor units? currency field? | Amounts are never `double` |
| Authentication, which user's data | Headers, scoping |
| Where the page sits in navigation | Routes, entry points |

- Building blocks you will reuse (section 2).
- Every change **outside** the feature (shared widget, theme, dependency, other feature). Each one needs a yes.

**Can't ask** (non-interactive run, developer unavailable)? Don't guess silently: put the plan and the questions first in your report, use the safest default for each, and list each default as an assumption.

## 2. Reuse the app's building blocks

Before writing UI, search `shared/`, `common/`, `widgets/`, `components/`, `utils/` and `core/` for: success/error feedback, confirm dialog, loading or skeleton, empty and error views, page scaffold, money and date formatters, localization, router.

- Use what exists, even if you'd do it differently.
- **One feedback style per app.** If results are shown with a dialog helper, a new SnackBar is a bug.
- Missing piece? Propose it in the plan; don't add it to shared code on your own.

## 3. Stay in scope

- Don't edit shared components, other features or the theme for this feature unless the plan listed it and the developer agreed.
- `dart format` only the files you touched, never the whole project.
- Code generation rewrites unrelated generated files? Leave them out of your change and say so.
- A new page needs **one** way in: put it where similar pages are reached from (drawer, tab, button on the parent page) and name it in the plan. Nothing else that wasn't asked for (extra entry points, detail screens).
- Follow the project's rule on who runs commands (code generation, migrations). When unsure, tell the developer which command to run.

## 4. Values the user sees

- **Text:** app has localization → every new string is a key in every language. No localization → match the app, and **say in the report** that the strings are hardcoded.
- **Money:** `int` minor units + ISO 4217 code; format with the currency's decimals and the user's locale. Never `double`.
- **Dates:** parse defensively; format with the user's locale (`DateFormat.yMMMd(locale)` or the app's helper), never a fixed `yyyy-MM-dd`.

## 5. Tests come with each layer

Write the test first. Repository (mocked HTTP client), BLoC (`bloc_test`: each success **and each error case**), every page (widget test: loading, data, empty, error, the main action). `flutter analyze` adds no new issues, even where the code you copied has them.

## Red flags: stop and fix

- "I'll assume the response is…" → it belongs in the plan's questions
- "Something went wrong" or "Failed to…" for a known case
- `double` for an amount
- `ScaffoldMessenger` in an app with a feedback helper
- A `shared/` file in your diff that the plan didn't list
- A new page with no way to reach it
- `dart format .` or a diff full of regenerated files you didn't touch

## Report

Files changed; questions and the assumptions you used; commands the developer must run; `flutter analyze` and `flutter test` summaries.
