# Confidential Comets: Kernel Integration Specification

Status: **waypoint specification, amended**. The Jael/Ames integration is
merged. The on-Bitcoin format authority is now the OP_RETURN revision and its
decisions addendum in the Groundwire repo (see below); the economic-admission
machinery and the two-fragment packet bound described in §3 are **descoped**
by that addendum and retained here only as historical context.

Companion documents:

- [implementation state](confidential-comets-state.md)
- [remaining work and architect decisions](confidential-comets-todo.md)
- Groundwire userspace specification:
  `gwbtc/groundwire/groundwire/doc/confidential-comets-agent.md`
- **Format and scope authority** (supersedes conflicting sections here):
  `gwbtc/groundwire/groundwire/doc/opret-revision/01-spec-revision.md` and
  `04-decisions-addendum.md`

## Revision history

- **2026-08-03 — OP_RETURN revision and decisions addendum adopted.** Where
  this document conflicts with the Groundwire OP_RETURN revision docs, they
  win. Summary of kernel-relevant deltas, all landed on this branch:
  - The canonical `dat` is now
    `(can 0 (mat %gw-btc) (mat 9) [256 d] ~)` — domain tag first (all the
    kernel ever reads), then a Kelvin protocol version (starting at 9,
    counting down), then a 32-byte hiding commitment to the spawn satpoint.
    The `can`/`mat` satpoint layout §2.1 shows is superseded.
  - Every snapshot change increments life (a rift bump implies a life bump),
    so Ames's life-based intake triage is a total order and no same-life
    re-verification path is needed.
  - Stale attestations: `$stale-notice` fact → jael forgets the point →
    `[%sybl %stale]` → Ames drops the peer without snubbing. Resolves the
    stale-vs-`%fail` and remote re-attestation questions (owner-driven;
    no peer-directed request API).
  - Additive `[%snub form act ships]` Ames task; `%gost`/`%ghul`/`%bane`
    no longer clobber manual blocklists. Resolves todo §15's snub item.
  - Jael `%dome` scry: the PKI domain committed in a ship's pass.
  - Udiff source authorization landed without the `%bane` tombstone's
    unsafe state edit; a durable tombstone remains deferred pending a
    proper Jael state migration.
  - First-contact attestations must fit **one** Mesa fragment; the
    two-fragment bound and bounded anonymous reassembly path (§3.2,
    todo §11) are descoped. Economic-admission staging (§3.3–3.4) is
    descoped in favor of plain single-flight-per-ship deduplication in
    the domain agent; on-chain cost is the sybil resistance.

- **2026-07-29 — first maintained verbal waypoint.** Separates three things
  that earlier drafts mixed together: the kernel integration merged by Urbit
  PR #57, the currently working fetch-based `%gw-btc` implementation, and the
  selected next protocol revision. The next revision restores full-state
  commitments, harmonizes the immutable tweak encoding, admits expensive work
  only behind an economically qualified current tip, and permits a tightly
  bounded two-fragment first-contact attestation. This entry starts the
  explicit history; earlier development is summarized in the state document.

Future entries should state the semantic change, why it was made, compatibility
impact, and the relevant commits or pull requests. A dirty worktree must never
be described here as merged behavior.

## 1. Purpose and boundaries

A Groundwire confidential comet proves control of a single Bitcoin sat from a
combined `%spawn`/initial-state commitment through a current unspent tip. Its
first Ames packet carries a self-attestation. The receiver verifies the
attested networking state asynchronously before admitting the peer.

The responsibilities are deliberately split:

- **Ames** transports and authenticates the self-attestation, recognizes its
  PKI domain, bounds anonymous first-contact work, and waits for Jael's result.
- **Jael** registers one Gall verifier per PKI domain, forwards verification
  requests and results, stores accepted public networking state, and publishes
  the ordinary `%public-keys` effects.
- **`%gw-btc`** parses Groundwire evidence, performs packet-local checks,
  schedules verification, applies local admission policy, and converts a
  verified full state into Jael's point/udiff representation.
- **`%light-client`** owns canonical-chain, confirmation, transaction-witness,
  UTXO, and reorganization truth. It may query configured full nodes. Reorg and
  chaintip algorithms do not belong in `%gw-btc`.
- **The policy engine** chooses economic thresholds and queue priority from
  authenticated facts. Those values are not wire-validity rules.

