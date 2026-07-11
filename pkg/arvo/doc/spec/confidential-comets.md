# Confidential Comets: Kernel Integration Spec & Proposal

Status: **draft** (branches `cyc/cc-draft` + `cyc/cc-draft-2`)
Companion to: *Confidential Comets* (~hanfel-dovned) and the
`hd/urb-handler` prototype in `gwbtc/groundwire`
(`sur/self-attestation.hoon`, `app/urb-watcher.hoon`).

## 1. Background and motivation

Groundwire IDs prove their existence by revealing TapScript inscriptions
on Bitcoin. Confidential comets avoid the on-chain reveal: on first
contact, a comet hands its peer a **self-attestation** off-chain —
everything needed to verify, against the chain, an unbroken key-path-spend
ownership history for a single sat, from the comet's `%spawn` commit
through the current (unspent) tip UTXO. Every spend in that chain is an
ordinary Taproot key-path spend; the committed `urb` leaf is disclosed
off-chain and checked by recomputing the tweaked output key
(`Q = P + H_TapTweak(x(P) || leaf-hash) * G`, single-leaf tree, sparse by
construction).

The agent-level machinery for this exists in the `hd/urb-handler`
prototype: `%urb-watcher` verifies packets in a khan thread and maintains
the confidential-comet registry. What did **not** exist was the kernel
side — the prototype pokes a *placeholder, nonexistent* `%ames` agent with
`%attestation-request` / `%attestation-verdict`. This branch replaces
those placeholders with real Ames/Jael plumbing.

## 2. Design overview

The kernel treats on-chain verification as a **pluggable PKI domain**: a
local gall agent, registered with Jael per domain tag (1:1: e.g.
`%groundwire` names both the domain and the agent), owns all chain
knowledge. The kernel only:

1. recognizes that an incoming comet attestation claims a domain,
2. routes it to the domain's registered agent via Jael,
3. hears the verdict back and promotes (or snubs) the peer.

```
comet ~zig                    verifier ship
   |                              |
   |  $open-packet (suite-%c     |
   |   pass, dom in key tweak)   |
   |----------------------------->| ames +al-take-proof / +on-hear-open
   |                              |   %pynt scry: unknown / newer life?
   |                              |--%writ dom ship pass--> jael
   |                              |                          |  dos lookup
   |                              |                          |--%jael-writ poke--> %urb-watcher
   |                              |                          |                       (khan thread,
   |                              |                          |<--%writ-response fact--  bitcoin rpc)
   |                              |                          |  store point; %public-keys
   |                              |<---%sybl gift (/sybl)----|  give verdict to %sybl subs
   |                              | +sy-sybl:
   |                              |   %full -> +sy-publ (promote alien, drain queues)
   |                              |   %fail -> snub + drop pending
   |                              |   %lost -> no-op (stub)
```

### 2.1 The attestation carrier: the pass itself

`$open-packet` is **unchanged** — vanilla comets are fully
backward-compatible. The discriminator is the crypto suite of the
packet's `pass`:

- **suite `%b`** — vanilla comet: plain self-signed key, life 1
  forever. Verified and registered entirely locally, exactly as before.
- **suite `%c`** — exclusively a confidential groundwire comet (suite
  `%c` was upstreamed for precisely this). The pass carries two
  distinct payloads (see `sur/stealth.hoon` for the full anatomy):
  - `dat.tw.pub` — the **actual Schnorr tweak data**, hashed into the
    signing key and therefore immutable for the ID's lifetime: exactly
    the `+mat`-encoded PKI domain tag (extracted by the receiving Ames
    with `+rub`, `+pass-pki-dom`) followed by the sat's **spawn
    satpoint**.
  - `xtr.tw.pub` — the **off-chain reveal of the on-chain event log**:
    merkle proofs into the block headers for each ownership-sat
    transfer, spawn → tip. *Not* tweaked into the key, so it grows
    over time without changing the name. Kernel-opaque: it rides
    inside the `$pass` straight through Ames and Jael to the domain
    agent, which alone parses and verifies it. Refreshed via `%anew`
    (§2.6).

