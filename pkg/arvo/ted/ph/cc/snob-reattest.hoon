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
;<  ~  bind:m  (assert-known:io ~bud comet)
;<  before=[snd=(set @ud) rcv=(set @ud)]
    bind:m  (peer-bones:io ~bud comet core)
::
::  The domain withdraws its vouch.  ~bud soft-blocks the comet -- keeping
::  it as a %known peer -- and solicits a fresh attestation (%poof).  The
::  comet answers at once, the writ reaches the oracle, and the %full
::  lifts the block.  The fixture oracle deliberately waits one second,
::  leaving the intermediate soft block observable before its response.
;<  ~  bind:m  (poke-snob:io ~bud comet)
;<  ~  bind:m  (assert-snobbed:io ~bud comet)
;<  ~  bind:m  (assert-known:io ~bud comet)
::  The fixture oracle waits one second before producing its %fact; leave
::  another second for Gall, Jael, and Ames to consume that event chain.
;<  ~  bind:m  (sleep:io ~s2)
;<  ~  bind:m  (assert-not-snobbed:io ~bud comet)
;<  ~  bind:m  (assert-known:io ~bud comet)
;<  ~  bind:m  (assert-bones-retained:io ~bud comet core before)
;<  ~  bind:m  (send-hi:io comet ~bud)
;<  ~  bind:m  (send-hi:io ~bud comet)
::
;<  ~  bind:m  end:io
(pure:m *vase)
