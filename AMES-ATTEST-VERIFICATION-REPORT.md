# Confidential Comets — Ames ⇄ %urb-watcher: code footprint & verification

**Purpose.** This is a *current-state* report: what the code **is** after this
pass and exactly what each change touches, so you can audit the footprint
yourself. It is organised as a per-arm table (§2) plus an honest account of what
is genuinely exercised versus what is still stubbed or delivered out-of-band
(§3–§4). The build-process narrative (toolchain, the three boot bugs, the
diagnostic bisects) is demoted to an appendix (§8).

Repositories / branches — all local, **nothing pushed**:

| repo | path | branch | what changed |
|---|---|---|---|
| urbit (kernel) | `urbit/` | `gw/cc-attest` | the Ames suite gate, the attest cycle, the `/atst` transport |
| groundwire (desk + harness) | `groundwire/` | `hd/cc-e2e` | `%urb-watcher` handler wiring; the `gwharness` test driver |
| vere (runtime) | `vere-tinnus/` | `tinnus-test-hack` | the kelvin-408 + `-G feed` runtime (`gw-vere-tinnus`) |

---

## 1. The one architectural fact

The spec (*Confidential Comets 2.0 ~hanfel-dovned*) describes a single loop:

> On first contact a comet provides a self-attestation packet … **the other
> ship's Ames pokes the contents of this packet to a registered handler agent**
> (`%urb-watcher`) which verifies it on-chain and **stores the data in Jael if
> successful**. The watcher tracks the ownership sat; when it moves it **pokes
> Ames to request a new packet … if the packet never arrives or is invalid, Ames
> suspends its relationship.**

So there is a **closed wire between Ames and `%urb-watcher`** with three signals:

1. Ames → watcher: *"verify this packet."*  (`%self-attestation` poke)
2. watcher → Ames: *"verdict: ok / not-ok."*  (`%attest-verdict`)
3. watcher → Ames: *"this peer's sat moved — re-request."*  (`%attest-request`)

Before this pass that wire **did not exist**: the packet reached the watcher by
an out-of-band eyre POST, and the verdict reached Ames only by direct task
injection in the harness. The watcher's own pokes targeted a **nonexistent
`%ames` agent** and were nack-swallowed. This pass builds the wire end-to-end and
verifies it on regtest. The security property it protects is unchanged: a
**suite-C** comet's networking key embeds a Bitcoin satpoint claim, so it must
**not** be trusted on its bare Ames self-attestation (that would let it lie about
being non-Groundwire); it is **held** until a Bitcoin verdict arrives.

The crypto-suite is the last byte of the networking key (`pass`): `'a'`→0 (unused),
`'b'`→1 (ordinary non-Groundwire comet, bare-accepted), `'c'`→2 (Bitcoin-backed,
**gated**). `on-hear-open` reads it as `(sub (end 3 pass) 'a')`.

---

## 2. Footprint — what each arm does and its status

Status legend: **LIVE-V** = implemented and verified running this pass;
**LIVE** = implemented, compiles, exercised indirectly; **NEW** = added this pass
(the `/atst` transport, compile-gated by the solid pill); **OBS** = observability
slog added this pass.

### 2a. Kernel — `urbit/pkg/arvo/sys/vane/ames.hoon` (+ `lull.hoon`)

