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
      /test-pki/ok    /test-pki/fail
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
      :: confidential (suite-%c) identities.  derived from the fixture
      :: dat, never written out: see +cc-comet-ok:aqua-azimuth.
      cc-comet-ok:az
      cc-comet-fail:az
  ==
::  +udiff-agent: the fake udiff source the scenarios install
::
::    Stands in for %azimuth: it registers with jael as an udiff source
::    and republishes whatever the scenario pokes into it.  Nothing
::    confidential travels this way -- see +pki-agent below.
::
++  udiff-agent
  '''
  /+  default-agent
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %.n) bowl)
  ++  on-init
    ^-  (quip card:agent:gall _this)
    :_  this
    [%pass /listen %arvo %j %listen ~ %| %test-udiff]~
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card:agent:gall _this)
    ?>  ?=(%test-udiffs mark)
    =+  !<(=udiffs:point:jael vase)
    :_  this
    [%give %fact ~[/] %test-udiffs !>(udiffs)]~
  ++  on-watch
    |=  =path
    ~&  [%test-udiff %on-watch path=path]
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
::  +pki-agent: the fake domain verifier the scenarios register
::
::    Stands in for a real on-chain verifier.  It is a LOOKUP TABLE,
::    not an implementation -- base arvo must not contain one.  A real
::    verifier, the code that parses a domain's dat, opens whatever
::    commitment it carries and checks an ownership history against the
::    chain that domain lives on, belongs in that domain's own desk and
::    is tested there.
::
::    What these scenarios exercise is the KERNEL's half of pluggable
::    comet PKI, and that half is identical whatever the oracle
::    computes: ames must hold an unknown suite-%c comet, jael must
::    route its pass to the agent that claimed the domain, the verdict
::    must come back over /writs, and ames must promote or snub
::    accordingly.  So the oracle answers from a fixture table.  It
::    accepts a pass byte-identical to the fixture pass for that ship
::    at that life, and rejects everything else -- including
::    +cc-comet-fail:aqua-azimuth, the deliberately-broken fixture,
::    which no row names.  What a real verifier would reject that one
::    FOR is its own domain's business, not arvo's.
::
::    The agent's name is +cc-domain:aqua-azimuth, because jael routes
::    a %writ to the agent named by the leading +mat of the pass, and
::    the fixture dats commit to that domain.
::
::    The table is derived from +cc-keys:aqua-azimuth and rendered into
::    the agent's source below, so it cannot go stale against the
::    fixtures.
::
++  pki-agent
  ^-  @t
  %-  crip
  %-  zing
  :~  (trip pki-agent-head)
      "\0a"
      ::  index 12 is +cc-comet-ok's slot in +comets, which
      ::  ted/aqua/ames decodes as its fake %if lane
      ::
      (oracle-row cc-comet-ok:az %ok 1 12)
      (oracle-row cc-comet-ok:az %ok 2 12)
      "  ==\0a"
      (trip pki-agent-body)
  ==
::  +oracle-row: one fixture verdict, as a line of agent source
::
++  oracle-row
  |=  [who=@p which=?(%ok %fail) lyfe=life fef=@ud]
  ^-  tape
  =/  =pass  pub:ex:(cc-keys:az which lyfe)
  ;:  weld
    "      ["  (scow %p who)
    " "        (scow %ud lyfe)
    " "        (scow %ux `@ux`pass)
    " "        (scow %ud fef)
    "]\0a"
  ==
::
++  pki-agent-head
  '''
  /+  default-agent
  ::  $oracle: the Aqua fixture verdict table, [ship life pass fief-index]
  ::
  ::    Generated by +pki-agent:ph-cc-util.  A pass not named here is
  ::    rejected; this stands in for a chain the simulation does not have.
  ::
  =/  oracle=(list [who=@p lyfe=@ud pas=@ux fef=@ud])
    :~
  '''
::
++  pki-agent-body
  '''
  =>  |%
      ::  +verify: the whole oracle.  ~ means "reject".
      ::
      ++  verify
        |=  [oracle=(list [who=@p lyfe=@ud pas=@ux fef=@ud]) who=@p =pass]
        ^-  (unit point:jael)
        ::  the pass must still be a well-formed suite-%c pass: that
        ::  much is generic kernel format, not domain knowledge
        ::
        =/  cic  (com:nu:cric:crypto pass)
        ?.  ?=(%c suite.+<.cic)  ~
        =/  hit
          %+  skim  oracle
          |=  [w=@p * p=@ux *]
          &(=(w who) =(p `@ux`pass))
        ?~  hit  ~
        =*  row  i.hit
        :-  ~
        :*  rift=0
            life=lyfe.row
            keys=(my [lyfe.row num:ex:cic pass]~)
            sponsor=`who
            fief=`[%if `@`0xdead.beef `@`fef.row]
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
    ~&  [%test-pki %queued ship.task]
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
    =/  res=(unit point:jael)  (verify oracle ship.req pass.req)
    ~&  [%test-pki %response ship.req ?=(^ res)]
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
