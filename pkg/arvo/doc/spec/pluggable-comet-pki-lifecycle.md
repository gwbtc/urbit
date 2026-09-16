# Pluggable Comet PKI: Rotation Lifecycle and Consistency

Status: **review companion to the kernel contract**. This document expands the
ordering and failure semantics of suite-C life-key rotation. The normative data
layout and kernel API remain in `pluggable-comet-pki.md`.

PR-split note: this document describes the composed `hd/cc-key-rotation` plus
`hd/cc-snob-only` result, including the latter's withdrawal/re-attestation
mechanics. It is not a claim that `%snob` exists in the prerequisite alone.
See `pluggable-comet-pki-split.md` for scope and merge order.

The central distinction is between an identity's immutable name and the
distributed views of its current networking key. A rotation is not one atomic
global event. It is a sequence of independently durable facts which converge:

1. an external authority records a new public point;
2. the local domain agent reports that point to Jael;
3. Jael has both that authorized point and its matching private ring;
4. Ames activates the key and announces it;
5. each peer independently verifies the announcement and advances its view.

For a routine life rotation whose rift is unchanged, the kernel makes the
public/private intermediate states fail closed with respect to key use: no
unauthorized private ring becomes active. It does not pretend that all five
locations change simultaneously. Verifier policy freshness and live advancement
of our own rift have separate, explicitly recorded gaps.

## 1. The state at each boundary

For a comet at life `N`, write:

- `P[N]` for the externally authorized Jael point, including its suite-C pass;
- `R[N]` for the matching private ring;
- `J.pub` for Jael's latest accepted public point;
- `J.priv` for Jael's cached rings and active private life;
- `A.self` for Ames's active local ring, pass, and life;
- `A.peer[X]` for a peer Ames's currently accepted point for ship `X`.

These are deliberately not one piece of state. The external authority never
receives private key material. Jael can stage a private ring before its public
authorization exists, and can store a public authorization before the private
ring is locally available. Ames changes its live key only after Jael has joined
the two exactly.

Remote peers have the same separation. An attestation proves possession of the
`cry` claimed in its pass; the domain verdict proves that the pass is the
authority's current `P[N]`. Neither fact substitutes for the other.

## 2. Invariants

The rotation machinery maintains these invariants:

1. **The name is permanent.** `@p == fig(pass)` at every life. For suite C,
   `fig` depends on immutable `ugn` and `dat`, never on the live `cry`.
2. **One life names one live key.** A changed `cry` requires a strictly greater
   life. A same-life verdict may update evidence, route, sponsor, or rift, but
   must retain `cry`.
3. **Life zero is not an authorization.** A suite-C verdict must name a current
   life greater than zero.
4. **Public authority precedes local use.** Jael never activates `R[N]` unless
   its exact suite and pass equal the current key entry in `P[N]`.
5. **A private ring cannot rename the running comet.** Its derived pass must
   fingerprint to the booted `@p`.
6. **Counters do not roll back.** Accepted verdicts cannot decrease life or
   rift. Ames also ignores a private-key gift below its active life.
7. **The domain is immutable.** The domain decoded from `dat` must equal the
   answering registered agent. A verdict cannot move an identity between
   domains.
8. **Sponsorship remains routable.** A verdict may omit the sponsor, which uses
   the comet's ordinary star fallback, or explicitly name a star or comet. It
   cannot install another ship class merely because userspace supplied the
   whole point.
9. **Generic point feeds cannot update comets.** Both local Gall `udiff`s and
   remote Jael snapshots and updates exclude comets. Boot tasks install our
   initial point, and migration retains stored points; subsequent suite-C
   comet point updates require a validated verdict from the committed domain.
10. **Public notification precedes private activation.** When the final missing
   half arrives, Jael queues the public-point gift before the private-key gift.
   Ames therefore knows the authorized point before it changes its signer and
   agreement key.
