/+  cc-io=ph-cc-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-hi
=/  io  ~(. cc-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
::
=/  =onchain:io
  :~  [comet-1 1 0 ~ %if]
      [comet-2 1 0 ~ %if]
  ==
::
;<  ~  bind:m  start-simple:io
::
;<  ~  bind:m  (start-cc-comet:io comet-1 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-2 core onchain)
::
;<  ~  bind:m  (send-hi:io comet-1 comet-2)
;<  ~  bind:m  (send-hi:io comet-2 comet-1)
::
;<  ~  bind:m  end:io
(pure:m *vase)
