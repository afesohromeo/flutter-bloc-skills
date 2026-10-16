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

---

## Phase 3: candidate skills (baselines first)

Same setup: Sonnet, vague request, "developer unavailable, list what you'd ask". Six candidates, both projects each, run in parallel. Plan-only tasks (Serverpod, release) and the review task may not change files.

### Checklists

**Paginated list** ("Add a customers page with search"; `GET /customers?page&size&search` → `{content, totalElements}`, thousands of rows)
P1 infinite scroll with the app's list mechanism (kit: `PagingController` / `CustomPaginatedList`) · P2 last page detected, no fetch past the end · P3 no duplicate or parallel page fetches · P4 search debounced, server-side, restarts at page 0, a late response for an old search can't overwrite the new one · P5 an error on a later page keeps the loaded rows and offers retry at the bottom · P6 "no customers" and "no results for 'x'" are different · P7 pull-to-refresh · P8 tests for append, last page, search reset, later-page error

**Tests** ("The X feature lacks tests; add what it needs")
T1 repository/API tests with a mocked client, one per status and parse failure · T2 BLoC tests per event and per error, exact states · T3 widget tests per page state and the main interactions · T4 assertions that would fail if the behaviour broke · T5 the project's helpers, fixtures and keys · T6 bugs found while testing are reported, not hidden by tests that assert the bug · T7 no production change without saying so

**Localization** (plain: "make the app work in French as well as English"; kit: summary card "3 items · Updated 5 min ago", "Last sync:" + date)
L1 setup (`flutter_localizations`, gen-l10n, ARB, delegates, supported locales) · L2 every string moved, including BLoC/repository messages · L3 ICU plurals, placeholders, no concatenation · L4 French typography (space before ":", no-break) · L5 dates, numbers and relative time formatted for the locale · L6 tests still pass with localizations wired · L7 kit: `labelColon`, EN + FR, `toFrench.txt` empty

**Code review** (review the phase-2 Sonnet baseline changes; known flaws)
- Plain diff: R1 one generic message for all failures · R2 repository throws hardcoded `Exception('Failed …')` · R3 money as `double`, no currency · R4 no repository or widget tests · R5 hardcoded text, not flagged · R6 2 new analyzer infos
- Kit diff: R7 SnackBar although the app has `DialogUtils` · R8 409 has no own message (server text) · R9 shared `showConfirmDialog` changed · R10 unrelated diffs: 10 files reformatted, 2 regenerated `.freezed.dart` files · R11 no amounts although orders have totals (scope gap)

**Serverpod** (plan the move to Serverpod 4 with email sign-in; plan only)
S1 layout: `_server` / `_client` / `_flutter`, where the existing app goes · S2 who runs what: the developer runs `serverpod start`, migrations, Docker; generated code never edited · S3 models in `.spy.yaml`, `create-migration` / apply · S4 client setup: `Client(...)` with connectivity monitor and `FlutterAuthSessionManager`, `auth.restore()` before the first frame, server URL from `--dart-define` / `config.json`, `10.0.2.2` on the emulator · S5 sign-in with **Serverpod 4's `serverpod_auth_idp`** (not the 2.x `serverpod_auth` module), secrets in `passwords.yaml`, not committed · S6 repositories keep their interface, BLoCs unchanged, server exceptions mapped · S7 pitfalls (upload hang without timeout, one account per email, Windows `serverpod.bat` path)

**Release** (Google Play + web next month; email and Google sign-in; Google Maps; checklist only)
E1 privacy policy in the app and at a public URL, every language · E2 account deletion in the app + a web route · E3 Play data-safety form matching the policy · E4 upload key outside the repo, `key.properties` gitignored · E5 release SHA-1 added to Google sign-in, Firebase and Maps key restrictions; SHA-256 in `assetlinks.json` · E6 API keys restricted (package + SHA-1, web referrers) · E7 OAuth consent screen published · E8 production build config (`--dart-define`), version bump · E9 crash reporting · E10 manual acceptance on a real Android device and the web · E11 store listing, content rating, demo account for reviewers · E12 split of what the agent can do vs the developer