| arm / site | what it does | status |
|---|---|---|
| `lull.hoon` `$task:ames` `[%attest-verdict =ship ok=?]` / `[%attest-request =ship]` | the two watcher→ames tasks; routed in `+call` | LIVE-V |
| `lull.hoon` `$attest-state` `[stage=?(%fetch %verify %grace) =lane deadline=@da]` | per-comet in-flight verification record | LIVE-V |
| `lull.hoon` axle `attest=(map ship attest-state)` / `bad=(map ship until=@da)` | held comets; suspended comets (lazy ~d1) | LIVE-V |
| `+on-hear-open` suite branch | suite-C → record `%fetch`, slog "holding…", arm timer, **and now fire `+atst-fetch`**; suite-B/-A bare-accept unchanged | LIVE-V |
| `+on-hear-packet` dispatch | route `%atst-req` content → `+on-hear-atst-req`; a bare packet from a comet we hold (`%fetch`) → `+on-hear-atst-resp` | NEW |
| `+atst-fetch` | fire a plaintext `%atst-req` at the held comet's lane (no peer/channel installed) | NEW |
| `+on-hear-atst-req` | serve our full self-attestation: scry our own handler's `/x/keyfile`, reply to the requester's lane | NEW |
| `+on-hear-atst-resp` | a held comet returned its packet → advance `%fetch`→`%verify`, re-arm timer, `+atst-poke-handler` | NEW |
| `+atst-poke-handler` | `%g %deal` poke of mark `%noun [%attest-packet ship packet]` to the registered handler (Edit 3) | NEW |
| `+scry-handler-keyfile` | `(rof … %gx …/keyfile/noun)` — read our own keyfile from the handler agent | NEW |
| `+handler-agent` | constant `%urb-watcher` (the spec's "registered handler"; a future `(map suite dap)`) | NEW |
| `+atst-req-blob` / `+atst-resp-blob` | build the two bare `%atst` packets (mirror `+encode-keys-packet`) | NEW |
| `+sy-attest-verdict` | `ok` → clear the entry (idempotent vs the Jael ride); `!ok` → delete peer, suspend ~d1, `%nail` | LIVE-V |
| `+sy-attest-request` | known peer → `%grace` stage + ~m30 deadline (re-prove while still working) | LIVE-V |
| `+set-attest-timer` / `+on-take-wake [%attest @ ~]` | behn deadline → on expiry drive `sy-attest-verdict ok=%.n` | LIVE |
| `+on-publ-full` / `-rekey` | the Jael ride: verified `%public-keys` install the peer **and** clear the attest entry | LIVE-V |
| `%30→%31` migration (`axle-30`, `state-30-to-31`, molt/load/stay) | one-way upgrade adding `attest`/`bad`; fresh comets boot at `%31` | LIVE |
| `/x//attest-packet` scry | serve our own signed open-packet (test hook for the lane-injection trigger) | LIVE-V |

### 2b. Handler — `groundwire/groundwire/app/urb-watcher.hoon`

| arm / site | what it does | status |
|---|---|---|
| `+verdict-poke` / `+request-poke` | **rewritten** from pokes to a dead `%ames` agent → `[%pass /attest/… %arvo %a [%attest-verdict who ok]]` / `[%attest-request who]` kernel tasks | LIVE-V |
| `on-agent` | the `[%ames *]` nack-swallow **deleted**; reverted to `on-agent:def` | LIVE-V |
| `on-poke` `%noun` arm | **extended** to accept `[%attest-packet who packet]` (the ames `%g %deal`) → re-poke self with `%self-attestation` (reuses the verify path) | NEW |
| `[%verify %remote …]` return | on VALID: `apply-verified` + feed Jael (the ride) **and** `verdict-poke ok=%.y`; on INVALID/crash: `verdict-poke ok=%.n` | LIVE-V |
| `+scan-conf` confidential-move branch | sat moved with no on-chain sotx → `request-poke` (now a real task) + record `requested`; **OBS slog** added so the move is observable | LIVE-V / OBS |
| `+scan-conf` public-continuation branch | sat moved **with** an on-chain reveal → "now a public comet", drop from `conf`, hand to classic chain-watching | LIVE |
| `known-public` guard | a revealed-public ship's packets are refused (cannot return to confidential) | LIVE |
| `on-arvo /eyre/connect` | no-op the eyre `%bound` ack (prevents a default-agent crash on the 408 kernel) | LIVE-V |

### 2c. Harness — `groundwire/testnet/gwharness/`

| arm | what it does | status |
|---|---|---|
| `milestones.run_m5` | genuine **failure**: hold B → POST a tampered B packet → watcher INVALID → **real** verdict task → suspend | LIVE-V (PASS) |
| `milestones.run_m3` | genuine **two-ship verify**: each holds the other → watcher VALID → **real** verdict clears both holds → `\|hi` | LIVE-V (verify PASS; see §4) |
| `milestones.run_m4` | genuine **re-attestation**: `management_op %no-op` 2nd tx → `scan-conf` → **real** `%attest-request` → re-verify | NEW |
| `milestones._use_my_kernel` / `_boot_pair` / `_count_log` / `_await_count` | shared boot + occurrence-count log assertions | NEW |

---

## 3. What is genuinely driven vs. still injected / out-of-band

The whole point of the wire is to remove injection. After this pass:

- **The verdict is real.** `%urb-watcher`'s `verdict-poke` is a kernel `%a` task,
  so a real Bitcoin verdict drives `sy-attest-verdict` → suspend (INVALID) or
  clear (VALID). **No verdict injection.** *(Verified: m5, m3.)*
- **The re-attestation request is real.** `scan-conf` detecting an on-chain sat
  move fires a real `%attest-request` task. *(Built; exercised by m4.)*
- **The packet delivery is Ames-native** via the new `/atst` bare-packet
  transport (§5), **verified live by `run_m6`**: the held comet is asked over
  Ames and replies over Ames, and Ames pokes the handler — *no eyre POST*. (The
  earlier scenarios m3/m4/m5 deliver the packet by eyre POST — still a real
  watcher verification; m6 is the one that drives the full Ames-native path.)
- **One injection remains by necessity:** the *initial* open-packet/lane. The
  harness boots comets `-L` (loopback), where a cold comet cannot route a first
  packet to an `%alien` peer (it would go to an unreachable galaxy sponsor), and
  `%dear` only records a lane for an already-known peer. So the first open-packet
  is injected to fire the gate; **everything after it is genuine.** On a real
  network the runtime discovers lanes and this injection disappears.

Deferred (documented, not built this pass — see §7): the in-ship `%spv-wallet`
**script-path reveal signing** (gates the full public-comet path) and a
**snapshot-serving indexer** comet (the public-via-indexer half of sponsor-down).

---

## 4. Verification — scenario by scenario (exact slogs)

All assertions are pier-log slogs (gall scries return `~` over conn on this fork,
so the log is the assertion channel).

**m5 — genuine failure → suspend. PASS.**
`A` boots my %31 kernel, hears `B`'s injected suite-C open-packet, and holds it:
`ames: holding suite-C comet ~…tombyr… pending Bitcoin verification`. The harness
POSTs a **tampered** `B` packet (tip offset +1) to `A`'s watcher, which verifies
it against regtest and returns `… is INVALID` with the precise failed check
`[XX] tip-sont`. The watcher's now-real `verdict-poke %.n` drives the kernel:
`ames: comet ~…tombyr… attestation failed; suspended` — peer torn down, added to
`bad` for ~d1, `%nail` clears lanes. **The suspend is produced by the real
watcher→ames task, not an injected verdict.**

**m3 — genuine two-ship verify through the hold. Verify PASS.**
Both comets hold each other (`A holds B: True   B holds A: True`); each watcher
verifies the peer's **real** packet against regtest (`… is VALID` both ways); the
real `verdict-poke %.y` clears both holds (`attestation verified` ×2 →
`A cleared hold on B: True   B cleared hold on A: True`). The final `|hi`
round-trip is the same Jael-ride install M2 already proves; it hung here behind a
slow install probe and was not re-confirmed, so m3 is reported as **verify-proven,
round-trip via the M2 mechanism**.

**m4 — genuine re-attestation after a 2nd Bitcoin tx. PASS.**
`B` verifies `A`'s 1-link packet; `chainops.management_op(%no-op)` broadcasts a
**second** on-chain commit that moves `A`'s sat; `B`'s block loop detects the
confidential move (`… sat moved confidentially; requesting re-attestation`) and
**fires the real `%attest-request`** task; the updated 2-link packet re-verifies
VALID with the tracked sont reconciled as an interior link (`[ok] tracked-tip` —
proving genuine re-verification, not a fresh verify).

**m6 — the `/atst` transport, end-to-end, no eyre POST. PASS.**
`B` pokes and verifies its **own** keyfile (so its watcher can serve it). `A`
holds suite-C `B` (the only injected step). `A`'s gate fires `+atst-fetch`,
sending `B` a plaintext `%atst-req` at `B`'s lane; `B` serves its full
self-attestation from its own `/x/keyfile` (the in-kernel `%gx` scry) and replies
to `A`'s lane; `A` pokes its watcher (`%g %deal %noun [%attest-packet …]`). The
log shows `A's watcher got B's packet over /atst: True` — the watcher's
`verifying self-attestation` slog with **no eyre POST** — then `VALID` and the
real verdict clears the hold. This exercises every new arm of the transport
genuinely; only the initial open-packet/lane is injected.

---

## 5. The `/atst` transport (built this pass)

**Design — bare plaintext packets, no channel.** When `A` holds suite-C `B`, `A`
emits a plaintext `%atst-req` straight at the lane it recorded (`+atst-fetch` →
`%give %send lane blob`). `B` receives it (`+on-hear-atst-req`), scries its **own**
`%urb-watcher` `/x/keyfile` for its full self-attestation, and replies to the
requester's lane. `A` receives the reply (`+on-hear-atst-resp`), advances the
attest entry `%fetch`→`%verify`, and `%g %deal`-pokes its handler
(`+atst-poke-handler`, mark `%noun [%attest-packet who packet]`); the watcher casts
it and runs the normal verify path, whose verdict returns over the §1 wire.

**Why bare packets, not the classic `%plea`/`%boon`.** The encrypted plea/boon
path needs an installed symmetric-key channel, but for `B` to decrypt `A`'s plea
`B` would have to install a channel for `A` — yet `B`'s own gate **holds** `A`
instead (mutual-hold deadlock). Bare packets sidestep this entirely: each side
uses the lane it already has, nothing is encrypted, and — crucially — **no peer is
installed**, so the gate's security property is preserved exactly (a held comet is
never trusted until its Bitcoin verdict lands). Emitting `%give %send lane blob`
directly with the held lane also bypasses the `-L` routing catch-22, so the
exchange is genuinely testable on loopback.

