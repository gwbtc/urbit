::  sur/stealth: kernel-side types for confidential comets
::
::  NOTE: this file is a design sketch and is not currently built by
::  anything.  the authoritative $open-packet lives in sys/vane/ames.hoon
::  (unchanged from vanilla comets); the jael task/gift types
::  ($writ-result, $writ-response) live in sys/lull.hoon.  see
::  doc/spec/confidential-comets.md for the protocol.
::
::  a confidential groundwire comet is exactly a comet whose $pass is
::  suite %c.  its key-tweak data (dat.tw of the cric core) is:
::
::    (cat 0 (mat dom) <domain-specific attestation data>)
::
::  i.e. the +mat-encoded PKI domain tag at the head, extracted by the
::  receiving ames with +rub (+pass-pki-dom in ames.hoon), followed by
::  the domain payload.  since the comet's name is the hash of the
::  pass, the name commits to the domain, preventing cross-chain
::  double-boot; and $open-packet is untouched, so vanilla (suite-%b)
::  comets are fully backward-compatible.
::
|%
::  $groundwire-pass: the %bitcoin domain's tweak payload (after the
::  domain tag): the comet's ownership satpoint plus the off-chain
::  reveal log that lets a verifier walk the sat's commit chain.
::  parsed and verified by %urb-watcher, not by the kernel.
::
+$  groundwire-pass
  $:  =satpoint
      log=(list utxo-tweak)
  ==
+$  utxo-tweak  [outpoint script]
--
