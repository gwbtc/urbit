# Internal kernel PR split

This split preserves the reviewed combined kernel chapter without making new
signing, readiness, or own-rift design changes.

## Branches and merge order

1. `hd/cc-key-rotation` targets `hd/cc-kernel`: suite-C name/live-key separation,
   Jael point/ring reconciliation and authority checks, life/rift fixes,
   current-key re-attestation, bounded intake, fallback, and their tests.
2. `hd/cc-snob-only` initially targets `hd/cc-key-rotation`: soft blocking,
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

The composed source/test tree must match the checkpoint, with only the newer
base CI file and explicit documentation additions excepted. Separate
prerequisite compilation/tests are required because combined-tree equivalence
alone does not prove that the extracted first PR stands on its own.

The September 7 verification results and known failures remain recorded in
the lifecycle checkpoint. No end-to-end Bitcoin regtest or live-own-rift
success should be inferred from the PR split. The untweaked-versus-tweaked
life-1 signing question remains open in lifecycle §12.

## Split verification (2026-09-09)

| Check | Result |
|---|---|
| Repair-only full pill | Passed, `%suc`; Ames `0v1j.b76av`, Jael `0vb.dq2vo` |
| Fresh ship booted from repair pill | Passed |
| Repair Jael suite on that ship | 25 passed, `ok=%.y` |
| Repair Ames suite on that ship | 81 passed, same six documented baseline failures, `ok=%.n` |
| Repair-pill Aqua life-2 over legacy Ames | Passed through point-first publication, exact rekey, peer acceptance and final hi |
| Repair-pill Aqua life-2 over Mesa | Inconclusive reruns; see below, not counted as a pass |
| Composed source/test equivalence | Matches the preserved checkpoint byte-for-byte |
| Diff whitespace checks | Passed |

The already-upgraded test host cannot be downgraded from Ames state 33 to
the prerequisite's state 32, nor can its global Lull types compile the old
`%stale` interface. Accordingly, the prerequisite was built from an isolated
source desk and its unit tests run on a fresh ship booted from that pill.
No backward state migration or compatibility shim was added for testing.

The reused-host Mesa run eventually completed initial contact and reached an
authorized/active life 2, but did not produce the final hi acknowledgement
before it was stopped. A separate fresh-host rerun also waited at first
contact after a positive verifier response. Neither is an assertion failure
demonstrating a signing defect, nor is either a completed passing scenario.
The prior composed-kernel Mesa success does not substitute for completing
this prerequisite-only check. No cause or misplaced split dependency was
established by source review; keep this as an explicit review/validation gap.

One testing-harness issue found during that inspection is that `ph/io`'s
`stop-threads` is a no-op, so repeated scenarios can retain Aqua worker
threads. That is a separate cleanup concern, not an established explanation
for the delay (including the fresh-host observation). The testing chapter
should give scenarios bounded completion and reliable worker cleanup.
