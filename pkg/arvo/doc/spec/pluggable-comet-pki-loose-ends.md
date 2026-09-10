# Pluggable Comet PKI: Loose Ends Annex

Status: **non-normative follow-up record**. This annex collects deferred
proposals, current limitations, companion gates, and testing debt discovered
during the suite-C life-key and `%snob` work. Sections 1 through 3 preserve
policy/hardening prototypes deliberately removed from the current bite; later
sections identify implemented mechanics whose remaining edge conditions or
cross-layer dependencies need separate work. Where behavior is current or was
prototyped and removed, its section says so explicitly.

## 1. Terminal negative verdict for a previously accepted peer

The prototype treated a negative `%verdict` for a ship already present in
the domain's vouched-for set as a terminal revocation. Jael removed the
ship from that set, deleted its stored point, emitted the ordinary
`%public-keys %breach` effect, and still gave Ames `%sybl %fail` so that it
would snub the identity.

This is deferred because a failed candidate attestation does not, by
itself, prove that the previously accepted point is invalid. The verdict
protocol currently carries no request identity or generation with which
to distinguish a current rejection from a delayed answer. Applying a
terminal breach could therefore destroy healthy flows in response to a
stale or merely malformed replacement. The present contract keeps these
meanings separate:

- `%fail` rejects the candidate attestation and drops only pending alien
  state; it cannot hard-snub the claimed identity, because suite C lets an
  attacker copy the immutable name fields and present an arbitrary signer
  that the domain will correctly reject;
- `%snob-notice` withdraws a vouch non-terminally, retains the point and
  flows, and asks the peer to re-attest;
- `%bane` destructively removes a compromised domain and breaches all of
  the points it supplied.

A follow-up must specify the missing causal distinction, including
whether verdicts need request identifiers, expected life/rift, or another
freshness proof. Tests must cover delayed negative answers, a failed
replacement for an otherwise valid known peer, and a genuinely revoked
identity before any automatic breach is restored.

## 2. Rekey recovery inferred from Ames life-tick mismatch

The prototype used encrypted-packet header tick mismatches to initiate
key resynchronization for suite-C comets. A sender-life mismatch caused us
to solicit the peer's self-attestation; a receiver-life mismatch caused
us to re-send our own attestation. A shared `/poof` timer rate-limited the
attempts.

This is not needed for the basic rotation contract: `+sy-priv` already
re-attests proactively after a valid local rekey, and `%snob` explicitly
solicits a peer when its domain withdraws a vouch. A tick is only life
modulo 16, and a packet that cannot be decrypted has not authenticated
the claimed sender. Treating that header as a recovery signal adds
spoofable work and ambiguous behavior around tick wrap, stale packets,
forwarding, and simultaneous rotation.

A follow-up should first define an authenticated or otherwise bounded
resynchronization protocol. It needs separate retry state for solicitations
and announcements, clear behavior across modulo-16 wrap, and tests for
spoofed headers, replay, simultaneous rekeys, offline peers, both Ames
transports, and recovery after the proactive attestation was lost.

## 3. Opportunistic `%anew` when a known peer requests our keys

The prototype treated a `%keys` request from a peer we already knew as a
hint that our mutable suite-C evidence (`xtr`) was stale. Before answering,
Ames also asked Jael to invoke the local domain agent's `%anew` flow.

This is deferred because `%keys` means only "send me your current
self-attestation". It does not authenticate a claim that the evidence is
stale, and it is not a sound trigger for potentially expensive userspace
or chain work. It also races with rekey: a response prepared for life N
may arrive after life N+1 has become active. The kernel now rejects an
`%anew` result whose immutable identity fields or live key do not match
the currently active suite-C state, but that safety check does not make an
unsolicited refresh policy desirable.

A follow-up must define who may request refresh, how requests are
authenticated and rate-limited, and whether the domain agent can provide
an explicit staleness signal. Tests must cover request floods, duplicate
requests, a delayed life-N response after an N+1 rekey, agent suspension,
and restart/persistence of the refreshed `xtr`.

## 4. Provenance for overlapping block policy

`%gost`, `%ghul`, and `%bane` edit Ames's existing hard `snub` policy rather
than replacing it. This preserves unrelated manual entries, but the set stores
no reason or owner for an entry. If a ship was already blocked manually when a
domain suspends it, the later `%ghul` deletion cannot distinguish the two
reasons and may remove the manual block. The analogous overlap exists in
`%allow` mode.

The soft `snob` list has the same limitation. A `%full` applies the inverse of
the verifier's earlier `%snob` edit, but can also remove an overlapping manual
soft block because both reasons occupy the same set entry.