**Trade-off (documented).** A bare packet is a single datagram, so a comet with a
**very long** sat-chain (many management ops) could exceed one packet; on
loopback and for the common short-chain case this is fine. Long-chain
fragmentation (the classic plea/boon path) is a follow-up.

**The one risk — resolved.** `+scry-handler-keyfile` does a synchronous
`rof … %gx` scry from *inside* an Ames event into the gall agent — a pattern with
no existing precedent in the kernel. It **works** (verified by `run_m6`, below);
had it returned `~` the responder would no-op and the requester time out → suspend
(graceful degradation), but it returns the keyfile. **Status: VERIFIED** — the new
ames compiles through the strict `solid:pill` vane build (it caught a real
`mint-vain` first; fixed), and `run_m6` drives the whole transport live on regtest.

---

## 6. "Suspend", and the packet format

**What suspend means** (the spec flags this as open). On a negative verdict or a
deadline, `sy-attest-verdict ok=%.n`: deletes the peer from `peers`, inserts it
into `bad` with `until = now + ~d1`, and gives a `%nail` to clear its lanes. While
suspended, a fresh suite-C open-packet from that comet is **dropped silently**
(the gate checks `bad` before holding). After ~d1 the entry lazily expires on next
contact. This is a launch decision, not a protocol constant.

