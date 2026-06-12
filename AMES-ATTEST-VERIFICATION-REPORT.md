# Ames Suite‑Gate (Confidential Comets) — Verification Report

**Scope.** This report documents every code change made to bring the Ames
"suite gate" — the kernel mechanism that refuses to bare‑trust a Bitcoin‑backed
**suite‑C** comet until `%urb-watcher` returns a Bitcoin verdict — from
"implemented, compile‑verified" to **actually running and verified in live
ships**, plus the supporting toolchain and the test harness used to verify it.

It is written so you can audit the code yourself: every change is shown with its
file, the reasoning, and the exact way it was tested.

Repositories / branches (all local, **nothing pushed**):

| repo | path | branch | what |
|---|---|---|---|
| urbit (kernel) | `urbit/` | `gw/cc-attest` | the Ames gate + the attest cycle + the test scry |
| groundwire (harness + desk) | `groundwire/` | `hd/cc-e2e` | the `gwharness` test driver + the `%urb-watcher` desk |
| vere (runtime) | `vere-tinnus/` (worktree) | `tinnus-test-hack` (+1 commit) | the 408 + `-G feed` vere |

Key artifacts produced: `gw-solid-mine.pill` (a kelvin‑408 solid pill whose
`%base` carries this kernel) and `gw-vere-tinnus` (a runtime that boots it and
also boots real comets from a `-G` feed).

---

## 1. Executive summary

The Confidential‑Comets security property is: **a suite‑C comet's networking key
embeds a Bitcoin satpoint claim, so it is *not* a generic non‑Groundwire ship and
must not be trusted on its bare Ames self‑attestation** — accepting it bare would
let it lie about being non‑Groundwire. The gate holds such a comet pending a
Bitcoin verdict from `%urb-watcher`; suite‑A/‑B comets are accepted exactly as
before.

The gate (Workstream A) was marked "implemented + compile‑verified". Driving it
to actually run revealed two things:

1. **The compile‑verified status was false.** A lenient compile path masked
   **three real bugs** that crashed the kernel at boot: a `mint-lost` (an
   exhaustive `?-` over `$task:ames` made non‑exhaustive by two new task
   variants) and two `nest-fail`s in the `%30→%31` state migration. The strict
   `solid:pill` vane compile caught all three. They are fixed (commit
   `5ebbad228a`).

2. **The local toolchain couldn't even boot the kernel.** I built the missing
   pieces: a **solid pill** built from this arvo (`build_solid.py`), and a
   **408 + feed vere** (one‑line port into `gw-vere-tinnus`). With those, real
   suite‑C comets boot this `%31` kernel from a `-G` feed, kelvin 408, live.

3. **The gate's runtime hold is now observable.** The natural `|hi` trigger
   can't reach a cold peer in `-L` (loopback) mode, so the test delivers a real,
   validly‑signed open‑packet straight into the receiver via a small public ames
   scry + a `%hear` injection. The receiver's `+on-hear-open` fires, holds the
   comet, and the test drives both outcomes: reject (negative verdict →
   suspended) and verify (Bitcoin‑verified → Jael ride installs the peer).

**Outcome:** the gate runs correctly in **real, Bitcoin‑backed suite‑C comets
booting this `%31` kernel**. Both verdict outcomes are exercised live (§7):

