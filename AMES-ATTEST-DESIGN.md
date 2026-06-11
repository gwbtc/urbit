# Workstream A — Ames suite gate + Bitcoin attest cycle

Branch: `gw/cc-attest` (off `gw/next/kelvin/408`).

## Implementation status (Stage 1 — landed)

The security-critical core is **implemented** in `pkg/arvo/sys/{lull,vane/ames}.hoon`:

- **`%30 → %31` state migration** — `attest=(map ship attest-state)` and
  `bad=(map ship @da)` added to the axle (lull:1619); frozen `axle-30` +
  `state-30-to-31` (bunt-and-override, not the `%=`-add the spec sketched —
  that can't add faces) + molt/load/stay wiring.
- **The suite gate** (`on-hear-open`) — reads the suite byte; a suite-C comet
  that isn't already Jael-known is **never bare-accepted**. It is held in
  `attest` with a `~m15` deadline (no peer install), and slogged
  (`ames: holding suite-C comet <who> pending Bitcoin verification`). Suite-B/-A
  comets are accepted bare, unchanged. Recently-suspended comets (`bad`, lazy
  expiry) are dropped.
- **Verdict handlers** (`sy-attest-verdict` / `sy-attest-request`) + the task
  router + lull `$task` constructors. ok → clear the hold (the peer is/will be
  installed by the Jael ride); not-ok → suspend for `~d1` + tear down + `%nail`.
- **Idempotent clear on the Jael ride** (`on-publ-full` / `on-publ-rekey`) — the
  primary SUCCESS path: `%urb-watcher` verifies the packet → feeds Jael → Jael
  `%public-keys` installs the peer **and** clears the `attest` hold. This reuses
  exactly the path C-M2 already proved works.
- **Behn timeout** (`on-take-wake`, `[%attest @ ~]`) — a hold that outlives its
  deadline drives a negative verdict (suspend); early-wake guard makes re-arms
  safe.

**Design choice: strict, not provisional.** The original sketch installed the
suite-C peer provisionally (for `/atst` transport) then tore it down on failure.
We instead **do not install at all** until verified — strictly matching "a
suite-C comet must not be accepted on the bare self-attestation." The peer is
installed only via the Jael ride after Bitcoin verification.

**Stage 2 (deferred): the `/atst` auto-fetch transport** (spec Edits 5-7 —
`request-atst` plea, `fo-sink-plea` responder, `on-take-boon` relay). In Stage 1
the comet's off-chain packet reaches `%urb-watcher` via the existing eyre POST
(how the harness and Causeway already deliver keyfiles); `/atst` is the
production transport that makes first-contact fully automatic. It is the
riskiest part (inter-ship plea/boon, fakeship-untestable) and is left as the
clearly-scoped next step.

**Testing.** Compile + the `%30→%31` migration are checked on a fakeship
(`|commit %base` after a fast pill boot reloads the kernel and runs the molt).
Live behaviour is exercised by `python3 -m gwharness gate` (harness): a
new-kernel comet holds an unverified suite-C peer, then either suspends it
(injected negative verdict) or installs it after Bitcoin verification (the Jael
ride). The verdict path is driven over conn (`lanes.inject_attest_verdict`),
decoupling the gate test from the urb-watcher rewiring (spec Edit 10, also
deferred — it couples the desk to the new kernel's lull).

---

## Original design (full cycle, for reference)

This document pins every change to an exact arm so the diff
is reviewable and so the cycle can be implemented and compile-checked against a
fakeship (`urbit -F zod -B bin/solid.pill -A pkg/arvo`, then `|commit %base`).

The harness (groundwire `testnet/`) is the live test rig: scenario "native
first-contact" and the suite-gate pair (see `testnet/gwharness/scenarios.py`)
exercise this end-to-end once it lands. Until then the harness delivers packets
out-of-band over eyre (`%self-attestation` / `%attestation-keyfile` POST), which
already validates the *verifier* — the half this workstream wires to Ames.

## The security property (user directive)

> All suite-B comets are treated as non-Groundwire, and all suite-C comets must
> provide a Groundwire attestation. If a suite-C comet could provide the usual
> Ames self-attestation, it could be lying about its non-Groundwire-ness.

A comet's @p is `SHAF` over its networking key. A **suite-C** key embeds a
Bitcoin satpoint claim (the Groundwire tweak); a **suite-B** key does not.
Accepting a suite-C comet on the bare Ames self-attestation (crypto-only) would
let it assert its identity — and thereby its (false) non-Groundwire-ness —
without proving the on-chain ownership its key commits to. So:

- **suite B → upstream path unchanged.** Bare self-attestation accepted; this
  is, explicitly, a non-Groundwire comet.
- **suite C → must verify.** Never installed on crypto checks alone; always
  enters the attest cycle below. A suite-C comet already known to Jael (its
  keys were verified before and are in the PKI) still bypasses via the existing
  `/lyfe` scry — that path is authoritative.

## Where the suite is already read

`on-hear-open` (`pkg/arvo/sys/vane/ames.hoon:4706`) already decodes the suite
byte at line 4733:

```hoon
=/  crypto-suite=@ud  (sub (end 3 pass.open-packet) 'a')
```

`'a'`→0, `'b'`→1 (suite B), `'c'`→2 (suite C). The lines that follow
(4734-4760) are the **crypto-only bare-accept**: build a `point` from the
packet's `pass`, install it via `sy-publ` (mesa) / `on-publ-full`, set the lane,
mark `%known`, emit `%nail`. **This block is exactly what must be gated.**

## The attest cycle

State (axle-level, `ames-state`), gated behind the `%31` migration:

```
attest=(map ship attest-state)     :: in-flight verifications
bad=(map ship until=@da)           :: suspended suite-C comets (lazy expiry)
```

```
+$  attest-state
  $:  stage=?(%fetch %verify %grace)   :: fetch packet / awaiting verdict / re-attest
      lane=lane                         :: provisional transport lane
      deadline=@da                      :: behn timeout for this stage
  ==
```

`bad` is separate from user-managed `snub`; it is the kernel's own suspension
of suite-C comets that failed or timed out, with lazy expiry.

### 1. Gate + provisional install (`on-hear-open`, replacing 4732-4760)

```hoon
=/  crypto-suite=@ud  (sub (end 3 pass.open-packet) 'a')
::  suite C: do NOT trust the bare packet. Install a PROVISIONAL %known peer
::  (so the channel can carry the /atst request+response), record an attest
::  entry, and request the comet's Bitcoin self-attestation packet.
?:  =(crypto-suite 2)
  =.  event-core  (install-provisional sndr.shot open-packet lane)
  =.  event-core  (request-atst sndr.shot)               :: send the /atst plea
  =.  attest.ames-state
    (~(put by attest.ames-state) sndr.shot [%fetch lane (add now ~m2)])
  (set-attest-timer sndr.shot (add now ~m2))
::  suite B and below: ordinary non-Groundwire comet — accept bare (unchanged).
=.  event-core  (install-known sndr.shot open-packet lane)   :: the old 4732-4760
event-core
```

`install-provisional` reuses the same `sy-publ`/point-install as the old block
(the channel needs working keys to carry transport); the difference is the
`attest` entry marking it unverified and the `bad`/teardown on failure.

### 2. Transport: `/atst` internal plea  (rejected alternatives below)

A new internal vane plea carries the opaque packet; the kernel never parses it.

- Requester: `[%pass /atst/(scot %p who) %a %plea who [%$ /atst ~]]`.
- Responder: serves it by scrying its own watcher —
  `(rof ... %gx /urb-watcher/keyfile/noun ...)` (the eyre `do-scry` precedent) —
  and replies `[%boon [%atst (unit *)]]`.
- Requester's boon handler pokes `%urb-watcher` with the packet (step 3).

Rejected: extending `open-packet` (blows the MTU); remote-scry (the packet
changes per sat-move at constant life — immutability violation); plain
agent-to-agent (gall state with an unverified peer).

### 3. Dispatch to the verifier  (`%g %deal`, the poke-ping-app pattern)

```hoon
:*  %pass  /attest/(scot %p who)  %arvo  %g
    %deal  [our our]  %urb-watcher
    %poke  %self-attestation  noun+!>(packet)
==
```

`%urb-watcher` **soft-casts** the vase (it arrives as a noun cage), runs the
existing verify thread, and reports back.

### 4. Verdict transport: urb-watcher → ames kernel tasks

`%urb-watcher` already emits the verdict — today as placeholder pokes of a
nonexistent `%ames` *agent* (`app/urb-watcher.hoon:772,781`, nack-swallowed at
:566). Convert those two passes to **kernel tasks**:

```hoon
::  app/urb-watcher.hoon
[%pass /attest/verdict/(scot %p who) %arvo %a [%attest-verdict who ok]]
[%pass /attest/request/(scot %p who) %arvo %a [%attest-request who]]
```

and delete the `on-agent` nack-swallow (:566). Add the matching tasks to
`$task:ames` in `pkg/arvo/sys/lull.hoon` after `[%goad =ship]` (:943):

```hoon
[%attest-request who=@p]    :: ask the kernel to (re-)request a comet's packet
[%attest-verdict who=@p ok=?]  :: the watcher's Bitcoin verdict
```

Dispatch them in the task router beside `%dear`
(`pkg/arvo/sys/vane/ames.hoon:8819`):

```hoon
%attest-verdict  sy-abet:(sy-attest-verdict:sy-core +.task)
%attest-request  sy-abet:(sy-attest-request:sy-core +.task)
```

### 5. Completion / suspension (`sy-attest-verdict`)

```hoon
++  sy-attest-verdict
  |=  [=ship ok=?]
  ?~  (~(get by attest.ames-state) ship)  sy-core    :: stale verdict, ignore
  =.  attest.ames-state  (~(del by attest.ames-state) ship)
  ?:  ok
    sy-core                                           :: provisional install stands; now verified
  ::  negative: tear down the provisional peer, suspend, clear lanes
  =.  peers.ames-state  (~(del by peers.ames-state) ship)
  =.  bad.ames-state    (~(put by bad.ames-state) ship (add now ~d1))
  (sy-emit unix-duct %give %nail ship ~)              :: empty lanes
```

Idempotency: a Jael `%public-keys` gift (from the watcher's udiffs on the happy
path) also clears the `attest` entry in `on-publ-full`/`on-publ-rekey`, so
verified-ness rides both the explicit verdict and the PKI update.

### 6. Re-attestation = grace, not gate (`sy-attest-request`)

`%attest-request` on a known ship → `%grace` attest entry + a fresh `/atst`
plea; traffic continues; fail/timeout → suspend. Initiation is pull-symmetric:
both-unknown first contact is two concurrent cycles (existing `%dear`/
alien-agenda machinery already triggers the peer's open-packet).

### 7. Timeouts (one constants section)

`%fetch ~m2`, `%verify ~m15`, `%grace ~m30`; `behn` deadline per `attest`
entry, lazy `bad` expiry on next contact.

### 8. Migration `%30 → %31`

Freeze `axle-30`, molt the chain adding `attest`/`bad` (both empty), update both
`stay`/`load` arms. Mesa mirrors in `al-take-proof`/`fo-sink-plea`/
`ev-req-plea`.

## Tests (`tests/sys/vane/ames.hoon`)

1. suite-B comet → bare-accepted `%known` (unchanged path).
2. suite-C comet, no packet → stays provisional, never trusted; `%fetch`
   timeout → `bad`, lanes cleared.
3. suite-C comet, `/atst` boon → `%g %deal` poke emitted to `%urb-watcher`.
4. `%attest-verdict ok=%.y` → entry flushed, peer stays `%known`.
5. `%attest-verdict ok=%.n` → peer torn down, `bad` set, empty `%nail`.
6. Jael `%public-keys` gift clears a pending `attest` entry (ride).
7. `%attest-request` on known ship → `%grace` + fresh plea, traffic uninterrupted.
8. `%30→%31` migration molts cleanly; both `stay` arms round-trip.
9–10. mesa mirrors for the plea/boon path.

## Why this isn't landed live yet

The cycle spans two repos and is catastrophic-if-broken (a wrong edit to
`on-hear-open` breaks *all* comet networking). The bar for merging an ames edit
is: compiles on a fakeship, the migration molts, and the harness's native
first-contact + suite-gate scenarios pass. This session delivered the verifier
(the hard correctness core) end-to-end and the harness that will gate this
change; the kernel wiring is the well-specified next step, not a guess.
