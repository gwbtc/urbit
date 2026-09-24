/+  cc-io=ph-cc-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-attestation-malformed
=/  io  ~(. cc-io loud tag)
::
::  A suite-C comet whose dat carries a bare atom rather than a
::  +mat-encoded domain at its head: the one malformation the kernel is
::  able to see, since the +mat is all of a dat it ever reads.
=/  comet  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  sponsor  (^sein:title comet)
=/  =onchain:io  [peer=comet life=1 rift=0 spon=~ fef=%if]~
::
;<  ~  bind:m  start-azimuth:io
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io sponsor)
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io sponsor | core)
;<  ~  bind:m  (start-cc-comet:io comet core onchain)
::
::  Both Ames packet paths must drop this pass before creating alien
::  verification state or asking Jael.  A clean timeout is the expected
::  result; the old direct +rub call crashed instead.
;<  ~  bind:m  (must-timeout:io ~s30 (send-hi:io comet ~bud))
::
;<  ~  bind:m  end:io
(pure:m *vase)
