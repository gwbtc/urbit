/+  *ph-gw-util
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
=/  loud  %.n
::
;<  ~  bind:m  start-simple
::
;<  ~  bind:m  (start-gw-comet comet-1 loud core [comet-2 1 ~ %if]~)
;<  ~  bind:m  (start-gw-comet comet-2 loud core [comet-1 1 ~ %if]~)
::
~?  >>  loud  [%gw-comet-hi "{(cite:title comet-1)}: send hi to {(cite:title comet-2)}"]
;<  ~  bind:m  (send-hi comet-1 comet-2)
~?  >>  loud  [%gw-comet-hi "{(cite:title comet-2)}: send hi to {(cite:title comet-1)}"]
;<  ~  bind:m  (send-hi comet-2 comet-1)
::
;<  ~  bind:m  end
(pure:m *vase)
