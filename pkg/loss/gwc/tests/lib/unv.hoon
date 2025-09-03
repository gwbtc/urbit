/+  lais, ord
=,  crypto
=,  ord
|%
++  walt
  |_  [sed=@uw lyf=_1 hd-idx=@]
  ++  nu
    |=  sed=@uw
    ..nu(sed sed)
  ::
  ++  cyc
    %:  pit:nu:cryc
        512  (shaz (jam sed lyf))
        %c   (jam %btc %ord %gw %test)
    ==
  ::
  ++  btc
    !!
  ::
  ++  fig  `@p`fig:ex:cyc(lyf 1)
  ++  spawn
    |=  $:  ::from=(unit [=pos =off])
            out=[spkvh=@ux pos=(unit pos) =off tej=off]
        ==
    ^-  sotx
    [fig^~ [%spawn pub:ex:cyc +<]]
  ::
  ++  keys
    |=  bech=?
    ^+  [*sotx ..nu]
    =.  ..nu  ..nu(lyf +(lyf))
    ~!  cyc
    [fig^~ [%keys pub:ex:cyc bech]]^..nu
  ::
  ++  escape
    |=  her=@p
    ^-  sotx
    [fig^~ [%escape her]]
  ::
  ++  cancel-escape
    |=  her=@p
    ^-  sotx
    [fig^~ [%cancel-escape her]]
  ::
  ++  adopt
    |=  her=@p
    ^-  sotx
    [fig^~ [%adopt her]]
  ::
  ++  reject
    |=  her=@p
    ^-  sotx
    [fig^~ [%reject her]]
  ::
  ++  detach
    |=  her=@p
    ^-  sotx
    [fig^~ [%detach her]]
  ::
  ++  fief
    |=  fef=(unit ^fief)
    ^-  sotx
    [fig^~ [%fief fef]]
  ::
  ++  set-mang
    |=  man=(unit mang)
    ^-  sotx
    [fig^~ [%set-mang man]]
  --
::
++  ali  (nu:walt (shaz 'ali'))
++  bob  (nu:walt (shaz 'bob'))
--
=+  ^-  wats=(list _walt)
    :~  ali  bob
    ==
|%
::
++  spawns
  |=  [txh=@ os-vals=(list @ud) off=@ud]
  |^  ::^-  (list sotx)
  =+  make-input
  ~

  ++  make-outputs
    ~+  =|  pos=@ud
    |-  ^-  (list output:tx)
    ?~  os-vals  ~
    :_  $(os-vals t.os-vals)
    [256^(shax pos) i.os-vals]
  ::
  ++  make-input
    =/  sots  make-sots
    =/  en-sots  p:(encode:lais (slag 200 sots))
    ~&  (met 3 en-sots)
    =/  tscr  (unv-to-script:en en-sots)
    =/  wit   (en:bscr tscr)
    =/  de-wit  (need (de:script wit))
    ?>  =(de-wit tscr)
    =/  de-unv  (unv:de de-wit)
    ?>  ?=([* ~] de-unv)
    =/  rol  (parse-roll i.de-unv)
    ~&  [(lent rol) (lent sots)]
    ~&  [rol=sot:(rear rol) sot=(rear sots)]
    ?>  =((turn rol |=([* =sotx] +<+)) sots)
    ~
  ::
  ++  make-sots
    =/  os  make-outputs
    =/  l  (lent wats)
    =/  tot  (roll os |=([[* a=@] b=@] (add a b)))
    ~|  [l=l tot=tot]
    =/  feq  (rsh 8 (div (lsh 8 (dec (sub tot off))) l))
    ~|  %spawn-test-insufficient-sats
    ?>  !=(0 tot)
    ?>  !=(0 feq)
    ?>  (lth (mul feq l) tot)
    ?>  ?=(^ os)
    ::?>  (lth off feq)
    =/  sats  value.i.os
    =|  sots=(list sotx)
    =|  i=@ud
    =|  pos=@ud
    ~|  %spawn-test-shouldnt-happen
    |-  ^+  sots
    ?~  wats  (flop sots)
    =/  xat  (add (mul i feq) off)
    ?:  (lte sats xat)
      ?>  ?=(^ t.os)
      $(os t.os, sats (add sats value.i.t.os), pos +(pos))
    =.  i  +(i)
    =/  en-out  (can 3 script-pubkey.i.os 8^value.i.os ~)
    =/  hax-out  (shay (add 8 wid.script-pubkey.i.os) en-out)
    =/  sot
      (spawn:i.wats hax-out ?:(=(0 (mod i 2)) ~ `pos) (sub sats xat) 0)
    $(sots sot^sots, wats t.wats)
  ::
  --
::
++  keys
  ^-  [sots=(list sotx) =_wats]
  =|  n=@ud
  =/  taws  ^+(wats ~)
  =|  sots=(list sotx)
  |-  ^+  [sots wats]
  ?~  wats  [(flop sots) (flop taws)]
  =*  wat  i.wats
  =^  sot  wat  (keys:wat =(0 (mod n 2)))
  $(sots sot^sots, taws wat^taws, n +(n), wats t.wats)
::
--
