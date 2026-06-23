/+  *ph-io, az=aqua-azimuth
|%
+$  onchain  (list [peer=@p =life spon=(unit @p) fef=?(~ %turf %is %if)])
++  start-gw-comet
  |=  [comet=@p loud=? core=?(%ames %mesa) =onchain]
  |^
  =.  onchain  (sort-onchain onchain)
  =/  m  (strand:rand ,~)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: init"]
  ;<  ~  bind:m  %*($ init-ship ship comet, fake |, core core)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: mount %base"]
  ;<  ~  bind:m  (mount comet %base)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: copy %gw agent"]
  ;<  ~  bind:m  (copy-file comet /app/gw/hoon gw-agent)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: copy udiff mark"]
  ;<  ~  bind:m  (copy-file comet /mar/groundwire-udiffs/hoon udiffs-mark)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: start %gw agent"]
  ;<  ~  bind:m  (dojo comet "|start %gw")
  ;<  ~  bind:m  (wait-for-output comet "booted %gw")
  |-  ^-  form:m
  =*  loop  $
  ?~  onchain
    (pure:m ~)
  ~?  >>  loud  [%gw-aqua "{(cite:title comet)}: inject udiffs for {(cite:title peer.i.onchain)}"]
  ;<  ~  bind:m  (poke-udiffs i.onchain)
  ;<  ~  bind:m  (wait-for-output comet ":gw &groundwire-udiffs")
  loop(onchain t.onchain)
  ::
  ++  sort-onchain
    |=  cha=^onchain
    ^-  ^onchain
    %+  sort  cha
    |=  $:  a=[peer=@p =life spon=(unit @p) fef=*]
            b=[peer=@p =life spon=(unit @p) fef=*]
        ==
    |(?=(~ spon.a) ?=(^ spon.b))
  ::
  ++  poke-udiffs
    |=  $:  for=@p
            =life
            spon=(unit @p)
            fef=?(~ %turf %is %if)
        ==
    =/  m  (strand:rand ,~)
    ^-  form:m
    =/  =pass  pub:ex:(get-keys:az for life)
    =/  =udiffs:point:jael
      :~  (keys-udiff for life)
          (fief-udiff for fef)
          (rift-udiff for)
          (spon-udiff for ?~(spon `for spon))
      ==
    (poke-app comet %gw %groundwire-udiffs udiffs)
  ::
  ++  spon-udiff
    |=  [for=@p spon=(unit @p)]
    ^-  [=ship =udiff:point:jael]
    [for *id:block:jael %spon spon]
  ::
  ++  rift-udiff
    |=  for=@p
    ^-  [=ship =udiff:point:jael]
    [for *id:block:jael %rift 0 %.y]
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
  --
--
