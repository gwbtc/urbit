/+  *ph-io, az=aqua-azimuth
=<
|=  vase
=/  m  (strand:rand ,vase)
=/  comet-1  ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
=/  comet-2  ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
::
;<  ~  bind:m  start-simple
::
;<  ~  bind:m  (init-ship comet-1 |)
;<  ~  bind:m  (init-ship comet-2 |)
::
~&  [%gw-comet-hi "mounting base desks"]
;<  ~  bind:m  (mount comet-1 %base)
;<  ~  bind:m  (mount comet-2 %base)
::
~&  [%gw-comet-hi "copy agent to comet 1"]
;<  ~  bind:m  (copy-file comet-1 /app/gw/hoon gw-agent)
~&  [%gw-comet-hi "copy mark to comet 1"]
;<  ~  bind:m  (copy-file comet-1 /mar/groundwire-udiffs/hoon udiffs-mark)
~&  [%gw-comet-hi "copy agent to comet 2"]
;<  ~  bind:m  (copy-file comet-2 /app/gw/hoon gw-agent)
~&  [%gw-comet-hi "copy mark to comet 2"]
;<  ~  bind:m  (copy-file comet-2 /mar/groundwire-udiffs/hoon udiffs-mark)
::
~&  [%gw-comet-hi "start agent comet 1"]
;<  ~  bind:m  (dojo comet-1 "|start %gw")
~&  [%gw-comet-hi "start agent comet 2"]
;<  ~  bind:m  (dojo comet-2 "|start %gw")
::
;<  ~  bind:m  (dojo comet-1 "|ames/verb %snd %rcv %odd %msg %ges %for %rot")
;<  ~  bind:m  (dojo comet-2 "|ames/verb %snd %rcv %odd %msg %ges %for %rot")
::
;<  ~  bind:m  (sleep ~s15)
::
~&  [%gw-comet-hi "poke udiffs comet 1"]
;<  ~  bind:m  (poke-init-udiffs comet-1 comet-2 1 %if)
~&  [%gw-comet-hi "poke udiffs comet 2"]
;<  ~  bind:m  (poke-init-udiffs comet-2 comet-1 1 %if)
::
;<  ~  bind:m  (sleep ~s15)
::
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
::
=/  aqua-pax-1=path
  /i/(scot %p comet-1)/ax/(scot %p comet-1)/(scot %da now)/peers/noun
=/  p1=(map ship ?(%alien %known))  ;;((map ship ?(%alien %known)) (scry-aqua:util noun our now aqua-pax-1))
~&  >>>  [%lanes-1 p1]
=/  aqua-pax-2=path
  /i/(scot %p comet-2)/ax/(scot %p comet-2)/(scot %da now)/peers/noun
=/  p2=(map ship ?(%alien %known))  ;;((map ship ?(%alien %known)) (scry-aqua:util noun our now aqua-pax-2))
~&  >>>  [%lanes-2 p2]
~&  [%gw-comet-hi "send hi comet 1"]
;<  ~  bind:m  (send-hi comet-1 comet-2)
~&  [%gw-comet-hi "send hi comet 2"]
;<  ~  bind:m  (send-hi comet-2 comet-1)
::
;<  ~  bind:m  end
(pure:m *vase)
::
|%
++  poke-init-udiffs
  |=  [who=@p for=@p =life fef=?(~ %turf %is %if)]
  =/  m  (strand:rand ,~)
  ^-  form:m
  =/  =pass  pub:ex:(get-keys:az for life)
  =/  =udiffs:point:jael
    :~  (keys-udiff for life)
        (fief-udiff for fef)
        (rift-udiff for)
        (spon-udiff for `for)
    ==
  (poke-app who %gw %groundwire-udiffs udiffs)
::
++  spon-udiff
  |=  [for=@p spon=(unit @p)]
  ^-  [=ship =udiff:point:jael]
  [for *id:block:jael %spon spon]
::
++  rift-udiff
  |=  [for=@p]
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
