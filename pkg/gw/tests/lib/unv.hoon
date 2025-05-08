/+  lais, ord, crac, *mip
=,  crypto
=,  ord
|%
++  walt
  |_  [sed=@uw lyf=_1 hd-idx=@ xtr=@]
  ++  nu
    |=  [sed=@uw xtr=@]
    ..nu(sed sed, xtr xtr)
  ::
  ++  cac
    =<  ?>(&(?=(%c suite.+<) ?=(^ sek.+<)) .)
    %:  pit:nu:crac
        512  (shaz (jam sed lyf))
        %c   (rap 3 ~[lyf %btc %ord %gw %test])
        xtr
    ==
  ::
  ++  btc
    !!
  ::
  ++  fig  `@p`fig:ex:cac(lyf 1)
  ++  skim
    |%
    ++  spawn
      |=  $:  ::from=(unit [=pos =off])
              out=[spkvh=@ux pos=(unit pos) =off tej=off]
          ==
      ^-  single:skim-sotx
      [%spawn pub:ex:cac +<]
    ::
    ++  keys
      |=  bec=?
      ^+  [*single:skim-sotx ..nu]
      =.  ..nu  ..nu(lyf +(lyf))
      [%keys pub:ex:cac bec]^..nu
    ::
    ++  escape
      |=  her=@p
      ^-  single:skim-sotx
      [%escape her]
    ::
    ++  adopt
      |=  her=@p
      ^-  single:skim-sotx
      [%adopt her]
    ::
    ++  fief
      |=  fief=(unit ^^fief)
      ^-  single:skim-sotx
      [%fief fief]
    ::
    ++  batch
      |=  sots=(list single:skim-sotx)
      ^-  skim-sotx
      [%batch sots]
    --
  ++  spawn
    |=  $:  ::from=(unit [=pos =off])
            out=[spkvh=@ux pos=(unit pos) =off tej=off]
        ==
    ^-  sotx
    =/  sot=skim-sotx  (spawn:skim +<)
    (sign-skim sot)
  ::
  ++  keys
    |=  bec=?
    ^+  [*sotx ..nu]
    =.  ..nu  ..nu(lyf +(lyf))
    =^  sot=skim-sotx  ..nu  (keys:skim +<)
    (sign-skim sot)^..nu
  ::
  ++  sign-batch
    |=  sots=(list single:skim-sotx)
    ^-  sotx
    =/  sot  (batch:skim +<)
    =/  ent  (skim:encode:lais sot)
    =/  sig  (sign-octs-raw:ed 512^(shaz ent) [sgn.pub sgn.sek]:+<:cac)
    [fig^[~ sig] sot]
  ::
  ++  sign-skim
    |=  sot=skim-sotx
    ^-  sotx
    =/  ent  (skim:encode:lais sot)
    =/  sig  (sign-octs-raw:ed 512^(shaz ent) [sgn.pub sgn.sek]:+<:cac)
    [fig^[~ sig] sot]
  ::
  ++  escape
    |=  her=@p
    ^-  sotx
    [fig^~ (escape:skim +<)]
  ::
  ++  cancel-escape
    |=  her=@p
    ^-  sotx
    [fig^~ [%cancel-escape her]]
  ::
  ++  adopt
    |=  her=@p
    ^-  sotx
    [fig^~ (adopt:skim +<)]
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
    [fig^~ (fief:skim +<)]
  ::
  ++  set-mang
    |=  man=(unit mang)
    ^-  sotx
    [fig^~ [%set-mang man]]
  --
::
--
=+  :*  ali=(nu:walt (shaz 'ali') 0xcafe.babe)
        bob=(nu:walt (shaz 'bob') 0xcafe.babe)
        car=(nu:walt (shaz 'car') 0xcafe.babe)
        dav=(nu:walt (shaz 'dav') 0xcafe.babe)
    ==
|%
++  count-sonts
  =,  ord
  |=  sm=sont-map
  %-  ~(rep by sm)
  |=  [[* a=(mip pos off sont-val)] b=@]
  %-  ~(rep by a)
  |=  [[* a=(map off sont-val)] =_b]
  (add ~(wyt by a) b)
