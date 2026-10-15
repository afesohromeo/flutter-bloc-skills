# flutter-bloc-skills

Agent skills for Flutter apps built with [flutter_bloc](https://pub.dev/packages/flutter_bloc): Clean Architecture layers, BLoC with Freezed states, repositories with one error message per case, localized text, paginated lists, tests, and release preparation.

They give a coding agent (Claude Code, Codex, Cursor, Gemini CLI and others) the conventions of a production Flutter team, so the code it writes is consistent, tested and reviewable.

> **Status:** in development (v1.0 planned). See [`doc/skills-repo-plan.md`](doc/skills-repo-plan.md).

## Install

```bash
npx skills add afesohromeo/flutter-bloc-skills                       # all skills
npx skills add afesohromeo/flutter-bloc-skills --list                # see what's included
npx skills add afesohromeo/flutter-bloc-skills --skill flutter-bloc-add-feature
```

## Skills

| Skill | Use it when the agent… |
|---|---|
| `flutter-bloc-architecture` | starts work in the app: layers, folders, naming, barrels |
| `flutter-bloc-add-feature` | adds a feature end to end |
| `flutter-bloc-add-api-endpoint` | calls a new REST endpoint |
| `flutter-bloc-add-paginated-list` | shows a server list with infinite scroll |
| `flutter-bloc-write-tests` | tests a BLoC, repository or widget |
| `flutter-bloc-localize` | adds user-facing text |
| `flutter-bloc-serverpod` | uses Serverpod as the backend |
| `flutter-bloc-review` | reviews a change against the rules |
| `flutter-bloc-release` | prepares a store or web release |

## Works with any flutter_bloc app

The skills don't require a particular template. Where they need a building block (a dialog helper, a responsive scaffold, a paginated list, an API error handler), they use the project's own, or add a small version from the skill's `references/` folder.

For a new app, [flutter_bloc_kit](https://github.com/afesohromeo/flutter_bloc_kit) has all of these built in, plus the full written standards these skills come from.

## Licence

[MIT](LICENSE)