This pass deliberately uses deterministic light-client vectors rather than an
external Bitcoin node. A later end-to-end layer will run `%gw-btc` and
`%light-client` against a sidecar `bitcoind` in regtest mode.

## 2. Stable kernel contract

### 2.1 Suite-C pass and immutable identity data

`$open-packet` remains the ordinary Ames open packet. Suite `%b` remains the
vanilla comet path. Suite `%c` identifies a confidential comet whose pass has
two payloads:

- `dat.tw.pub` is hashed into the signing-key tweak and therefore into the
  comet name. It is immutable for the identity.
- `xtr.tw.pub` is not hashed into the key. It carries the refreshable
  attestation evidence and may change without changing the comet name.

For `%gw-btc`, the canonical immutable encoding is:

```hoon
(can 0 (mat %gw-btc) [256 txid] (mat vout) (mat off) ~)
```

The fields after the `+mat`-encoded domain identify the original funding
satpoint. They are directly encoded, not a jammed `[txid vout off]` noun. Ames
extracts only the leading domain with `+rub`; the domain agent interprets the
remainder. All Groundwire codebases and test-vector generators must use this
same encoding.

Committing `%gw-btc` in `dat` prevents cross-domain double boot: changing the
domain changes the pass and therefore the `@p`. Ames must check the pass/name
binding before asking Jael or allocating confidential-comet state.

### 2.2 State commitments

Groundwire commitments are **states, not updates**. A state-bearing Taproot
leaf contains a complete per-identity Jael/`urb-snapshot` networking state plus
its sequence number. “Snapshot” here means the full committed identity state,
not a Gall process checkpoint.

The state includes enough information to derive the Jael point: rift, life,
the complete relevant key history/current key, public sponsor state, and the
other fields selected by the harmonized Groundwire mold. The suite-C pass
stored inside the committed state is normalized with `xtr=0`; verification
compares the identity, suite, and key material while ignoring only the outer
pass's refreshable `xtr`. This avoids recursive commitment to the evidence
packet itself.

The initial custody transaction is a combined genesis: it both takes custody
of the immutable spawn satpoint and commits the initial full state. Later
state-bearing transactions reaffirm the entire state. Pure custody transfers
may carry no reveal, but the selected first-contact profile requires the
**current unspent tip** to be state-bearing. Otherwise the last state-bearing
output is already spent and cannot simultaneously bind the signer and provide
the live economic admission resource.

Only public sponsors are supported in the initial release. Explicit sponsor
revocation and more complex/private sponsorship policy are out of scope;
sponsors may decline routing for abandoned children. Single-leaf Taproot
commitments remain the required construction for this revision. More complex
Taptrees are future work. When the committed state has no sponsor, conversion
to an udiff uses the ship itself as the sponsor fallback; it must not invent an
external sponsor. An explicit sponsor missing from the receiver's authoritative
public snapshot is deferred or policy-ineligible until it becomes public; it is
never silently rewritten to self and is not, by itself, cryptographic fraud.

### 2.3 Jael domain API

The merged target adds a one-agent-per-domain registry to Jael state `%5` and
migrates state `%4` correctly. This kernel migration is distinct from
userspace `%gw-btc` state: the network starts after a breach, so there is no
`%urb-watcher` migration and no versioned `%gw-btc` persistence migration.

The relevant tasks are:

| Task | Meaning |
|---|---|
| `[%anex pax]` | the sending Gall agent registers itself as its same-named domain and asks Jael to watch `pax` |
| `[%writ dom ship pass]` | asynchronously verify a suite-C attestation through the registered domain |
| `[%sybl ~]` | subscribe to verification results; Ames subscribes at boot |
| `[%anew dom]` | ask the local domain agent to refresh our own mutable `xtr` |
| `[%gost dom]` | suspend the domain and snub its accepted peers |
| `[%ghul dom]` | restore the domain and unsnub its accepted peers |
| `[%bane dom]` | destructively deregister the domain, delete its accepted points, breach and snub its peers |

The registered agent answers `%jael-writ` asynchronously by publishing a
`%writ-response` fact on its registered watch path:

```hoon
+$  writ-response  [dom=@tas =ship res=(unit point)]
```

Jael stores a successful point through its normal `feel` machinery and gives
`[%sybl %full ...]`; failure gives `%fail`; an absent/unavailable domain gives
`%lost`. Ames funnels `%full` through the ordinary promotion path, additively
snubs a failed alien, and treats `%lost` as non-authoritative/transient.