11. **A routine life rotation is not a breach.** Ames retains flows and
    rederives their symmetric keys and Mesa paths. A remote peer's rift increase
    is a separate, destructive transition and uses the ordinary breach machinery.
    The equivalent live-own-rift transition remains a target contract.
12. **Evidence refresh is not key rotation.** A same-life suite-C pass whose
    derived live public key is unchanged updates metadata without rederiving
    Mesa paths or discarding partial proof/page state.

Implementation status: invariant 11 is enforced for a remote peer's
higher-rift whole point, but not yet for a live increase of our own rift. The
current Ames scalar update cannot by itself keep the node quiescent throughout
the supported public-point-before-private-ring interval. The required pending
state, wipe/activation boundary, and tests are specified in section 12 of the
loose-ends annex; the partial one-event wipe prototyped during this audit was
removed rather than presented as a complete continuity guarantee.

## 3. Recommended ordering: ring first, authority second

The least disruptive operator sequence is:

1. Generate `R[N+1]` while retaining the same `ugn`, `dat`, and therefore
   `@p`. Its derived pass carries a fresh `cry` and the final `xtr` which will
   appear in the authorized point.
2. Send Jael `[%rekey N+1 R[N+1]]`. Jael stores it as a pending future ring.
   It does not notify Ames and does not sign or derive with it.
3. Publish `P[N+1]` through the external system.
4. After whatever finality policy the domain uses, its agent publishes a
   positive verdict for `P[N+1]`.
5. Jael validates and stores the point, queues the public gift, matches the
   staged ring, advances its private life, and queues the private gift.
6. Ames receives the public point, then activates `R[N+1]`, rederives every
   peer key/path, and sends a fresh signed self-attestation to every known
   legacy and Mesa peer.
7. Each peer checks the immutable name and current-key signature, asks its own
   registered domain agent to verify `P[N+1]`, and changes `A.peer[self]` only
   after `%full`.

The useful intermediate state is:

```text
external: P[N]    Jael public: P[N]    Jael pending: R[N+1]
Ames self: N      peers: N
```

Nothing on the network changes until the authority moves. Once the verdict
arrives, local activation can follow without waiting for another secret-bearing
operation. This minimizes the interval in which the chain says `N+1` while the
ship can only speak as `N`.

“Matching” above means the complete pass, including `xtr`, not merely the same
seed or `cry`. Current companion tooling stages a pre-finalization ring and then
grows the custody log during publication; it must re-stage the final xtr-bearing
ring or change that ordering before it satisfies this contract. Jael should not
weaken exact agreement to compensate for userspace staging the wrong artifact.

## 4. Supported reverse ordering: authority first, ring second

For a routine rotation whose rift is unchanged, point-first is safe with respect
to key authorization, but it can make the ship temporarily unavailable:

1. The domain reports `P[N+1]`.
2. Jael stores and publishes the public point, but cannot activate it without
   `R[N+1]`.
3. Ames continues signing and deriving at `N`.
4. Peers whose domain agents have observed the authority change may withdraw
   their old vouch, soft-block the ship, and solicit a fresh attestation. The
   ship can only answer with `N`, which should not be re-authorized as current.
5. When `%rekey` supplies the exact `R[N+1]`, Jael activates it and the normal
   announcement sequence begins.

This is a fail-closed key-availability gap, not an identity split: the kernel
does not use the unauthorized secret, and peers do not accept the obsolete
signer as the new point. Operational tooling should therefore stage and
acknowledge the ring before publishing the point whenever the external protocol
permits it. A point which also advances our own rift is outside this guarantee;
its required quiescent transition remains deferred.

## 5. Wire manifestation and peer convergence

`+sy-priv` announces a newly activated comet life with the ordinary plaintext
open packet even when application traffic with a peer uses Mesa. A narrow Mesa
dispatch bridge sends that packet—and a known Mesa peer's legacy `%keys`
request during recovery—through the common Ames control-packet handlers without
migrating the peer back to the legacy core. An open packet for a pending Mesa
alien takes the same verification path and leaves that alien state in place
while its verdict is pending.

