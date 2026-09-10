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
;<  ~  bind:m  (install-pki-mounted:io comet)
;<  ~  bind:m  (assert-life-key-model:io comet)
;<  ~  bind:m  (assert-ames-keys:io comet 1)
;<  ~  bind:m  (assert-jael-point:io comet comet 1 0)
;<  ~  bind:m  (assert-jael-active-life:io comet 1)
::
::  Establish the life-1 point through the asynchronous verifier.
;<  ~  bind:m  (send-hi:io comet ~bud)
;<  ~  bind:m  (assert-jael-point:io ~bud comet 1 0)
::
::  Exercise the userspace-facing order: the domain agent first publishes
::  an own %verdict carrying the authorized public point.  Only then does
::  standard %rekey activate the matching private ring and send +sy-priv.
;<  ~  bind:m  (poke-self-verdict:io comet comet 2)
;<  ~  bind:m  (assert-jael-point:io comet comet 2 0)
;<  ~  bind:m  (assert-jael-active-life:io comet 1)
;<  ~  bind:m  (poke-rekey:io comet 2)
;<  ~  bind:m  (assert-ames-keys:io comet 2)
;<  ~  bind:m  (assert-jael-active-life:io comet 2)
::
::  ~bud has no injected life-2 udiff, so the next open packet must take
::  the suite-C writ path again and promote the returned life-2 point.
;<  ~  bind:m  (send-hi:io comet ~bud)
;<  ~  bind:m  (assert-jael-point:io ~bud comet 2 0)
::
;<  ~  bind:m  end:io
(pure:m *vase)
