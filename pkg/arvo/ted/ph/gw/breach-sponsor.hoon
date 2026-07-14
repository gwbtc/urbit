/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %gw-breach-sponsor
=/  io  ~(. gw-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
=/  comet-3  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
=/  comet-4  ~fosnys-noctyd-talfyl-borryl--davhus-disbyn-fotnec-mardev
::
=/  oc=onchain:io
  :~  [peer=comet-1 life=1 rift=0 spon=`comet-2 fef=~]
      [peer=comet-2 life=1 rift=0 spon=~ fef=%if]
      [peer=comet-3 life=1 rift=0 spon=`comet-4 fef=~]
      [peer=comet-4 life=1 rift=0 spon=~ fef=%if]
  ==
::
;<  ~              bind:m  start-simple:io
::
;<  ~              bind:m  (start-gw-comet:io comet-1 core oc)
;<  ~              bind:m  (start-gw-comet:io comet-2 core oc)
;<  ~              bind:m  (start-gw-comet:io comet-3 core oc)
;<  ~              bind:m  (start-gw-comet:io comet-4 core oc)
::
;<  ~              bind:m  (send-hi:io comet-1 comet-2)
;<  ~              bind:m  (send-hi:io comet-3 comet-4)
::
;<  oc=onchain:io  bind:m  (gw-breach:io comet-1 new-life=2 new-rift=1 core oc)
::
;<  ~              bind:m  (send-hi:io comet-2 comet-1)
;<  ~              bind:m  (send-hi:io comet-1 comet-2)
::
;<  oc=onchain:io  bind:m  (gw-breach:io comet-4 new-life=2 new-rift=1 core oc)
::
;<  ~              bind:m  (send-hi:io comet-3 comet-4) 
;<  ~              bind:m  (send-hi:io comet-4 comet-3)
::
;<  ~              bind:m  end:io
(pure:m *vase)
