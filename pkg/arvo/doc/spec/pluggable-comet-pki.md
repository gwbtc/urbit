# Pluggable Comet PKI: Kernel Contract

Status: **implemented**. This document describes the whole of base arvo's
half of pluggable comet PKI, and nothing else.

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

Everything in §2 through §7 is kernel; everything a domain agent does with
the bytes it is handed is out of scope here.

## 2. Suite-C pass and immutable identity data

`$open-packet` is the ordinary Ames open packet, unchanged. Crypto suite
`%b` remains the vanilla comet path, also unchanged. Suite `%c` marks a
comet whose pass carries two extra payloads:

- `dat.tw.pub` is hashed into the signing-key tweak and therefore into
  the comet's name. It is immutable for the life of the identity.
- `xtr.tw.pub` is not hashed into the key. It carries refreshable
  evidence and may change without changing the comet's name.

The kernel's entire contract with `dat` is its leading field:

```hoon
(can 0 ~[(mat dom) [wid domain-data]])
```

`dom` is a `@tas`, the PKI domain. Ames extracts it with `+rub` and reads
no further; the domain agent interprets everything after it. Because `dat`
is hashed into the name, committing the domain in it prevents cross-domain
double boot: changing the domain changes the pass and therefore the `@p`.
Ames checks the pass/name binding before asking Jael or allocating any
state for the sender.

A malformed `dat` — one whose leading `+mat` does not decode, or decodes
to something that is not a term — must fail closed before alien state or
a Jael request is created.

`+dome`, a Jael scry (`.^((unit @tas) %j /=dome=/[ship])`), reports the
domain committed in a known ship's pass, or `~` for a suite-`%b` or
unknown ship. It mirrors `+pass-pki-dom:ames` and the two must stay in
step.

## 3. Jael domain API

Jael state holds a registry mapping a domain term to the agent that
claimed it, the path Jael watches on that agent, whether the domain is
currently live, and the set of ships it has vouched for.

| Task | Meaning |
|---|---|
| `[%anex pax=path]` | the sending Gall agent registers itself as its same-named domain and asks Jael to watch `pax` |
| `[%writ dom ship pass]` | asynchronously verify a suite-C attestation through the registered domain |
| `[%sybl ~]` | subscribe to verification results; Ames subscribes at boot |
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
+$  stale-notice   [dom=@tas =ship]
```

Jael stores a successful point through its normal `feel` machinery and
gives `[%sybl %full ...]`; `res=~` gives `%fail`; an absent or suspended
domain gives `%lost`. Ames funnels `%full` through the ordinary promotion
path, additively snubs a failed alien, and treats `%lost` as
non-authoritative and transient.

Clay's `%tire` subscription supplies desk suspension and revival: a
registered domain's desk going `%dead` suspends the domain and `%add`s
its peers to Ames's blocklist; the desk coming back `%live` `%del`s them.
Both edits are additive — they never clobber a manually set blocklist.
Gall app nuke and restart is a different lifecycle, handled by the
idempotent re-watch above.

A domain agent may also register as a source of ordinary `udiff`s for the
identities it knows about. Jael accepts udiffs only from a live
registered domain or from an explicitly authorized app source.

## 4. Ames intake

Both the Mesa and legacy Ames packet paths apply the same branches:

1. For an unknown suite-C comet, or a candidate at a higher life than one
   already accepted, validate the packet/pass/name relationships, extract
   a well-formed domain, subscribe to its public keys, and send `%writ` to
   Jael. Do not register the peer locally yet.
2. For a state already accepted at the same or a later life, retain the
   ordinary key subscription.
3. For a vanilla suite-B comet, retain the existing local life-1
   verification and registration behavior.

Until a verdict arrives the sender stays an alien with a bounded agenda.
No unverified suite-C packet may cause work proportional to its contents:
in particular a packet payload must be shown to be a well-formed, bounded
`(jam [signature=@ signed=@])` *before* it is `+cue`d, since `+cue` can
bail `%meme` on a hostile backreference and `%meme` escapes `+mole`.

## 5. Routes carried by a verdict

A verified `point` may carry a `fief`: the peer's committed route. A
domain whose identities are confidential publishes no udiffs for them, so
the verdict is the only carrier such a route has.

Therefore a whole point arriving as `[%sybl %full ...]` pushes its fief to
the runtime, exactly as an incremental `[%diff @ %fief *]` does. Handling
only the diff — which was the original behavior — left a verified route
stored in Jael, visible in `/pynt`, and never actually routed to.

Jael likewise publishes the fief of a point installed from a
`%verdict` to its `%fief` subscribers.

## 6. Staleness

An attestation can stop being true without ever having been fraudulent:
the external fact it rests on may simply move on. That is not a reason to
snub anyone.

A domain agent that notices this gives Jael a `$stale-notice`. Jael drops
the point, removes the ship from that domain's vouched-for set, and gives
`[%sybl %stale dom ship]`. Ames demotes a `%known` peer to a *fresh*
`%alien` with an empty agenda — never deleting it, never snubbing it — and
leaves an already-`%alien` peer untouched. The peer can then re-attest
through the ordinary first-contact path.

## 7. Re-attestation of our own identity

`%anew` refreshes **our own** `xtr`: Ames asks Jael, Jael asks the local
domain agent, and the returned pass is installed after confirming that its
immutable identity still hashes to our name. A refreshed pass is not
currently written back to the boot keyfile.

Ames re-attests on rekey, so a peer that has already accepted us learns
about a new life through the same path that admitted us.

## 8. Compatibility and verification requirements

- Suite-B comets and their one-fragment paths must remain unchanged.
- Jael's state migration to the registry-bearing version is required for
  live non-domain state and is merged.
- A first-contact attestation must fit **one** Mesa fragment. Bounded
  anonymous multi-fragment reassembly is not implemented and is not
  assumed by anything here.
- Aqua must cover the real Ames -> Jael -> Gall -> Jael -> Ames
  asynchronous path with a deterministic oracle: acceptance, rejection, a
  malformed `dat`, and a higher life. Those scenarios live in
  `ted/ph/cc/`, and their fake domain verifier is generated from the
  fixtures in `lib/aqua-azimuth.hoon` so it cannot go stale against them.
  It is a lookup table, deliberately: base arvo must not contain a
  verifier.

## 9. Domain implementations

No domain implementation, codec, or domain specification belongs in this
repository. The reference implementation of one such domain — a
confidential comet whose identity is bound to a scarce on-chain
resource — is Groundwire's `%gw-btc`, specified and implemented in
`gwbtc/groundwire`:

- kernel-facing protocol: `groundwire/doc/confidential-comets.md`
- implementation state: `groundwire/doc/confidential-comets-state.md`
- remaining work: `groundwire/doc/confidential-comets-todo.md`
