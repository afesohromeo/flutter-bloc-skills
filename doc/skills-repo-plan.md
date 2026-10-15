# Plan: flutter-bloc-skills v1.0

**Status:** Approved 2026-10-16
**Source of the rules:** [flutter_bloc_kit](https://github.com/afesohromeo/flutter_bloc_kit) `_standards/`, v2.1.0

---

## Goal

Publish the engineering standards of flutter_bloc_kit as agent skills that work in **any Flutter app built with flutter_bloc**, installable with:

```bash
npx skills add afesohromeo/flutter-bloc-skills
```

That command supports Claude Code, Codex, Cursor, Gemini CLI and about 70 other agents. The repo is also a portfolio piece.

## Decisions

| # | Decision |
|---|----------|
| D-1 | **Licence: MIT.** Anyone may use, copy and change the skills if they keep the copyright notice; no warranty. |
| D-2 | **Target: any flutter_bloc app**, not only apps built from the kit. Rules are generic; where the kit has a ready-made piece (dialogs, responsive scaffold, paginated list, API error handler, test helpers), a skill says "use the project's equivalent; if there is none, add it from `references/`". The README recommends the kit as the fastest start. Kit-only names (`customColors`, `app_theme_kit`) become "the app's theme". |
| D-3 | **Name:** `flutter-bloc-skills`; every skill is prefixed `flutter-bloc-`. |
| D-4 | `_standards/` in the kit stays the source of truth. Each skill names the kit version it reflects; changes are logged in `CHANGELOG.md`. No generator script. |

## Layout

```
skills/<skill-name>/SKILL.md        one skill per task, < 500 words
skills/<skill-name>/references/     longer detail and copyable code, loaded when needed
README.md  LICENSE  CHANGELOG.md
.claude-plugin/marketplace.json     also installable as a Claude Code plugin
doc/                                this plan, skill test results
```

## Skills

| Skill | Used when the agent… | From standards |
|---|---|---|
| `flutter-bloc-architecture` | starts work in the app (layers, folders, naming, barrels) | 01, 03, 09 |
| `flutter-bloc-add-feature` | adds a feature: model, service, repository, BLoC, page, route, l10n, tests | 02, 04–07, 10 |
| `flutter-bloc-add-api-endpoint` | calls a new REST endpoint and handles its errors | 04, 05 |
| `flutter-bloc-add-paginated-list` | shows a server list with infinite scroll, search and filters | 13, 08 |
| `flutter-bloc-write-tests` | tests a BLoC, repository or widget, or checks screens with a screenshot harness | 15 |
| `flutter-bloc-localize` | adds user-facing text (label colons, plurals, the second-language pass) | 12 |
| `flutter-bloc-serverpod` | uses Serverpod as the backend | 14 |
| `flutter-bloc-review` | reviews a change against the rules | 09, 11 |
| `flutter-bloc-release` | prepares a store or web release | 16 |

## Testing each skill (test first)

Following the writing-skills method:

1. **Without the skill (baseline):** a subagent gets a realistic task and records what it does. Its choices are checked against the rules the skill covers.
2. **With the skill:** same task, same checks (`flutter analyze`, tests, the skill's rules).
3. **Tighten:** fix the gaps the run shows, re-test.
4. Results go in `doc/skill-tests.md`.

Each skill is tested in **two projects** (outside this repo, disposable):
- **Kit app:** a copy of flutter_bloc_kit v2.1.0 **without** `_standards/`, `CLAUDE.md` and `.claude/` (the skill must carry the rules itself).
- **Plain app:** a `flutter create` app with flutter_bloc and one small existing feature in a common feature-first layout, without the kit's building blocks.

Code generation (`build_runner`, `gen-l10n`) runs inside these disposable test projects only.

## Phases

1. Repo skeleton, README, licence, this plan.
2. Test projects; write and test `flutter-bloc-architecture` and `flutter-bloc-add-feature`. **Developer review of style and depth before the rest.**
3. Write and test the other seven skills.
4. Installation check: `npx skills add <local folder> --list`, a real install into a scratch project, the plugin manifest.
5. Developer review → push to GitHub (public), tag `v1.0.0` → CV line, `career-plan.md`, link from the kit README.

## Out of scope

- Pull requests to `flutter/skills` (later, generic improvements only).
- Dart-only or MVVM variants; a GenUI skill.

## Definition of done

All nine skills tested in both projects with results in `doc/skill-tests.md`; install verified; README complete; the developer has reviewed before push and tag.