::
++  test-0
  =/  oc  ord-core
  =.  oc
    %+  handle-tx:oc  0xcafe.babe
    =-  (spawns 0xcafe.beef - ~)
    :~  [val=100 ali spk=[256 (shax 'ali-spawn')] pos=0 off=0 xsot=~]
        [val=100 bob spk=[256 (shax 'bob-spawn')] pos=1 off=0 xsot=~]
        [val=100 car spk=[256 (shax 'car-spawn')] pos=2 off=0 xsot=~]
        [val=100 dav spk=[256 (shax 'dav-spawn')] pos=3 off=0 xsot=~]
    ==
  =/  tx-ali  (sing ali oc 100 (adopt:ali fig:ali))
  =/  tx-bob  (sing bob oc 100 (adopt:bob fig:bob))
  =.  oc  (handle-tx:oc 0xcafe.feed tx-ali)
  =.  oc  (handle-tx:oc 0xdead.babe tx-bob)
  =^  tx-ali  ali  =^(so ali (keys:ali |) (sing ali oc 100 so)^ali)
  =^  tx-bob  bob  =^(so bob (keys:bob &) (sing bob oc 100 so)^bob)
  =.  oc  (handle-tx:oc 0xdead.f00d tx-ali)
  =.  oc  (handle-tx:oc 0xbeef.f00d tx-bob)
  =/  tx-ali  (sing ali oc 100 (fief:ali ~ %if .127.0.0.1 1.337))
  =/  tx-bob  (sing bob oc 100 (fief:bob ~ %if .127.0.0.2 1.338))
  =.  oc  (handle-tx:oc 0xbeef.feed tx-ali)
  =.  oc  (handle-tx:oc 0xbabe.feed tx-bob)
  =/  tx-car  (sing car oc 100 (escape:car fig:ali))
  =/  tx-dav  (sing dav oc 100 (escape:dav fig:bob))
  =.  oc  (handle-tx:oc 0xbeef.babe tx-car)
  =.  oc  (handle-tx:oc 0xf00d.cafe tx-dav)
  =/  tx-ali  (sing ali oc 100 (adopt:ali fig:car))
  =/  tx-bob  (sing bob oc 100 (adopt:bob fig:dav))
  =.  oc  (handle-tx:oc 0x1337.f00d tx-ali)
  =.  oc  (handle-tx:oc 0x1337.babe tx-bob)
  oc
::
++  test-1
  =/  oc  ord-core
  =+  [kex nali]=(keys:skim:ali |)
  =+  [kex nbob]=(keys:skim:bob &)
  =.  oc
    %+  handle-tx:oc  0xcafe.babe
    %^  spawns  0xcafe.beef
      ^-  (list [val=@ud wat=_walt spk=byts pos=@ud off=@ud xsot=(list single:skim-sotx)])
      :~  =-  [val=100 ali spk=[256 (shax 'ali-spawn')] pos=0 off=0 xsot=-]
          ~[(adopt:skim:ali fig:ali) kex (fief:skim:ali ~ %if .127.0.0.1 1.337)]
          =-  [val=100 bob spk=[256 (shax 'bob-spawn')] pos=1 off=0 xsot=-]
          ~[(adopt:skim:bob fig:bob) kex (fief:skim:bob ~ %if .127.0.0.2 1.338)]
          [val=100 car spk=[256 (shax 'car-spawn')] pos=2 off=0 ~[(escape:skim:car fig:ali)]]
          [val=100 dav spk=[256 (shax 'dav-spawn')] pos=3 off=0 ~[(escape:skim:dav fig:bob)]]
      ==
    ^-  (list sotx)
    :~  (adopt:ali fig:car)
        (adopt:bob fig:dav)
    ==
  =.  ali  nali
  =.  bob  nbob
  oc
