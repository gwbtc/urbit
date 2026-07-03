# Confidential Comets: Kernel Integration Spec & Proposal

Status: **draft** (branch `cyc/cc-draft`)
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
local gall agent, registered with Jael per domain tag (e.g. `%bitcoin` →
`%urb-watcher`), owns all chain knowledge. The kernel only:

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
   |                              |<---%writ gift (/sybl)----|  give verdict to %sybl subs
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
  `%c` was upstreamed for precisely this). The key's **tweak data**
  (`dat.tw` of the cric core) carries, at its head, the `+mat`-encoded
  PKI domain tag — extracted by the receiving Ames with `+rub`
  (`+pass-pki-dom`) — followed by the domain-specific attestation data.

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

New top-level state (`state-4`):

```hoon
dos=(map @tas dom-state)
+$  dom-state
  $:  dap=term          ::  verifier agent
      pax=path          ::  watch path
      hep=(set ship)    ::  ships verified through this domain
  ==
```

plus `syl=(set duct)` in `zim` — the `%sybl` (writ-result) subscriber
set. Both are initialized empty by the `%3`→`%4` migration (which the
stashed scaffold had left non-typechecking; it is now an explicit
construction).

**Agent liveness is deliberately bracketed** (commented out at the
`$dom-state` definition and the `%gost`/`%ghul`/`%bane` handlers): a
suspended domain should also stop being watched and refuse `%writ`s
(`liv=?` flag), and `%bane` should stop the agent itself. Whether Jael
*drives* the agent's state (task → effect on agent) or *reacts* to it
(subscribing to agent status through future Gall affordances) is an
open design question — see §4. Until then, `%gost`/`%ghul` act only on
the domain's peers, and Jael's subscription to the agent stays up.

### 2.3 Task/gift API (lull)

| Task | Meaning |
|---|---|
| `[%anex dom dap pax]` | register a PKI domain: `dap` verifies writs, jael watches `pax` for its responses and chain updates |
| `[%writ dom ship pass]` | verify an attestation: poke the domain agent with `[%jael-writ dom ship pass]`; unknown domain → immediate `%lost` verdict. `dom` is what Ames extracted from the pass tweak |
| `[%sybl ~]` | subscribe to all writ verdicts (Ames does this once at boot, in `+sy-init`) |
| `[%gost dom]` | suspend a domain: `%snub` its verified peers; registration and peer set retained. (Agent suspension bracketed, §2.2) |
| `[%ghul dom]` | recover from `%gost`: mass-unsnub. (Agent resumption bracketed) |
| `[%bane dom]` | destroy a domain (DOS attack / compromised PKI): deregister, delete its ships' points, `%breach`-broadcast (a la `%ruin`) and `%snub` them. (Agent stop/nuke bracketed) |
| `[%hand dom dap pax]` | re-point a domain at a new agent or watch path |

New gift, to `%sybl` subscribers:

```hoon
[%writ =writ-result]
+$  writ-result
  $%  [%full dom=@tas =ship =point]   ::  verified; point now in jael
      [%fail dom=@tas =ship]          ::  failed validation
      [%lost dom=@tas =ship]          ::  unknown/suspended domain
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

1. **Agent liveness / Gall affordances.** The `liv` flag and every
   place Jael would act on (or react to) the domain agent's runtime
   state — un-watching on `%gost`, re-watching on `%ghul`,
   stopping/nuking on `%bane`, refusing writs and dropping udiffs from
   a suspended domain — is bracketed in comments. The open design
   question: should a `%gost` task *cause* the agent's suspension, or
   should Jael *subscribe to agent status* (suspended → `%gost`
   semantics, nuked → `%bane` semantics) once Gall grows an affordance
   for that? To be covered in a discrete later step.
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
   `%attestation-verdict` poke. The `%attestation-request` placeholder
   (asking Ames to fetch a fresh packet when a watched sat moves) still
   needs a kernel entry point — probably a Jael task that triggers
   `+al-read-proof`.
4. **How much attestation data rides in the pass?** The full
   `$self-attestation` chain can be large (up to 1024 links in the
   prototype), while the mesa proof path asserts a 1-fragment (≤1KiB)
   packet. Either the pass tweak carries a compact form (domain tag +
   satpoint + reveal log, as `$groundwire-pass` sketches) with the
   agent fetching txs itself, or the attestation must be fetched as a
   multi-fragment message rather than carried in the open-packet.
   **This is the biggest unresolved sizing question.**
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
