::  A comet with a conventional sponsor is reachable at its own fief.
::
::    comet-1 is sponsored by comet-2 and publishes an %if fief.
::    comet-2 publishes none and is never started, so it can relay
::    nothing and its ships-to-lane lookup fails outright.  comet-3 has
::    never heard a packet from comet-1, so the only address it can
::    possibly have for comet-1 is the one comet-1 committed to.
::
::    +sy-put-ship used to give a peer a route only when it sponsored
::    itself, so comet-3 held route=~ here, +send-blob-via traced
::    "no route to" and handed everything to comet-2, and this hung.
::    Compare +ph-cc-hi-sponsor, where the sponsor is up and relaying
::    is enough.
::
/+  cc-io=ph-cc-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %cc-hi-fief
=/  io  ~(. cc-io loud tag)
::
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
=/  comet-3  ~dansyr-ponbec-tocfel-laddux--socnut-nisnyx-dinsut-marbud
::
=/  =onchain:io
  :~  [peer=comet-1 life=1 rift=0 spon=`comet-2 fef=%if]
      [peer=comet-2 life=1 rift=0 spon=~ fef=~]
      [peer=comet-3 life=1 rift=0 spon=~ fef=%if]
  ==
::
;<  ~  bind:m  start-simple:io
::
;<  ~  bind:m  (start-cc-comet:io comet-1 core onchain)
;<  ~  bind:m  (start-cc-comet:io comet-3 core onchain)
::
;<  ~  bind:m  (send-hi:io comet-3 comet-1)
::
;<  ~  bind:m  end:io
(pure:m *vase)
