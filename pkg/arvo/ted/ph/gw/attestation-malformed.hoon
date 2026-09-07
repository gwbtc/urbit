/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-attestation-malformed
=/  io  ~(. gw-io loud tag)
::
::  This suite-C fixture predates the canonical Groundwire packet and
::  carries an atom rather than a +mat-encoded domain at the head of dat.
=/  comet  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  sponsor  (^sein:title comet)
=/  =onchain:io  [peer=comet life=1 rift=0 spon=~ fef=%if]~
::
;<  ~  bind:m  start-azimuth:io
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io sponsor)
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io sponsor | core)
;<  ~  bind:m  (start-gw-comet:io comet core onchain)
::
::  Both Ames packet paths must drop this pass before creating alien
::  verification state or asking Jael.  A clean timeout is the expected
::  result; the old direct +rub call crashed instead.
;<  ~  bind:m  (must-timeout:io ~s30 (send-hi:io comet ~bud))
::
;<  ~  bind:m  end:io
(pure:m *vase)
