# CC stack on 408k-2 and the upstream Mesa core

Prepared locally on 2026-09-21. The prerequisite changes are
[RC integration #75](https://github.com/gwbtc/urbit/pull/75),
[Mesa core restoration #76](https://github.com/gwbtc/urbit/pull/76), and the
companion [Vere 4.6 integration #25](https://github.com/gwbtc/vere/pull/25).
All three prerequisite PRs are merged, verified on 2026-09-23. The merged
Arvo base `ee2ab28289` has the same tree as the validated Mesa restoration
`a872698f59`; the original CC targets have not changed. The CC update merges
therefore preserve the validated production and test source. Only documentation
has changed since those runs.

[Test and CI repair PR #78](https://github.com/gwbtc/urbit/pull/78) owns the
separate fixture work, including the Mesa proof path. These CC updates leave
that work separate and retain the measured six-failure baseline.

## Branch order and update PRs

The rebased source candidates are stacked in this order:

1. `hd/mesa-upstream-core` at `a872698f59`, containing upstream RC
   `5a187feded` through the history-preserving integration merge.
2. `hd/cc-kernel-408k2-core`.
3. `hd/cc-key-rotation-408k2-core`.
4. `hd/cc-snob-only-408k2-core`.

Local `hd/cc-kernel-408k2-update`, `hd/cc-key-rotation-408k2-update`, and
`hd/cc-snob-only-408k2-update` branches provide matching merge heads for PRs
into the existing `hd/cc-kernel`, `hd/cc-key-rotation`, and `hd/cc-snob-only`
branches. Each update head has the same tree as its rebased source candidate
and preserves its existing target as a parent; each later update also includes
the preceding update. The existing shared branches are not rewritten.

The September 23 update sequence uses the actual merged base for kernel,
then the merged kernel target for key rotation, then the merged key-rotation
target for snob. Each merge head retains exact tree equality with its source
candidate. This sequence updates the CC branches and leaves the feature-review
stack (#67, #71, and #72) open. The results below cover the tested snapshots;
future source changes require their own validation.

## Mesa structure and migrations

Mesa is the upstream direct core. It receives `now`, `eny`, and `rof` from
the enclosing adult vane. The outer vane gate and legacy Ames gate remain.
There is no Mesa gate-construction workaround in the current source:

- RC state-33/34 and state-36/37 helpers use `fo:ev:mesa:adult-core` directly.
- Both CC packet helpers use `ma-pact:ma:mesa:ames-core`, retaining the RC
  packet API and Groundwire fief/sponsor fixture corrections.
- Key rotation's pending-Mesa-peer promotion uses `sy:mesa`; it still promotes
  the peer in place and retains the complete pending Mesa agenda.
- Snob's attestation solicitation uses `sy:mesa` and still explicitly copies
  the current event's `ames-state` into the synchronization core before
  `sy-poof`. Removing the gate does not remove this state transfer.

Kernel and key rotation retain the RC's Ames state 37. Snob adds state 38 after
the RC migrations. Its state-33/34 helper still converts temporary old state
with `state-37-to-38`; this is a state-layout adaptation, not a Mesa-shape
workaround. Adult and cached-larval state-37-to-38 regression coverage passed.
No additional state-version bump is needed for the core restoration itself.

## Independently measured test results

Each prepared stage built a fresh solid pill, booted its own disposable fake
ship, and ran its own complete Ames, Jael, and Mesa MTU suites. The current
runs used the prepared Groundwire Vere 4.6 runtime. All kernel source files in
each test desk were checked against its source checkout. No scratch-only
fixture changes were needed for these three candidates.

| Source checkpoint | Ames passed / failed / crashed | Jael passed | Mesa passed |
|---|---:|---:|---:|
| Original shared base `edf656c1fb` (2026-09-03) | 14 / 3 / 3 | Not run | Not run |
| RC + Mesa restoration `a872698f59` | 14 / 3 / 3 | Not run | 18 |
| CC kernel `134e1e8be9` | 41 / 3 / 3 | 11 | 18 |
| CC key rotation `1f77af2e5f` | 81 / 3 / 3 | 25 | 18 |
| CC snob `7286887908` | 89 / 3 / 3 | 25 | 18 |

Hashes identify the tested snapshots before documentation-only follow-ups.
They are preserved under `refs/backup/mesa-core-validation-20260921/`.
The two earlier base runs used Vere 4.4 and fixture-only compatibility
corrections: missing fief fields, the appropriate Mesa packet-helper API, and
the RC Mesa fixture's sponsor scry. Their production kernel source was not
patched. Thus these are independently observed checkpoints, not a claim that
every intervening commit or runtime combination was tested.

The same six failing tests reproduce on every row:

| Test | Result at every measured checkpoint |
|---|---|
| `test-message-flow` | Assertion failure: additional `%nail` effect |
| `test-ames-flow-with-new-rift` | Assertion failure: additional `%nail` effect |
| `test-alien-encounter` | Assertion failure: additional `%nail` effect |
| `test-comet-sends-mesa` | Crash |
| `test-comet-message-flow` | Crash |
| `test-comet-comet-message-flow` | Crash |

All common test names retain their preceding stage's status. No new failing
test appears in the prepared stack. The subsequent
[historical investigation](pluggable-comet-pki-ames-test-history.md) extends
this evidence to the original July 21 fork point (identical kernel/tests to
`edf656c1fb`), the July 14 base before the earlier CC draft, and the initial
Groundwire commit `6f8080c1bc` in October 2025. Its upstream parent passes all
20 tests. October's unmodified suite does not compile; after mechanical API
repairs it reproduces these six failures and two additional older failures.

The historical investigation separates two routing bugs fixed by
`99dd84ddd0` and `2455bec477` in June from sponsorship-fixture and proof-path
expectation drift that persisted afterward. With corrected fixtures, the June
repair sequence gives 18, 19, then 20 passing tests; the July pre-CC kernel
also passes all 20. Those diagnostic test patches have not been added to this
prepared stack. Its suite remains red as recorded above; the investigation
changes the explanation, not these measured candidate results. Historical
Aqua and live-network/upgrade coverage remain separate.

## What changes between CC stages

- **Kernel versus original base:** 27 additional Ames cases and 11 Jael cases
  pass, covering malformed attestations, admission/verdict handling, stale
  notices, snub handling, verifier registration, and fief routing. The 20
  original Ames test outcomes are unchanged.
- **Key rotation versus kernel:** 44 Ames cases are added and four removed
  (net +40); 14 Jael cases are added. All added cases pass. Coverage includes
  current-life keys, point/ring reconciliation, authority checks, bounded
  packet intake, fallback and suspended-domain behavior, rift handling, and
  Mesa path/state preservation. The four removed assertions expected a failed
  verdict to hard-snub or a successful verdict to clear/bypass a hard snub.
  Their replacements test the new policy: reject only the pending candidate
  and retain the operator's hard block.
- **Snob versus key rotation:** 11 Ames cases are added and three removed
  (net +8); two Jael stale-notice cases are replaced by two snob-notice cases.
  All added cases pass. This changes destructive stale demotion into soft
  blocking with retained points/flows, tests proof re-verification and retry
  stopping, and adds the adult/cached-larval RC migration regression. A full
  verdict clears the soft block while retaining any hard snub.

The removed cases express deliberately superseded semantics; they are not
newly failing cases hidden from the result table. Test-name and outcome deltas,
complete logs, source hashes, and range-diffs are recorded in the local
`output/cc-mesa-core-20260921/` rebase report.

## Separate limitations and historical results

The September 7/9 lifecycle and split checkpoints record successful Aqua
life-2 and snob scenarios on their then-current code. Those multiship scenarios
were not rerun for this preparation, so their success is historical evidence,
not a fresh result for these candidate tips.

The historical `ph/cc/breach` setup failures are a different issue from the six
Ames unit failures. Their generic comet-udiff fixture conflicts with the newer
Jael authority checks; both transports failed before the breach was exercised.
That failure has not been reproduced on the original base and must not be
described as part of the six-failure base baseline.

Populated state-33/36 migration fixtures, live own-rift quiescence, Bitcoin
regtest, and upgrades of deployed comets remain unverified here. Earlier
stock-pill-to-fork OTA attempts failed at Ames loading with `nest-fail`; this
preparation used fresh pills and does not establish that upgrade path.