Clay's `%tire` subscription supplies desk suspension/revival. Gall app nuke
and restart is a different lifecycle. The merged target rejects duplicate
`%anex`. The selected follow-up behavior is that an exact duplicate from the
same agent and path is an idempotent re-watch, while a changed path remains a
conflict. The dirty worktree contains that fix, but it must land in the separate
Jael `%base` PR before this specification may be treated as implemented. A
durable `%bane` tombstone remains an architect decision recorded in the TODO.

### 2.4 Ames intake

Both Mesa and legacy Ames paths must apply the same semantic branches:

1. For an unknown suite-C comet, or a higher-life candidate, validate the
   packet/pass/name relationships, extract a well-formed domain, subscribe to
   its public keys, and send `%writ` to Jael. Do not register it locally yet.
2. For a state already accepted at the same or later life, retain the ordinary
   key subscription. A new economically qualified Groundwire state may still
   need userspace verification; life alone is not the final ordering rule.
3. For a vanilla suite-B comet, retain the existing local life-1 verification
   and registration behavior.

Malformed suite-C `dat` must fail closed before alien state or a Jael request
is created. The current dirty worktree implements this hardening in both
packet paths, but it is not part of target commit `802b386a43`.

## 3. Selected next attestation revision

The exact Hoon molds must be harmonized with the other Groundwire codebases
before implementation. The following is the normative semantic envelope, not
permission to invent a divergent local mold.

### 3.1 Evidence profiles

Every accepted packet has one canonical tagged envelope and a hard bound on
its complete jammed open response. It contains:

- a mandatory **inline head**: the entire raw current-tip transaction, its
  claimed canonical height, and the complete current state reveal;
- a bounded, custody-ordered list of compact historical commitment/custody
  references shaped like `[txid height reveal]`, with no reveal for a pure
  custody move; and
- origin evidence identifying the immutable spawn satpoint and combined
  genesis. For short logs, the canonical profile may require the complete
  first custody/spawn transaction (and, if needed for offset/value proof, the
  funding transaction or an authenticated funding-prevout fact).

The sender must not freely choose a weaker representation. The short/long
profile rule must be deterministic after exact golden-vector measurement.
“About five entries” is a sizing hypothesis, not a wire rule.

The inline head is canonicalized by parsing and re-encoding it. `%gw-btc`
derives its txid and the unique matching commitment `vout`; redundant claimed
values are rejected rather than trusted. The head reveal must name the ship,
contain the highest accepted state sequence for that custody history, and
attest the suite-C key that verified the outer self-attestation.

### 3.2 Two-fragment bound

Mesa may carry at most two 1 KiB data fragments for an unverified Groundwire
first contact. The limit applies to the **complete serialized response**,
including the open-packet/pass/signature/container overhead, not merely to
`xtr`.

This requires bounded anonymous reassembly, not a one-line relaxation of the
existing one-fragment assertion:

- a hard 2,048-byte complete-payload limit and at most two data fragments;
- a small fixed-capacity alien pool with short TTL and LRU eviction;
- authenticated root metadata and ordered fragment requests;
- cue, pass derivation, name binding, and signature verification only after
  complete assembly; and
- isolation from established-peer Mesa state.

The legacy unfragmented Ames open-packet path remains single-fragment unless a
separate protocol is designed. Source/lane metadata may protect this free
pre-authentication pool, but it is transport hygiene, not identity authority.

### 3.3 Packet-local economic preflight

Before allocating a historical-verification job, `%gw-btc` performs bounded
checks over the assembled packet:

1. enforce canonical envelope, `dat`, `xtr`, sizes, entry count, heights, and
   unique txids;
2. require the inline head to be the state-bearing current tip;
3. parse and canonicalize the raw transaction and derive its txid;
4. parse the complete state, sequence, ship, and normalized current pass;
5. bind the committed key to the outer self-attestation signer;
6. reconstruct the single-leaf Taproot output and require exactly one matching
   transaction output; and
7. read that output's nominal value and reject values below the local minimum
   before doing historical work.

The raw transaction proves its serialization, txid, outputs, state commitment,
and nominal output value. It does **not** prove canonical-chain inclusion,
confirmation count, current unspentness, witness authenticity, or fee. Bitcoin
fees require authenticated prevout values; txid also excludes SegWit witness
data.

### 3.4 Light-client economic probe and policy

