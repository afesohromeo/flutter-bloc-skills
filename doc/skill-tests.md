# Skill Tests

How each skill was tested (see the plan, "Testing each skill"). Runs use disposable copies of two projects:

- **Kit app:** flutter_bloc_kit v2.1.0 without `_standards/`, `CLAUDE.md`, `.claude/`, `doc/` and with a minimal README. It still has the kit's code (reference `items` feature, components, tests).
- **Plain app:** `flutter create` + flutter_bloc, equatable, http, bloc_test, mocktail, with one `todos` feature in the common feature-first style (`lib/todos/{bloc,data,view}`), Equatable states with a status enum, hardcoded English text, `Navigator`, no localization, no router. Baseline: 2 analyzer infos, 2 tests.

Each run is a general-purpose subagent, told to work only in its folder, not to use agent skills, and not to ask questions. "With skill" runs are told to read the skill's `SKILL.md` first.

---

## Phase 2: `flutter-bloc-architecture` + `flutter-bloc-add-feature`

### Task (same for every run)

> Feature: Orders
> - A page listing the user's orders from the app's API: GET /orders returns a JSON array of {id, reference, amountMinor: int, currency, status: pending | paid | cancelled, createdAt: ISO-8601}.
> - Tapping an order opens its details page (GET /orders/{id}: same fields plus items: [{name, quantity}]).
> - On the details page, a pending order can be cancelled (POST /orders/{id}/cancel) after the user confirms. Possible errors: 404 (order not found), 409 (the order can no longer be cancelled), network failure.
> - Add a way to reach the orders page from the home page.

### Checklist

| # | Check | Kit app | Plain app |
|---|-------|---------|-----------|
| C1 | **Layers:** UI → BLoC → repository → API/data source; UI never calls the repository; dependencies injected through constructors | same | same |
| C2 | **Matches the project:** its state style, file layout, naming, imports (barrels if the project has them) | Freezed sealed, barrels, kit folders | Equatable, `lib/orders/{bloc,data,view}`, relative imports like `todos` |
| C3 | **State per operation:** separate status + error for list, details and the cancel action; a failed cancel doesn't wipe the loaded details; the action state is reset after the user sees the result | same | same |
| C4 | **One message per error case:** 404, 409 and network failure each produce their own user message; no generic "something went wrong" for a known case; no swallowed exceptions; `return await` inside `try` | same | same |
| C5 | **Text:** no hardcoded user-facing text where the app has localization | ARB keys in EN + FR | follows the app (no l10n yet); text kept in one place or the gap flagged |
| C6 | **Money and dates:** amount stays `int` minor units, formatted with its currency; dates parsed safely and formatted for the locale | kit money/date utils | `intl` or equivalent |
| C7 | **Action UX:** confirmation before cancelling; loading shown during the call; `context.mounted` after async gaps; result shown through the app's feedback mechanism | `showConfirmDialog`, `DialogUtils` | `showDialog` / app's own |
| C8 | **Coming back:** after a cancel, the list shows the new status | `ReloadOnReturn` or refresh | refresh on return |
| C9 | **Navigation:** the app's router; named routes; details nested under the list | go_router `goNamed`, nested | `Navigator` (no router) |
| C10 | **Building blocks reused:** existing loading / empty / error widgets, scaffold, dialogs | `ResponsiveScaffoldWrapper`, `ShimmerSkeleton`, `ErrorStateWidget`, `EmptyWidget` | the app's own, or small new ones |
| C11 | **Tests:** BLoC tests including each error case; repository tests with a mocked client; a widget test per page | same | same |
| C12 | `flutter analyze` adds no issues; all tests pass | same | same |

### Results: baseline (no skill), 2026-10-16

Model: the session's default (Opus 5.5). Checked by reading the code, not only the agents' reports.