Committing the domain inside the tweak (rather than attesting it in a
packet field) means the comet's *name* — the hash of the pass — commits
to the domain, which prevents **cross-chain double-boot**: the same
identity cannot present itself under one domain to one peer and another
domain to another, because a different domain implies a different pass
and therefore a different `@p`. The `fig:ex:cic` = `@p` check in the
kernel enforces this before any chain work happens; the *chain* is what
the domain agent verifies.

Because a confidential comet can rotate keys with an on-chain (still
key-path) transfer, its life may exceed 1. `+sift-open-packet`'s life-1
assertion is now conditional on the suite (`'c'` passes exempt); the
mesa proof path (`%publ` life-1 space assertion) is likewise only
applied on the vanilla branch.

### 2.2 Jael: PKI domains as first-class state

New top-level state (`state-5`):

```hoon
dos=(map @tas dom-state)
+$  dom-state
  $:  pax=path          ::  watch path on the domain agent
      liv=?             ::  %.n while the agent is suspended
      hep=(set ship)    ::  ships verified through this domain
  ==
```

**Domains and agents are 1:1 by construction**: the domain name *is*
the verifier agent's name (e.g. `%groundwire` names both), and Jael
derives it from the `[%gall %use dap ...]` duct the `%anex` task
arrives on — an agent can only ever register itself. This eliminates
the `%hand` re-pointing task and the whole class of dom/dap skew bugs;
"changing the handler" is now: nuke or suspend the old agent (see
liveness below), install the new one, let it `%anex`.

> **Naming note**: the verdict *gift* is tagged `%sybl` (matching the
> subscription task), not `%writ`. Clay already gives a `%writ` gift, and
> userspace (e.g. dojo's `+on-arvo`) switches on the gift tag across all
> of `sign-arvo` — a second `%writ` gift forks that match and breaks the
> build. Discovered when `%base` failed to rebuild at bootstrap.

plus `syl=(set duct)` in `zim` — the `%sybl` (writ-result) subscriber
set. Because these change the shape of Jael's durable state, the state
version is bumped to `%5` with a proper `%4`→`%5` migration
initializing both empty. (The stashed scaffold had instead redefined
`state-4` in place — fine for fresh boots, but a live ship's real `%4`
state no longer matched the type and `+load` crashed on upgrade; this
was caught by upgrading a running fakeship.)

**Agent liveness flows causally from Gall to Jael.** Gall grows a
`[%view =dude]` task: subscribe a duct to an agent's lifecycle, giving
`[%view sate=?(%live %idle %nuke)]` — the current state immediately,
then a gift on every transition (hooked in `+mo-receive-core`,
`+mo-idle`, `+mo-nuke`; subscribers in a new `vew` jug, gall state
`%20`→`%21`). Jael subscribes on `%anex` and reacts:

- **`%idle`** (agent suspended) → `%gost` semantics: mark `liv=|`,
  refuse `%writ`s with `%lost`, ignore the agent's facts, `%snub` the
  domain's `hep` peers. Idempotent — the initial `%view` snapshot on a
  live agent is a no-op.
- **`%live`** (agent back) → `%ghul` semantics: `liv=&`, unsnub.
- **`%nuke`** → **not** `%bane`. Agents get nuked for ordinary
  bug-fixing reasons, and users can't be trusted to reserve nuking for
  true emergencies — so deletion breaches the domain's peers (their
  points are forgotten and must re-verify from scratch once a new
  agent registers) and deregisters the domain, but does **not** snub
  anyone. The full snub response remains available as the explicit
  `%bane` task.

Jael never drives the agent's state in the other direction —
`%gost`/`%ghul` remain as manual levers over the same `liv`/peer
effects, and `%bane` as the emergency lever, but none of them touch
the agent itself; Gall owns liveness.

### 2.3 Task/gift API (lull)