The current change does not add policy provenance to Ames state. A follow-up
should decide whether blocks need reference-counted owners, separate
manual/domain layers combined at the packet gate, or a more general policy
representation. Tests must cover overlapping manual and domain edits on both
lists and in both `%deny` and `%allow` modes, repeated suspension/revival,
multiple domains, and state migration. Until then, the contract promises only
that domain edits do not replace unrelated list entries.

## 5. Testing rectification: authoritative multilateral lifecycle coverage

The focused vane tests and current two-pier Aqua scenarios exercise kernel
mechanics, malformed intake, re-attestation, and life transitions. They do not
establish that the complete ownership lifecycle works through the actual
external authority. In particular, the project did not catch a broken live-key
rotation path because it lacks end-to-end, multilateral tests driven by a
Bitcoin regtest node.

This deserves its own review and implementation chapter. The harness should run
at least an owner/controller, a rotating comet, more than one independently
observing peer, each relevant userspace domain agent, and a Bitcoin regtest
node. It should observe—not inject past—the following boundaries:

- generation and local staging of the next private ring;
- publication, mining, confirmation, and optional reorganization of the new
  on-chain public point;
- independent domain-agent observation and Jael verdict delivery;
- Jael public/private reconciliation and Ames signer/DH activation;
- proactive legacy and Mesa re-attestation to peers at different sync states;
- loss, restart, delayed verdicts, withdrawn vouches, and eventual recovery;
- agreement that the immutable `@p` survives while all live networking key
  material changes.

The harness should expose assertions at each boundary rather than reducing the
scenario to one final connectivity check. It should also retain adversarial unit
tests for malformed nouns and local event ordering; regtest coverage complements
those tests and must not replace them. Designing this machinery, its fixtures,
and its CI/runtime tradeoffs is deliberately deferred until after the current
kernel-mechanics review checkpoint.

The 2026-09-07 checkpoint also exposed obsolete coverage in the existing
`ph/cc/breach` Aqua scenario. Both `%ames` and `%mesa` runs fail at the first
remote-point assertion, before any traffic or breach. `start-cc-comet` installs
`%test-udiff` and feeds comet points through generic `%listen`/`udiff` delivery;
it never registers a domain verifier. The current comet authority checks
correctly reject that setup. Do not weaken those checks to make the fixture
pass.

Migrating this scenario requires more than changing one assertion:

- use a registered test domain and its real verdict path, as the life-2 and
  snob scenarios now do;
- replace the old fixtures' `dat=0xdead.beef.cafe`, whose leading field is not
  a valid domain term;
- generate later-life keys while preserving genesis `ugn` and `dat`; the old
  `aqua-azimuth` fixture calls fresh `+pit` for later lives, changing the name
  material;
- retain explicit observations of public point, active private life, and
  peer state before and after the transition.

`cc-breach` calls Aqua's `%init-ship` path, which resets the simulated pier
before boot. Even after fixture repair, this is fresh-pier recovery coverage,
not a live own-rift test. The latter must separately prove the quiescent
pending interval described in §12. The checkpoint in the lifecycle companion
records the full Ames suite's six inherited failures as well; the testing
chapter must restore a green, meaningful baseline rather than count only the
new passing cases.

## 6. Competing attestations versus local proof-routing races

The fixed Mesa paths tolerate one proof already in flight while Jael's local
subscription changes the peer's transport classification from `%alien` to
`%known`. That is a local message-routing race, not permission for an identity
owner to advertise a stream of competing on-chain lives during initial contact.

The current kernel adds no proof job IDs, candidate queue, or winner-selection
state. Existing monotonic verdict checks reject rollback and same-life key
replacement. Higher-life positive verdicts therefore converge regardless of
arrival order: if the higher one lands first, the lower is discarded. Two
different positively vouched keys at one previously unseen life are
first-positive-wins locally, so distinct observers can diverge only if the
trusted domain equivocates. Same-life verdicts which retain the accepted `cry`
may still replace mutable evidence and other whole-point metadata in arrival
order. Likewise, before activation, two local `%rekey` rings for the same future
life are last-write-wins; a nonmatching survivor cannot activate and must be
replaced with the authorized ring.

`%snob-notice` and a positive `%full` verdict also carry no causal generation.
A delayed positive answer for the retained same point can therefore arrive
after `%snob` and clear Ames's soft block: `%full` currently applies the inverse
soft-list edit unconditionally. Delivery is serial and no key can roll back,
but the most recently delivered trusted-domain policy event wins even when it
was produced earlier. A generation-aware design would need to distinguish the
fresh re-attestation solicited by `%snob` from an older outstanding verdict.

