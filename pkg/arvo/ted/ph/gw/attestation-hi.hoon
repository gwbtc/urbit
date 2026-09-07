/+  gw-io=ph-gw-io, az=aqua-azimuth
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-attestation-hi
=/  io  ~(. gw-io loud tag)
=/  comet  gw-comet-ok:az
=/  sponsor  (^sein:title comet)
=/  =onchain:io  [peer=comet life=1 rift=0 spon=~ fef=%if]~
::
;<  ~  bind:m  start-azimuth:io
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io sponsor)
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io sponsor | core)
;<  ~  bind:m  (install-gw-btc:io ~bud)
;<  ~  bind:m  (start-gw-comet:io comet core onchain)
::
::  No udiff for .comet is installed on ~bud.  Its first packet must
::  travel ames -> jael -> %gw-btc -> behn -> jael before |hi can finish.
;<  ~  bind:m  (send-hi:io comet ~bud)
::
;<  ~  bind:m  end:io
(pure:m *vase)
