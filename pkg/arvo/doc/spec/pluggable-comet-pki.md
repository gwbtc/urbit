# Pluggable Comet PKI: Kernel Contract

Status: **implemented key-rotation chapter**. This document describes base
arvo's current pluggable-comet PKI mechanics. It does not claim completion of
the verifier-readiness or live-own-rift continuity chapters; both are recorded
in the lifecycle companion and loose-ends annex.

PR-split note: this contract describes the **composed reviewed end state**.
The `hd/cc-key-rotation` prerequisite does not yet include `%snob`; the stacked
`hd/cc-snob-only` PR adds it. Until both are applied, the inherited `%stale`
withdrawal path remains. See `pluggable-comet-pki-split.md` for branch scope.

Arvo has always had exactly one kind of self-signed identity: the comet,
whose `@p` is a fingerprint of its own key. A comet is free but
unaccountable, so it is cheap to make a million of them. Pluggable comet
PKI lets a comet additionally commit, inside the key that names it, to an
external system that can say something more about it — that the key is
backed by a scarce resource, that a named party vouches for it, or
anything else an external authority can attest. The kernel provides the
mechanism: it recognizes such a commitment, routes it to userspace for
adjudication, waits for a verdict, and applies the result. It provides no
policy and knows nothing about any particular authority.

That separation is the point of this document. The kernel must never need
to know what a domain's data *means*, and no domain implementation may
live in base arvo. Implementations live in their own desks; a base kernel
that shipped one would be picking a winner and would grow a second,
divergent copy of a format whose whole job is to be canonical.

## 1. Boundaries

- **Ames** transports and authenticates the self-attestation, reads the
  PKI domain out of the sender's pass, holds the sender as an unresolved
  alien while asking, and applies the verdict when it comes back.
- **Jael** keeps a registry of one Gall agent per PKI domain, forwards
  verification requests to the right agent, stores accepted public
  networking state, and publishes the ordinary `%public-keys` effects.
- **The domain agent** — userspace, in its own desk — is the entire
  policy and format authority for its domain. It decides what evidence
  looks like, what makes it valid, and what the resulting point is.

Everything in §2 through §8 is kernel; everything a domain agent does with
the bytes it is handed is out of scope here.

## 2. Suite-C pass and immutable identity data

`$open-packet` is the ordinary Ames open packet, unchanged. Crypto suite
`%b` remains the vanilla comet path, also unchanged. Suite `%c` marks a
comet whose pass carries a genesis key and two extra payloads:

- `ugn.tw.pub` is the public half of the comet's *genesis* key. Tweaked by
  `dat` and hashed, it is the comet's name. It never changes. The untweaked
  genesis key is also the live signer at life 1; after the first rotation
  `ugn` is retained only as public name material and its secret is no
  longer needed.
- `dat.tw.pub` is hashed into that tweak and therefore into the name. It
  is immutable for the life of the identity.
- `xtr.tw.pub` is not hashed into the key. It carries refreshable
  evidence and may change without changing the comet's name.

The pass's `cry` is the comet's *current* key. It both encrypts (ECDH for
channel keys) and signs (`sgn` **is** `cry` for suite `%c`): the attestation
packet, Fine responses and Mesa page roots are all signed with it, and a
rekey rotates it. At life 1 the current key is the genesis key, so
`ugn == cry`; later lives carry a fresh `cry` and the same `ugn`. Whether a
given `cry` is really the identity's current key is the domain's to
establish (§4); the kernel only ever checks that a packet is signed by the
key its pass claims. The same life key is used in its Edwards signing form
and Montgomery agreement form. Every signature site must retain its
structured, domain-separated message; nothing signed by a suite-`%c` key
may be a bare point or a peer-chosen atom.

The kernel's entire contract with `dat` is its leading field:

```hoon
(can 0 ~[(mat dom) [wid domain-data]])
```

`dom` is a `@tas`, the PKI domain. Ames extracts it with a bounded raw
`+mat` scan, without calling the jetted `+rub` on peer-controlled input, and
reads no further; the domain agent interprets everything after it. Because
`dat` is hashed into the name, committing the domain in it prevents
cross-domain double boot: changing the domain changes the pass and therefore
the `@p`. Ames checks the pass/name binding before allocating state for the
sender or sending a verification request to the domain agent.

A malformed `dat` — one whose leading `+mat` does not decode, or decodes
to something that is not a term — must fail closed before alien state or
a Jael request is created.