| # | Kit app | Plain app |
|---|---------|-----------|
| C1 | ✅ API provider → repository → 2 BLoCs → pages; injected | ✅ repository → 2 BLoCs → pages (repository calls `http` directly, like `todos`) |
| C2 | ✅ Freezed sealed, barrels, kit folders and naming. Minor: no `GenericFlowStep` / `refreshController`; statuses named `orderStatus` / `cancelStatus` | ✅ Equatable, `lib/orders/{bloc,data,view}`, Page/View split |
| C3 | ✅ load and cancel tracked separately; failed cancel keeps the details | ✅ same |
| C4 | ✅ own l10n message for 404, 409, network, 401; repository `log` + `rethrow`; reloads the order after 404/409 | ✅ one typed exception with a reason per case; `return await` with a 15 s timeout |
| C5 | ✅ EN + FR keys, `toFrench.txt` empty | ❌ hardcoded English; the missing localization isn't mentioned |
| C6 | ✅ `formatMoney`, `formatDate`, `convertJsonDate` | ⚠️ money correct (minor units, currency decimals); dates in a fixed `yyyy-MM-dd HH:mm`, not the user's locale |
| C7 | ✅ `showConfirmDialog`, `DialogUtils`, button disabled while cancelling | ✅ confirm dialog, `context.mounted`; result in a SnackBar (the app has no feedback helper) |
| C8 | ✅ `ReloadOnReturn` on the list | ✅ quiet reload after returning |
| C9 | ✅ nested named routes, `goNamed` | ✅ `Navigator.push` (the app has no router) |
| C10 | ✅ `ResponsiveScaffoldWrapper`, skeleton, `ErrorStateWidget`, empty state | ✅ own small error view |
| C11 | ✅ 50 tests: model, API provider, repository, BLoCs, pages, navigation | ✅ 39 tests: repository (MockClient), BLoCs, pages |
| C12 | ✅ no issues, 189 tests pass | ✅ no new issues, 41 tests pass |

Also seen: the kit run changed a shared component (`showConfirmDialog` got a `dismissLabel`) and added a drawer entry nobody asked for; neither run presented a plan (they were told not to ask).

### Results: harder baseline (no skill, vague task, Sonnet), 2026-10-16

Task, as a developer would write it: *"Add an orders page where the user can see their orders and cancel a pending one. The backend has GET /orders, GET /orders/{id} and POST /orders/{id}/cancel."* The agent was told that the developer can't answer, and to list what it would have asked or waited for.

| # | Kit app | Plain app |
|---|---------|-----------|
| C1 | ✅ | ✅ |
| C2 | ✅ copied `items` | ✅ copied `todos` |
| C3 | ✅ list and cancel tracked separately | ⚠️ one status for the list plus a set of ids being cancelled; no error stored per operation |
| C4 | ⚠️ typed exceptions mapped (400 → server message, 401, network); no own message for "can no longer be cancelled" | ❌ one generic "Something went wrong" for loading, one "Could not cancel the order" for every cancel failure; repository throws hardcoded `Exception('Failed …')` |
| C5 | ✅ EN + FR | ❌ hardcoded English, not flagged |
| C6 | — no amounts shown (fields unknown) | ❌ `total` stored as `double`, no currency |
| C7 | ❌ **SnackBar** for the result although the app has `DialogUtils`; `showConfirmDialog` used | ⚠️ confirm dialog; SnackBar |
| C8 | — no child page | — no child page |
| C9 | ✅ named route, drawer entry | ⚠️ icon on the todos app bar |
| C10 | ✅ skeleton, error, empty | ✅ own small views |
| C11 | ✅ repository, BLoC, page tests | ❌ BLoC tests only; no repository or widget test |
| C12 | ✅ no issues, 157 tests | ⚠️ 2 new analyzer infos (same pattern as `todos`), 7 tests |

Scope and process:
- **Kit:** changed a shared component (`showConfirmDialog` `dismissLabel`, as the Opus run did); ran `dart format` on the whole project (10 unrelated files reformatted); regenerated unrelated `.freezed.dart` files; ran code generation itself.
- **Both:** listed good open questions (response shape, error codes, money units, authentication) but **built anyway**, with guesses, instead of presenting them first. Neither presented a plan.

**Test-setup caveat:** the test agents also see this machine's Claude memory and the CLAUDE.md of the folder the session runs in (they mentioned "plan first" and "skills"). That is the same for every run, so before/after comparisons stay fair.

### Gaps the skills must close (from the four baselines)

