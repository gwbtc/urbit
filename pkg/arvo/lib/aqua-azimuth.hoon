/-  dice, *aquarium
/+  ethereum, azimuth, gwp=gw-btc-pass
::
|%
::
++  extract-request
  |=  [uf=unix-effect dest=@t]
  ^-  (unit [num=@ud =request:http])
  ?.  ?=(%request -.q.uf)  ~
  ?.  =(dest url.request.q.uf)  ~
  `[id.q.uf request.q.uf]
::
++  router
  |=  [our=ship her=ship uf=unix-effect azi=az-state]
  ^-  (unit card:agent:gall)
  =,  enjs:format
  =/  ask-load
    %+  extract-request  uf
    'https://bootstrap.urbit.org/mainnet.azimuth-snapshot'
  ?^  ask-load
    =/  events=(list aqua-event)
      :_  ~
      :*  %event
          her
          /i/http-client/0v1n.2m9vh
          %receive
          num.u.ask-load
          [%start [200 ~] `(as-octs:mimes:html (jam *versioned-snap:dice)) &]
      ==
    %-  some
    :*  %pass  /aqua-events
        %agent  [our %aqua]
        %poke  %aqua-events
        !>(events)
    ==
  =/  ask  (extract-request uf 'http://fake.aqua.domain/')
  ?~  ask
    ~
  ?~  body.request.u.ask
    ~
  =/  req  q.u.body.request.u.ask
  |^  ^-  (unit card:agent:gall)
  =/  method  (get-method req)
  ?:  =(method 'eth_blockNumber')
    :-  ~
    %+  answer-request  req
    s+(crip (num-to-hex:ethereum latest-block))
  ?:  =(method 'eth_getBlockByNumber')
    :-  ~
    %+  answer-request  req
    :-  %o
    =/  number  (hex-to-num:ethereum (get-first-param req))
    =/  hash  (number-to-hash number)
    =/  parent-hash  (number-to-hash ?~(number number (dec number)))
    %-  malt
    ^-  (list (pair term json))
    :~  hash+s+(crip (prefix-hex:ethereum (render-hex-bytes:ethereum 32 hash)))
        number+s+(crip (num-to-hex:ethereum number))
        'parentHash'^s+(crip (num-to-hex:ethereum parent-hash))
    ==
  ?:  =(method 'eth_getLogs')
    :-  ~
    %+  answer-request  req
    ?^  (get-param-obj-maybe req 'blockHash')
      %-  logs-by-hash
      (get-param-obj req 'blockHash')
    %+  logs-by-range
      (get-param-obj req 'fromBlock')
    (get-param-obj req 'toBlock')
  ~&  [%ph-azimuth-miss req]
  ~
  ::
  ++  latest-block
    (add launch:contracts:azimuth (dec (lent logs.azi)))
  ::
  ++  get-single-req
    |=  req=@t
    =/  batch
      ((ar:dejs:format same) (need (de:json:html req)))
    ?>  ?=([* ~] batch)
    i.batch
  ::
  ++  get-id
    |=  req=@t
    =,  dejs:format
    %.  (get-single-req req)
    (ot id+so ~)
  ::
  ++  get-method
    |=  req=@t
    =,  dejs:format
    ~|  req=req
    %.  (get-single-req req)
    (ot method+so ~)
  ::
  ++  get-param-obj
    |=  [req=@t param=@t]
    =,  dejs:format
    %-  hex-to-num:ethereum
    =/  array
      %.  (get-single-req req)
      (ot params+(ar (ot param^so ~)) ~)
    ?>  ?=([* ~] array)
    i.array
  ::
  ++  get-param-obj-maybe
    |=  [req=@t param=@t]
    ^-  (unit @ud)
    =,  dejs-soft:format
    =/  array
      %.  (get-single-req req)
      (ot params+(ar (ot param^so ~)) ~)
    ?~  array
      ~
    :-  ~
    ?>  ?=([* ~] u.array)
    %-  hex-to-num:ethereum
    i.u.array
  ::
  ++  get-first-param
    |=  req=@t
    =,  dejs:format
    =/  id
      %.  (get-single-req req)
      (ot params+(at so bo ~) ~)
    -.id
  ::
  ++  answer-request
    |=  [req=@t result=json]
    ^-  card:agent:gall
    =/  resp
      %-  en:json:html
      :-  %a  :_  ~
      %-  pairs
      :~  id+s+(get-id req)
          jsonrpc+s+'2.0'
          result+result
      ==
    =/  events=(list aqua-event)
      :_  ~
      :*  %event
          her
          /i/http-client/0v1n.2m9vh
          %receive
          num.u.ask
          [%start [200 ~] `(as-octs:mimes:html resp) &]
      ==
    :*  %pass  /aqua-events
        %agent  [our %aqua]
        %poke  %aqua-events
        !>(events)
    ==
  ::
  ++  number-to-hash
    |=  =number:block:jael
    ^-  @
    ?:  (lth number launch:contracts:azimuth)
      (cat 3 0x5364 (sub launch:contracts:azimuth number))
    (cat 3 0x5363 (sub number launch:contracts:azimuth))
  ::
  ++  hash-to-number
    |=  =hash:block:jael
    (add launch:contracts:azimuth (div hash 0x1.0000))
  ::
  ++  logs-by-range
    |=  [from-block=@ud to-block=@ud]
    %+  logs-to-json  (max launch:contracts:azimuth from-block)
    ?:  (lth to-block launch:contracts:azimuth)
      ~
    %+  swag
      ?:  (lth from-block launch:contracts:azimuth)
         [0 +((sub to-block launch:contracts:azimuth))]
      :-  (sub from-block launch:contracts:azimuth)
      +((sub to-block from-block))
    logs.azi
  ::
  ++  logs-by-hash
    |=  =hash:block:jael
    =/  =number:block:jael  (hash-to-number hash)
    (logs-by-range number number)
  ::
  ++  logs-to-json
    |=  [count=@ud selected-logs=(list az-log)]
    ^-  json
    :-  %a
    |-  ^-  (list json)
    ?~  selected-logs
      ~
    :_  $(selected-logs t.selected-logs, count +(count))
    %-  pairs
    :~  'logIndex'^s+'0x0'
        'transactionIndex'^s+'0x0'
        :+  'transactionHash'  %s
        (crip (prefix-hex:ethereum (render-hex-bytes:ethereum 32 `@`0x5362)))
      ::
        :+  'blockHash'  %s
        =/  hash  (number-to-hash count)
        (crip (prefix-hex:ethereum (render-hex-bytes:ethereum 32 hash)))
      ::
        :+  'blockNumber'  %s
        (crip (num-to-hex:ethereum count))
      ::
        :+  'address'  %s
        (crip (address-to-hex:ethereum azimuth:contracts:azimuth))
      ::
        'type'^s+'mined'
      ::
        'data'^s+data.i.selected-logs
        :+  'topics'  %a
        %+  turn  topics.i.selected-logs
        |=  topic=@ux
        ^-  json
        :-  %s
        %-  crip
        %-  prefix-hex:ethereum
        (render-hex-bytes:ethereum 32 `@`topic)
    ==
  --
::
::  +gw-comet-ok, +gw-comet-fail: the %gw-btc (kelvin-9) fixture comets
::
::    Both names are DERIVED, never chosen.  A confidential comet's @p
::    is (shaf %cfig) of its tweaked signing key, and the tweak hashes
::    .dat, so any change to a fixture's spawn satpoint, blind, or seed
::    renames it.  Everything that lists these comets (+comets below,
::    +comets/+turfs in lib/ph/gw/util.hoon and ted/aqua/ames.hoon)
::    refers to these arms rather than repeating a literal, because
::    those lists are +zip'ped with a strict equal-length check and a
::    stale name crashes long before any attestation logic runs.
::
::    Current values, for grepping:
::      ok    ~sogmyr-ritwyx-ladfet-hidrup--polhep-hattyn-narful-podlug
::      fail  ~wicdev-fablyr-radryp-hadtyp--nacfed-siptus-rilsep-rinpel
::
++  gw-comet-ok    ^~(`@p`(gw-fig %ok))
++  gw-comet-fail  ^~(`@p`(gw-fig %fail))
::  +gw-fig: a fixture comet's derived name
::
++  gw-fig
  |=  which=?(%ok %fail)
  ^-  @p
  `@p`fig:ex:(gw-keys which 1)
::  +gw-seed: a fixture comet's master seed (its entry in +comets)
::
++  gw-seed
  |=  which=?(%ok %fail)
  ^-  @
  ?:(?=(%ok which) 1 2)
::  +gw-spawn: the spawn satpoint a fixture comet's dat commits to
::
++  gw-spawn
  |=  which=?(%ok %fail)
  ^-  sont:gwp
  ?:(?=(%ok which) [0x1111 0 0] [0x2222 1 0])
::  +gw-dat: the immutable kelvin-9 tweak data
::
::    A hiding commitment to the spawn satpoint under a seed-derived
::    blind; the satpoint itself is never in the clear.
::
++  gw-dat
  |=  which=?(%ok %fail)
  ^-  @
  (make-dat:gwp (gw-spawn which) (make-blind:gwp (gw-seed which)))
::  +gw-sed: the 64-byte cric seed of a fixture comet at .lyfe
::
::    Suite C splits the seed into a signing half (bytes 0-31, which
::    fixes the @p through the tweak) and a messaging half (bytes
::    32-63).  Rekeying a confidential comet rotates ONLY the messaging
::    half: life rides in the on-chain snapshot, never in the seed.
::    Deriving both halves from a life-dependent seed -- as this fixture
::    used to -- gives every life a different signing key and therefore
::    a different @p, so the life-2 self-attestation fingerprints to a
::    ship that is not the sender and the receiver correctly refuses it.
::
++  gw-sed
  |=  [which=?(%ok %fail) lyfe=life]
  ^-  @
  =/  base  (shal 64 (gw-seed which))
  =/  sgn   (end 8 base)
  =/  cry   (shax (can 3 ~[[32 (cut 8 [1 1] base)] [8 lyfe]]))
  (can 3 ~[[32 sgn] [32 cry]])
::  +gw-crub: activate a suite-%c core from an explicit 64-byte seed
::
::    +pit:nu:cric derives the whole seed by hashing one number, which
::    cannot express "same signing key, new messaging key".  This builds
::    the same $ring +pit would, with the seed supplied outright.
::
++  gw-crub
  |=  [sed=@ dat=@ xtr=@]
  %-  nol:nu:cric:crypto
  ^-  ring
  =<  p
  %-  fax:plot
  :-  0
  :*  [s+~ 3 [1 'C'] ~]
      [s+~ 3 [64 sed] ~]
      (mat dat)
      ?:  =(0 xtr)  ~
      [(met 0 xtr)^xtr ~]
  ==
::  +gw-cry: a fixture comet's messaging public key at .lyfe
::
::    Independent of dat and xtr, so it can be computed before the
::    custody log that commits to it.
::
++  gw-cry
  |=  [which=?(%ok %fail) lyfe=life]
  ^-  @
  cry:ded:ex:(gw-crub (gw-sed which lyfe) 0 0)
::  +gw-internal-key: 33-byte compressed P2TR internal key (secp G)
::
::    The Aqua fixtures have no chain to check taproot output keys
::    against, so this is decorative; it matches the golden vectors.
::
++  gw-internal-key
  ^-  @ux
  0x2.79be.667e.f9dc.bbac.55a0.6295.ce87.0b07.029b.fcdb.2dce.28d9.59f2.815b.16f8.1798
::
++  gw-start-height  778.000
::  +gw-log: a fixture comet's custody log, oldest entry first
::
::    One entry per life.  Entry 0 is the spawn: it alone carries the
::    $blind-opening that opens the pass's hiding dat commitment.  Later
::    entries are rekeys, each opening the snapshot committed at that
::    custody hop; the newest snapshot is the comet's current state.
::
::    The %fail fixture is broken deliberately and minimally: its
::    blind-opening names a satpoint its dat does NOT commit to, so the
::    verifier's commitment check -- and only that check -- must fail.
::    Give it (gw-spawn %fail) instead and it verifies like %ok.
::
++  gw-log
  |=  [which=?(%ok %fail) lyfe=life]
  ^-  custody-log:gwp
  =/  open=blind-opening:gwp
    :+  ?:(?=(%ok which) (gw-spawn which) [0x3333 1 0])
      gw-start-height
    (make-blind:gwp (gw-seed which))
  ::  index in +comets, which ted/aqua/ames.hoon uses as a fake lane
  ::
  =/  idx  ?:(?=(%ok which) 12 13)
  %+  turn  (gulf 1 lyfe)
  |=  l=life
  ^-  custody-entry:gwp
  :+  `@ux`(add 0x1111.0000 l)
    (add gw-start-height (dec l))
  :-  ~
  :+  gw-internal-key
    :*  life=l
        rift=0
        key=(gw-cry which l)
        sponsor=~
        fief=`[%if `@`0xdead.beef `@`idx]
    ==
  ?:(=(1 l) `open ~)
::  +gw-keys: a fixture comet's full suite-%c core at .lyfe
::
++  gw-keys
  |=  [which=?(%ok %fail) lyfe=life]
  %^  gw-crub  (gw-sed which lyfe)
    (gw-dat which)
  (jam (gw-log which lyfe))
::
++  get-keys
  |=  [who=@p lyfe=life]
  ?~  cum=(~(get by comets) who)
    %^  pit:nu:cric:crypto  32
      (can 5 [1 (scot %p who)] [1 (scot %ud lyfe)] ~)
    [%b ~]
  ?:  =(who gw-comet-ok)    (gw-keys %ok lyfe)
  ?:  =(who gw-comet-fail)  (gw-keys %fail lyfe)
  ?.  =(lyfe 1)
    %^  pit:nu:cric:crypto  32
      (can 5 [1 (scot %p who)] [1 (scot %ud lyfe)] ~)
    [%c 0xdead.beef.cafe]
  ?:  ?=(%b suite.u.cum)
    (pit:nu:cric:crypto 512 seed.u.cum %b ~)
  (pit:nu:cric:crypto 512 seed.u.cum %c 0xdead.beef.cafe)
::
++  get-public
  |=  [who=@p lyfe=life]
  ^-  public-keys:ames
  ded:ex:(get-keys who lyfe)
::  +comets: allowed comets, their +cric suite and seeds
::    the tweak for %c comets is 0xdead.beef.cafe
::
++  comets
  ^~  ^-  (map ship [suite=?(%b %c) seed=@uw])
  %-  ~(gas by *(map ship [suite=?(%b %c) seed=@uw]))
  ^-  (list [=ship suite=?(%b %c) seed=@uw])
  %+  zip
    ::  comet names
    ^-  (list @p)
    :~  :: marbud, %c suite
        ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
        ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
        ~dansyr-ponbec-tocfel-laddux--socnut-nisnyx-dinsut-marbud
        :: marbud, %b suite
        ~harrep-podpec-torsut-docnyx--mopsyx-fosdus-ladpen-marbud
        ~liblyn-togrut-tabwel-hodbet--dovbex-parryt-mirbyt-marbud
        ~hidreb-naptev-banben-bicrup--massup-dantus-fodwet-marbud
        :: mardev, %c suite
        ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
        ~fosnys-noctyd-talfyl-borryl--davhus-disbyn-fotnec-mardev
        ~tonmep-tabrux-rinbep-firmur--silmex-saldef-pasfer-mardev
        :: mardev, %b suite
        ~holwyx-ramped-tognet-barsyn--navler-ronmeg-topbex-mardev
        ~hacmet-doslyr-narhut-tiptec--micbyl-motnev-worsyn-mardev
        ~ribmut-nopdul-minmet-pardeg--wisfex-rosfus-fogsyn-mardev
        :: %gw-btc (kelvin 9) confidential identities, derived above
        gw-comet-ok
        gw-comet-fail
    ==
  %+  zip
    ::  comet suites
    ^-  (list ?(%b %c))
    ~[%c %c %c %b %b %b %c %c %c %b %b %b %c %c]
  ::  comet seeds
  ^-  (list @uw)
  :~  0w2.5sfF0.~inVv.dQ7zb.ykQSG.aX5nF.uGQsm.keVzY.6Pu1S.
      quvGI.b0Ht2.Ctbbr.-ADfG.7yIL4.NXJ5a.lGmJZ.5wkdb.9Z775
      0w5Disb.xWJtw.cszH3.YBTFu.9k6Nc.JjeyV.origh.VkYmT.
      9-Obr.T3TOs.IPdWd.MmsUQ.ZZGZa.OLHMe.5azFd.l7hXr.~vuI~
      0w1.7wOws.lF20Y.WRmex.htiLX.WrZ43.yxBCD.Ow3oE.kumTc.
      dRou7.xGeQm.Lbbx-.6hTii.hzYgP.Z2iQ9.7YYLB.2qb1b.PDItX
      0w3.7aZCR.XIcSt.sKqRG.AS4KD.A-FAT.bbZwc.2N4z5.pez5t.
      aZGIz.d0Hy9.C~RPd.87GcR.LM0Jt.6oVFF.LL4v7.rzlwk.~Fm5Z
      0w1.fuip3.x~XMr.eE02V.K4RC5.OvDaK.jug28.75z30.UY476.
      ZlB3Q.bD78k.M8E~g.I4LRY.OytPc.XD2Bm.XDM9t.iQEhl.LNCMM
      0w1.BHOHC.VyVuo.4kS0o.VKJNU.-zMyL.T2zJo.j1EF5.symnK.
      yQB8T.TvCPN.Z8~P~.KS6j4.~055y.E-jBn.UhIxJ.mItiE.PmML1
      0w3.mAqpe.eRL-v.65LTo.aHWFA.5kTRF.qQ1o-.xK2W-.tae8A.
      FLBV~.wL3iP.A~53S.izniF.SiLrJ.DDxNO.A9Yps.QLFta.LmorX
      0w3.L29ce.OZsch.LKI2F.f86PX.JuhkV.8gnMT.FSqcd.~MqL3.
      v4wEj.yFnGN.DHr-Z.TiCRY.tG-7r.E1oza.pW2FM.i097b.yA~Ql
      0w2.iUm0y.wCmrI.GrVKW.r5yu9.Stccm.3diy3.vS4r7.tV~jd.
      -mxoM.S1nFG.soxnp.dDr6X.DUI99.4uhQO.ntSQJ.UYiQi.pMRi2
      0w2.i8vIr.hWTd1.aC9jk.F6Y3e.r5OEr.nzm8U.KHzQN.RsEzF.
      trAnj.MqRRu.397ik.L8o9k.RSIip.0vZ4Q.qhnSI.eXfhu.brJPS
      0ws1~UQ.v~fJv.C5MPg.LFX3N.ZmJmu.0LeVG.lyyT7.shhvL.
      2~det.i-jOI.OVI8v.9ldMk.16MGj.AZxso.qsTpQ.inrUz.aE1sa
      0w~w9s8.YLtr3.bSQ8H.SIK5g.Dnh9M.aIcT2.mqIqG.geVWH.
      lJUzq.OTuUl.oM9ww.7MwQh.pQ7Q9.NB38f.FzzKE.S7is8.~0Gg-
      `@uw`1
      `@uw`2
  ==
::  +zip: combine two lists into a list of cells of their elements
::
++  zip
    |*  [a=(list) b=(list)]
    ^-  (list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
    =|  out=(list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
    ?>  =((lent a) (lent b))
    |-
    ?~  a  (flop out)
    ?~  b  (flop out)
    $(out [[i.a i.b] out], a t.a, b t.b)
::
::  Generate logs
::
++  lo
  =,  azimuth-events:azimuth
  |%
  ++  broke-continuity
    |=  [who=ship rut=rift]
    ^-  az-log
    :-  ~[^broke-continuity who]
    %-  crip
    %-  prefix-hex:ethereum
    (render-hex-bytes:ethereum 32 `@`rut)
  ::
  ++  changed-keys
    |=  [who=ship enc=@ux aut=@ux crypto=@ud lyfe=life]
    ^-  az-log
    :-  ~[^changed-keys who]
    %-  crip
    %-  prefix-hex:ethereum
    ;:  welp
        (render-hex-bytes:ethereum 32 `@`enc)
        (render-hex-bytes:ethereum 32 `@`aut)
        (render-hex-bytes:ethereum 32 `@`crypto)
        (render-hex-bytes:ethereum 32 `@`lyfe)
    ==
  --
--