`+dome`, a Jael scry (`.^((unit @tas) %j /=dome=/[ship])`), reports the
domain committed in a known ship's pass, or `~` for a suite-`%b` or
unknown ship. It mirrors `+pass-pki-dom:ames` and the two must stay in
step. `+dose` (`.^((unit ?) %j /=dose=/[dom])`) reports whether an agent
has registered `dom` and, if so, whether the registration is live — the
same test `%writ` applies before forwarding.

## 3. Jael domain API

Jael state holds a registry mapping a domain term to the agent that
claimed it, the path Jael watches on that agent, whether the domain is
currently live, and the set of ships it has vouched for.

| Task | Meaning |
|---|---|
| `[%anex pax=path]` | the sending Gall agent registers itself as its same-named domain and asks Jael to watch `pax` for domain-protocol facts; generic udiffs still require separate `%listen` source authority |
| `[%writ dom ship pass]` | asynchronously verify a suite-C attestation through the registered domain |
| `[%sybl ~]` | subscribe to `%full`, `%fail`, `%lost`, `%snob`, and `%anew` results; Ames subscribes at boot |
| `[%anew dom]` | ask the local domain agent to refresh our own mutable `xtr` |
| `[%gost dom]` | suspend the domain and snub its accepted peers |
| `[%ghul dom]` | restore the domain and unsnub its accepted peers |
| `[%bane dom]` | destructively deregister the domain, delete its accepted points, breach and snub its peers |

**Registration is by agent name.** A `%anex` arrives on a
`[%gall %use dap ...]` duct, and `dap` *is* the domain — one agent, one
domain, 1:1 by construction. This is why a pass's committed domain term
determines which agent adjudicates it, with no separate routing table to
keep consistent. An exact duplicate `%anex` from the same agent on the
same path is an idempotent re-watch (a restarted verifier repeats its
`+on-init`); a changed path is a conflicting registration and crashes.

The registered agent answers asynchronously by publishing facts on its
registered path:

```hoon
+$  verdict        [dom=@tas =ship res=(unit point)]
+$  snob-notice    [dom=@tas =ship]
```

Jael stores a successful point through its normal `feel` machinery and
gives `[%sybl %full ...]`; `res=~` gives `%fail`; an absent or suspended
domain gives `%lost`. Ames funnels `%full` through the ordinary promotion
path. `%fail` drops only pending alien state, never an established peer
and never into a persistent name blocklist: because suite C separates the
immutable name from the live signer, anyone can copy the name fields and
submit an arbitrary signer that the domain will reject. `%lost` is
non-authoritative and transient.

A positive userspace verdict is not carte blanche to rewrite a point. Jael
rechecks that life is nonzero, the current key is a structurally valid suite-C
pass for the claimed name and answering domain, life and rift do not roll back,
a same-life answer retains the accepted live key, and any explicit sponsor is a
star or comet. A null sponsor keeps the ordinary star fallback for a comet.

Clay's `%tire` subscription supplies desk suspension and revival: a
registered domain's desk going `%dead` suspends the domain and `%add`s
its peers to Ames's blocklist; the desk coming back `%live` `%del`s them.
The edits preserve unrelated entries rather than replacing the list, but
the list does not preserve provenance when a manual and domain edit overlap;
that policy question is recorded in the loose-ends annex. Gall app nuke and
restart is a different lifecycle, handled by the idempotent re-watch above.

A domain agent may separately be selected with the ordinary `%listen`
mechanism as a source of public Azimuth `udiff`s. Domain registration by
itself authorizes only that domain's verdict protocol. Local Gall `udiff`s
are accepted only from the source selected for each ship (or the configured
default source). Remote Jael results retain the existing source handling for
numeric ships; its per-ship validation limitation is recorded in the loose-ends
annex, section 13.

Both local `udiff`s and remote Jael snapshots and updates exclude comets.
`%dawn` and `%fake` install our initial point, and migration retains stored
points. After bootstrap, suite-C comet point updates require the committed
domain's validated `%verdict`.

## 4. Ames intake

Both the Mesa and legacy Ames packet paths apply the same authentication and
admission branches. Every attestation first passes the structural checks
(bounded shape, sender, receiver, permitted transport-specific receiver-life
coordinate, sponsor class), a signature check under the `cry` carried in its
own pass, and the immutable name check
`sender == hash(tweak(ugn, dat))`. The kernel performs that name check for
every suite-C packet; a domain agent authorizes only whether `cry` is the
current life key for that already-bound identity. Then:

1. Extract the domain from a suite-C pass; a malformed one is dropped.
   Ask Jael (`+dose`) for one of the three effective states: unregistered,
   registered and live, or registered and suspended. A failed or malformed
   scry is not evidence that the domain is unregistered and fails closed.
2. **Registered and live.** For an unknown comet, or a candidate at a
   higher life than one already accepted (or one the domain has asked to
   hear from again), subscribe to its public keys and send `%writ`. Do not
   register the peer locally. For a state already accepted at the same or
   a later life, retain the ordinary key subscription.
3. **Unregistered.** Permit only the compatibility case `life == 1` and
   `ugn == cry`, then register the comet locally from the pass and ignore
   `xtr`. A rotated comet fails this and is dropped: a kernel with suite-C
   support but no agent for this domain can follow the identity exactly
   until its first rotation, and no further.
4. **Registered and suspended.** Drop the attestation. Suspension must not
   acquire the unregistered-domain compatibility privilege.
5. For a vanilla suite-B comet, retain the existing local life-1
   verification and registration behavior.

The one receiver-life distinction is the legacy Ames `%keys` bootstrap.
`%keys` is unauthenticated and exposes only the requester's wrapping four-bit
life tick, so it never supplies a trusted full life. Every responder therefore
signs its `%keys` answer with `rcvr-life == 1`, the fixed bootstrap coordinate,
even when it already knows the requester: that stored view can itself be stale
when both comets rotate before either new attestation arrives. The legacy
receiver permits either its exact current life or that sentinel, but the
sentinel supplies no authority: the candidate is admitted only after the normal
packet shape, signature, immutable-name, domain, and sponsor checks. The signed
body's actual `sndr-life` and pass remain authoritative. Proactive announcements
and the reciprocal attestation emitted after first-contact promotion remain
bound to the peer's exact stored life; only the direct response to `%keys` uses
the sentinel.

This exception is legacy-Ames-only. Mesa still requires the open packet's
receiver life to equal the requester's current life. Its fixed outer `%publ 1`
and `/pawn/proof/1/...` coordinates bootstrap discovery of the publisher; they
do not relax that exact inner receiver-life check.

Until a verdict arrives an unknown sender stays in its existing alien
transport slot with a bounded agenda; a sender already known at an older life
remains known while the candidate is checked.
No unverified suite-C packet may cause allocation or work proportional to an
attacker-claimed length larger than the bytes actually received: in particular,
a packet payload must be shown to be a well-formed, bounded
`(jam [signature=@ signed=@])` *before* it is `+cue`d, since `+cue` can
bail `%meme` on a hostile backreference and `%meme` escapes `+mole`.

## 5. Routes carried by a verdict

A verified `point` may carry a `fief`: the peer's committed route.
Domain-backed identities receive no generic udiffs, so
the verdict is the only carrier such a route has.

Therefore a whole point arriving as `[%sybl %full ...]` pushes its fief to
the runtime, exactly as an incremental `[%diff @ %fief *]` does. Handling
only the diff — which was the original behavior — left a verified route
stored in Jael, visible in `/pynt`, and never actually routed to.

Jael likewise publishes the fief of a point installed from a
`%verdict` to its `%fief` subscribers.

## 6. Withdrawn vouches: soft block and re-solicitation

An attestation can stop being something its domain will vouch for without
ever having been fraudulent: the external fact it rests on may simply
move on. That is not a reason to snub anyone, and it is not a reason to
tear down the flows a ship has with that peer.

A domain agent that can no longer vouch for a ship gives Jael a
`$snob-notice`. Jael **keeps** the point and the ship's place in the
domain's vouched-for set, and gives `[%sybl %snob dom ship]`. Ames puts
the ship on its *soft* blocklist (`snob`, edited with the `%snob` task
exactly as `snub` is with `%snub`) and asks it for a fresh attestation
(`%poof`): a `%keys` packet on the legacy path, the proof peek on Mesa,
retried every 30 seconds while the ship stays soft-blocked. A soft-blocked
ship's authenticated packets are dropped as a snubbed ship's are — on
both cores — with two exceptions: its own self-attestations, and its
requests for ours. Mesa `%peek` packets carry no authenticated requester;
the requested publisher is `name.her` and the return lane is not an
identity. They therefore remain read-only, anonymous requests for our
namespace. The authenticated Mesa `%page` and `%poke` paths are filtered.
Nothing else about the peer changes: `%known` state, flows, routes and
subscriptions all stand.