Legacy first contact and `%snob` recovery have a separate bootstrap coordinate.
The `%keys` request is unauthenticated and carries only a wrapping four-bit life
tick, so it never establishes the requester's full life. Every direct `%keys`
response therefore uses fixed `rcvr-life == 1`, including when the requester is
already known: the responder's stored life can be stale after simultaneous
rotation. The legacy receiver permits either its exact current life or this
sentinel, but only as a coordinate match: the response must still pass the
normal bounded-shape, signature, immutable-name, domain, and sponsor validation
before it changes peer state. Its signed `sndr-life` and pass state the
responder's actual life and key and remain authoritative. Proactive
announcements and the reciprocal attestation emitted after a first-contact
promotion continue to use the peer's exact stored life. Thus losing crossed
proactive announcements can stall traffic, but one-shot `%keys` solicitations
recover both stale views without inferring a life from either request header.

This tolerance is confined to legacy Ames. Mesa keeps the open packet's
receiver life exact. Its outer `%publ 1` and `/pawn/proof/1/...` fields below
are fixed publisher-discovery coordinates, not an equivalent receiver-life
sentinel.

Mesa discovery and `%snob` recovery also use the established public proof
endpoint. Its outer `%publ 1` and `/pawn/proof/1/...` coordinates are fixed
bootstrap coordinates supplied by the requester; they are not a claim that the
publisher is at life 1. Only this proof endpoint is exempt from ordinary Mesa
public-namespace life matching. The returned page contains an open packet with
the publisher's actual life and pass and is signed by that pass's current key.
The receiver treats the signed body as authoritative.

Every recognized proof page or proof poke takes the attestation-verification
path, even if an earlier Jael subscription has already promoted the transport
peer to `%known`. This closes a transport-classification race involving one
in-flight proof: the subscription response could change `%alien` to `%known`
before that same page arrived, causing it to be mistaken for ordinary namespace
data. It is not a queue for competing rotations and adds no proof job IDs.

The legacy `1` sentinel and this proof-routing tolerance are local control-flow
rules for incomplete or changing local knowledge, not statements that rapid,
competing attestations are normal network-actor behavior. Neither describes a
second actor-visible life or licenses a peer to emit competing attestations. An
honest peer should publish one current authorized life and single-shot re-attest
it. If distinct candidate lives nevertheless overlap, the kernel does not order
them with a proof queue or correlate them with job IDs: each candidate is
checked independently, and the life/rift and same-life-key invariants prevent a
later verdict from rolling back or replacing an accepted same-life key. Whether
repeated conflicting candidates should additionally mark the peer stale or
misbehaving and place it under `%snob` until it stabilizes is a separate
protocol-policy question, recorded in the loose-ends annex rather than hidden
in Mesa dispatch state.

On `%full`, a peer switches directly from its old current key to the new one.
There is no dual-key grace period. Packets produced during asymmetric rollout
may be dropped until both ends agree, but established flow state is retained
and its cryptographic paths are rederived once the point advances.

## 6. Withdrawn vouches and recovery

When a domain can no longer vouch for the stored point, it sends
`%snob-notice`. Jael retains the point. Ames retains peer and flow state, adds a
soft block, and solicits a current attestation every 30 seconds. Only
self-attestations and requests for our attestation pass the soft gate.

The retry stops only after a new `%full` lifts the soft block. A failed candidate
does not hard-snub the claimed `@p`: an attacker can copy immutable suite-C name
material, attach an arbitrary live key, and elicit a legitimate negative
verdict. `%fail` therefore discards only pending alien state.

Because `%full` carries no verifier generation, Ames cannot tell a fresh answer
from a successful job which began before the withdrawal. The domain agent must
reject a completion older than its current snob/chain generation; otherwise a
delayed old `%full` can incorrectly lift the block. This is a required companion
freshness invariant, not a request for a proof-job queue in the kernel.