### Phase 3 baseline results (no skill), 2026-10-16

Per-run scores (checked in the code where it mattered):

- rel-plain: E1 ✅ (public URL; in-app link not mentioned ⚠️) E2 ✅ in app + web link E3 ✅ E4 ✅ never commit, agent won't hold keystore E5 ✅ debug/release/Play App Signing SHA-1/256 in Firebase E6 ✅ E7 ✅ E8 ⚠️ version, keys via dart-define E9 ✅ E10 ✅ E11 ✅ reviewer account, content rating E12 ✅. Extra: 12 testers / 14 days closed test for new personal accounts (missing from kit 16). Verdict: strong.
- sp-plain: says "from memory of Serverpod 3.x", asks to verify. S1 ✅ siblings, discard generated flutter app S2 ⚠️ manual docker + `dart bin/main.dart --apply-migrations` (pre-4 workflow, no `serverpod start`); agent would run `serverpod generate` itself S3 ✅ S4 ⚠️ 10.0.2.2 + dart-define ✅; no `auth.restore()` before first frame, no connectivity monitor, "authentication key manager" (old API name) S5 ⚠️ guessed idp package names (flagged), email codes via callbacks ✅, passwords.yaml ✅ S6 ✅ repository interface kept S7 ❌ none of the known pitfalls (upload hang, one account per email, serverpod.bat path). Extra ✅ release INTERNET permission missing. Verdict: version-specific gaps → skill justified.
- review-plain: verdict "merge after fixes". R1 ⚠️ generic message noted as "not blocking" R2 ⚠️ only "catch (_) drops the error" R3 ❌ double money not mentioned R4 ✅ thin tests, concrete missing cases R5 ⚠️ hardcoded text "not blocking" R6 ⚠️ dismissed as repo style. Extra ✅ real bug: refetch failure after a successful cancel reported as cancel failure; ✅ fromJson fragility. Verdict: finds logic bugs, under-weights team standards (money, messages, text) → skill justified (what blocks a merge).
- rel-kit: E1 ⚠️ public URL, in-app link not mentioned E2 ✅ E3 ✅ E4 ✅ found release uses signingConfigs.debug E5 ✅ upload + Play App Signing SHA-1 E6 ✅ E7 ⚠️ consent screen created, "publish" not mentioned E8 ✅ dart-defines, version, Makefile target lacks defines E9 ✅ recordError E10 ✅ E11 ✅ E12 ✅. Extra: 12 testers/14 days; screenshot harness for listing. Verdict: strong → no release skill; feed 12-tester rule + debug signing finding back to the kit.
- sp-kit (looked up docs online): S1 ✅ siblings, delete generated flutter stub S2 ⚠️ manual docker + `dart bin/main.dart --apply-migrations`; agent would run `serverpod generate`, `create-migration` itself (kit: developer) S3 ✅ S4 ⚠️ SERVER_URL dart-define, 10.0.2.2 ✅; `await client.auth.initialize()` before runApp (blocks start on network) instead of `restore()` + background `initialize()`; no connectivity monitor S5 ✅ `serverpod_auth_idp_*`, not legacy; mail callback ✅ S6 ✅ mapper, BLoC unchanged, ServerpodClientException mapped S7 ⚠️ dependency-conflict + CORS noted; none of upload hang / one account per email / serverpod.bat. Verdict: skill justified (workflow `serverpod start`, who runs what, session restore, pitfalls).
- test-plain: T1 ✅ MockClient: GET URL, 200, empty, 201/404/500, malformed JSON/item, ClientException T2 ✅ incl. reload keeps data, recovery T3 ✅ spinner, error, data, empty, rebuild, page dispatch T4 ✅ T5 n/a T6 ✅ 3 findings reported (failed reload hides old data, concurrent events, no retry); pinned current behaviour but said so T7 ✅ no lib changes. Minor: low-value tests (state equality/copyWith), file name `todos_bloc_more_test.dart`. Verdict: strong.
- loc-plain: L1 ✅ gen-l10n, ARB, delegates, locales L2 ✅ (3 strings only) L3–L5 not exercised (no counts, dates or labels in the app) L6 ✅ locale tests. Verdict: inconclusive by task design (too little text); the kit task decides.
- page-plain: P1 ✅ scroll-near-bottom P2 ✅ stops at totalElements P3 ✅ droppable P4 ✅ 400 ms debounce, restartable + stale next-page guard P5 ✅ footer spinner/retry P6 ⚠️ one "No customers found" P7 ❌ no pull-to-refresh P8 ✅ first/next/end/stale. Added `bloc_concurrency` before asking (covered by feature-workflow). 2 new analyzer infos (copied todos). Verdict: strong.
- review-kit: verdict "merge after fixes". R7 ❌ SnackBar not flagged; it even suggests adding a snackbar R8 ❌ 409 has no own message: not flagged R9 ❌ shared `showConfirmDialog` change not flagged R10 ⚠️ 2 freezed files flagged (as line-ending noise); the 10 reformatted files not flagged R11 ❌ missing amounts not flagged. Extra ✅ real bugs: failed reload after cancel invisible, no-op buttons look enabled, non-map 2xx body = failed cancel, empty id. Verdict: same as plain: strong on logic, blind to team conventions and scope → skill justified.
- test-kit: T1 ✅ provider (Dio mocked), repository, demo provider T2 ✅ 17 BLoC tests incl. each exception, filtering, last page, refresh T3 ✅ 9 page tests (skeleton, empty, error+retry, debounce 500 ms, search-empty message, demo notice) T4 ✅ T5 ✅ reused pumpApp, mocks, fixtures, setUpTestLocalization T6 ✅ reported: ItemsBloc has no 410 branch (generic message), Item.fromJson bad id → 0 T7 ✅. Verdict: strong → no tests skill. Kit findings: 410 branch in ItemsBloc; fromJson id fallback.
- page-kit: P1 ✅ PagingController + CustomPaginatedList P2 ✅ by totalElements (better than items' short-page rule, which fetches one extra empty page at an exact multiple) P3 ✅ P4 ✅ 500 ms, request counter drops stale answers, refresh invalidates in-flight; test P5–P7 ✅ via CustomPaginatedList/refresh P8 ✅ incl. race. Scope: unrequested home button + drawer + demo provider (asked afterwards) → covered by feature-workflow. Verdict: strong → no pagination skill (phase-2 "Load more" was a one-off).
- loc-kit: L3 ✅ ICU plurals (items, hours, days) L4 ✅ labelColon L5 ✅ formatDate + localized relative time L7 ✅ EN + FR; reverted unrelated .freezed files. Verdict: strong.

### Phase 3 verdicts

| Candidate | Verdict | Why |
|-----------|---------|-----|
| Paginated list | **No skill** | Both runs: infinite scroll with the app's mechanism, end of list, no duplicate fetches, stale-search guards, tests. Scope creep seen is covered by `flutter-bloc-feature-workflow`. |
| Tests | **No skill** | Both runs: every layer, each error case, project helpers reused, findings reported, no production changes. `flutter-bloc-feature-workflow` already requires tests per layer. |
| Localization | **No skill** | Kit run: ICU plurals, `labelColon`, locale dates, EN + FR. Plain run: correct gen-l10n setup. The text rules in `flutter-bloc-feature-workflow` cover the rest. |
| Release | **No skill** | Both runs covered E2–E12 with a clear agent/developer split, and added the 12-testers / 14-days closed test. |
| **Serverpod** | **Skill** | Both runs: pre-4 workflow (manual Docker, `dart bin/main.dart`) instead of `serverpod start`; the agent would run generation and migrations itself; no fast session `restore()`; none of the known pitfalls. One run worked from 3.x memory. |
| **Code review** | **Skill** | Both runs found real logic bugs but missed almost every team-standard flaw: `double` money, generic messages, SnackBar beside `DialogUtils` (one even suggested more SnackBars), shared component edits, unrelated diffs, missing amounts. |

**Kit findings from these runs** (for the kit, not the skills): `showConfirmDialog` needs a `cancelLabel`; `_standards/16` should add the Play closed-test rule (12 testers, 14 days, new personal accounts); release builds are signed with the debug key and `make build-android` passes no `--dart-define`; `ItemsBloc` has no 410 message; `Item.fromJson` turns a bad id into 0; the items "short page = last" rule fetches one extra empty page when the total is a multiple of the page size.

### Phase 3 with skills, 2026-10-16

Serverpod (plan only) and code review, same tasks, Sonnet, agent reads the skill (and `flutter-bloc-api-errors`) first.

| Check | Baseline (both projects) | With skill |
|-------|------|------|
| S2 Who runs what | manual Docker + `dart bin/main.dart`; agent would run generation/migrations | ✅ both: "You run" table, `serverpod start`, no Docker, agent never starts the server or runs migrations, old dev loop named as outdated |
| S4 Client setup | `initialize()` awaited before `runApp`, or no session restore | ✅ both: `restore()` before the first frame, `initialize()` unawaited, `10.0.2.2`, HTTPS `SERVER_URL` |
| S5 Sign-in | one run guessed package names from 3.x memory | ✅ both: `serverpod_auth_idp`, secrets in `passwords.yaml` |
| S7 Pitfalls | none of the known ones | ✅ both: all of them; plain run added "user id from the session, never from the app" |
| R1–R6 plain flaws | money, generic messages, text "not blocking"/missed | ✅ all blocking (round 1 and 2) |
| R7 SnackBar beside `DialogUtils` (kit) | missed; one review suggested *adding* a SnackBar | ✅ blocking, `DialogUtils` named |
| R8 409 without own message (kit) | missed | ✅ blocking, per-case mapper proposed |
| R9 Shared component changed (kit) | missed | ⚠️ round 1: seen but "fine, backward compatible" |
| Logic bugs | ✅ found | ✅ still found |

**Round 1 problems → refactor of `flutter-bloc-review`:** the plain review marked the SnackBar as blocking ("the app shows results via dialogs"), but the plain app only has a confirm dialog, not a results helper; the kit review let the unagreed shared change pass as "backward compatible". Fix: the feedback rule applies only when the app has a results helper (a confirm dialog isn't one); a new **Needs approval** grade for shared changes, extras and deferring localization, even when backward compatible. Round 2 (plain): SnackBar correctly accepted, shared edits under Needs approval, all flaws still caught.

R11 (missing amounts) was dropped from the checklist: the vague request never mentioned amounts, so no reviewer could know.

### Phase 4: installation, 2026-10-16

- `npx skills add <repo> --list` first found **3 of 4 skills**: the Serverpod description contained `(Serverpod 4): creating`, and an unquoted `": "` breaks the YAML front matter, so the skill was skipped (Claude Code would have skipped it too; the test runs didn't notice because they read the file directly). Fixed by quoting the description; all 4 found.
- `npx skills add <repo> -a claude-code -y` in a scratch folder: all 4 skills and their `references/` installed under `.claude/skills/`.
- Claude Code plugin: `.claude-plugin/marketplace.json` (plugin `flutter-bloc`, source `./`) and `.claude-plugin/plugin.json`; `claude plugin validate .` passes. Not registered with `claude plugin marketplace add`, which would change the user's settings.

Round 2 (kit, after the refactor): R7 and R8 blocking as in round 1; **R9 now under Needs approval** with the drawer tile and the unrequested demo data; freezed line-ending noise flagged as an unrelated diff; logic findings kept. **Verdict: both phase-3 skills pass.**
