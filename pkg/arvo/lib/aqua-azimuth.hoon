/-  dice, *aquarium
/+  ethereum, azimuth
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
::  Confidential-comet fixtures for the Aqua simulation.
::
::    Base arvo implements GENERIC pluggable comet PKI: a suite-%c pass
::    carries a +mat-tagged domain plus opaque domain data, jael routes
::    it to whichever agent claimed the domain, ames holds the peer
::    until a verdict.  Nothing in this kernel knows -- or may learn --
::    what a domain's data MEANS.
::
::    So the two arms below are CHECKED-IN DATA, not a computation.
::    .dat and .xtr are byte-for-byte outputs of the one authoritative
::    %gw-btc codec, which lives in the groundwire desk as
::    lib/gw-btc-pass.hoon.  Arvo treats them as the opaque atoms they
::    are: it hands them to +gw-crub and never looks inside.
::
::    TO REGENERATE, on a ship with the groundwire desk installed:
::
::        +groundwire!aqua-fixtures
::
::    (gen/aqua-fixtures.hoon in that desk; it prints every literal in
::    this file, and is the only place the fixture inputs -- seeds 1
::    and 2, spawn satpoints, start height, internal key, comet indices
::    -- are written down).  Paste its output back here.  The desk's
::    codec is pinned in turn by vectors/gw-kelvin-9.json, which
::    Causeway's TypeScript and Python implementations also match.
::
::  +gw-comet-ok, +gw-comet-fail: the %gw-btc (kelvin-9) fixture comets
::
::    Both names are DERIVED from the fixture data by the kernel's own
::    generic cric, never chosen.  A confidential comet's @p is
::    (shaf %cfig) of its tweaked signing key and the tweak hashes
::    .dat, so any change to a fixture renames it.  Everything that
::    lists these comets (+comets below, +comets/+turfs in
::    lib/ph/gw/util.hoon and ted/aqua/ames.hoon) refers to these arms
::    rather than repeating a literal, because those lists are +zip'ped
::    with a strict equal-length check and a stale name crashes long
::    before any attestation logic runs.
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
::  +gw-dat: the immutable tweak data, as an opaque fixture atom
::
::    In the %gw-btc domain this is a +mat-tagged domain and kelvin
::    followed by a hiding commitment to a spawn satpoint -- but that
::    is the domain's business, not arvo's.  Here it is forty-odd bytes
::    that ride the pass and fix the name; only the leading +mat is
::    kernel business, and only ames reads it.
::
++  gw-dat
  |=  which=?(%ok %fail)
  ^-  @
  ?:  ?=(%ok which)
    0x39f5.b92d.7973.d9b4.1950.de86.6970.c18e.faa8.cbc1.1bed.791d.e45f.
    850b.9de6.3a32.4637.4622.d776.77c0
  0x1c.874d.b2f1.5e5c.b31a.29dd.df28.41c0.9d6e.7b1d.44b5.3d7d.96a5.
  f90d.ae69.1614.5cd2.4637.4622.d776.77c0