This recovery path is part of eventual convergence. The kernel intentionally
does not treat an unauthenticated four-bit Ames life tick as proof that a key
changed. Domain implementations must monitor whatever external facts invalidate
their accepted points and issue `%snob-notice` promptly. The optional design of
a separate authenticated resynchronization signal is recorded in the loose-ends
annex.

## 7. Failure, replay, and crash cases

| Case | Current result or required response | Consistency consequence |
|---|---|---|
| `R[N+1]` arrives before `P[N+1]` | Cache only; no gift to Ames | Safe staged state; resend may be needed if a different ring overwrites the pending slot |
| `P[N+1]` arrives before `R[N+1]` | Store/publish public point; keep Ames at `N` | Safe but potentially unavailable until the ring arrives |
| Ring does not reproduce the authorized pass | Keep it inactive | No signing or ECDH under an unauthorized key |
| Same-life verdict changes `cry` | Reject verdict | Prevents two live keys for one life and peer divergence |
| Lower life or lower rift verdict | Reject verdict | Delayed/replayed authority facts cannot roll state back |
| Same-life verdict keeps `cry` | Accept evidence/route/rift refresh | No key rotation; for a remote peer, a rift increase still causes ordinary breach behavior; live own-rift is deferred |
| Two distinct same-life keys receive positive verdicts | First accepted key wins locally; the other is rejected | Different observers can diverge only if the trusted domain equivocates; recovery requires a higher life |
| Same-life, same-key verdicts arrive in different orders | The last accepted whole point supplies mutable evidence and metadata | Signing/DH key and monotone counters remain safe; mutable views can differ until the domain publishes one stable answer |
| Stale `%anew` response arrives after rekey | Reject unless domain, `ugn`, `dat`, name, and active public key still match | Mutable evidence cannot restore an old live key |
| Proactive announcement is lost or peer is offline | Peer remains at the old key | Domain withdrawal plus `%snob` solicitation supplies retry; there is no tick-triggered retry |
| Domain is unregistered at receiver | Accept only life 1 with `ugn == cry` | Compatibility ends at first rotation, by design |
| Domain is registered but suspended or its scry fails | Drop | Suspension never acquires unregistered fallback privilege |
| Verdict supplies an explicit non-star/non-comet sponsor | Reject verdict | Userspace cannot install an unroutable sponsorship relationship |
| Chain reorganization invalidates the accepted point | Domain should issue `%snob-notice` | Recovery may reauthorize the same key/evidence or move to a higher life; a different key cannot replace the same life |
| Old verifier job completes after `%snob-notice` | Domain must suppress the stale `%full` | Ames has no generation with which to identify it; emitting it would lift the soft block |
| Verifier is running but not caught up | Current kernel can mark the domain live; target behavior keeps it suspended | Unimplemented kernel-and-companion readiness chapter; process liveness alone must not re-admit retained old keys |
| A remote peer's rift increases | Breach before installing the new point | That peer's flow state is wiped; this is not routine rotation |
| Our own rift increases live | Enter a quiescent pending transition before activation | Target contract; current implementation gap is recorded in the loose-ends annex |
| Same-life `xtr` changes with the same live key | Update the pass without invoking rekey | Partial Mesa pages, paths, flows, and the shared key remain intact |
| Crash between separate input events | Replay each event deterministically | Ring-only and point-only states are explicit safe states, not torn writes |

An Arvo event is atomic, including its durable state mutation and queued moves.
The public point and private ring normally arrive as separate events, so the
intermediate states above are intentional. If a crash occurs after an event is
logged but before its moves complete, replay regenerates those moves from the
same state transition.

## 8. Local and global consistency model

The model is monotone but eventually consistent:

- Jael's accepted life and rift never decrease.
- Ames's active local life changes only after exact public/private agreement.
- Each remote Jael independently authorizes the announced pass against its own
  domain view and confirmation policy.
- Consequently, different peers may temporarily hold different lives for the
  same immutable `@p`. This is expected during propagation; accepting two keys
  for the same life is not.