| Gap | Seen in |
|-----|---------|
| G1 Unknowns (response shape, error codes, money units, auth) guessed instead of asked; no plan presented before coding | all 4 |
| G2 Error cases not enumerated: generic messages, or the server's message instead of an own message per known case | Sonnet runs |
| G3 Existing building blocks ignored (SnackBar although the app has a dialog helper) | Sonnet kit |
| G4 Changes outside the task: shared components edited, whole-project format, unrelated generated files | both kit runs |
| G5 Money as `double`, no currency | Sonnet plain |
| G6 Tests: no repository or widget tests | Sonnet plain |
| G7 Localization missing and not flagged; dates not locale-aware | both plain runs |

**Finding (first baseline):** with a detailed task and a strong model, both baselines already meet almost every check. In the kit app, the kit's own code (the `items` feature) teaches the patterns; in the plain app, the model's general flutter_bloc knowledge does. Skills that restate these patterns would not change the result. The real gaps are small: localization in an app without it, locale-aware dates, and scope discipline (unrequested changes, no plan).

### Results: with skills (vague task, Sonnet), 2026-10-16, round 1

Same task and model as the harder baseline; the agent read `flutter-bloc-feature-workflow` and `flutter-bloc-api-errors` first.

| Gap | Kit app: baseline → with skills | Plain app: baseline → with skills |
|-----|------|------|
| G1 Unknowns and plan | built on silent guesses → plan and questions listed first, each default named | same improvement |
| G2 One message per error case | 409 shown with server text → own messages for 409, 404/410, 401, network, unreadable, separate for loading and cancel; reloads after 404/409 | one generic message per operation → own message per case, per operation (`orders_messages.dart`) |
| G3 Building blocks | SnackBar → `DialogUtils` + `showConfirmDialog`, `formatMoney`, `formatDate` | no helpers in the app; SnackBar is the only feedback style ✅ |
| G4 Scope | shared component edited, whole-project format, unrelated generated files → no shared edits (the wanted `dismissLabel` was asked about instead), unrelated `.freezed.dart` files reverted | only touched files formatted; the edit to `todos_page.dart` (entry point) flagged for confirmation |
| G5 Money | — → `int` minor units + ISO code, `formatMoney` | `double` → `int` minor units + code; locale grouping needs `intl`, asked instead of adding the dependency |
| G6 Tests | 157 total → 34 new: provider (each status), repository, BLoC (exact message per case), page | 5 BLoC tests → 26: repository per status, BLoC per case, page states |
| G7 Text and dates | EN + FR ✅ | hardcoded, now **flagged**; dates with `MaterialLocalizations` |
| C12 | no issues, 183 tests | 4 new analyzer infos (copied the `todos` constructor style), 40 tests |

**New problems the skills caused or didn't fix:**
- Kit: the page had **no way in**: the agent read "no extra entry points" as "no entry point at all".
- Plain: new analyzer infos, justified as "same as the existing feature".

**Refactor:** "A new page needs one way in, where similar pages are reached from"; "no new analyzer issues, even where the code you copied has them"; red flag "a new page with no way to reach it". Re-tested in round 2.

**Kit finding (not a skill issue):** 3 of the 4 kit runs wanted a "Keep order" label on `showConfirmDialog`, whose dismiss button is always "Cancel" (ambiguous next to "Cancel order"). Suggest a `cancelLabel` parameter in the kit.

### Results: with skills, round 2 (after the refactor), 2026-10-16

| Check | Kit app | Plain app |
|-------|---------|-----------|
| Way in | ✅ one drawer tile, like the other top-level pages (+7 lines in `app_drawer.dart`, named in the report) | ✅ one app-bar action on the home page, flagged for confirmation |
| New analyzer issues | ✅ none, 181 tests pass | ✅ none (the agent used the newer constructor style instead of copying the lint), 36 tests pass |
| G1–G7 | ✅ as in round 1 (own message per case and operation, `DialogUtils`, no other shared edits, unrelated generated files reverted, `int` money, tests per layer, EN + FR) | ✅ as in round 1; hardcoded text flagged |

**Fixed in the reference:** the plain-app agent noticed that `guardRequest` caught only `dart:io`'s `SocketException`. Since http 1.0, `package:http` reports connection failures as `http.ClientException` on every platform (including web). The reference now catches that and no longer imports `dart:io`.

**Seen, left for a later skill:** the kit agent used a "Load more" button although the app's lists use infinite scroll (`PagingController` in `items`). Evidence for the `flutter-bloc-add-paginated-list` candidate.

**Verdict:** both skills pass. Phase 2 complete.
