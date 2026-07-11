Status: drafted on cyc/cc-draft; see doc/spec/confidential-comets.md
for the full spec, flows, and open questions.

Jael:
- [x] add to $task:
  - [x] %sybl: subscribe to %writ verification results - sent from Ames at boot (+sy-init)
  - [x] %gost: suspend a domain's registered agent and %snub its peers - ordinary troubleshooting path
  - [x] %ghul: recover from %gost, mass-unsnub domain peers
  - [x] %bane: nuke registered agent, %ruin peers, and delete domain - response to DOS attack or compromised PKI
  - [x] %hand: update registered agent or its watch path
- [x] agent response contract: %writ-response fact on the %anex watch path (spec §2.3)
- open q:
  - subscribing to agent status in gall? - %gost on suspended, %bane on nuked?
    (agent-liveness effects bracketed in comments pending this; spec §4.1)
  - additive %snub task in ames: %gost/%ghul/%bane currently clobber the blocklist (spec §4.2)

Ames:
- [x] send %sybl task to Jael on boot to subscribe to %writ results
- [x] triple check and clean up new attestation logic in +al-take-proof
      (added sndr/rcvr/fig asserts; %writ args fixed to lull shape; dom
      extracted from the suite-c pass tweak via +pass-pki-dom) including
      downstream invocation of al-register-comet
- [x] mirror this modified logic from the +mesa side of the code to the
      +ames side (+on-hear-open etc.); also relaxed life-1 asserts for
      confidential comets in +sift-open-packet and the dup-attestation guard
- [x] handle incoming writ responses on the sybl wire (+sy-sybl):
  - [x] successful ($point): funnel into +sy same as existing comet attestations and Jael keys gifts
  - [x] failed validation: snub this ID (additively) and drop pending requests from it
  - [x] unknown domain: stubbed, no-op

Next (kernel):
- gall affordances for agent liveness; unbracket the %gost/%ghul/%bane
  agent effects in jael (spec §4.1)
- decide attestation payload sizing: pass-tweak-only vs fetched packet (spec §4.4)
- kernel entry point for %attestation-request (watcher asks a ship to re-attest) (spec §4.3/§4.5)

Next (agent, hd/urb-handler):
- %jael-writ poke handler + %writ-response fact in %urb-watcher, replacing
  the placeholder %attestation-verdict/%attestation-request pokes

Phase 2 (cyc/cc-draft-2), after team review:
- [x] causal liveness: gall %view subscription (task+gift, state %21); jael
      subscribes on %anex and reacts (%idle -> gost, %live -> ghul,
      %nuke -> breach hep WITHOUT snubbing + deregister; %bane task remains
      the explicit snub-everything lever)
- [x] 1:1 domain<->agent: %anex takes pax only, dom = sending agent's name
      (from the gall duct); %hand eliminated
- [x] pass anatomy split documented + enforced where kernel-visible:
      dat.tw = mat(dom) + spawn satpoint (immutable, name-committing);
      xtr.tw = off-chain reveal log (kernel-opaque, varies)
- [x] %anew flow: ames task -> jael -> %jael-anew poke -> %anew-response
      fact -> [%sybl %anew] gift -> pass.ames-state updated
- [x] spec: urb-watcher %jael-writ pseudocode (verify from pass + chain
      view alone); fragment sizing (variant A ~1 entry/KiB, variant B
      ~5-7); multi-fragment DOS assessment (bounded LRU pool if needed)
- open q:
  - %view unsubscribe affordance (jael's sub outlives deregistration)
  - auto-fire %anew when a peer rejects a stale attestation
  - persist %anew-refreshed pass to the boot keyfile?
