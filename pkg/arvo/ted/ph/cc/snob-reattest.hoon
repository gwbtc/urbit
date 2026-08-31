/+  cc-io=ph-cc-io, az=aqua-azimuth
::  A verified confidential comet loses its domain's vouch (%snob-notice):
::  the receiver soft-blocks it and solicits a fresh attestation.  The
::  comet's next attestation verifies, the %full lifts the block, and the
::  two keep talking -- the peer was never demoted, so no flow was lost.
::
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-snob-reattest
=/  io  ~(. cc-io loud tag)
=/  comet  cc-comet-ok:az
=/  sponsor  (^sein:title comet)
=/  =onchain:io  [peer=comet life=1 rift=0 spon=~ fef=%if]~
::
;<  ~  bind:m  start-azimuth:io
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io sponsor)
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io sponsor | core)
;<  ~  bind:m  (install-pki:io ~bud)
;<  ~  bind:m  (start-cc-comet:io comet core onchain)
::
::  Establish the life-1 point through the asynchronous verifier.
;<  ~  bind:m  (send-hi:io comet ~bud)
;<  ~  bind:m  (assert-not-snobbed:io ~bud comet)
::
::  The domain withdraws its vouch.  ~bud soft-blocks the comet -- keeping
::  it as a %known peer -- and solicits a fresh attestation (%poof).  The
::  comet answers at once, the writ reaches the oracle, and the %full
::  lifts the block: the whole round trip completes inside the poke's
::  event chain, so the soft block is not observable from outside; what
::  is observable is that the oracle was asked AGAIN for a ship it had
::  already vouched for -- which only a solicitation can cause -- and
::  that afterwards the peer is unblocked and traffic flows both ways.
;<  ~  bind:m  (poke-snob:io ~bud comet)
;<  ~  bind:m  (wait-for-output:io ~bud "%test-pki %response")
;<  ~  bind:m  (assert-not-snobbed:io ~bud comet)
;<  ~  bind:m  (send-hi:io comet ~bud)
;<  ~  bind:m  (send-hi:io ~bud comet)
::
;<  ~  bind:m  end:io
(pure:m *vase)