::  +gw-xtr: the mutable pass tail at .lyfe, as an opaque fixture atom
::
::    Excluded from the key tweak, so it may grow without renaming the
::    comet -- +gw-fig is deliberately taken at life 1 and the life-2
::    fixture below has the same @p.  In the %gw-btc domain it is a
::    jammed custody log; arvo neither knows nor cares.
::
::    The %fail fixture is broken deliberately and minimally: the
::    groundwire generator gives it a spawn its .dat does not commit
::    to, so a real %gw-btc verifier fails that check and only that
::    check.  The Aqua oracle in lib/ph/gw/util.hoon cannot see a
::    chain and does not repeat that check -- see its comment.
::
::    Only lives 1 and 2 exist: the scenarios boot at life 1 and the
::    rekey scenario advances to life 2.  Asking for more must crash
::    loudly rather than silently produce a pass no fixture describes.
::
++  gw-xtr
  |=  [which=?(%ok %fail) lyfe=life]
  ^-  @
  ?:  ?=(%ok which)
    ?+  lyfe  ~|([%no-gw-fixture-for-life which lyfe] !!)
        %1
      0x17.b5d5.692f.aa4f.562b.d3ca.424e.0493.0fbe.ee6c.3948.9920.ed4c.
      ca3e.c66c.bcc0.b460.0400.ba8d.a622.3605.9c21.bd5b.7dde.0807.334f.
      8199.d0fc.b01e.f398.66b5.6bd3.246b.7e9c.2655.5583.8439.3621.9895.
      6882.7bbf.0b5e.40f9.8019.c59e.6f99.9fbe.772e.eb15.6818.a573.a1c2.
      c1c0.a6ff.36cb.738a.3656.7ca0.56c5.be05.e600.a003.37be.2090.1888.
      8000.ec05
    ::
        %2
      0x1.5402.8720.3a94.943e.bb94.44be.8d19.5cdc.ecc3.0cb4.17c9.7010.
      95a7.f00c.ffbd.42f7.8027.de01.0019.90b4.f8d9.bdf1.1480.c444.000b.
      602f.b5d5.692f.aa4f.562b.d3ca.424e.0493.0fbe.ee6c.3948.9920.ed4c.
      ca3e.c66c.bcc0.b460.0400.ba8d.a622.3605.9c21.bd5b.7dde.0807.334f.
      8199.d0fc.b01e.f398.66b5.6bd3.246b.7e9c.2655.5583.8439.3621.9895.
      6882.7bbf.0b5e.40f9.8019.c59e.6f99.9fbe.772e.eb15.6818.a573.a1c2.
      c1c0.a6ff.36cb.738a.3656.7ca0.56c5.be05.e600.a003.37be.2090.1888.
      8000.ec05
    ==
  ?+  lyfe  ~|([%no-gw-fixture-for-life which lyfe] !!)
      %1
    0x534.96d1.1887.e452.a602.91f8.27be.5875.9949.986d.2dbc.e5f0.d20d.
    e40e.e254.6ba8.37fc.0175.1b63.999e.8167.486f.56df.7782.01cc.d3e0.
    6662.a9a7.7c37.b9fd.2013.7356.a892.442a.b599.c5d2.4133.8b36.61da.
    f5a4.c727.ec9c.c4ff.8019.c59e.6f99.9fbe.772e.eb15.6818.a573.a1c2.
    c1c0.a6ff.36cb.738a.3656.7ca0.56c5.be05.e600.a003.37be.2090.1888.
    8000.ec05
  ::
      %2
    0x2.a865.0ea3.cef6.b16b.3b9d.2332.228a.0a24.2751.3361.3c1d.17e9.
    59f7.03ea.2e5b.b960.26f9.df60.0664.2d3e.366f.7c45.2031.1100.02d8.
    0b34.96d1.1887.e452.a602.91f8.27be.5875.9949.986d.2dbc.e5f0.d20d.
    e40e.e254.6ba8.37fc.0175.1b63.999e.8167.486f.56df.7782.01cc.d3e0.
    6662.a9a7.7c37.b9fd.2013.7356.a892.442a.b599.c5d2.4133.8b36.61da.
    f5a4.c727.ec9c.c4ff.8019.c59e.6f99.9fbe.772e.eb15.6818.a573.a1c2.
    c1c0.a6ff.36cb.738a.3656.7ca0.56c5.be05.e600.a003.37be.2090.1888.
    8000.ec05
  ==
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
::  +gw-keys: a fixture comet's full suite-%c core at .lyfe
::
++  gw-keys
  |=  [which=?(%ok %fail) lyfe=life]
  %^  gw-crub  (gw-sed which lyfe)
    (gw-dat which)
  (gw-xtr which lyfe)
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