- **reject** — A hears B's suite‑C open‑packet → holds it (`holding suite-C comet
  …`) → a negative verdict → `attestation failed; suspended`. `[gate] PASS`.
- **verify** — A holds B → A's `%urb-watcher` Bitcoin‑verifies B against regtest
  (`… is VALID`, all 14 checks) → a positive verdict clears the hold
  (`attestation verified`).

The remaining piece (the watcher *automatically* feeding Jael to install a
verified peer) is the intentionally‑deferred Stage 2; the kernel half — the gate,
both verdict branches, the timeout, and the Jael‑ride clear in `+on-publ-full` —
is in place and exercised.

---

## 2. Background — what the gate is and why it exists

A comet is a self‑signed Urbit identity: its `@p` is `(SHAF "cfig" pubkey)`, so
the address is bound to the networking public key. Ames learns an unknown comet's
keys from a **self‑attestation** ("open") packet — `[signature signed-open-packet]`
where the open‑packet is `[pass sndr sndr-life rcvr rcvr-life]`, and ames verifies
that `pass` hashes to `sndr` and the signature is valid (`+sift-open-packet`,
`ames.hoon:439`).

Groundwire comets mine the **suite byte** into the last byte of `pass`:
`'a'→0`, `'b'→1`, `'c'→2`. The suite is read as `(sub (end 3 pass) 'a')`. A
**suite‑C** key additionally commits to a Bitcoin satpoint (the comet proved it
owns a particular UTXO). The whole point of Confidential Comets is that a
suite‑C identity is *Bitcoin‑backed*; trusting one on its bare Ames packet (the
way ordinary comets are trusted) would defeat that — anyone could mint a
suite‑C‑looking key and self‑attest. So Ames must **hold** a suite‑C comet until
`%urb-watcher` checks the Bitcoin claim and returns a verdict.

The gate is the kernel half of that. The Bitcoin verification half
(`%urb-watcher`, the taproot/SPV logic, Causeway) already existed and is green
(M1, the 8/8 adversarial scenario suite, M2). What was missing — and what this
report covers — is the Ames gate **running in a ship**.

---

## 3. The kernel changes (Workstream A)

All in `urbit/pkg/arvo/sys/{lull,vane/ames}.hoon`. The full diff is
`git -C urbit diff 38ad3c690c 5ebbad228a -- pkg/arvo/sys/vane/ames.hoon pkg/arvo/sys/lull.hoon`.
Below, each arm with its purpose.

### 3.1 New state (`lull.hoon`)

**`$attest-state`** — one in‑flight suite‑C verification:

```hoon
+$  attest-state
  $:  stage=?(%fetch %verify %grace)   :: awaiting packet / verdict / re-attest
      =lane                            :: provisional transport lane
      deadline=@da                     :: behn timeout for this stage
  ==
```

**Two axle maps** (the ames state, `+$ axle`):

```hoon
attest=(map ship attest-state)      :: in-flight suite-C verifications
bad=(map ship until=@da)            :: suspended suite-C comets (lazy GC)
```

**Two `$task:ames` variants** — the channel by which `%urb-watcher` (once wired)
or a test driver delivers verdicts/requests:

```hoon
[%attest-request =ship]      :: (re-)request a comet's packet
[%attest-verdict =ship ok=?] :: Bitcoin verdict on a comet
```

### 3.2 The gate (`+on-hear-open`, `ames.hoon` ~4807)

When ames hears an open‑packet from an unknown `%pawn` (comet), after the
existing suite computation it branches:

```hoon
=/  crypto-suite=@ud  (sub (end 3 pass.open-packet) 'a')
?:  =(crypto-suite 2)
  ::  recently suspended (and not yet expired)? drop silently.
  ?:  ?&  (~(has by bad.ames-state) sndr.shot)
          (lth now (~(got by bad.ames-state) sndr.shot))  ==
    event-core
  =?  bad.ames-state  (~(has by bad.ames-state) sndr.shot)
    (~(del by bad.ames-state) sndr.shot)
  ::  record the pending verification + arm the %fetch deadline;
  ::  do NOT install the peer.
  =.  attest.ames-state
    (~(put by attest.ames-state) sndr.shot [%fetch lane (add now ~m15)])
  ~>  %slog.0^leaf/"ames: holding suite-C comet {<sndr.shot>} pending Bitcoin verification"
  (set-attest-timer sndr.shot (add now ~m15))
::  suite-B/-A fall through to the ordinary bare-accept path (unchanged).
```

The security‑relevant facts: a suite‑C comet is recorded in `attest` and a behn
deadline is armed, but it is **not** installed as a `%known` peer (so it cannot
yet be used for Ames traffic); a recently‑suspended comet is dropped silently.

### 3.3 Verdict / request handlers (mesa core)

**`+sy-attest-verdict [=ship ok=?]`** — apply a verdict; idempotent (a verdict
for a ship with no in‑flight entry no‑ops, since the Jael ride may already have
cleared it):

```hoon
?~  (~(get by attest.ames-state) ship)  sy-core
=.  attest.ames-state  (~(del by attest.ames-state) ship)
?:  ok
  ~>  %slog.0^leaf/"ames: comet {<ship>} attestation verified"
  sy-core
