/+  cc-io=ph-cc-io, az=aqua-azimuth
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-attestation-reject
=/  io  ~(. cc-io loud tag)
=/  comet  cc-comet-fail:az
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
::  The vector is rejected only after the scheduled behn wake.  The
::  channel must not establish, and ames must add the claimant to snub.
;<  ~  bind:m  (must-timeout:io ~s30 (send-hi:io comet ~bud))
;<  ~  bind:m  (assert-snubbed:io ~bud comet)
::
;<  ~  bind:m  end:io
(pure:m *vase)