- No local queue establishes a global order among candidate proofs. Arvo applies
  each verdict event serially; monotonic checks make higher-life convergence
  order-independent, except that a trusted domain which positively equivocates
  between two keys at one previously unseen life can cause different observers
  to keep different first answers. That is an authority failure, not an honest
  rotation state.
- A peer that has advanced cannot communicate under the old shared key. A peer
  that has not advanced cannot communicate under the new one. Convergence of
  attestations and verdicts restores communication without changing identity or
  discarding flows.

The domain agent is the policy trust boundary. The kernel proves possession,
name binding, domain binding, structural safety, and monotonicity; it cannot
prove the external ownership claim itself. A compromised registered domain
agent can vouch for a false current point inside its own domain. `%gost` freezes
that authority, and `%bane` is the explicit destructive response.

## 9. Operator-visible checkpoints

Before considering a rotation complete, operator tooling should distinguish at
least these observations:

1. the next ring was accepted for staging, while the active life stayed `N`;
2. the authority published `P[N+1]` at the desired confirmation depth;
3. Jael accepted the point and advanced its active private life;
4. Ames activated `N+1` and emitted re-attestations;
5. important peers have accepted `N+1`, or their domain verifiers are still
   pending/retrying.

A single “rotation submitted” indicator collapses materially different failure
modes. Companion userspace should expose these phases separately and make the
ring-first sequence the default. Exact UI, confirmation policy, peer-progress
telemetry, and recovery controls belong to the userspace chapter; the kernel
mechanics above are the boundary that UI can rely on.

## 10. Cross-layer gates before daily-driver use

The implemented kernel mechanics do not by themselves make the current system
safe to dogfood. Four explicit cross-layer gates remain:

1. **Companion:** stage the final xtr-bearing ring that exactly reproduces the
   published pass;
2. **Companion:** discard verifier completions older than the current
   withdrawal/chain generation;
3. **Kernel and companion, not yet implemented:** keep a domain suspended until
   its agent is actually synced and trigger revalidation when it becomes ready,
   update every registered domain when a shared desk changes state, and include
   a policy for life-1 peers previously admitted through unregistered fallback;
   and
4. **Companion:** structurally bound/decode peer-controlled `xtr` without raw
   unsafe `cue`.

There is also a format-level limit: an ever-growing custody log exceeds Mesa's
single-fragment proof envelope after only a small number of realistic rotations,
and eventually exceeds legacy Ames's signed-open bound. The measured thresholds
and design alternatives are recorded in the loose-ends annex. That issue must be
settled before “permanent” means indefinitely rotatable, even if the first few
dogfood rotations work mechanically.

## 11. Kernel chapter review checkpoint (2026-09-07)

This checkpoint describes the uncommitted work on `hd/cc-snob`, based on
`79f649bea8`. It is a review boundary, not an upstream-readiness or daily-driver
signoff. The companion userspace has not been changed in this chapter, and the
internal `%snob` / other-kernel-fixes PR split has not yet been made.

The original signing diagnosis needs a precise qualification: `%rekey` already
replaced Ames's whole private crypto core, including both `sgn` and `cry`.
The old suite-C key construction nevertheless derived `sgn` from the immutable
name seed while deriving `cry` from separate messaging entropy. Replacing the
core could therefore rotate agreement material while preserving the signer if
the name seed was retained. The repair separates immutable public name material
from the current private life key, and derives both live signing and agreement
from the latter. This is a key-layout/derivation defect, not an omitted `sgn`
assignment in Ames. Exact Jael point/ring reconciliation and userspace actually
delivering the matching `%rekey` are separate necessary parts of activation.

After the interrupted application sessions, no test-ship or compiler process
survived. Verification resumed from the preserved disposable pier using the
local aarch64 macOS Vere build. The latest behavior-changing Jael authority
guard was compiled into base revision 45 and the rebuilt full pill; subsequent
source changes were comments only.