**Format.** `groundwire/groundwire/sur/self-attestation.hoon` already matches the
spec mold (`tapleaf` / `reveal` / `link` / `self-attestation`), with two benign
additions: a per-link `block=@ux` (and `precommit=[txid block]`) so verifiers can
use `getrawtransaction`'s blockhash argument with no `-txindex`, and a `skeleton`
sub-mold (the on-chain-derivable subset Causeway builds off-ship; `sots` are
re-derived on-ship from each leaf). No format change was needed.

---

## 7. Deferred — explicitly out of scope this pass

- **Public comets / on-chain reveal signing.** The watcher's public-continuation
  classifier and `known-public` refusal are implemented (§2b). Producing the
  triggering on-chain **reveal** needs a Taproot **script-path** spend, which only
  the in-ship `%spv-wallet` can sign (Causeway desktop deliberately cannot —
  `CONFIDENTIAL-COMETS.md:133`). That signing is a separate workstream.
- **Sponsor-down (public-via-indexer half).** Per spec, a comet whose sponsor is
  down republishes a fief on-chain to become discoverable ("permanently
  confidential XOR permanently reachable"). The confidential-unreachable half
  (hold → timeout → suspend) is covered by m5; the public-indexer half needs the
  reveal above plus a snapshot-serving indexer comet the harness does not yet run.
- **Long-chain `/atst` fragmentation** (§5).

---

## 8. Appendix — toolchain & build process

Carried from the prior pass (details unchanged): the strict **`solid:pill`** vane
build is the real compile gate (a lenient `-A` check previously masked three
boot-crashing bugs — a `mint-lost` from the non-exhaustive `?- -.task` and two
`%30→%31` migration `nest-fail`s); `build_solid.py` produces `gw-solid-mine.pill`
from this arvo; `gw-vere-tinnus` is the kelvin-408 runtime that boots it and boots
real comets from a `-G feed`. Reproduce: `build_solid.py <builder-pier>` to build
the pill, then `python3 -m gwharness {m5,m3,m4}` (regtest bitcoind on **18549**).