| Task | Meaning |
|---|---|
| `[%anex pax]` | register a PKI domain: the *sending agent's name* is the domain (1:1); jael watches `pax` for its responses and chain updates, and watches the agent's liveness via gall `%view` |
| `[%writ dom ship pass]` | verify an attestation: poke the domain agent with `[%jael-writ dom ship pass]`; unknown domain → immediate `%lost` verdict. `dom` is what Ames extracted from the pass tweak |
| `[%sybl ~]` | subscribe to all writ verdicts (Ames does this once at boot, in `+sy-init`) |
| `[%anew dom]` | request a fresh self-attestation (updated `xtr` reveal log) from the domain agent; the new pass returns to `%sybl` subscribers (§2.6) |
| `[%gost dom]` | suspend a domain: `liv=|`, `%snub` its verified peers; registration and peer set retained. Also fired causally by gall `%view %idle` |
| `[%ghul dom]` | recover from `%gost`: `liv=&`, mass-unsnub. Also fired causally by `%view %live` |
| `[%bane dom]` | destroy a domain (DOS attack / compromised PKI): deregister, delete its ships' points, `%breach`-broadcast (a la `%ruin`) and `%snub` them. NB: nuking the agent instead breaches *without* snubbing (`%view %nuke`) |

New gift, to `%sybl` subscribers:

```hoon
[%sybl =writ-result]
+$  writ-result
  $%  [%full dom=@tas =ship =point]   ::  verified; point now in jael
      [%fail dom=@tas =ship]          ::  failed validation
      [%lost dom=@tas =ship]          ::  unknown domain
  ==
```

Agent→Jael response contract: the registered agent answers a
`%jael-writ` poke **asynchronously** with a `%writ-response` fact on its
registered watch path:

```hoon
+$  writ-response  [dom=@tas =ship res=(unit point)]
```

`res=~` means verification failed. On success Jael stores the point via
the ordinary `feel` machinery (so `%public-keys` subscribers — including
Ames — hear it too), records the ship in the domain's `hep`, and gives
`%full` to `%sybl` subscribers. The agent may *also* keep publishing
`%azimuth-udiffs` facts on the same path for ongoing chain updates
(sat movement, public reveals); those flow through `+new-event`
unchanged, except that facts from a `%gost`-suspended domain's agent are
dropped.

Rationale for a fact rather than a poke-ack: verification spans many
events (a khan thread doing Bitcoin RPC), so the poke-ack cannot carry
the verdict; and a fact on the `%anex`-registered path reuses the
existing subscription rather than inventing a new agent→vane channel.

### 2.4 Ames: attestation intake and verdicts

`+al-take-proof` (mesa) and `+on-hear-open` (legacy |ames) now share the
same three-way branch (the latter mirrored from the former, per todo):

1. **Confidential, unknown or newer life** (suite `%c`, and jael's
   `%pynt` scry shows no point or an older life): extract the domain
   from the pass tweak, subscribe to the ship's `%public-keys`, then
   pass `[%writ dom ship pass]` to Jael. Nothing is registered locally;
   the comet retries its attestation, and by the time verification
   lands the peer is promoted through `+sy-publ` via either the
   `%sybl` `%full` verdict or the `%public-keys` gift.
2. **Known to jael** at this life or later: just (re)subscribe to its
   public keys. (Marked XX: an equal-or-lower-life re-attestation may be
   where groundwire breach handling slots in later.)
3. **Vanilla first contact**: full local verification
   (`fig`-hash-to-`@p`, signature, life 1) and immediate registration
   (`+al-register-comet` / inline `on-publ-full`), as before.

Intake hardening added while "triple-checking" per todo: the mesa path
now asserts `sndr`/`rcvr`/`rcvr-life` consistency between packet and
scry path, and the `fig:ex:cic` = `@p` binding, which previously only
the legacy path checked.

Boot: `+sy-init` adds `[%pass /sybl %j %sybl ~]` alongside the existing
`/turf`, `/private-keys`, `/public-keys`, `/fief` subscriptions.

Verdict handling (`+sy-sybl`, routed from both vane cores via the
`/sybl` wire and the widened `[%jael %writ *]` sign):

