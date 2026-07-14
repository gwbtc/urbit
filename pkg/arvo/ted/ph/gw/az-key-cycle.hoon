/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-az-key-cycle
=/  io  ~(. gw-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
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
