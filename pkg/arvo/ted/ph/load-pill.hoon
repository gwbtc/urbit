::  Easily load a pill into Aqua
::
::    Also turns off OTAs by editing kiln.hoon
::
::    Arg is one of:
::    - nothing: use base desk
::    - %blah: use %blah desk as base
::    - [%pill /===/my-pill/pill]
::    - [%desk %base-desk %groups /=landscape= %pals ~]
::    - [%desk /===/sys ...]
::    (you can mix and match beams and desks in the %desk case)
::    (note if you specify a beam for base it must be to /sys, not /)
::
/+  pill, strandio
|=  arg=vase
|^  =/  m  (strand:rand ,vase)
::
;<  our=@p   bind:m  get-our:strandio
;<  now=@da  bind:m  get-time:strandio
::
=/  [base=base-source rest=(list [desk path])]
  =+  !<(args=(unit args) arg)
  ?~  args
    [%desk (en-beam [our %base da+now] /sys)]~
  ?@  u.args
    [%desk (en-beam [our u.args da+now] /sys)]~
  ?:  ?=(%pill -.u.args)  [u.args ~]
  :-  ?^  base.u.args
        [%desk base.u.args]
      [%desk (en-beam [our base.u.args da+now] /sys)]
  %+  turn  more.u.args
  |=  d=$@(desk [@ta @ta @ta path])
  ?^  d  [+<.d d]
  [d (en-beam [our d da+now] /)]
?:  ?=(%pill -.base)
  =/  =pill:pill  (no-ota-in-pill .^(pill:pill %cx path.base))
  ;<  ~  bind:m  (poke:strandio [our %aqua] pill+!>(pill))
  (pure:m !>(~))
=/  =pill:pill
  (no-ota-in-pill (solid:pill path.base rest | now | ~))
;<  ~  bind:m  (poke:strandio [our %aqua] pill+!>(pill))
(pure:m !>(~))
::
+$  desks  (list $@(desk [@ta @ta @ta path]))
+$  args
  $@  desk
  $%  [%pill path=[@ta @ta @ta path]]
      [%desk base=$@(desk [@ta @ta @ta path]) more=desks]
  ==
::
+$  base-source
  $%  [%pill =path]
      [%desk =path]
  ==
::
++  no-ota-in-pill
  |=  pil=pill:pill
  |^  ^-  pill:pill
  ?.  ?=(%pill -.pil)
    pil
  ?.  =(%solid nam.pil)
    pil
  %=    pil
      userspace-ova
    %+  turn  userspace-ova.pil
    |=  ue=unix-event:pill
    ^-  unix-event:pill
    ?.  ?=(%park -.q.ue)    ue
    ?.  =(%base des.q.ue)   ue
    ?.  ?=(%.y -.yok.q.ue)  ue
    =+  got=(~(get by q.p.yok.q.ue) /lib/hood/kiln/hoon)
    ?~  got                 ue
    ?.  ?=(%.y -.u.got)     ue
    ?.  =(%hoon p.p.u.got)  ue
    =/  pag=page  [`@tas`%hoon (no-ota ;;(@t q.p.u.got))]
    %=    ue
        q.p.yok.q
      %+  ~(put by q.p.yok.q.ue)
        /lib/hood/kiln/hoon
      `(each page lobe:clay)`[%& pag]
    ==
  ==
  ::
  ++  no-ota
    |=  txt=@t
    %-  of-wain:format
    %+  turn  (to-wain:format txt)
    |=  lin=@t
    ?:  ?|  =(lin '    abet:init:(apex:(sync %base sop %kids) `%kids)')
            =(lin '    abet:init:(sync i.dez u.src i.dez)')
        ==
      '..on-init  ::  disabled for aqua'
    lin
  --
--
