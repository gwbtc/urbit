/+  cc-io=ph-cc-io, az=aqua-azimuth
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-attestation-life-2
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
::
::  Rekey only the sender.  ~bud has no injected life-2 udiff, so the
::  next open packet must take the suite-C writ path again and promote
::  the returned life-2 point before traffic can resume.
;<  ~  bind:m  (poke-rekey:io comet 2)
;<  ~  bind:m  (poke-keys-udiff:io comet comet 2)
;<  ~  bind:m  (send-hi:io comet ~bud)
::
;<  ~  bind:m  end:io
(pure:m *vase)
