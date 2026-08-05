/+  *ph-io, az=aqua-azimuth
|%
+$  onchain  (list [peer=@p =life =rift spon=(unit @p) fef=?(~ %turf %is %if)])
::
++  sort-onchain
  |=  cha=onchain
  ^-  onchain
  %+  sort  cha
  |=  $:  a=[peer=@p =life =rift spon=(unit @p) fef=*]
          b=[peer=@p =life =rift spon=(unit @p) fef=*]
      ==
  |(?=(~ spon.a) ?=(^ spon.b))
::
++  spon-udiff
  |=  [for=@p spon=(unit @p)]
  ^-  [=ship =udiff:point:jael]
  [for *id:block:jael %spon spon]
::
++  rift-udiff
  |=  [for=@p =rift]
  ^-  [=ship =udiff:point:jael]
  [for *id:block:jael %rift rift %.y]
::
++  keys-udiff
  |=  [for=@p =life]
  ^-  [=ship =udiff:point:jael]
  =/  =pass  pub:ex:(get-keys:az for life)
  =/  =key-update:point:jael  [life (sub (^end 3 pass) 'a') pass]
  [for *id:block:jael %keys key-update %.y]
::
++  fief-udiff
  |=  [for=@p opt=?(~ %turf %is %if)]
  ^-  [=ship =udiff:point:jael]
  :^  for  *id:block:jael  %fief
  ^-  (unit fief)
  ?-    opt
      ~    ~
      %is  ~
      %turf
    ?~  got=(~(get by turfs) for)
      ~
    `[%turf ~[u.got] *@udE]
  ::
      %if
    =/  index=(unit @ud)  (find ~[for] comets)
    ?~  index
      ~
    `[%if `@`0xdead.beef u.index]
  ==
::
++  turfs
  ^~  ^-  (map @p turf)
  %-  ~(gas by *(map @p turf))
  ^-  (list [@p turf])
  =-  (zip:az comets -)
  ^-  (list turf)
  :~  /marbud/fasteg  /marbud/daldyl  /marbud/dansyr
      /marbud/harrep  /marbud/liblyn  /marbud/hidreb
      /mardev/molpyx  /mardev/fosnys  /mardev/tonmep
      /mardev/holwyx  /mardev/hacmet  /mardev/ribmut
      /podlug/gw-ok   /rinpel/gw-fail
  ==
::
++  comets
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
      :: %gw-btc (kelvin 9) confidential identities.  derived from the
      :: fixture dat, never written out: see +gw-comet-ok:aqua-azimuth.
      gw-comet-ok:az
      gw-comet-fail:az
  ==
::
++  gw-agent
  '''
  /+  default-agent
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %.n) bowl)
  ++  on-init
    ^-  (quip card:agent:gall _this)
    :_  this
    [%pass /listen %arvo %j %listen ~ %| %gw]~
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card:agent:gall _this)
    ?>  ?=(%groundwire-udiffs mark)
    =+  !<(=udiffs:point:jael vase)
    :_  this
    [%give %fact ~[/] %groundwire-udiffs !>(udiffs)]~
  ++  on-watch
    |=  =path
    ~&  [%gw %on-watch path=path]
    ^-  (quip card:agent:gall _this)
    ?>  ?=(~ path)
    `this
  ++  on-save   on-save:def
  ++  on-load   on-load:def
  ++  on-leave  on-leave:def
  ++  on-agent  on-agent:def
  ++  on-peek   on-peek:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
  '''
::
++  udiffs-mark
  '''
  |_  dis=udiffs:point:jael
  ++  grab
    |%
    ++  noun  udiffs:point:jael
    --
  ++  grow
    |%
    ++  noun  dis
    --
  ++  grad  %noun
  --
  '''