- `%full` — funnel `[%full (my [ship point]~)]` into `+sy-publ`, i.e.
  the *same* path as existing comet attestations and Jael keys gifts:
  aliens are promoted, queued pokes/peeks drain, `%nail` goes to vere.
- `%fail` — **additive** snub (put into the `%deny` set, or delete from
  an `%allow` set — deliberately not the wholesale `%snub` task
  semantics) and drop the `%alien` entry (pending requests) from both
  `chums` and `peers`. A known peer is untouched.
- `%lost` — traced no-op, per todo ("just stub this case out").

### 2.5 Serving our own attestation

A comet answers `/pawn/proof/...` peeks (`+peek-pawn`, mesa) and builds
`+attestation-packet` (legacy) from `pass.ames-state` — **unchanged**.
The domain needs no separate plumbing: it is baked into the pass at
keyfile-generation time, so whatever booted the comet already committed
it.

### 2.6 Refreshing our attestation: the `%anew` flow

The immutable tweak (`dat`) never changes, but the reveal log (`xtr`)
must grow whenever our ownership sat moves. The kernel entrypoint is
the Ames task `[%anew ~]` (manual/dojo for now; XX auto-fire when a
peer rejects a stale attestation):

```
ames %anew task
  -> +pass-pki-dom on pass.ames-state (no-op for vanilla ships)
  -> %pass /sybl %j [%anew dom]
jael
  -> registered + live?  %jael-anew poke to the domain agent
agent (async: reads its own chain state)
  -> %anew-response fact [dom=@tas =pass] on the %anex watch path
jael
  -> [%sybl %anew dom pass] gift to %sybl subscribers
ames +sy-sybl %anew
  -> assert (fig:ex pass) is still our name (tweak unchanged)
  -> pass.ames-state := pass
```

Subsequent open-packets and `/pawn/proof` peeks carry the fresh log.
XX: the updated pass is not persisted to the boot keyfile; after a
breach-and-reboot the agent re-derives it and one `%anew` round-trip
restores it.

## 3. End-to-end flows

