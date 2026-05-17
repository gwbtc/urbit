|%
+$  open-packet
  $:  dom=(unit @tas) :: PKI domain
      =pass :: public key (fallback/vanilla comet) or PKI-specific attestation data
      sndr=ship
      =sndr=life
      rcvr=ship
      =rcvr=life
  ==
+$  groundwire-pass
  $:  =satpoint
      log=(list utxo-tweak)
  ==
+$  utxo-tweak  [outpoint script]
--