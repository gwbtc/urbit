::  sur/stealth: kernel-side types for confidential comets
::
::  NOTE: this file is a design sketch and is not currently built by
::  anything.  the authoritative $open-packet lives in sys/vane/ames.hoon
::  (unchanged from vanilla comets); the jael task/gift types
::  ($writ-result, $writ-response, $anew-response) live in sys/lull.hoon.
::  see doc/spec/confidential-comets.md for the protocol.
::
::  anatomy of a confidential comet's $pass (suite %c, encoded by
::  +pub:ex:cric in zuse):
::
::    dat.tw.pub -- the actual Schnorr tweak data.  hashed into the
::      signing key, so the comet's name (the hash of the pass's
::      tweaked key) commits to it; it can NEVER vary in the lifetime
::      of the ID.  contains exactly:
::
::        (cat 0 (mat dom) <spawn satpoint>)
::
::      i.e. the +mat-encoded PKI domain tag (which is also the name
::      of the verifier agent, 1:1) followed by the sat's spawn
::      satpoint.  extracted with +rub by the receiving ames
::      (+pass-pki-dom) and by jael; committing the domain here
::      prevents cross-chain double-boot.
::
::    xtr.tw.pub -- the off-chain reveal of the on-chain event log: a
::      list of merkle proofs into the block headers, one per
::      ownership-sat transfer from the %spawn commit through the
::      current (unspent) tip.  NOT hashed into the key (+nol/+com
::      tweak over dat only), so it grows over the ID's lifetime
::      without changing the name.  kernel-opaque: ames and jael pass
::      the whole $pass through to the domain agent, which alone
::      parses and verifies it (see $reveal-entry below).  refreshed
::      via the %anew flow when the sat moves.
::
::  the self-attestation packet ($open-packet) adds only sndr/rcvr
::  names and lives around the pass; those stay kernel-level for
::  vanilla-comet and persistent-node interactions.
::
|%
::  $reveal-entry: one ownership-sat transfer in xtr.tw.pub.
::
::  two candidate shapes (see spec for size analysis):
::
::  self-contained (SPV against locally-held headers; ~1 entry per
::  1KB fragment):
::
::    $:  txdata=octs                 ::  full serialized transaction
::        reveal=octs                 ::  committed `urb` tapleaf script
::        proof=(list @ux)            ::  tx merkle path to block root
::        block=@ud                   ::  block height (header lookup)
::    ==
::
::  fetch-based (agent fetches tx by txid from its own node/indexer;
::  ~5-7 entries per fragment):
::
::    $:  =txid                       ::  transaction id
::        block=@ud                   ::  block height
::        reveal=octs                 ::  committed `urb` tapleaf script
::    ==
::
+$  txid  @ux
--