Key activation remains fail closed: a stale or mismatched private ring cannot
become Ames's signer. Policy freshness does **not** remain fail closed with the
current companion implementation. A verifier job started before an ownership
move can finish after `%snob-notice` and emit its old successful `%full`; neither
the verdict nor the soft block carries a generation, so Ames must accept that
trusted answer and clear `%snob`. Groundwire can then also delete its own
suppression record, leaving the old signer admitted indefinitely. Before
dogfooding, the companion verifier must reject any completion whose observed
tip/generation predates its current snob record. The required interleaving test
is: start old-life verification, observe a chain move and emit `%snob-notice`,
then finish the old job; no `%full` may be emitted and the snob record must
remain.

The broader cases expose causal freshness which life/rift alone cannot express.
A later protocol chapter should decide whether repeated distinct candidates
within one verification window need an explicit behavioral response, such as
treating the peer as stale/misbehaving and soft-snobbing it until a single
current attestation can be verified, and whether mutable same-life answers or
staged rings need stricter equality rules. Any such rule must define its
trigger, recovery condition, denial-of-service implications, and interaction
with delayed honest verdicts before adding kernel state.

## 7. Companion rotation ordering and exact evidence agreement

Jael activates a private ring only when its derived pass exactly equals the
authority's current pass, including suite C's opaque `xtr`. This is deliberate:
the kernel cannot decide that two different custody proofs are equivalent merely
because they expose the same live key.

The current Causeway workflow does not yet satisfy that contract. It stages a
life ring before the final custody opening has been appended, then finalization
grows `xtr` and instructs the operator to refresh the public custody entry. If
the xtr-bearing final ring is not staged again, Jael holds a public point and a
private ring whose live keys match but whose passes do not, and correctly leaves
the new life inactive. The companion PR must make the final, authority-matching
ring the value sent through `%rekey`, and must expose acknowledgement of that
exact match before declaring rotation complete. The kernel matching rule should
not be weakened to paper over this ordering mismatch.

A focused companion test should cover both orderings: stage the final ring then
publish its exact point, and publish the point then stage the exact ring. It
should also prove that a pre-finalization ring with the same seed but stale
`xtr` does not activate.

## 8. Verifier availability is not verifier readiness

Jael currently treats a registered domain as live across an app kick and
unsnubs retained peers as soon as a suspended desk revives. Groundwire registers
its domain during initialization before its chain client reports that it is
synced, and deliberately holds new verification work until synchronization.
Already-known peers, however, need not produce a new writ while Jael's stored
life is current. A verifier restart or desk revival can therefore re-expose a
retained old signer during an unbounded catch-up window after the external
authority has moved.

The current `%tire` handler has a second, independent scope error: it assumes at
most one registered domain per desk and updates only one matching registry
entry. `%anex` enforces one agent per domain, not one domain per desk, so the
generic interface does not justify that assumption. If several domain agents
share a desk, a desk suspension can leave some of them marked live. The
readiness chapter must update every registration on the affected desk and test
multi-domain suspension and revival explicitly.

The cross-layer contract needs an explicit readiness transition. App exit/kick or
desk suspension must leave the domain authority suspended; only an agent which
has caught up to its required chain tip/finality policy may revive it. Revival
must trigger revalidation or solicitation of retained suite-C peers before
ordinary traffic is admitted. Tests must rotate the authority while the agent
is down, restart it unsynced, and prove old-key traffic remains blocked until
the ready/re-attest transition completes.

There is a related installation transition. A suite-C life-1 peer admitted under
the unregistered-domain compatibility rule exists only in Ames, not Jael's
domain-owned point set. Merely registering the verifier later neither discovers
nor solicits that peer, and `%snob-notice` cannot name a point the domain never
accepted. The first release must either require domain registration/readiness
before such traffic, or add an explicit revalidation trigger which scans known
fallback peers and requests their attestations. This is actor lifecycle policy,
not a reason to add proof-job queues to Ames.

The smallest coherent kernel design found in this audit reuses Jael's existing
`liv` bit as an explicit verifier-readiness assertion. A first `%anex` registers
the endpoint suspended; `%gost` and Gall app loss make that domain unready; Clay
desk loss makes every registered domain on that desk unready; Clay `%live` alone
does nothing; and only an authenticated `%ghul` from the matching agent, after
it has synchronized and fenced old work, makes it ready. Jael would
broadcast domain-level `%gost`/`%ghul` results on its existing `%sybl`
subscription. Ames, which is the only layer that can see fallback-only peers,
would scan both known transport tables by the domain committed in each pass.
`%gost` would soft-block those peers without soliciting; `%ghul` would keep them
soft-blocked and solicit each once; only an individual fresh `%full` would
release that peer. Replaying current domain readiness to a new `%sybl`
subscriber closes the Ames-restart case. This adds no verifier job identifiers
or candidate queue, but still requires companion code to cancel/fence every
pre-readiness verification job.

## 9. Unbounded custody evidence exceeds both transport envelopes

