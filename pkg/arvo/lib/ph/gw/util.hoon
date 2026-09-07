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
      /nomdyl/gw-ok   /rilfun/gw-fail
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
      :: prototype %gw-btc asynchronous-path identities
      ~nilnyd-tabmec-ravfer-fabler--dozpub-balsym-lasled-nomdyl
      ~fadbep-panrev-rolluc-rapbes--racmur-lavrel-sapryc-rilfun
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
++  gw-btc-agent
  '''
  /+  default-agent
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
    =/  cic  (com:nu:cric:crypto pass.req)
    ?>  ?=([%c *] +<.cic)
    =/  verdict  (cue xtr.tw.pub:+<.cic)
    =/  ok=?
      ?@  verdict
        ;;(? verdict)
      ;;(? -.verdict)
    =/  verified-life=life
      ?@  verdict
        1
      ;;(life +.verdict)
    =/  keys=(map life [@ud pass])
      (~(put by *(map life [@ud pass])) verified-life [2 pass.req])
    ::  Aqua's prototype gw-ok comet is route-table index 12.
    =/  point=point:jael
      [rift=0 life=verified-life keys sponsor=`ship.req fief=`[%if `@`0xdead.beef 12]]
    =/  res=(unit point:jael)  ?:(ok `point ~)
    ~&  [%gw-btc-test %response ship.req ok]
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
