---
name: flutter-bloc-api-errors
description: Use when a Flutter app with flutter_bloc or Cubit calls an HTTP or backend API, when adding an endpoint or repository method, or when handling failures, status codes, timeouts or the error messages users see.
metadata:
  source: flutter_bloc_kit _standards v2.1.0
---

# API Errors in flutter_bloc Apps

## Overview

Every failure a user can hit gets its own message that says what happened and what to do next. A generic "Something went wrong" for a known case is a bug, and so is showing the server's raw text for a case the app knows about.

## 1. List the error cases before coding

For each call, fill this table in your plan. Ask the developer for the backend's codes and meanings.

| Call | Case | Detected by | Message | Then |
|---|---|---|---|---|
| Cancel order | No longer cancellable | 409 | "This order can no longer be cancelled." | Reload the order |
| Cancel order | Not found | 404 | "This order no longer exists." | Back to the list |
| Any | No connection, timeout | transport error | "No connection. Check your network and try again." | Retry |

Always cover: no connection or timeout, 401 (session expired), 404, the business rules (409/422), 5xx, and an unreadable response. The same status gets **different messages per operation**: loading ("Couldn't load your orders") is not cancelling ("The order wasn't cancelled").

## 2. Data layer: typed exceptions, in one place

- Convert transport errors to typed exceptions in **one** handler. Use the project's own; if it groups all 4xx into one type, branch on its status code for the known cases. No handler? Add `references/api_exceptions.dart`.
- Repositories: no user-facing text, never swallow (`log` then `rethrow`), `return await` inside `try`, a request timeout.

## 3. BLoC: state per operation, message per case

- One status **and** one error field per operation group (list, details, each action). A failed action keeps the loaded data on screen.
- The BLoC (or a mapper it calls) turns each exception into that operation's localized message:

```dart
String _cancelErrorMessage(Object e, AppLocalizations l10n) => switch (e) {
  ApiException(statusCode: 409) => l10n.errorOrderNotCancellable,
  ApiException(statusCode: 404) => l10n.errorOrderNotFound,
  UnauthorizedException() => l10n.errorSessionExpired,
  NetworkException() => l10n.errorNoConnection,
  // Unknown 4xx: the server's text if any, else this operation's message.
  ApiException(:final message) => message ?? l10n.errorCancellingOrder,
  _ => l10n.errorCancellingOrder,
};
```

- After the user has seen the result, reset the action's status (a `resetAction` event) so it doesn't show again on rebuild.
- After 404 or 409, reload the affected data so the screen shows the real state.

## 4. UI

- Show results through the app's feedback helper (dialog or toast), the same way as the rest of the app.
- Offer Retry only when retrying can help (network, 5xx), not for 404 or 409.

## 5. Tests

- Repository: one test per status code and for a transport failure, with a mocked client.
- BLoC: one `blocTest` per error case, asserting the exact message for that case.

## Red flags

- One `catch (_)` that emits a single failure message
- `throw Exception('Failed to …')` in a repository
- 409 shown with the server's raw text when the app knows the case
- One `errorMessage` field shared by loading and an action