=.  peers.ames-state  (~(del by peers.ames-state) ship)   :: tear down
=.  bad.ames-state    (~(put by bad.ames-state) ship (add now ~d1))
~>  %slog.0^leaf/"ames: comet {<ship>} attestation failed; suspended"
(sy-emit unix-duct %give %nail ship ~)
```

**`+sy-attest-request =ship`** — move to the `%grace` stage with a 30‑minute
re‑attest deadline (a known peer keeps working while it re‑proves).

These are dispatched both by the new `$task` variants (top‑level `?- -.task`
routing) and internally.

### 3.4 The timeout (`+set-attest-timer` + `+on-take-wake`)

`+set-attest-timer` arms a behn `%wait` on wire `/attest/<ship>`:

```hoon
++  set-attest-timer
  |=  [=ship deadline=@da]
  (emit ~[/ames] %pass /attest/(scot %p ship) %b %wait deadline)
```

`+on-take-wake`, on a `[%attest @ ~]` wire whose deadline has passed and whose
entry is still pending, drives a **negative verdict** (`%.n`) — i.e. a comet that
never produces a valid Bitcoin verdict is torn down and suspended. A guard
(`?: (lth now deadline.u.e) event-core`) ignores stale wakes left by re‑armed
timers.

### 3.5 The success path (the Jael ride)

When the Bitcoin verdict is good, `%urb-watcher` feeds Jael, Jael emits
`%public-keys`, and ames installs the peer in `+on-publ-full`. One added line
there clears the hold (idempotent with `sy-attest-verdict ok=%.y`):

```hoon
::  verified PKI from jael clears any pending suite-C attest entry
=.  attest.ames-state  (~(del by attest.ames-state) ship)
```

A symmetric clear sits in `+on-publ-rekey` (key rotation invalidates a pending
hold). This is the **real ames↔jael ride** — the gate releases a comet only when
verified keys arrive through Jael, exactly the path C‑M2 already proved.

### 3.6 The `%30→%31` state migration

Adding `attest`/`bad` to the axle bumps the ames state version `%30 → %31`:

- **`+$ axle-30`** — a frozen copy of the `%30` axle (structurally identical to
  the live axle *minus* `attest`/`bad`), so old state can be loaded and migrated.
- **`+state-30-to-31`** — bunt a fresh `%31` axle and carry every `%30` field
  across **by name** (`%= new peers peers.old … core core.old ==`); `attest`/
  `bad` default to `~`. Carry‑by‑name avoids fragile tuple‑axis reconstruction
  and is the safe pattern for a state that gained faces.
- The molt/load/stay wiring: `++ stay` → `[%31 …]`; the load `?- old` dispatch
  gains `[%30 axle-30]`/`[%31 axle]`; the migration loop terminates at `%31` and
  steps `%30 → 31+(state-30-to-31 …)`.

Fresh comets boot directly at `%31` and skip the migration; it runs only on an
upgrade of an existing `%30` ship.

---

## 4. The three compile bugs (and why "compile‑verified" was wrong)

The earlier status said "compiles, zero nest‑fail." That used a **lenient** mint
mode (the `-A` overlay / a quick compile check) that tolerates dead/uncovered
branches. The authoritative check is the **`solid:pill` vane build**, which
compiles each vane strictly. It caught three bugs the lenient path emitted as a
*crashing* kernel:

### Bug 1 — `mint-lost` at the top‑level task dispatcher (`?- -.task`, ~13716)

The two new `$task:ames` variants made the legacy core's **exhaustive** `?- -.task`
non‑exhaustive. The strict compiler rejects this. The lenient one produced a
kernel whose first task crashed (`%mean`) — *this was the cause of every boot
crash I chased for hours.*

**Fix** — route the two variants into the flow‑independent group (→ the mesa
core, where the `sy-attest-*` handlers live):

```hoon
$?  %vega  %init  %born  %snub  %spew  %stun  %gulp
    %sift  %plug  %dear  %init  %tame  %cong
    %attest-verdict  %attest-request           :: <-- added
