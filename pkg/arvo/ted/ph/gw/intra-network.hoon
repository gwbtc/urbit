/+  *ph-gw-util
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
=/  comet-3  ~dansyr-ponbec-tocfel-laddux--socnut-nisnyx-dinsut-marbud
::
=/  loud  %.n
::
=/  =onchain
  :~  [peer=comet-1 life=1 spon=`comet-2 fef=~]
      [peer=comet-2 life=1 spon=~ fef=%if]
      [peer=comet-3 life=1 spon=~ fef=%if]
  ==
::
;<  ~  bind:m  start-azimuth
::
;<  ~  bind:m  (spawn ~bud)
;<  ~  bind:m  (init-ship ~bud |)
;<  ~  bind:m  (spawn ~marbud)
;<  ~  bind:m  (init-ship ~marbud |)
::
;<  ~  bind:m  (start-gw-comet comet-1 loud core onchain)
;<  ~  bind:m  (start-gw-comet comet-2 loud core onchain)
;<  ~  bind:m  (start-gw-comet comet-3 loud core onchain)
::
~?  >>  loud  [%intra-network "{(cite:title comet-1)}: send hi to {(cite:title comet-2)}"]
;<  ~  bind:m  (send-hi comet-1 comet-2)
~?  >>  loud  [%intra-network "{(cite:title comet-3)}: send hi to {(cite:title comet-1)}"]
;<  ~  bind:m  (send-hi comet-3 comet-1)
::
~?  >>  loud  [%intra-network "{(cite:title comet-1)}: send hi to {(cite:title ~bud)}"]
;<  ~  bind:m  (send-hi comet-1 ~bud)
~?  >>  loud  [%intra-network "{(cite:title comet-2)}: send hi to {(cite:title ~bud)}"]
;<  ~  bind:m  (send-hi comet-2 ~bud)
~?  >>  loud  [%intra-network "{(cite:title comet-3)}: send hi to {(cite:title ~bud)}"]
;<  ~  bind:m  (send-hi comet-3 ~bud)
::
~?  >>  loud  [%intra-network "{(cite:title ~marbud)}: send hi to {(cite:title comet-1)}"]
;<  ~  bind:m  (send-hi ~marbud comet-1)
~?  >>  loud  [%intra-network "{(cite:title comet-3)}: send hi to {(cite:title ~marbud)}"]
;<  ~  bind:m  (send-hi comet-3 ~marbud)
::
;<  ~  bind:m  end
(pure:m *vase)
