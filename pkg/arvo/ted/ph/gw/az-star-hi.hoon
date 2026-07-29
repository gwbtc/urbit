/+  gw-io=ph-gw-io
|=  arg=vase
=/  m  (strand:rand ,vase)
=/  core=?(%ames %mesa)  (fall !<((unit ?(%ames %mesa)) arg) %ames)
::
=/  loud  %.y
=/  tag  %az-star-hi
=/  io  ~(. gw-io loud tag)

::
::  Keep this legacy synthetic-PKI case on suite-B comets.  Suite-C
::  comets now require an actual registered domain verifier.
=/  comet-1  ~harrep-podpec-torsut-docnyx--mopsyx-fosdus-ladpen-marbud
=/  comet-2  ~liblyn-togrut-tabwel-hodbet--dovbex-parryt-mirbyt-marbud
=/  comet-3  ~hidreb-naptev-banben-bicrup--massup-dantus-fodwet-marbud
::
::  Ames can exercise the synthetic comet-to-comet sponsor edge below.
::  Mesa only honors emitted %saxo for suite-C comets; for vanilla suite-B
::  comets it routes through the default sponsor hierarchy instead.
=/  comet-1-sponsor=(unit @p)  ?:(=(%ames core) `comet-2 ~)
::
=/  =onchain:io
  :~  [peer=comet-1 life=1 rift=0 spon=comet-1-sponsor fef=~]
      [peer=comet-2 life=1 rift=0 spon=~ fef=%if]
      [peer=comet-3 life=1 rift=0 spon=~ fef=%if]
  ==
::
;<  ~  bind:m  start-azimuth:io
::
;<  ~  bind:m  (spawn:io ~bud)
;<  ~  bind:m  (init-ship-core:io ~bud | core)
;<  ~  bind:m  (spawn:io ~marbud)
;<  ~  bind:m  (init-ship-core:io ~marbud | core)
::
::  Ames retains the synthetic-PKI topology.  Mesa's suite-B routing uses
::  Azimuth's default sponsor hierarchy, so boot its comets through the
::  simulated Azimuth snapshot just like the vanilla interop tests.
;<  ~  bind:m
  ?:  =(%ames core)
    (start-gw-comet:io comet-1 core onchain)
  (init-ship-core:io comet-1 | core)
;<  ~  bind:m
  ?:  =(%ames core)
    (start-gw-comet:io comet-2 core onchain)
  (init-ship-core:io comet-2 | core)
;<  ~  bind:m
  ?:  =(%ames core)
    (start-gw-comet:io comet-3 core onchain)
  (init-ship-core:io comet-3 | core)
::
::  Vanilla Mesa comets first discover the default hierarchy.  Ames skips
::  this warm-up so its first comet-to-comet exchange still covers the
::  synthetic sponsor edge.
;<  ~  bind:m  ?:(=(%mesa core) (send-hi:io comet-1 ~bud) (sleep:io ~s0))
;<  ~  bind:m  ?:(=(%mesa core) (send-hi:io comet-2 ~bud) (sleep:io ~s0))
;<  ~  bind:m  ?:(=(%mesa core) (send-hi:io comet-3 ~bud) (sleep:io ~s0))
::
;<  ~  bind:m  (send-hi:io comet-1 comet-2)
;<  ~  bind:m  (send-hi:io comet-3 comet-1)
::
;<  ~  bind:m  (send-hi:io comet-1 ~bud)
;<  ~  bind:m  (send-hi:io comet-2 ~bud)
;<  ~  bind:m  (send-hi:io comet-3 ~bud)
::
;<  ~  bind:m  (send-hi:io ~marbud comet-1)
;<  ~  bind:m  (send-hi:io comet-3 ~marbud)
::
;<  ~  bind:m  end:io
(pure:m *vase)