::
++  sing
  |=  [wat=_walt oc=_ord-core val=@ sot=sotx]
  ^+  *dataw:tx
  =/  pon  (~(got by unv-ids:oc) fig:wat)
  =|  tx=dataw:tx
  =.  is.tx  ~[(make-unv-input txid.sont.own.pon pos.sont.own.pon val ~[sot])]
  =.  os.tx  ~[[256 (shax 0)]^val]
  tx
::
::++  adopt
::  |=  [wat=_walt oc=_ord-core val=@ who=@p]
::  ^+  *dataw:tx
::  =/  pon  (~(got by unv-ids:oc) fig:wat)
::  =/  sot  (adopt:wat who)
::  =|  tx=dataw:tx
::  =.  is.tx  ~[(make-unv-input txid.sont.own.pon pos.sont.own.pon val ~[sot])]
::  =.  os.tx  ~[[256 (shax 0)]^val]
::  tx
::::
::++  escape
::  |=  [wat=_walt oc=_ord-core val=@ who=@p]
::  ^+  *dataw:tx
::  =/  pon  (~(got by unv-ids:oc) fig:wat)
::  =/  sot  (escape:wat who)
::  =|  tx=dataw:tx
::  =.  is.tx  ~[(make-unv-input txid.sont.own.pon pos.sont.own.pon val ~[sot])]
::  =.  os.tx  ~[[256 (shax 0)]^val]
::  tx
::::
::++  fief
::  |=  [wat=_walt oc=_ord-core val=@ fef=(unit ^fief)]
::  ^+  *dataw:tx
::  =/  pon  (~(got by unv-ids:oc) fig:wat)
::  =/  sot  (fief:wat fef)
::  =|  tx=dataw:tx
::  =.  is.tx  ~[(make-unv-input txid.sont.own.pon pos.sont.own.pon val ~[sot])]
::  =.  os.tx  ~[[256 (shax 0)]^val]
::  tx
::::
::++  keys
::  |=  [wat=_walt oc=_ord-core val=@ bec=?]
::  ^+  [*dataw:tx wat]
::  =/  pon  (~(got by unv-ids:oc) fig:wat)
::  =^  sot  wat  (keys:wat bec)
::  =|  tx=dataw:tx
::  =.  is.tx  ~[(make-unv-input txid.sont.own.pon pos.sont.own.pon val ~[sot])]
::  =.  os.tx  ~[[256 (shax 0)]^val]
::  tx^wat
::
++  make-unv-input
  |=  [itxid=@ pos=@ud value=@ sots=(list sotx)]
  ^-  inputw:tx
  =/  en-sots  (encode:lais sots)
  =/  tscr  (unv-to-script:en en-sots)
  =/  wit   (en:bscr tscr)
  =/  de-wit  (need (de:script wit))
  ?>  =(de-wit tscr)
  =/  de-unv  (unv:de de-wit)
  ?>  ?=([* ~] de-unv)
  =/  rol  (parse-roll i.de-unv)
  ~|  %failed-to-parse-the-same
  ?>  =((turn rol |=([* sotx] +<+)) sots)
  =|  in=inputw:tx
  =.  value.in  value
  =.  witness.in  [wit [0 0] ~]
  =.  txid.in  itxid
  =.  pos.in  pos
  in
