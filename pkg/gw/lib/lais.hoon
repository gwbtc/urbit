/+  der, scr=btc-script, ord
|%
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
  =-  :~  [5 0]
          [[%s ~] (en-sig sig)]
          [128 our]
          [[%s ~] bloq=0 -]
          [[%s ~] [bloq=0 $(sots t.sots)]]
       ==
  ^-  (list plat:plot)
  =-  $.+(sots t.sots)
  =/  sots=(list single:skim-sotx)
    ?:(?=(%batch +<.sot) bat.sot ~[+.sot])
  =-  ?:  =(i 0)  ~
      ?:  =(i 1)  pat
      [[7 10] (mat i) pat]
  =|  i=@ud
  =|  pas=(list plat:plot)
  |-  ^-  [i=@ud pat=(list plat:plot)]
  ?~  sots  i^pas
  =*  sot  i.sots
  =-  $(sots t.sots, i +(i.+), pas (weld - pas))
  |-  ^-  (list plat:plot)
  ?-    -.sot
      %set-mang
    ~!  sot1=sot
    ?~  mang.sot  [[7 8] [2 0] ~]
    ~!  sot2=sot
    ?-  -.u.mang.sot
        %sont
      [[7 8] [2 1] (en-sont sont.u.mang.sot)]
        %pass
      [[7 8] [2 2] [256 pass.u.mang.sot] ~]
    ==
      %spawn
    =+  m=(mat pass.sot)
    [[7 1] [1 0] m (en-sont sont.sot)]
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
    ?~  sig  [bloq=0 [1 0] ~]
    [bloq=0 [1 1] [512 u.sig] ~]
  ::
  ++  en-sont
    |=  sont
    ^-  (list plat:plot)
    =/  mi  (mat pos)
    =/  mo  (mat off)
    [[1 0] [256 txh] mi mo ~]
  --
--
