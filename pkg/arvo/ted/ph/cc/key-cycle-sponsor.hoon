/+  cc-io=ph-cc-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-key-cycle-sponsor
=/  io  ~(. cc-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
=/  comet-3  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
=/  comet-4  ~fosnys-noctyd-talfyl-borryl--davhus-disbyn-fotnec-mardev
::
=/  =onchain:io
  :~  [peer=comet-1 life=1 rift=0 spon=`comet-2 fef=~]
      [peer=comet-2 life=1 rift=0 spon=~ fef=%if]
      [peer=comet-3 life=1 rift=0 spon=`comet-4 fef=~]
      [peer=comet-4 life=1 rift=0 spon=~ fef=%if]
  ==
::
;<  ~  bind:m  start-simple:io
::
;<  ~  bind:m  (start-cc-comet:io comet-1 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-2 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-3 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-4 core onchain)
::
;<  ~  bind:m  (send-hi:io comet-1 comet-2)
;<  ~  bind:m  (send-hi:io comet-3 comet-4)
::
;<  ~  bind:m  (poke-rekey:io comet-1 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-1 comet-1 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-2 comet-1 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-3 comet-1 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-4 comet-1 2)
::
;<  ~  bind:m  (send-hi:io comet-2 comet-1)
;<  ~  bind:m  (send-hi:io comet-1 comet-2)
::
;<  ~  bind:m  (poke-rekey:io comet-4 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-1 comet-4 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-2 comet-4 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-3 comet-4 2)
;<  ~  bind:m  (poke-keys-udiff:io comet-4 comet-4 2)
::
;<  ~  bind:m  (send-hi:io comet-4 comet-3)
;<  ~  bind:m  (send-hi:io comet-3 comet-4)
::
;<  ~  bind:m  end:io
(pure:m *vase)
