/+  cc-io=ph-cc-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-hi-sponsor
=/  io  ~(. cc-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
=/  comet-3  ~dansyr-ponbec-tocfel-laddux--socnut-nisnyx-dinsut-marbud
::
=/  =onchain:io
  :~  [peer=comet-1 life=1 rift=0 spon=`comet-2 fef=~]
      [peer=comet-2 life=1 rift=0 spon=~ fef=%if]
      [peer=comet-3 life=1 rift=0 spon=~ fef=%if]
  ==
::
;<  ~  bind:m  start-simple:io
::
;<  ~  bind:m  (start-cc-comet:io comet-1 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-2 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-3 core onchain)
::
;<  ~  bind:m  (send-hi:io comet-1 comet-2)
;<  ~  bind:m  (send-hi:io comet-3 comet-1)
::
;<  ~  bind:m  end:io
(pure:m *vase)