**First contact, confidential comet.** ~zig (confidential) pokes a plea
to ~mun. ~mun's Ames sees an alien pawn, requests its proof
(`+al-read-proof` peek via its sponsor galaxy). ~zig serves its
open-packet; `+al-take-proof` validates shape/sig/fig, scries `%pynt`
(nothing), branches confidential: `%public-keys` sub + `%writ`. Jael
looks up `%bitcoin` in `dos`, pokes `%urb-watcher` with `%jael-writ`.
The agent decodes the attestation from the pass tweak, runs its verify
thread against the Bitcoin node, and gives
`[%writ-response %bitcoin ~zig `point]` on its watch path. Jael stores
the point (feel → `%public-keys` gifts), adds ~zig to `hep`, and gives
`[%writ %full %bitcoin ~zig point]` on `/sybl`. Ames `+sy-sybl` funnels
the point into `+sy-publ`; ~zig's pending state drains and traffic
flows.

**Fraudulent attestation.** Same until the agent's thread fails a check:
`res=~` → Jael gives `%fail` → Ames snubs the claimed `@p` additively
and deletes its alien todos. Retransmitted attestations are now dropped
at the packet layer (snub check).

**Unknown domain.** A comet claims `dom=%dogecoin`; no `%anex` was ever
done. Jael immediately gives `%lost`; Ames traces and no-ops. The alien
entry stays pending (and will eventually be trimmed) — deliberately
minimal per todo.

**Key rotation (new life).** ~zig moves its sat with a new key at life
2 and re-attests. Receivers know life 1, so `(lth 1 2)` routes to
`%writ` again; on success the stored point's `%keys`/`%rift` update via
the same feel path, and `%public-keys` `%diff`s go out.

**Troubleshooting / compromise.** Operator (or later, automation) sends
`%gost %bitcoin`: Jael leaves `%urb-watcher`'s path, snubs `hep`.
`%ghul` undoes it. `%bane` deletes the registration and the domain's
points, breaches (`%ruin`-style broadcast) and snubs its ships.
`%hand` re-points the domain after an agent migration (e.g. to
`%urb-watcher-2`).

## 4. Open questions / deferred (proposal items)

1. **Agent liveness / Gall affordances — RESOLVED** (cyc/cc-draft-2):
   causal flow from Gall to Jael via the `%view` subscription (§2.2).
   Remaining loose ends: `%view` has no unsubscribe, so Jael's
   subscription outlives a `%bane`/nuke deregistration (gifts for
   unregistered domains are ignored); and `ap-nuke`'s kicks land
   before the `%view %nuke` gift, so Jael may harmlessly resubscribe
   to a just-nuked agent's watch path (negative `%watch-ack`, logged).
2. **Additive `%snub` in the Ames task API.** `%gost`/`%ghul`/`%bane`
   currently emit the wholesale `%snub` task, which clobbers manual
   blocklists (`%ghul` clears the whole list). `+sy-sybl` already snubs
   additively by editing the set directly; the task API wants
   `[%snub ?(%add %del %set) form ships]`. Marked XX at the emit sites.
3. **Agent-side `%jael-writ` handling.** `%urb-watcher` (prototype
   branch `hd/urb-handler`) must grow: a `%noun` poke handler for
   `[%jael-writ dom ship pass]` that decodes the attestation from the
   pass tweak (domain tag at the head, then `$groundwire-pass`-shaped
   payload, see `sur/stealth.hoon`) or — more likely — treats the pass
   as a locator and requests the full `$self-attestation` packet; and a
   `%writ-response` mark/fact in place of the placeholder
   `%attestation-verdict` poke (pseudocode in §7). The
   `%attestation-request` placeholder now has its kernel entry point:
   the `%anew` flow (§2.6) — though auto-firing it when a watched sat
   moves (rather than by manual task) is still TODO.
4. **How much attestation data rides in the pass?** Quantified in §8:
   a fully self-contained SPV log fits ~1 transfer per 1KiB fragment;
   a fetch-based log fits ~5–7. Recommendation there: fetch-based
   entries in a single fragment, with bounded multi-fragment reserved
   for deep histories if self-contained proofs become a requirement.
5. **Groundwire breaches.** Re-attestation at an equal/lower life, and
   the `[?????????]` in the design doc (what a watcher does when a
   tracked sat moves without a new packet), are stubbed at the "known"
   branch XX. The prototype's answer (request a fresh packet, verdict
   either way) needs the kernel entry point from item 3.
6. **Lane on writ-promoted peers.** The vanilla branch records the
   sender's lane (`sy-dear` / manual route); the confidential branch
   promotes via Jael later, with no lane recorded — relying on
   sponsor-forwarding until a direct route is learned. Probably fine
   (comets are relayed anyway); flagged for testing.
7. **Public⇄confidential transitions.** The design doc's open question
   ("do we allow public comets to become confidential?") is answered
   *no* by the prototype (`known-public` refuses packets); the kernel is
   agnostic — it will happily writ anything the agent is willing to
   verify.

## 5. Change inventory (this branch)

- `sys/lull.hoon` — jael: `$writ-result`, `$writ-response`, `%writ`
  gift; `%sybl`/`%gost`/`%ghul`/`%bane`/`%hand` tasks.
- `sys/vane/jael.hoon` — `dos` registry (`$dom-state`), `syl`
  subscriber set (state + migration fixed); `%anex`/`%writ` rewritten;
  new domain-lifecycle task handlers (agent-liveness effects bracketed
  in comments); `%writ-response` fact handling (replacing the
  non-compiling `pass.sot` stash); agent-kick resubscribe;
  `+leave-peer`, `+dom-for-app`; `subscribers-ship` rename completed;
  note type widened for `%snub`.
- `sys/vane/ames.hoon` — `$open-packet` unchanged; suite `%c` is the
  groundwire discriminator; `+pass-pki-dom` extracts the tweak-committed
  domain; `+sift-open-packet` life-1 relaxation for suite `%c`;
  `+al-take-proof` cleaned up and hardened; `%writ` task args fixed to
  lull's shape; `+on-hear-open` mirrored (incl. higher-life
  re-attestation); `/sybl` boot subscription; `+sy-sybl`; sign/wire
  routing for `[%jael %writ *]`.
- `sur/stealth.hoon` — documented as a non-built design sketch, synced
  with the authoritative types (tweak encoding described).

## 6. Verification

Not yet compiled or booted (draft). To verify:

1. Build a pill / boot a fakeship with this kernel; confirm jael and
   ames compile (`|mass`, or just successful boot).
2. On a fakeship: `|pass [%j %anex %bitcoin %urb-watcher /jael]`, then
   feed a `%writ` and a hand-rolled `%writ-response` fact from a stub
   agent; check `%sybl` gift delivery and point storage via `%pynt`.
3. Two-fakeship (or aqua) run with the `hd/urb-handler` desk once the
   agent grows its `%jael-writ` handler (item 3 above): end-to-end
   first-contact flow, then a `%fail` path (corrupt attestation) to see
   the snub land (`/ax/snubbed` scry).
4. `%gost`/`%ghul`/`%bane`/`%hand` exercised from dojo against the
   registered domain.

## 7. Agent-side verification (pseudocode)

What `%groundwire` (né `%urb-watcher`) does with a `%jael-writ` poke.
The point: **the pass alone, plus the agent's own view of the chain,
suffices** — no fetch of a wider `$self-attestation` structure is
needed. The packet-level sndr/rcvr names and lives exist only for
kernel-level handling; the agent reconstructs name and life from first
principles and the kernel cross-checks.

```
++  handle-jael-writ
  |=  [dom=@tas who=ship =pass]
  ::  runs in a khan thread; %writ-response fact on completion
  ::
  ::  1. decode the pass (mirror of +com:nu:cric)
  [ugn cry dat xtr]  (parse-cric-pass pass)      ::  'c' tag asserted
  [dom' spawn-sont]  (rub-decode dat)
  ?.  =(dom' dom)         (respond who ~)        ::  domain mismatch
  ::  2. the name must be the hash of the tweaked key
  ::     (jael/ames already checked this; re-derive, don't trust)
  sgn  (scap ugn (shax (cat 3 ugn dat)))         ::  tweaked signing key
  ?.  =(who (fig sgn))    (respond who ~)
  ::  3. walk the reveal log: spawn -> tip
  ::     each entry proves one key-path spend of the ownership sat
  sont  spawn-sont
  life  1
  keys  (parse-spawn-keys reveal.entry-0)        ::  %spawn sotx: initial pass
  |-  for entry in (parse-reveal-log xtr)
    ::  a. locate the tx: self-contained (verify merkle proof against
    ::     our header chain at block.entry) or fetch-based (fetch
    ::     txid.entry from our node, confirm block height)
    tx  (obtain-tx entry)
    ?.  (spends tx sont)  (respond who ~)        ::  gap in the chain
    ::  b. the spent output's key must commit to the revealed leaf:
    ::     Q == P + H_TapTweak(x(P) || leaf-hash(reveal.entry)) * G
    ::     and the tree must be provably sparse (root == leaf hash)
    ?.  (leaf-commits (output-key tx sont) reveal.entry)
      (respond who ~)
    ::  c. interpret the revealed sotx
    ?-  (parse-sotx reveal.entry)
      %no-op  ::  plain custody transfer, key unchanged
              sont := (advance-sont tx sont)
      %keys   ::  key rotation: new messaging pass, life bump
              keys := (put keys +(life) new-pass), life := +(life)
              sont := (advance-sont tx sont)
      %spawn  ?.  =(sont spawn-sont)  (respond who ~)   ::  only first
              sont := (advance-sont tx sont)
      *       (respond who ~)         ::  escapes etc: future work
    ==
  ::  4. the tip must be unspent *on our view of the chain*, and no
  ::     later spend of the sat may exist (the log must be complete)
  ?.  (utxo-live sont)    (respond who ~)
  ::  5. the pass's messaging key must be the latest attested one
  ?.  =(cry (latest keys))  (respond who ~)
  ::  6. verdict: the verified point
  (respond who `[rift=0 life=life keys=keys sponsor=`(sein who) fief=~])
::
++  respond
  |=  [who=ship res=(unit point)]
  (give-fact /jael %anew-response ... | %writ-response [dom who res])
```

`%jael-anew` is the dual: re-encode *our own* pass with
`(cat 0 old-dat)` unchanged and `xtr` extended by the entries the
watcher has indexed since the last encoding, then fact
`[%anew-response dom pass]`.

## 8. Attestation sizing and fragmentation

How many reveal-log entries fit in one ~1KiB mesa fragment? Fixed
overhead first: the `$open-packet` wrapper (sndr/rcvr/lives, jam
structure) plus the pass's fixed fields (`'c'` tag, `ugn` 32B, `cry`
32B, `dat` ≈ 45B for a mat-encoded domain tag + satpoint) and the
64B signature come to **≈ 230B**, leaving **≈ 790B** of fragment for
`xtr`.

**Variant A — self-contained SPV entry**
`[txdata envelope-datapush-reveal merkle-proof-hashes block-number]`:

| field | size |
|---|---|
| txdata (1-in/1-out P2TR key-spend, full serialization) | ~161 B |
| tapleaf reveal (leaf version + script with sotx datapush) | ~60–100 B |
| merkle path, 32B × ⌈log₂(~2–4k txs/block)⌉ = 11–12 hashes | ~352–384 B |
| block number | 4 B |
| noun/jam overhead (~10%) | ~60 B |
| **total** | **~640–710 B** |

→ **1 entry per fragment** (the first fragment holds *none* after
overhead; a spawn-only comet just fits). Every sat transfer costs
roughly one additional fragment.

**Variant B — fetch-based entry** `[txid block-number reveal]`
(agent required to fetch the tx from a full node / indexer it
trusts-but-verifies, not just from an up-to-date local light client):

| field | size |
|---|---|
| txid | 32 B |
| block number | 4 B |
| tapleaf reveal | ~60–100 B |
| jam overhead | ~10 B |
| **total** | **~106–146 B** |

→ **~5–7 entries in the single-fragment attestation** (≈790B / ~128B),
~7–8 per additional KiB. A comet that has moved its sat five times
still fits first-contact-in-one-fragment.

**Recommendation**: variant B in the pass. Verification is already
asynchronous (khan thread), so the extra fetches cost latency, not
protocol complexity — and the entries stay small enough that the
common case (0–5 transfers) never fragments. Variant A's
self-contained proofs matter mainly for off-Urbit verifiers (EUDI
thought experiment); those consumers can be served the fat form out of
band rather than in the handshake.

### Multi-fragment interactions with unverified peers

Is relaxing the mesa 1-fragment assertion for first-contact
attestations a DOS vector? **Yes, but a bounded and familiar one** —
it is exactly IP-fragmentation-style reassembly-state exhaustion:

- Fragments from an unverified peer are unattributable until the full
  pass reassembles (the name commits only to `dat`, and the packet
  signature can only be checked against the complete pass), so an
  attacker can open arbitrarily many partial reassemblies from
  invented names at ~zero cost. The name-check on `dat` in fragment 1
  is *not* a gate: generating a fresh (ugn, dat) pair per packet is
  free.
- Mitigations are standard: a fixed-size LRU reassembly pool reserved
  for unverified peers (e.g. 1024 slots × 8KiB cap ≈ 8MiB bounded
  memory), per-source-lane rate limits, short TTL, and a hard cap on
  attestation size (e.g. 8 fragments ≈ 50+ transfers under variant B).
  Attackers can then evict each other — and honest *new* handshakes —
  but cannot touch established peers or ship memory beyond the pool.
- Net effect: griefing of first contacts under active attack, no
  resource exhaustion. Acceptable, but **not free**: it adds a
  reassembly pool and eviction policy to mesa's currently stateless
  unverified-peer path.

Given variant B makes the common case single-fragment, the pragmatic
order is: ship variant B without touching mesa; add the bounded pool
only when deep-history comets (or variant-A consumers) actually
appear.