After local preflight, a small fixed-capacity probe pool asks `%light-client`
for an atomic fact about the candidate outpoint: canonical inclusion/height,
confirmations, exact script and value, current unspentness, and a chain-view
identifier. Authenticated fee data may be included when the light client can
establish the inputs' values.

The policy boundary consumes authenticated facts and returns `eligible`,
`ineligible`, or `defer`. Its settings include minimum current UTXO value,
confirmations, attributable fee, and credited state-commitment depth. Policy
rejection is not cryptographic fraud, and transient light-client failure must
not create a sticky Jael failure.

An eligible result reserves the distinct `[txid vout]` as an economic token.
Only then may the request enter the expensive custody queue. One outpoint may
back one active job at a receiver. This makes 1,024 concurrent jobs require
approximately `1,024 * minimum-value` in simultaneously unspent,
identity-bound outputs, before conservatively attributed fees.

UTXO value is locked capital, not burned cost. Fees are burned but can be
shared by batched transactions, so policy must not credit the full fee to
every output. A safe initial rule is conservative per-output allocation whose
total never exceeds the transaction fee. Multiple ships in one transaction
remain valid if each has a distinct state-committing output meeting policy.

At most one authenticated state commitment per ship per canonical block may
count toward policy depth. This forces per-identity time depth but does not
serialize an attacker's many ships; the distinct live outputs and fees remain
the additive Sybil cost. Whether same-block commitments are merely uncredited
or protocol-invalid remains an architect choice.

## 4. Asynchronous verification and ordering

The selected userspace pipeline is:

```text
bounded Ames assembly
  -> packet-local head/state checks
  -> bounded light-client economic probe
  -> policy and outpoint reservation
  -> bounded historical custody job
  -> final chain-view/outpoint recheck
  -> Jael result
```

The historical job validates the combined genesis, sat-position arithmetic,
the complete custody chain, each disclosed state commitment, current-state
ordering, and authenticated witnesses. Previously verified ships should reuse
their verified prefix and resolve only the suffix.

Every asynchronous request and callback carries a job identity/epoch tied to
the ship, state hash/sequence, economic outpoint, and captured chain view. A
late result may apply only if that identity is still current. A new unproven
packet cannot cancel paid in-flight work. At most one independently qualified
successor should wait behind an active job.

Publicly indexed and confidential candidates receive no semantic priority
from their source. The latest custody-proven state wins. Admission-source
metadata may be retained internally for fragment/probe fairness and
observability, but it cannot resolve state races.

On apply, `%gw-btc` rechecks the economic outpoint and chain view. A reorg or
spent tip makes the result stale/deferred and returns control to
`%light-client`; `%gw-btc` must not implement its own competing chaintip model.

## 5. Re-attestation

The merged `%anew` path refreshes **our own** `xtr`: Ames asks Jael, Jael asks
the local domain agent, and a returned pass is installed after confirming that
its immutable identity still hashes to our name. The refreshed pass is not
currently written back to the boot keyfile.

Remote stale-attestation recovery is separate. A verifier must be able to
classify an otherwise valid packet as stale, request re-attestation without a
sticky snub, and correlate the replacement with the waiting job. The existing
kernel API does not yet provide the complete peer-directed request/response
lifecycle; the smallest acceptable Ames/Jael addition and persistence behavior
remain in the TODO.

## 6. Compatibility and verification requirements

- Suite-B comets and their one-fragment paths must remain unchanged.
- The Groundwire comet network is intentionally breached for this wire change;
  no `%urb-watcher` or `%gw-btc` userspace migration is required.
- Jael state `%4` to `%5` migration remains required for live non-Groundwire
  state and is already merged.
- `sur/stealth.hoon` is a non-built design sketch. It must be synchronized with
  this specification or removed as an apparent second authority.
- Canonical test vectors must be shared across Urbit and Groundwire for `dat`,
  state snapshots, inline transactions, and complete packet byte sizes.
- Aqua must cover the real Ames -> Jael -> Gall -> Jael -> Ames asynchronous
  path using deterministic `%light-client` answers: success, economic
  ineligibility, malformed packet, stale/spent/unknown head, higher life,
  callback races, public/confidential ordering, and queue bounds.
- Later regtest E2E covers the production `%light-client`, full witnesses,
  confirmations, spends, and reorg behavior.

The exact implementation and acceptance sequence is maintained in
[confidential-comets-todo.md](confidential-comets-todo.md).
