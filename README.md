# flutter-bloc-skills

Agent skills for Flutter apps built with [flutter_bloc](https://pub.dev/packages/flutter_bloc): a feature workflow that asks before it guesses, one error message per failure case, a Serverpod 4 backend, and code review against a team's rules.

They give a coding agent (Claude Code, Codex, Cursor, Gemini CLI and others) the decisions a production Flutter team makes, where agents otherwise guess, so the code it writes is consistent, tested and reviewable.

> **Version 1.0.0.** Four skills, each written because agents got that work wrong without it, and tested before and after. See [`doc/skill-tests.md`](doc/skill-tests.md).

## Install

```bash
npx skills add afesohromeo/flutter-bloc-skills                       # all skills
npx skills add afesohromeo/flutter-bloc-skills --list                # see what's included
npx skills add afesohromeo/flutter-bloc-skills --skill flutter-bloc-feature-workflow
```

## Skills

| Skill | Use it when the agent… |
|---|---|
| `flutter-bloc-feature-workflow` | adds or changes a feature, page or flow, especially from a short request |
| `flutter-bloc-api-errors` | calls an API or handles failures and error messages |
| `flutter-bloc-serverpod` | uses or moves to a Serverpod 4 backend |
| `flutter-bloc-review` | reviews a change before it's merged |

Each skill exists because agents got that work wrong without it. How they were tested, and why other candidate skills (pagination, tests, localization, release) were dropped, is in [`doc/skill-tests.md`](doc/skill-tests.md).

### As a Claude Code plugin

```bash
/plugin marketplace add afesohromeo/flutter-bloc-skills
/plugin install flutter-bloc@flutter-bloc-skills
```

## Works with any flutter_bloc app

The skills don't require a particular template. Where they need a building block (a dialog helper, a responsive scaffold, a paginated list, an API error handler), they use the project's own, or add a small version from the skill's `references/` folder.

For a new app, [flutter_bloc_kit](https://github.com/afesohromeo/flutter_bloc_kit) has all of these built in, plus the full written standards these skills come from.

## Licence

[MIT](LICENSE)
