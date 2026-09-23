# History of the six inherited Ames failures

Investigated 2026-09-21. The six tests passed on the upstream parent of the first Groundwire commit. They were already broken at the original CC fork point, and also on the base before the earlier CC draft. The first Groundwire commit on this branch, `6f8080c1bc126176bb16752d6781a863e0682c6f` (October 1, 2025, author's timezone), is the adjacent passing-to-broken boundary. This is much earlier than September 2026.

## The actual CC fork

The first CC kernel commit, `99611677cd` (July 29, 2026), has parent `802b386a43` (July 21). This is also the merge base of the original shared CC kernel and base branches. The July 21 commit merged PR #57, an earlier `cyc/cc-draft`; it is before the later `hd/cc-kernel` work but is not free of all earlier confidential-comet work.

Between `802b386a43` and the previously tested September 3 base `edf656c1fb`, **only two CI workflow files changed**. `pkg/arvo`, `pkg/base-dev`, and `tests` are identical. Thus the September test result also establishes the July fork-point result by exact source equality, not by extrapolating over changed kernel code.

To remove the earlier draft from the comparison, a fresh pill was built from `1a24aa9c94` (July 14), the first parent of the July 21 merge. Its Ames suite independently reproduced the same three assertion failures and three crashes.

## Executed checkpoints

Every new execution used a fresh pill and disposable fake ship on the same prepared Vere 4.6 runtime. All production `pkg/arvo/sys` files were byte-checked against the checked-out historical source. Tests used each checkpoint's own suite; exceptions are explicit below.

| Production source | Test treatment | Ames passed / failed / crashed |
|---|---|---:|
| `b60bd6940f`, September 19, 2025: upstream parent | Original tests, no fixture patches | 20 / 0 / 0 |
| `6f8080c1bc`, October 1, 2025: first Groundwire commit | Original tests | Suite fails compilation; individual statuses unavailable |
| Same `6f8080c1bc` | Mechanical crypto/type/helper compatibility repairs only | 12 / 4 / 4 |
| Same `6f8080c1bc` | Also correct `%sein`, `%saxo`, and the proof path | 17 / 1 / 2 |
| `caafa90e4c`, June 24: before routing repairs | Corrected sponsorship and proof-path fixtures | 18 / 0 / 2 |
| `99dd84ddd0`, June 24: request fallback | Same corrected fixtures | 19 / 0 / 1 |
| `2455bec477`, June 25: reply fallback | Same corrected fixtures | **20 / 0 / 0** |
| `1a24aa9c94`, July 14, 2026: before draft merge | Previously documented fief/helper compatibility repairs only | 14 / 3 / 3 |
| Same `1a24aa9c94` | Also answer sponsorship scries correctly | 19 / 1 / 0 |
| Same `1a24aa9c94` | Also update the expected proof path's key-life component | **20 / 0 / 0** |
| `802b386a43`, July 21 fork point | Exact kernel/test equality with measured `edf656c1fb` | 14 / 3 / 3 |

The October compatibility run reproduces all six named failures. Its two additional failures are `test-fine-response` (assertion) and `test-old-ames-wire-mesa` (crash); these already pass by the July checkpoint. Their intervening repair commits were not bisected in this investigation.

The October test module still used removed `crub`/`priv` interfaces and would not compile as committed (`find.nu`). The diagnostic repairs use the crypto fixture conversion from `90109257fe`, adjusted to October's `cryc` spelling, plus explicit fief fields and the Mesa packet-helper gate call. No assertions were removed, no moves were filtered out, and no production files were changed. Treat its 12/4/4 result as a controlled compatibility experiment, not an assertion that the committed suite ran to completion in 2025.

## How the six tests broke

### Three extra-`%nail` assertion failures

`test-message-flow`, `test-ames-flow-with-new-rift`, and `test-alien-encounter` assume static numeric sponsorship. Their fixture roof answers every scry with an empty `(list turf)`. That commit leaves `tests/sys/vane/ames.hoon` unchanged despite changing its production APIs. The first Groundwire patch changes route classification and liveness from galaxy/static-sponsor checks to Jael-backed `%sein` lookups. Reading that dummy answer as a ship gives `~zod`, even for galaxies such as `~nec` that should sponsor themselves.

This changes the simulated route state and produces additional `%nail` effects. The tests' expected move lists were left unchanged. Returning the proper numerical sponsor for the stock fixture ships makes all three assertions pass, without accepting extra effects or modifying production routing. This was verified on both the October and July production snapshots.

### Three comet crashes, plus a masked path assertion

The comet fixtures likewise omit the new sponsorship contract. Generic roofs return the wrong sponsor/ancestry, while the custom `make-roof` supports the payload and an old `%saxo` case but does not answer `%sein`. Packet setup can then produce no packet for `snag-packet`, or fail on a missing sponsorship response deeper in Mesa. A crash status alone does not mean the comet signature or production transport is broken.

On the July pre-CC kernel, adding correct `%sein` responses makes `test-comet-message-flow` and `test-comet-comet-message-flow` pass. It also makes `test-comet-sends-mesa` reach its assertion, which then reveals a separate stale expectation:

- Expected: `/publ/1/a/x/1//pawn/proof/~bud/3`
- Actual: `/publ/1/a/x/1//pawn/proof/1/~bud/3`

The extra `1` is the comet's key life. The October 1 Groundwire patch added it to the proof-path grammar and request construction. Updating this exact expected path makes the final test pass; all 20 July tests are then green.

The October kernel additionally uses `%saxo` ancestry scries in paths where later code differs. A `%sein`-only repair is insufficient there: its three comet tests still crash, even though the three `%nail` assertions become green. Adding both `%sein` and `%saxo` answers and correcting the proof path makes `test-comet-sends-mesa` pass on October's kernel too. Two comet-flow crashes remain there. Source inspection identifies an additional historical routing defect: `fetch-comet-pki` routes its request through the unknown comet itself; `send-blob` requires a known peer, requeues the packet on the already-pending alien, and emits no packet. The test then crashes in `snag-packet`. Unknown-comet attestation replies have the analogous problem. Commits `99dd84ddd0` (June 24, 2026) and `2455bec477` (June 25) add the request and reply fallback through the default sponsor. Both reached the base through merge `08aac93581` (July 14). Historical status equality must not be described as proof of byte-identical crash causes across every intermediate revision.

## Adjacent-commit confirmation of the June routing repairs

These runs use the exact same corrected test file and exact historical production snapshots. Between `caafa90e4c` and `2455bec477`, the only repository change is the two commits' 34-line Ames diff.

- Before `99dd84ddd0`: 18 pass; both `test-comet-message-flow` and `test-comet-comet-message-flow` crash.
- At `99dd84ddd0`: 19 pass; only `test-comet-comet-message-flow` crashes. The initial attestation request now travels through a known numeric sponsor.
- At its immediate child `2455bec477`: all 20 pass. Attestation replies to unknown comets also use the default sponsor.

This distinguishes a real earlier transport regression, repaired before the CC fork, from the stale fixtures that continued reporting failures afterward. No fixture assertions were weakened to establish the June boundary. The corrected fixture file is identical across all three June runs and the green July run.

## What this does and does not establish

- There is a verified green upstream parent, followed immediately by the first Groundwire commit breaking test compilation and, after mechanical API repairs, all six individual scenarios.
- There is no verified green **committed, uncorrected** Groundwire pre-CC suite in these checkpoints. Every intermediate merge was not executed, so this is not proof that no temporary green revision ever existed.
- The July pre-CC production kernel supports all 20 scenarios when its test fixtures implement the changed sponsorship and proof-path contracts. This isolates the six contemporary failures to test drift for these cases; it is not a network-wide correctness or upgrade guarantee.
- September 3 was merely the first baseline checked in the earlier report, not the start of the failures. The first CC fork already inherited them. The RC, Mesa-core restoration, and successive CC branches did not introduce those six failing statuses.
- The diagnostic fixture repairs remain in scratch source and saved patches. They have not been added to the prepared CC branches, so those branches' previously recorded red-suite counts remain valid. Production code was not changed in this investigation.
- Historical Aqua breach/authority-fixture failures remain a separate issue.

## Reproduction artifacts

Local output: `output/ames-failure-history-20260921/`. `history-refs.json` records exact source and tree identities; `*-results.json`, `*-runtime.log`, `*-sys-sha256.json`, and `*-fixtures.patch` preserve executed outcomes, diagnostics, source checks, and each experiment's changes. `initial-gw-api-fixtures.patch` contains the complete October compatibility adjustment. `pre-draft-fixtures-fixed-fixtures.patch` is the narrow July sponsorship/proof-path repair relative to the already compile-compatible baseline. `run-history.py`, `run-probe.py`, and the probe scripts record the test procedure. Failed setup/compilation attempts are preserved and are not counted as passing test runs.