Suite C appends all of `xtr` to every pass and therefore to every
self-attestation. Groundwire currently uses `xtr` as the complete custody log,
adding an opening at each rekey. Mesa's proof endpoint requires the entire pass
to fit in one 1,024-byte fragment; with minimal realistic custody entries the
proof is about 975 bytes at eight entries and 1,056 bytes at nine. Richer routes
can fail earlier. The legacy Ames signed-open limit is 131,072 bits and is
crossed around 198 minimal entries. The smaller Aqua fixture crosses the Mesa
limit around life 15 and the legacy limit around life 319.

This is a permanence blocker, not merely a stress-test wishlist: repeated valid
rotation eventually makes an identity unable to attest. Before calling the
format permanent, choose and specify one of a bounded/compact custody proof, a
prunable commitment with a stable verification rule, or a fragmented Mesa proof
transport. The test suite must pin the chosen byte bound and exercise the last
accepted and first rejected/fragmented histories on both transports.

## 10. Peer-controlled `xtr` must not reach raw `cue`

The kernel now structurally checks jam before decoding a suite-C pass. The
Groundwire verifier still applies `cue` directly to peer-controlled `xtr` under
`mole`. A crafted jam backreference raises `%meme`, which that wrapper does not
contain; retransmission can repeatedly crash or livelock verification before
custody policy runs.

The companion PR must use an equivalent bounded structural pre-check (or another
decoder with the same guarantee) before `cue`. Reuse the kernel's compact
backreference bomb as a cross-layer regression vector, alongside depth, width,
and total-byte bounds.

## 11. Negative-verdict semantics must agree across layers

The current Groundwire branch still describes a negative verdict as terminal:
delete the point, breach flows, and sticky-snub the identity. This kernel bite
deliberately gives `%fail` the narrower meaning recorded in section 1: reject
the presented candidate and preserve any known peer. Until the terminal policy
has a causal freshness design, companion logs and behavior must be changed to
match the non-terminal kernel contract. Otherwise operators will be told that a
security action occurred when the kernel intentionally did not perform it.

## 12. Live advancement of our own rift needs a quiescent state

The ordinary remote-rift path now breaches a known peer before installing a
higher-rift whole point. The corresponding transition for our own ship is not
implemented safely. Ames currently ignores `%breach our`, and both a whole
point and an incremental rift update replace only `rift.ames-state`; existing
legacy/Mesa flows, alien agendas, cached symmetric keys, and server-side
`%shut` capabilities survive.

A one-shot global wipe is necessary but not sufficient. Jael publishes public
point changes before the matching private-key gift, and point-first operation
may intentionally last across events. After a wipe, another public-point event
or new local traffic can repopulate peer state while Ames still holds the old
private ring. Filtering siblings from one `%full` batch does not close that
interval because Jael also emits singleton gifts. Consequently the repair must
not pretend that event ordering is a durable quiescence mechanism.

The next rift chapter should specify an explicit pending/quiescent transition:

- a trusted own-breach or strictly higher own rift enters the pending state;
- entering it clears both transport tables, including alien queues and raw
  packets, and clears the server `%shut` key chain;
- while pending, old-ring traffic cannot recreate an authenticated channel;
  the policy for newly requested local work must be explicit (reject, retain as
  unauthenticated intent, or queue under a sharply bounded interface);
- a lower rift cannot roll state back, and an equal-rift replay is idempotent;
- only an exact public/private match for the authorized own point exits the
  pending state, with a final continuity wipe before the new ring becomes
  active; and
- the timer-based `+do-rift` repair path uses the same transition rather than
  assigning the scalar independently.

Tests must exercise whole and incremental points in both ring-first and
point-first order, intervening peer point gifts and local sends, crash/replay at
every boundary, legacy and Mesa state, alien work, old `%shut` capabilities,
same/lower-rift replay, and final rehydration under only the new ring. This is
separate from routine life rotation, which deliberately retains flows and
rederives their keys.

## 13. Remote numeric point feeds retain broader source trust

The local Gall `udiff` path now checks the selected source for each ship, with
explicit per-ship selections overriding the default. The inherited remote
Jael `%boon` path does not make the equivalent per-ship check when accepting
numeric points. A configured, authenticated remote source can return a snapshot
containing numeric ships outside its assigned selection, and those extra points
are accepted. The transport authenticates the responding source; this is a
scope-of-authority limitation, not an unauthenticated remote injection path.

The comet guard excludes comet entries from remote `%full` snapshots and drops
comet `%diff` and `%breach` results, so this inherited numeric-source limitation
cannot bypass suite-C domain verdicts. Tightening numeric source authorization
is a separate review: establish how each response identifies its selected
source, preserve moon-parent subscriptions, and cover mixed snapshots, default
versus explicit selections, and delayed responses after source reassignment.
