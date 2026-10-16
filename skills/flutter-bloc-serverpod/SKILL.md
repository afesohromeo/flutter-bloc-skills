---
name: flutter-bloc-serverpod
description: "Use when a Flutter app with flutter_bloc uses or is moving to a Serverpod backend (Serverpod 4): creating the server project, models, endpoints, migrations, the generated client, email or Google sign-in, running the server, or planning any of these."
metadata:
  source: flutter_bloc_kit _standards/14_serverpod.md, verified against Serverpod 4.0.3
---

# Serverpod 4 Backend for flutter_bloc Apps

## Overview

Serverpod changed a lot between 2.x, 3.x and 4.x, and memory of older versions gives wrong commands and APIs. This skill is verified against **Serverpod 4.0.3**. Check the installed version first (`serverpod version`); if the major version differs, say so and verify against the docs before relying on this.

## 1. Who runs what

| Developer | Agent |
|---|---|
| `serverpod start` (generates code, runs server and app, hot reload, embedded PostgreSQL: **no Docker**) | Writes `.spy.yaml` models, endpoints, services, app code |
| Migrations: `serverpod create-migration`, applying them | Runs the test suites: `dart test` (server), `flutter test` (app) |
| Installs, `serverpod create`, secrets in `config/passwords.yaml`, deploy (`scloud deploy`) | Reads logs (`tail_server_logs`, `tail_flutter_logs` from the `serverpod` MCP) |

An agent **never starts the server** and never edits generated code (`<app>_server/lib/src/generated/`, the whole `<app>_client` package). Write each developer step as "You run: …".

**Outdated, don't propose:** `docker compose up` + `dart bin/main.dart --apply-migrations` as the dev loop, the `serverpod_auth` module, `serverpod_auth_email_*` packages.

## 2. Project layout

```
my_app/
├── my_app_server/    generated; models in lib/src/models/*.spy.yaml
├── my_app_client/    generated; never edited
└── my_app_flutter/   the Flutter app
```

New project: `serverpod create my_app --database --auth --webapp --no-redis --no-website` (`--ide claude` also installs Serverpod's own agent skills). Existing app: replace the generated Flutter package with it (its BLoCs, pages and tests stay), then add `my_app_client` (path), `serverpod_flutter`, and for sign-in `serverpod_auth_idp_flutter`, all on the server's exact version.

## 3. Models and errors

- Shared types are `.spy.yaml` models; the app uses the generated classes directly (no copy, no `fromJson`).
- The server throws one serializable `AppException(code: AppErrorCode.x)`; **codes, never text**. The app maps each code to its own localized message. **REQUIRED SUB-SKILL:** `flutter-bloc-api-errors`.
- One error handler in the app maps `AppException` (and the auth module's own exceptions) → typed 4xx with code, `ServerpodClientUnauthorized` → 401, `ServerpodClientNetworkException` → network.
- Repositories keep their interface, so BLoCs and their tests barely change.

## 4. Client setup

```dart
final client = Client(await getServerUrl())   // --dart-define=SERVER_URL, else config.json, else localhost
  ..connectivityMonitor = FlutterConnectivityMonitor()
  ..authSessionManager = FlutterAuthSessionManager();
await client.auth.restore();              // saved session, before the first frame: no sign-in flash
unawaited(client.auth.initialize());      // validated with the server in the background
```

Android emulator: the PC is `10.0.2.2`. Release builds: an HTTPS `SERVER_URL`.

## 5. Sign-in

`serverpod_auth_idp` (email identity provider with verification codes, JWT with refresh), as set up by the 4.x template. Secrets in `config/passwords.yaml`, gitignored. With Google sign-in, decide **one account per email** up front: see `references/pitfalls.md`.

## 6. Schema changes

New columns on existing tables: nullable or with a default, or the migration drops the table. Migrations are generated and committed, never edited.

## 7. Before you finish

Read `references/pitfalls.md` for the known 4.0.3 problems (uploads that wait forever, endpoint parameters with defaults, leftover PostgreSQL processes, Windows PATH).

## Red flags

- "Start Docker" or `dart bin/main.dart` in a Serverpod 4 dev loop
- An agent running `serverpod start`, migrations or `hot_restart` unasked
- An edit inside `generated/` or `<app>_client`
- `throw Exception('…')` or error text in an endpoint
- `await client.auth.initialize()` blocking the first frame
