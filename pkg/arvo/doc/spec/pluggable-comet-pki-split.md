# Internal kernel PR split

This split preserves the reviewed combined kernel chapter without making new
signing, readiness, or own-rift design changes.

The [September 21 RC/Mesa-core preparation](pluggable-comet-pki-rebase-408k2.md)
supersedes the old base and state-version assumptions for current development.
Its local update branches will target the existing CC branches after the RC
and Mesa prerequisite PRs merge. No follow-up PR is open yet. That preparation
preserves the feature-review dependencies below; it does not itself merge the
feature PRs.

## Branches and merge order

1. [PR #71](https://github.com/gwbtc/urbit/pull/71), `hd/cc-key-rotation`, targets `hd/cc-kernel`: suite-C name/live-key separation,
   Jael point/ring reconciliation and authority checks, life/rift fixes,
   current-key re-attestation, bounded intake, fallback, and their tests.
2. [PR #72](https://github.com/gwbtc/urbit/pull/72), `hd/cc-snob-only`, initially targets `hd/cc-key-rotation`: soft blocking,
   attestation solicitation/retry, domain withdrawal notices retaining points,
   and the corresponding unit/Aqua coverage.

The second PR is stacked because it uses the first PR's proof-routing and
flow-preservation fixes. After the repair PR merges, retarget the snob PR to
`hd/cc-kernel`; do not merge the snob branch into the repair branch merely to
finish the stack. Both ultimately feed the existing `hd/cc-kernel` PR (#67)
to `gw/next/kelvin/408`, followed by the combined upstream Urbit PR.

The lifecycle, contract, and annex documents describe the composed reviewed
result. The repair prerequisite alone retains the inherited `%stale` notice
path; it does not supply the documented `%snob` withdrawal semantics until
the second PR is applied. This intermediate branch is for isolated review,
not deployment or a daily-driver signoff.

## Preservation and verification

The original dirty `hd/cc-snob` checkout is retained unchanged. Its complete
reviewed contents were captured in local checkpoint
`5e5e7ff1d348ac4ab559f9513e55bba882233f77` (tree
`3545d9053eb25f32faadf54ee1b1308513805862`) before extraction. The checkpoint
includes Fable's original commit and all subsequent chapter repairs/tests.

The remote `hd/cc-kernel` also advanced by a CI-only credential-reference
change, `284820ea2d`, after the reviewed local base `6298aff62a`. The split
must preserve that newer base change; it is not part of either kernel PR.

At the original extraction, the composed source/test tree was required to match
the checkpoint, with only the newer base CI file and explicit documentation
additions excepted. The current RC rebase additionally incorporates upstream
migrations, the restored direct Mesa core, and the state-38 snob adaptation;
it is no longer byte-identical to that historical checkpoint. Each current
stage was separately compiled, freshly booted, and tested, as recorded in the
rebase evidence. Combined-tree equivalence alone does not prove that the
extracted first PR stands on its own.

The September 7 verification results and known failures remain recorded in
the lifecycle checkpoint. No end-to-end Bitcoin regtest or live-own-rift
success should be inferred from the PR split. The untweaked-versus-tweaked
life-1 signing question remains open in lifecycle §12.

## Split verification (2026-09-09)

These are the original split results. The current key-rotation candidate again
passes 81 Ames cases and all 25 Jael cases, plus all 18 RC Mesa cases. Its same
six Ames failures are independently confirmed at the original July 21 fork
point (kernel/tests identical to `edf656c1fb`) and the July 14 base before the
earlier CC draft. The [history investigation](pluggable-comet-pki-ames-test-history.md)
traces the first break to October 2025 and distinguishes June production routing
repairs from remaining fixture drift. Its test-only corrections make the July
suite green; they are diagnostic patches, not part of these candidate results.
The Aqua results below were not rerun as part of the RC rebase.

| Check | Result |
|---|---|
| Repair-only full pill | Passed, `%suc`; Ames `0v1j.b76av`, Jael `0vb.dq2vo` |
| Fresh ship booted from repair pill | Passed |
| Repair Jael suite on that ship | 25 passed, `ok=%.y` |
| Repair Ames suite on that ship | 81 passed, same six documented baseline failures, `ok=%.n` |
| Repair-pill Aqua life-2 over legacy Ames | Passed through point-first publication, exact rekey, peer acceptance and final hi |
| Repair-pill Aqua life-2 over Mesa | Passed on a fresh host: final hi acknowledged and peer at life 2; completion was delayed, see below |
| Composed source/test equivalence | Matches the preserved checkpoint byte-for-byte |
| Diff whitespace checks | Passed |

At that historical checkpoint, the already-upgraded test host could not be
downgraded from Ames state 33 to the prerequisite's state 32, nor could its global Lull types compile the old
`%stale` interface. Accordingly, the prerequisite was built from an isolated
source desk and its unit tests run on a fresh ship booted from that pill.
No backward state migration or compatibility shim was added for testing.
The current RC uses state 37 in kernel/key rotation and state 38 in snob;
the September 21 runs likewise used a fresh pill and ship for each stage.

The reused-host Mesa run eventually completed initial contact and reached an
authorized/active life 2, but did not produce the final hi acknowledgement
before it was stopped; that run is inconclusive. The separate fresh-host
rerun also paused at first contact and after the life-2 verdict, then completed
without intervention: final hi acknowledged, peer point at life 2, `done`,
and result `0`. This is a passing prerequisite-only scenario, not an inference
from the prior composed-kernel run. No cause of the delay or misplaced split
dependency was established by source review; completion latency still merits
testing-harness investigation.

One testing-harness issue found during that inspection is that `ph/io`'s
`stop-threads` is a no-op, so repeated scenarios can retain Aqua worker
threads. That is a separate cleanup concern, not an established explanation
for the delay (including the successful fresh-host run). The testing chapter
should give scenarios bounded completion and reliable worker cleanup.
