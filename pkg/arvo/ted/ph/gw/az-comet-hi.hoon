/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-az-comet-hi
=/  io  ~(. gw-io loud tag)
::
::  This legacy case covers vanilla Azimuth interoperability.  The
::  canonical suite-C verification path lives in attestation-hi.
=/  gw-comet-1  ~hidreb-naptev-banben-bicrup--massup-dantus-fodwet-marbud
::  Azimuth suite B comets under ~marbud
::
=/  az-comet-1  ~harrep-podpec-torsut-docnyx--mopsyx-fosdus-ladpen-marbud
=/  az-comet-2  ~liblyn-togrut-tabwel-hodbet--dovbex-parryt-mirbyt-marbud
::  Azimuth suite B comets under ~mardev
::
=/  az-comet-3  ~holwyx-ramped-tognet-barsyn--navler-ronmeg-topbex-mardev
=/  az-comet-4  ~hacmet-doslyr-narhut-tiptec--micbyl-motnev-worsyn-mardev
::
=/  =onchain:io  [peer=gw-comet-1 life=1 rift=0 spon=~ fef=%if]~
::
;<  ~  bind:m  start-azimuth:io
::
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (spawn:io ~marbud)
;<  ~  bind:m  (spawn:io ~dev)
;<  ~  bind:m  (spawn:io ~mardev)
::
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (init-ship-core:io ~marbud | core)
::
;<  ~  bind:m  (init-ship-core:io ~dev | core)
;<  ~  bind:m  (init-ship-core:io ~mardev | core)
::
;<  ~  bind:m  (init-ship-core:io az-comet-1 | core)
;<  ~  bind:m  (init-ship-core:io az-comet-2 | core)
;<  ~  bind:m  (init-ship-core:io az-comet-3 | core)
;<  ~  bind:m  (init-ship-core:io az-comet-4 | core)
::
;<  ~  bind:m  (start-gw-comet:io gw-comet-1 core onchain)
::
;<  ~  bind:m  (send-hi:io gw-comet-1 ~bud)
::
;<  ~  bind:m  (send-hi:io az-comet-1 ~bud)
;<  ~  bind:m  (send-hi:io az-comet-2 ~bud)
;<  ~  bind:m  (send-hi:io az-comet-3 ~dev)
;<  ~  bind:m  (send-hi:io az-comet-4 ~dev)
::
;<  ~  bind:m  (send-hi:io gw-comet-1 az-comet-1)
;<  ~  bind:m  (send-hi:io az-comet-2 gw-comet-1)
::
;<  ~  bind:m  (send-hi:io gw-comet-1 az-comet-3)
;<  ~  bind:m  (send-hi:io az-comet-4 gw-comet-1)
::
;<  ~  bind:m  end:io
(pure:m *vase)
