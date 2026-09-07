/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-az-key-cycle
=/  io  ~(. gw-io loud tag)
::
::  Keep this legacy Azimuth key-cycle case on vanilla suite-B comets.
::  Suite-C async verification is covered by the attestation-* cases.
=/  comet-1  ~harrep-podpec-torsut-docnyx--mopsyx-fosdus-ladpen-marbud
=/  comet-2  ~holwyx-ramped-tognet-barsyn--navler-ronmeg-topbex-mardev
::
=/  =onchain:io
  :~  [comet-1 1 0 ~ %if]
  ==
::
;<  ~  bind:m  start-azimuth:io
::
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io ~marbud)
::
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io ~marbud | core)
::
;<  ~  bind:m  (start-gw-comet:io comet-1 core onchain)
::
;<  ~  bind:m  (send-hi:io comet-1 ~bud)
;<  ~  bind:m  (send-hi:io ~marbud comet-1)
::
;<  ~  bind:m  (poke-rekey:io comet-1 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-1 comet-1 2)
::
;<  ~  bind:m  (must-timeout:io ~m1 (send-hi:io ~marbud comet-1))
::
;<  ~  bind:m  end:io
(pure:m *vase)