The Mesa proof remains reachable at its established fixed life-1 bootstrap
path even after the publisher rotates. That path life is a requester-supplied
coordinate, not an assertion about the publisher. The signed open packet in
the returned page carries the authoritative current life. Ordinary Mesa
public-namespace reads remain exactly life-versioned, and every recognized
proof page or proof poke is routed through attestation verification even when
the transport peer has already become `%known`.

When the domain vouches again, the ordinary `%full` verdict applies the
inverse soft-list edit and installs the new point through `+on-publ-full`,
leaving the independent hard blocklist untouched. Because the soft list is a
single set, an overlapping manual `%snob` has no separate provenance; see the
loose-ends annex. `+on-publ-full`
keeps the existing peer state and runs the ordinary rekey machinery to
rederive its shared key and encrypted Mesa request paths. This is a
rekey, not a breach. If the new point raises the ship's rift, Jael's
`+feel` signals `%breach` first, and Ames and Gall wipe their state for
that ship as for any breach. This is why the point is retained rather
than dropped: with no prior point there would be nothing to compare the
rift against.

## 7. Re-attestation of our own identity

`%anew` refreshes **our own** `xtr`: Ames asks Jael, Jael asks the local
domain agent, and the returned pass is installed only after confirming
that it belongs to the responding domain, preserves `ugn` and `dat`,
hashes to our name, and carries the currently active public key. Thus a
response prepared before a rekey cannot restore the old life key. A
refreshed pass is not currently written back to the boot keyfile.

For a live-key rotation, userspace may publish the new authorized
`$point:jael` and provide its matching private `$ring` with `%rekey` in
either order. Jael caches a future ring without activating or announcing
it. It activates only when the point's current life exists in both maps,
the ring reproduces that point's suite and exact pass, and a comet ring
still fingerprints to the running ship. Life zero is invalid, neither life
nor rift can move backwards, and a life identifies one live key: a same-life
verdict may refresh evidence, routing, or rift only while retaining the key,
and `%rekey` never replaces an already-active life. When both halves
arrive, Jael emits the public point before the private-key gift, so Ames
learns the authorized life before switching its signer and agreement key.
Moons retain their existing immediate-rekey behavior.

Ames re-attests on rekey, so a peer that has already accepted us learns
about a new life through the same path that admitted us.

The precise point-first and ring-first intermediate states, peer-convergence
sequence, failure behavior, and operator-visible checkpoints are expanded in
`pluggable-comet-pki-lifecycle.md`.

## 8. Compatibility and verification requirements

- Suite-B comets and their one-fragment paths must remain unchanged.
- The life-1 fallback interoperates with a kernel implementing this
  suite-C layout but lacking an agent for the committed domain. It is not
  wire-compatible with the earlier suite-C layout, which interpreted the
  same two 32-byte fields as different key material and verified the
  tweaked signer. Old suite-C rings must not be activated under this
  layout; disposable identities from that Kelvin should be reminted unless
  a separately specified migration rule is introduced.
- Jael's state migration to the registry-bearing version is required for
  live non-domain state and is merged.
- A first-contact attestation must fit **one** Mesa fragment. Bounded
  anonymous multi-fragment reassembly is not implemented and is not
  assumed by anything here.
- Aqua must cover the real Ames -> Jael -> Gall -> Jael -> Ames
  asynchronous path with a deterministic oracle: acceptance, rejection, a
  malformed `dat`, a higher life, and a withdrawn vouch (`snob-reattest`:
  `%snob-notice` -> soft block -> `%poof` solicitation -> re-attestation ->
  `%full`, with the peer's flows intact throughout). Those scenarios live
  in `ted/ph/cc/`, and their fake domain verifier is generated from the
  fixtures in `lib/aqua-azimuth.hoon` so it cannot go stale against them.
  It is a lookup table, deliberately: base arvo must not contain a
  verifier.

## 9. Domain implementations

No domain implementation, codec, or domain-specific validation policy
belongs in this repository. Such implementations live in userspace desks
and use only the generic registration, writ, verdict, refresh, and
withdrawal interfaces specified above.

Non-normative proposals deliberately left out of this contract are
preserved in `pluggable-comet-pki-loose-ends.md`.