::
++  spawns
  |=  $:  itxid=@ux  hers=(list [val=@ud wat=_walt spk=byts pos=@ud off=@ud xsot=(list single:skim-sotx)])
          aft=(list sotx)
      ==
  |^  ^-  dataw:tx
  =|  tx=dataw:tx
  =.  is.tx  ~[make-input]
  =.  os.tx  make-outputs
  tx
  ::
  ++  make-outputs
    |-  ^-  (list output:tx)
    ?~  hers  ~
    :_  $(hers t.hers)
    [spk.i.hers val.i.hers]
  ::
  ++  make-input
    ::=.  sots  (weld sots sots)
    ::=/  sots  make-sots  ::(slag wut make-sots)
    =/  sots  (weld make-sots aft)
    (make-unv-input itxid 0 (add 1.000 (roll hers |=([[a=@ *] b=@] (add a b)))) sots)
  ::
  ++  make-sots
    =/  os  make-outputs
    =|  sots=(list sotx)
    =|  i=@ud
    |-  ^+  sots
    ?>  ?=(^ os)
    ?~  hers  (flop sots)
    =/  en-out  (can 3 spk.i.hers 8^value.i.os ~)
    =/  hax-out  (shay (add 8 wid.script-pubkey.i.os) en-out)
    =;  sot=sotx  $(sots sot^sots, hers t.hers, i +(i))
    =/  sot=single:skim-sotx  (spawn:skim:wat.i.hers hax-out ?:(=(0 (mod i 2)) ~ `pos.i.hers) off.i.hers 0)
    (sign-skim:wat.i.hers ?:(=(~ xsot.i.hers) sot [%batch sot xsot.i.hers]))
  ::
  --
::
::++  keys
::  ^-  [sots=(list sotx) =_wats]
::  =|  n=@ud
::  =/  taws  ^+(wats ~)
::  =|  sots=(list sotx)
::  |-  ^+  [sots wats]
::  ?~  wats  [(flop sots) (flop taws)]
::  =*  wat  i.wats
::  =^  sot  wat  (keys:wat =(0 (mod n 2)))
::  $(sots sot^sots, taws wat^taws, n +(n), wats t.wats)
::

::
++  old-spawns
  |=  [itxid=@ux os-vals=(list @ud) off=@ud wats=(list _walt)]
  |^  ^-  dataw:tx  ::^-  (list sotx)
  =|  tx=dataw:tx
  =.  is.tx  ~[make-input]
  =.  os.tx  make-outputs
  tx

  ++  make-outputs
    ~+  =|  pos=@ud
    |-  ^-  (list output:tx)
    ?~  os-vals  ~
    :_  $(os-vals t.os-vals, pos +(pos))
    [256^(shax pos) i.os-vals]
  ::
  ++  make-input
    ::=.  sots  (weld sots sots)
    ::=/  sots  make-sots  ::(slag wut make-sots)
    =/  sots  make-sots
    (make-unv-input itxid 0 (add 1.000 (roll os-vals add)) sots)
  ::
  ++  make-sots
    =/  os  make-outputs
    =/  l  (lent wats)
    =/  tot  (roll os |=([[* a=@] b=@] (add a b)))
    =/  feq  (rsh 8 (div (lsh 8 (dec (sub tot off))) l))
    ~|  %spawn-test-insufficient-sats
    ?>  !=(0 tot)
    ?>  !=(0 feq)
    ?>  (lth (mul feq l) tot)
    ::?>  (lth off feq)
    =|  sats=@ud
    =|  sots=(list sotx)
    =|  i=@ud
    =|  pos=@ud
    ~|  %spawn-test-shouldnt-happen
    |-  ^+  sots
    ?>  ?=(^ os)
    ?~  wats  (flop sots)
    =/  xat  (add (mul i feq) off)
    =/  nsats  (add sats value.i.os)
    ?:  (lte nsats xat)
      ?>  ?=(^ t.os)
      $(os t.os, sats nsats, pos +(pos))
    =.  i  +(i)
    =/  en-out  (can 3 script-pubkey.i.os 8^value.i.os ~)
    =/  hax-out  (shay (add 8 wid.script-pubkey.i.os) en-out)
    =/  sot
      (spawn:i.wats hax-out ?:(=(0 (mod i 2)) ~ `pos) (sub xat sats) 0)
    $(sots sot^sots, wats t.wats)
  ::
  --
::
::++  keys
::  ^-  [sots=(list sotx) =_wats]
::  =|  n=@ud
::  =/  taws  ^+(wats ~)
::  =|  sots=(list sotx)
::  |-  ^+  [sots wats]
::  ?~  wats  [(flop sots) (flop taws)]
::  =*  wat  i.wats
::  =^  sot  wat  (keys:wat =(0 (mod n 2)))
::  $(sots sot^sots, taws wat^taws, n +(n), wats t.wats)
::
--
