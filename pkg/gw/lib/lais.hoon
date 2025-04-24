/+  der, scr=btc-script, ord
|%
++  encode
  =,  ord
  |=  bat=(list sotx)
  %-  fax:plot
  :-  bloq=0
  |^  ^-  (list plat:plot)
  =*  sot  i.bat
  ?~  bat  ~
  =-  :~  [5 0]
          [3 0] :: ?>(?=(%own proxy) 0)
          [128 ship.from.sot]
          [[%s ~] bloq=0 -]
          [[%s ~] [bloq=0 $(bat t.bat)]]
       ==
  ^-  (list plat:plot)
  ?-    +<.sot
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
    ?-  +<.sot
      %escape         3
      %cancel-escape  4
      %adopt          5
      %reject         6
      %detach         7
    ==
  ==
  ::
  ++  en-sont
    |=  sont
    ^-  (list plat:plot)
    =/  mi  (mat pos)
    =/  mo  (mat off)
    [[1 0] [256 txh] mi mo ~]
  --
--
