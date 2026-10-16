# Changelog

## 1.0.0 (2026-10)

First release. Rules from [flutter_bloc_kit](https://github.com/afesohromeo/flutter_bloc_kit) `_standards/` v2.1.0; each skill tested with and without it on two projects ([`doc/skill-tests.md`](doc/skill-tests.md)).

- `flutter-bloc-feature-workflow`: plan with open questions first, reuse the app's building blocks, stay in scope, money and text rules, tests per layer.
- `flutter-bloc-api-errors`: error cases listed per call, one message per case and operation, state per operation; `references/api_exceptions.dart` for apps without a handler.
- `flutter-bloc-serverpod`: Serverpod 4 (verified on 4.0.3): who runs what, layout, client and session setup, `serverpod_auth_idp`, schema changes; `references/pitfalls.md`.
- `flutter-bloc-review`: scope first, team rules that block a merge, logic, grades (Blocking, Needs approval, Should fix, Nit).
- Installable with `npx skills add` and as a Claude Code plugin (`.claude-plugin/`).