::
::  +gw-btc-agent: the fake %gw-btc verifier the scenarios register
::
::    Stands in for the real on-chain verifier.  It cannot see a chain,
::    so it checks everything about a self-attestation that does not
::    need one: the pass must be suite %c, its tweak data must parse as
::    a %gw-btc kelvin-9 dat, its xtr must cue to a $custody-log, the
::    log's spawn entry must open the dat's hiding commitment, and the
::    newest opened snapshot must commit to the messaging key actually
::    in the pass.  The verdict is that computation's result -- the
::    fixtures do not tell it what to say.  The point it hands back is
::    built from the snapshot, so life, rift, sponsor and fief all come
::    from the comet's own attested state.
::
++  gw-btc-agent
  '''
  /+  default-agent, gwp=gw-btc-pass
  =>  |%
      ::  +spawn-opening: entry 0's blind-opening, if it has one
      ::
      ::    exactly one entry -- the spawn -- opens the dat commitment.
      ::
      ++  spawn-opening
        |=  log=custody-log:gwp
        ^-  (unit blind-opening:gwp)
        ?~  log  ~
        ?~  opening.i.log  ~
        blind-opening.u.opening.i.log
      ::  +last-snapshot: the newest opened state in the log
      ::
      ++  last-snapshot
        |=  log=custody-log:gwp
        ^-  (unit snapshot:gwp)
        =|  las=(unit snapshot:gwp)
        |-
        ?~  log  las
        %=  $
          log  t.log
          las  ?~(opening.i.log las `snapshot.u.opening.i.log)
        ==
      ::  +verify: the whole oracle.  ~ means "reject".
      ::
      ++  verify
        |=  [who=@p =pass]
        ^-  (unit point:jael)
        =/  cic  (com:nu:cric:crypto pass)
        ?.  ?=(%c suite.+<.cic)  ~
        =/  met  (parse-dat:gwp dat.tw.pub.+<.cic)
        ?~  met  ~
        ?.  &(=(domain:gwp dom.u.met) =(kelvin:gwp kel.u.met))  ~
        =/  log  (mole |.(;;(custody-log:gwp (cue xtr.tw.pub.+<.cic))))
        ?~  log  ~
        ::  the spawn entry must open the dat's hiding commitment
        ::
        ?~  bo=(spawn-opening u.log)  ~
        ?.  (verify-dat:gwp dat.tw.pub.+<.cic u.bo)  ~
        ::  the newest opened snapshot is the comet's current state, and
        ::  must commit to the messaging key actually in the pass
        ::
        ?~  snp=(last-snapshot u.log)  ~
        =*  snap  u.snp
        ?.  =(key.snap cry.pub.+<.cic)  ~
        :-  ~
        :*  rift=rift.snap
            life=life.snap
            keys=(my [life.snap num:ex:cic pass]~)
            sponsor=`?~(sponsor.snap who u.sponsor.snap)
            fief=fief.snap
        ==
      --
  =|  (list [dom=@tas ship=@p pass=@])
  =*  pending  -
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %.n) bowl)
  ++  on-init
    ^-  (quip card:agent:gall _this)
    :_  this
    [%pass /anex %arvo %j %anex /writs]~
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card:agent:gall _this)
    ?>  (team:title [our src]:bowl)
    ?>  ?=(%noun mark)
    ?.  ?=([%jael-writ @ @ *] q.vase)
      [~ this]
    =/  task  ;;([tag=@tas dom=@tas ship=@p pass=@] q.vase)
    =/  req=[dom=@tas ship=@p pass=@]  [dom.task ship.task pass.task]
    ?:  (lien pending |=(old=[dom=@tas ship=@p pass=@] =(old req)))
      [~ this]
    =/  wen=@da  (add now.bowl ~s1)
    ~&  [%gw-btc-test %queued ship.task]
    :_  this(pending (weld pending ~[req]))
    ?:  ?=(~ pending)
      [%pass /verify %arvo %b %wait wen]~
    ~
  ++  on-watch
    |=  =path
    ^-  (quip card:agent:gall _this)
    ?>  =(/writs path)
    `this
  ++  on-arvo
    |=  [=wire sign=sign-arvo]
    ^-  (quip card:agent:gall _this)
    ?.  =(/verify wire)
      (on-arvo:def wire sign)
    ?>  ?=(%wake +<.sign)
    ?~  pending
      [~ this]
    =/  req  i.pending
    =/  res=(unit point:jael)  (verify ship.req pass.req)
    ~&  [%gw-btc-test %response ship.req ?=(^ res)]
    =/  fact=card:agent:gall
      [%give %fact ~[/writs] %writ-response !>([dom.req ship.req res])]
    :_  this(pending t.pending)
    ?:  ?=(~ t.pending)
      [fact]~
    :~  fact
        [%pass /verify %arvo %b %wait (add now.bowl ~s1)]
    ==
  ++  on-save   on-save:def
  ++  on-load   on-load:def
  ++  on-leave  on-leave:def
  ++  on-agent  on-agent:def
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
  '''
--