| Check | Observed result | Scope / qualification |
|---|---|---|
| `-ph-load-pill` | `%suc` | Full kernel pill builds with the latest Jael guard |
| `-test %/tests/sys/vane/jael` | `ok=%.y` | Full suite, including remote snapshot/diff rejection and explicitly selected remote-source replacement/breach rejection for comets |
| `-test %/tests/sys/vane/ames` | `ok=%.n` | New focused cases passed; six inherited failures remain, listed below |
| `-ph/cc/attestation-life-2 %ames` and `%mesa` | Passed | Domain-verdict point-first life-2 activation, private life stays 1 until matching rekey, peer acceptance and traffic |
| `-ph/cc/snob-reattest %ames` and `%mesa` | Passed | Soft block, re-verification, retained flows, and resumed bidirectional traffic; Mesa's observer was corrected to read Mesa flow state |
| `-ph/cc/breach %ames` and `%mesa` | Failed during setup | Missing remote Jael point, before traffic or breach: old fixtures use generic comet `udiff` injection now rejected by authority checks; these runs establish no breach result |
| `git diff --check` | Passed | Whitespace check, not behavioral verification |

The Ames full-suite run used revision 40, before the Jael-only final guard;
there have been no subsequent Ames behavior edits. The six failures were also
reproduced against the comparison baseline during the audit:

- extra `%nail` effects in `test-message-flow`,
  `test-ames-flow-with-new-rift`, and `test-alien-encounter`;
- crashes in `test-comet-sends-mesa`, `test-comet-message-flow`, and
  `test-comet-comet-message-flow`.

The full Ames suite is therefore still red. Neither the Aqua successes nor the
baseline comparison substitutes for repairing that coverage. The obsolete
breach scenarios also need fixture migration, and even once repaired their
fresh-pier restart model will not test live own-rift quiescence. See annex §5.

The next kernel questions for mutual review are live own-rift quiescence and
verifier readiness (annex §§12 and 8). The promotion-routing fixes in §5 and
annex §6 add no candidate queue or job IDs. The separate multilateral Bitcoin
regtest chapter remains necessary to verify the actual on-chain and userspace
lifecycle, rather than just these kernel mechanics.

## 12. Open signing-design review: untweaked or tweaked life 1

The current rule, inherited from Fable's `79f649bea8` rather than introduced
during this audit, makes the untweaked genesis key the live life-1 signer and
agreement key. Its justification is uniformity: at every life, `cry == sgn`
is derived directly from the current private seed, while `ugn/dat` independently
determine the tweaked name commitment. The name tweak never participates in
live-key derivation. This is a simplicity argument, not a cryptographic
necessity or a demonstrated security advantage over a tweaked life-1 signer.

An alternative can use the tweaked genesis key at life 1 and independent fresh
keys afterward, retaining the same permanent naming relationship and requiring
no genesis secret after rotation. Both public and private decoding must agree
on the genesis-specific rule. `cric` currently receives a pass/ring, not a life
number, so such a design must identify the genesis case from its key relation
or change the interface/encoding. This decision is deliberately left for
review after the PR split; no signing behavior changes are part of the split.

The compatibility qualification matters: the passing fallback tests use the
updated kernel with no registered domain agent. They do not prove compatibility
with unchanged `hd/cc-kernel` receivers. That old suite-C parser derives the
verification signer from the tweaked genesis point, so it rejects the current
untweaked life-1 signature. Retaining the tweaked signer could preserve that
part of compatibility, but the old missing unknown-domain fallback is another,
separate admission obstacle.

Similarly, signature invalidation is relative to an accepted current key:
the cross-life tests prove an old-key signature fails under the new key; they
do not erase its mathematical validity under the old public key. A receiver
which has accepted the new point uses the new key without a dual-key grace
period. A stale receiver or an unregistered fallback receiver cannot learn
external revocation solely from that old signature. The multilateral
revocation/replay tests and verifier-freshness work remain outstanding.
