# Serverpod 4.0.3: known pitfalls

Found while building a production app (Plotwatch, October 2026). Re-check after a Serverpod major release.

| Pitfall | What to do |
|---------|-----------|
| A named endpoint parameter **with a default** (`{int page = 0}`) becomes **required** in the generated client | Use nullable named parameters (`{int? page}`) and apply defaults on the server |
| Adding a non-null column to an existing table makes `create-migration` drop and recreate the table | Add new columns as nullable or with `default=`; use `--force` only on tables without data |
| `serverpod start` can rewrite the client even when code generation fails (invalid Dart in an endpoint), removing endpoints from it | Fix the endpoint, then run `serverpod generate` by hand |
| The embedded PostgreSQL (dev and test) keeps running after `dart test` or after closing the `serverpod start` terminal; the next start fails | Stop the leftover `postgres` processes before starting again |
| `dart install serverpod_cli` installs to a folder that isn't on PATH on Windows | Add `%LOCALAPPDATA%\Dart\install\bin` to PATH; restart the editor so it sees the new PATH |
| On Windows, `serverpod` is a `.bat`; an editor started before the install doesn't find it, so MCP configs fail | Call it by full path: `cmd /c C:\Users\<you>\AppData\Local\Dart\install\bin\serverpod.bat mcp-server --server-dir my_app_server` |
| `serverpod create` on Windows prints "Updating Flutter app MacOS entitlements. failed." | Harmless; ignore |
| `FileUploader.upload` / `uploadByteData` **wait forever** when the connection fails (no timeout, error swallowed). Seen with an upload URL pointing at `localhost:8080` from the Android emulator | Wrap uploads in `.timeout(...)` and show an error; on the emulator, the PC is `10.0.2.2` |
| The Google identity provider finds users by Google account ID only: a first Google sign-in with the email of an existing password account creates a **second user** | Link by verified email (below) |
| `serverpod create --ide claude` makes the root `.gitignore` ignore the whole `.claude/` folder | Narrow it to `.claude/skills/`, `.claude/settings.local.json` and `.mcp.json`, so `CLAUDE.md` and `.claude/settings.json` are committed |

## One account per email (Google + email sign-in)

Serverpod leaves linking to the app. What worked:

- Google sign-in with a **verified** email that a password account already has → link the Google login to that user (in your `GoogleIdpEndpoint`, before the module's login). Never link an unverified email.
- Email sign-up with an email a Google user already has → refuse with its own error code ("This email is used with Google. Use Continue with Google.").
- Server tests for all four cases: linked, new user, unverified not linked, returning Google user.

## Server tests

`dart test` in the server package. Integration tests use the generated `withServerpod('Given …', (sessionBuilder, endpoints) { … })` from `test/integration/test_tools/serverpod_test_tools.dart`; changes roll back after each test. Set the caller with `sessionBuilder.copyWith(authentication: AuthenticationOverride.authenticationInfo(userId, {}))`. The test database is an embedded PostgreSQL: no Docker.
