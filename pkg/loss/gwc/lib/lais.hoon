/+  der, scr=btc-script, ord
|%
++  rax                                           ::  encode
  |=  p=$
  ^-  (trel @ bloq step)
  ?^  -.p
    =/  l  $(p l.p)
    =/  r  $(p r.p)
    =/  s  (rig +.l q.r)
    [(add p.l (lsh [q.r s] p.r)) q.r (add r.r s)]
  ::
  ?~  b.p  [0 a.p 0]
  =;  c=(pair @ step)
    =/  d  $(b.p t.b.p)
    [(add p.c (lsh [a.p q.c] p.d)) a.p (add q.c r.d)]
  ::
  ?@  i.b.p
    [i.b.p (^met a.p i.b.p)]
  ?-  -.i.b.p
    @       [(end [a.p p.i.b.p] q.i.b.p) p.i.b.p]
    [%c ~]  [(cut a.p [p q]:i.b.p) q.p.i.b.p]
    [%m ~]  =+((cut a.p [p q]:i.b.p) [- (^met a.p -)])
    [%s ~]  =/  e  $(p p.i.b.p)
            [p.e (rig +.e a.p)]
  ==

++  encode
  =,  ord
  |=  sots=(list sotx)
  %-  fax:plot
  :-  bloq=0
  |^  ^-  (list plat:plot)
  ?~  sots  ~
  =*  sot  i.sots
  =*  our  ship.sot
  =*  sig   sig.sot
  =-   :~  [5 0]
          [[%s ~] (en-sig sig)]
          [128 our]
          [[%s ~] bloq=0 -]
       ==
  ^-  (list plat:plot)
  =-  (weld - $(sots t.sots))
  =/  sots=(list single:skim-sotx)
    ?:(?=(%batch +<.sot) bat.sot ~[+.sot])
  ^-  (list plat:plot)
  =-  ^-  (list plat:plot)
      ?.  ?=(%batch +<.sot)  pat
      ?:  =(i 0)  ~
      ?:  =(i 1)  pat
      [[7 10] (mat i) pat]
  =|  i=@ud
  =|  pas=(list plat:plot)
  |-  ^-  [i=@ud pat=(list plat:plot)]
  ?~  sots  i^pas
  =*  sot  i.sots
  =-  $(sots t.sots, i +(i.+), pas (weld pas -))
  |-  ^-  (list plat:plot)
  ?-    -.sot
      %set-mang
    ?~  mang.sot  [[7 8] [2 0] ~]
    ?-  -.u.mang.sot
        %sont
      [[7 8] [2 1] (en-sont sont.u.mang.sot)]
        %pass
      [[7 8] [2 2] [256 pass.u.mang.sot] ~]
    ==
      %spawn
    |^  ^+  ^$
    =+  m=(mat pass.sot)
    ::[[7 1] [1 0] m en-to en-from]
    [[7 1] [1 0] m en-to ~]
    ::
    ++  en-to
      ^-  plat:plot
      :+  s+~  0
      :*  [256 spkvh.to.sot]
          (mat off.to.sot)  (mat tej.to.sot)
          ?~(pos.to.sot [2 0]^~ [2 1]^(mat u.pos.to.sot)^~)
          ::?~(pos.to.sot ~ [(mat u.pos.to.sot) ~])
      ==
    ::  ++  en-from
    ::    ^-  plat:plot
    ::    ?~  from.sot  [2 0]
    ::    [%s 0 ~[[2 1] (mat pos.from) (mat sat.from)]]
    --
  ::
      %keys
    =+  m=(mat pass.sot)
    [[7 2] [1 breach.sot] m ~]
  ::
      %fief
    :+  [7 11]  [1 0]
    ?~  fief.sot  ~[[2 0]]
    =*  fef  u.fief.sot
    ?-  -.fef
      %turf  !!
      %if  ~[[2 2] [32 p.fef] [16 q.fef]]
      %is  ~[[2 3] [128 p.fef] [16 q.fef]]
    ==
  ::
      ?(%escape %cancel-escape %adopt %reject %detach)
    =-  [[7 -] [1 0] [128 +>.sot] ~]
    ?-  -.sot
      %escape         3
      %cancel-escape  4
      %adopt          5
      %reject         6
      %detach         7
    ==
  ==
  ::
  ++  en-sig
    |=  sig=(unit @)
    ^-  plot
    ?~  sig  [bloq=0 [2 0] ~]
    [bloq=0 [2 1] [512 u.sig] ~]
  ::
  ++  en-sont
    |=  sont
    ^-  (list plat:plot)
    =/  mi  (mat pos)
    =/  mo  (mat off)
    [[1 0] [256 txid] mi mo ~]
  --
--