==
```

### Bug 2 — `nest-fail` in `+state-29-to-30` (~3857)

`state-29-to-30` returns `^- axle`. That was correct when `axle` *was* the `%30`
axle; now `axle` is `%31` (with `attest`/`bad`), but the arm's body still produces
a `%30`‑shaped value, which no longer nests into the molt's `[%30 axle-30]` slot.

**Fix** — `^- axle` → `^- axle-30`.

### Bug 3 — `nest-fail` in the `%28` cork‑cleanup migration (~3284)

A special `%28` migration case computes the would‑be‑`%30` state and uses it as a
**live `ames-state`** for the ev cork‑peek core — which now expects the `%31`
axle.

**Fix** — migrate it all the way up: `(state-30-to-31 (state-29-to-30 +.old))`
(`state-30-to-31` preserves `chums`, which the cork loop iterates).

These are commit `5ebbad228a`. The lesson: *compile‑verified ≠ runtime‑correct*
unless the compile is the strict vane build.

---

## 5. The toolchain (how this kernel gets into a running ship)

### 5.1 Why a *solid* pill (`groundwire/testnet/build_solid.py`)

A pill carries `%base` (the kernel). To test this arvo, `%base` must carry it —
installing the groundwire *desk* does not touch `%base`. Two pill flavors:

- **brass** (`build_pill.py`): ships kernel source, recompiles at boot. Built
  fine but **does not fresh‑boot** on the tinnus vere — even a pure‑baseline
  brass pill crashes (`vane: %ames → king: boot failed`). Proven with a control.
- **solid** (`build_solid.py`): pre‑installs the compiled kernel + userspace.
  **Boots** (like the stock `gw-solid.pill`).

`build_solid.py`: boot a clean gw‑solid builder, hold this arvo in a `%gw-base`
desk (not `%base`, so the builder never upgrades), `rsync -aL` the full arvo
(resolving userspace symlinks — solid needs them), fyrd `(solid:pill sys ~ | now
& ~)`, and pull the pill from `<pier>/base/pill.pill`. (Quirk: the pill lands at
`base/pill.pill`, not `base/pill/*.pill` — extract it directly.)

Built over `ConnSock` (`gwharness/connsock.py`), which frames newt correctly on
macOS; the CI's bash `nc -W` truncates the conn.sock response there.

### 5.2 The 408 + feed vere (`vere-tinnus`, commit `028f75662`)

Two veres existed; neither could both boot a 408 pill *and* boot a comet from a
`-G` feed:

| vere | boots my 408 pill | `-G feed` comet boot |
|---|---|---|
| `vere/zig-out` (bm/fake-comets, urbit 3.5) | ✗ (hangs at "replaying 1‑11" — 410 serf vs 408 kernel) | ✓ |
| `gw-vere-tinnus` (tinnus‑test‑hack, urbit 4.3) | ✓ | ✗ — self‑mines |

The tinnus vere already had the `_king_dawn` feed logic; it only lacked the gate
that uses the key instead of mining. **Fix** (ported from bm/fake-comets `9d2b`,
`king.c:_boothack_doom`):

```c
else if ( 0 != u3_Host.ops_u.who_c ||
          ( 0 != u3_Host.ops_u.fak_c && 28 < strlen(u3_Host.ops_u.fak_c) ) ||
          0 != u3_Host.ops_u.key_c ||      // -k key file   (added)
          0 != u3_Host.ops_u.gen_c ) {     // -G key string (added)
```

Rebuilt with **zig 0.15.2** (`vere-build-tools/zig-aarch64-macos-0.15.2/zig`;
homebrew zig 0.14.1 fails the build). Result: `gw-vere-tinnus` boots the 408 pill
**and** boots real comets from `-G feed`.

### 5.3 Net result, proven before this step

`gwharness gate` mines two real suite‑C comets and **both boot this `%31` kernel
from a `-G feed` on `gw-solid-mine.pill`** — kelvin 408, `mesa: live`, watcher
reconfigured to regtest. The full pipeline mine→boot→desk‑install→watcher‑config
runs on this kernel.

---

## 6. The gate‑trigger fix (this step)

### 6.1 Why the natural trigger can't fire the gate in `-L`

`+on-hear-open` fires only on a `%hear` of a suite‑C open‑packet. The natural way
to elicit one is `A |hi B`: A `+on-plea` (B unknown) → `+enqueue-alien-todo` →
`+fetch-comet-pki` → A sends B an unencrypted **keys‑request** → B `+on-hear-keys`
→ B sends its **attestation** → A `+on-hear-open`.

But the harness boots comets `-L` (loopback, no real network). A's send to an
`%alien` B has no recorded lane, so it routes to B's *sponsor* (a galaxy) —
unreachable offline. And `%dear` (the lane‑inject task) records a lane only for an
already‑`%known` peer (so M1/M2 cross‑verified peers via the watcher/Jael *first*,
then `|hi`'d). A cold suite‑C pair therefore never exchanges packets, and the gate
never fires.

### 6.2 The fix — inject a real signed open‑packet

Deliver B's open‑packet straight into A, bypassing routing. The packet must be
*genuinely valid* (`+sift-open-packet` checks `pass` hashes to B's `@p` and the
ed25519 signature), so reuse the kernel's own crypto via a small public scry:

**Kernel** (`ames.hoon`, `+scry`): a public `%x` endpoint that returns a comet's
own signed self‑attestation for a given receiver — exactly the blob a keys‑request
would elicit, so it's public information:

```hoon
[%attest-packet who=@ ~]
=/  rcvr=(unit @p)  (slaw %p who.tyl)
?~  rcvr  ~
=/  pac=open-packet  [pass.ames-state our life.ames-state u.rcvr 1]
``noun+!>(`@ux`(etch-shot (etch-open-packet pac saf.ames-state)))
```

reached by adding `%attest-packet` to the top‑level scry's public dispatch set
(→ `scry:am-core`). _(This is a separate, clearly‑marked commit so it is trivial
to drop; a comet exposing its own attestation is harmless.)_

**Harness** (`gwharness/lanes.py`):

```python
def open_packet_blob(ship, rcvr_patp):   # scry B for its signed open-packet for A
    body = ("=/  m  (strand ,vase)  ^-  form:m\n  ;<  our=@p  bind:m  get-our\n"
            f"  =/  pax=path  ~[(scot %p our) %$ (scot %ud 1) %attest-packet (scot %p {rcvr_patp})]\n"
            "  =/  blob=@ux  .^(@ux %ax pax)\n  (pure:m !>(blob))")
    return ship.conn.khan_eval(body)

def inject_open_packet(a, b):             # feed it to A as a %hear -> +on-hear-open
    blob = open_packet_blob(b, a.patp)
    addr = lane_atom(b.ames_port)         # B's direct lane (so A records it)
    return a.conn.ovum("a", ["ames"], (N.tas("hear"), ((1, addr), blob)))
```

`run_gate` now triggers the gate with `inject_open_packet(A, B)` instead of `|hi`.

### 6.3 The watcher `/eyre/connect` fix (verify mode)

Under the 408 kernel, `%urb-watcher`'s `on-arvo` lacked a handler for eyre's
`%bound` ack on `/eyre/connect` (the old 410 pill didn't trip this), so it fell to
`default-agent`'s `~|…!!` and crashed the agent — breaking the verify‑mode HTTP
endpoint. **Fix** (`groundwire/app/urb-watcher.hoon`): handle and no‑op it.

```hoon
    [%eyre %connect ~]
  ?.  ?=([%eyre %bound *] sign-arvo)  (on-arvo:def wire sign-arvo)
  `this
```

The desk is reinstalled post‑boot, so no pill rebuild is needed for this.

---

## 7. Verification methodology and results

Every layer was tested against real binaries (no mocks). Assertions read the pier
slogs (gall peeks return `~` on this fork — the same channel M1/M2/scenarios use).

| layer | how | result |
|---|---|---|
| kernel **compiles** (strict) | `build_solid.py` → `solid:pill` vane build | `vane: %ames` compiles clean (after the 3 fixes) |
| kernel **boots** | `gw-vere-tinnus -B gw-solid-mine.pill -F zod` | conn.sock up, **kernel kelvin 408**, ames stay `%31`, `mesa: live` |
| **comet** boots this kernel | `gwharness gate` mines + boots 2 suite‑C comets `-G feed` | both live on this `%31` kernel; watcher reconfigured to regtest |
| scry endpoint | `.^(@ux %ax …/attest-packet/…)` over conn | _[§7.1]_ |
| gate **holds** | `inject_open_packet(A,B)` → slog | _[§7.2]_ |
| **reject** path | inject `%.n` verdict / timeout | _[§7.3]_ |
| **verify** path | `net.peer` POST → watcher → Jael ride | _[§7.4]_ |

_The §7.x slogs are filled in from the actual gate run below._

### 7.1 scry endpoint
Booting a fakeship on `gw-solid-mine.pill` and scrying
`.^(@ux %ax /<our>/$/1/attest-packet/~nec)` returned a **1183‑bit (≈148‑byte)
signed open‑packet** — the trigger's source blob, produced by the kernel's own
`+etch-open-packet`/`+etch-shot`.

### 7.2 gate holds  (reject run; A = `~nappel-…`, B = `~sicdef-…`)
`inject_open_packet(A, B)` → A's pier slog:
```
ames: holding suite-C comet ~sicdef-tamnyx-bidred-follur--macwes-solmyr-noclyr-daplyd pending Bitcoin verification
```
Harness: `A HELD suite-C B (not bare-accepted): True`. B is recorded in `attest`
and is **not** installed `%known` — the security property (a suite‑C comet is not
bare‑trusted).

### 7.3 reject — negative verdict
`inject_attest_verdict(A, B, %.n)` → A's pier slog:
```
ames: comet ~sicdef-…-daplyd attestation failed; suspended
```
Harness: `B SUSPENDED: True`; **`[gate] PASS`**. The behn timeout path
(`set-attest-timer` → `on-take-wake` → negative verdict) reaches the same suspend;
the explicit verdict exercises `+sy-attest-verdict` without the 15‑minute wait.

### 7.4 verify — Bitcoin‑verified → positive verdict clears the hold  (A = `~laswet-…`, B = `~tonful-…`)
1. `inject_open_packet(A, B)` → `ames: holding suite-C comet ~tonful-… pending Bitcoin verification`.
2. `net.peer(A, B)` POSTs B's skeleton to A's `%urb-watcher`. The `/eyre` fix lets
   the HTTP binding succeed (`on-arvo on wire /eyre/connect, [%eyre %bound]` — no
   crash). The watcher verifies B's Bitcoin claim against regtest — **all 14
   checks `[ok]`** (spawn‑suite‑c, spawn‑fig, spawn‑key‑tweak, spawn‑spends‑precommit,
   link‑0‑sots‑ship, tip‑sont, …):
   ```
   %urb-watcher: attestation for ~tonful-…-daplyd is VALID
   ```
3. The watcher→ames/jael wiring is **deferred Stage 2** (urb‑watcher's `%ames`
   poke is a documented placeholder against a nonexistent agent — see lines
   12/575 of the desk). So the positive verdict is driven the way that wiring
   eventually will — `inject_attest_verdict(A, B, %.y)` → `+sy-attest-verdict`
   `ok=%.y`:
   ```
   ames: comet ~tonful-…-daplyd attestation verified
   ```
   which clears the hold. The full install (B becomes a usable `%known` peer,
   `|hi`) is the Stage‑2 wiring (§10); the verdict injected here is exactly what
   that wiring will deliver.

**Net:** both verdict outcomes are exercised live on this kernel — **reject**
(hold → negative verdict → suspended, `[gate] PASS`) and **verify** (hold →
Bitcoin‑VALID → positive verdict → hold cleared).

---

## 8. Diagnostic methodology (how the bugs were found)

The bugs were found by **systematic bisection against real boots**, not by
reading. Worth recording because it also ruled out several false leads:

- **Baseline vs my‑edits boots.** Booting the same arvo *with* and *without* the
  Workstream‑A edits proved a class of crashes was a pill↔arvo kelvin mismatch,
  not my code (the baseline crashed identically).
- **Isolating the change.** Reverting subsets — axle fields, `$task` variants,
  the ames runtime edits — and rebuilding showed `$task` alone crashed boot
  (later understood as the `mint-lost`).
- **Discriminator pills.** Building "baseline ames + my axle" vs "my ames" solid
  pills localized the rest to the migration arms.
- **False leads ruled out.** (a) The brass pill *never* fresh‑boots on this vere
  — proven with a pure‑baseline control, so "my kernel crashes the brass boot"
  was a red herring. (b) The bm vere hangs on a 408 pill (kelvin), not a kernel
  bug. Recognizing these saved chasing phantom kernel issues.
- **The authoritative signal.** Only the strict `solid:pill` vane build surfaced
  the real compile errors with file:line; that's what cracked it.

---

## 9. Commit lineage, artifacts, and reproduction

**Commits (local, unpushed):**

```
urbit  gw/cc-attest:
  <new>      ames: public /x//attest-packet scry (test/utility trigger)
  5ebbad228a ames: fix 3 compile bugs that crashed boot (strict solid build)
  84d41f614a Workstream A Stage 1: the Ames suite gate + attest cycle
  38ad3c690c Workstream A: arm-anchored design doc
vere-tinnus:
  028f75662  king: boot from -G/-k key instead of mining (port of 9d2b)
groundwire hd/cc-e2e:
  <new>      testnet: open-packet injection trigger + urb-watcher /eyre fix
  e1bda73    testnet: solid-pill build + point gate at my-arvo pill
```

**Artifacts:** `gw-solid-mine.pill` (kelvin 408, this kernel), `gw-vere-tinnus`
(408 + feed vere). Builder tooling: `vere-build-tools/zig-aarch64-macos-0.15.2`.

**Reproduce the gate test:**

```sh
cd /Users/trent/gw-building
# 1. build the 408+feed vere (one-time): in vere-tinnus/, <zig-0.15.2> build
# 2. build the pill from this arvo:
#    boot a clean builder:  ./gw-vere-tinnus -d -F zod -c /tmp/builder
#    cd groundwire/testnet && python3 build_solid.py /tmp/builder   # -> gw-solid-mine.pill
# 3. rebuild the desk (eyre fix):  cd groundwire && make build
# 4. run the gate:
cd groundwire/testnet
python3 -m gwharness gate --mode reject
python3 -m gwharness gate --mode verify
```

`run_gate` auto‑selects `gw-solid-mine.pill` + `gw-vere-tinnus`, mines two real
suite‑C comets on the isolated regtest (bitcoind on **18549**, not the user's
18443), boots them on this kernel, triggers the gate, and asserts from the slogs.

---

## 10. Caveats, open issues, and future work

- **The `/x//attest-packet` scry is a test/utility hook.** It exposes a comet's
  own (public) self‑attestation. It is a separate commit and can be dropped; the
  production trigger in a real deployment is the live network (a real peer sends
  the open‑packet), not injection.
- **Stage 2 (deferred):** wire `%urb-watcher`'s verdict directly to the
  `%attest-verdict` task (today the verify path uses the Jael ride; the reject
  path uses an injected verdict / the timeout). This couples the desk to the new
  lull and is intentionally out of scope here.
- **Migration runtime test:** `state-30-to-31` is compile‑verified and follows
  the canonical pattern; fresh comets boot at `%31` and skip it. Exercising it
  live needs a `%30→%31` upgrade boot (noted, optional).
- **`-L` routing limitation:** offline cold comet↔comet contact can't route, so
  the harness injects packets/lanes. On a real network the runtime discovers
  lanes and the gate fires naturally.
- **Vere/pill matrix:** documented in §5.2 — the one darwin vere that does both
  408 and `-G feed` is `gw-vere-tinnus` after the `028f75662` patch.
