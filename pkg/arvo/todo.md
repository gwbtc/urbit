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
