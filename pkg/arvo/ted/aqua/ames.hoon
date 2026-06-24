::  This needs a better SDN solution.  Every ship should have an IP
::  address, and we should eventually test changing those IP
::  addresses.
::
::  For now, we broadcast every packet to every ship and rely on them
::  to drop them.
::
/-  aquarium, spider
/+  aqua-vane-thread
/=  ames-raw  /sys/vane/ames
=,  aquarium
|%
::  $fiefs: fiefs emitted by ships
::
+$  fiefs  (map ship fiefs-result:jael)
::
::  $pit-map: mesa pending interest table
::
+$  pit-map  (jug mesa-key lane:pact:ames)
+$  mesa-key        [at=ship =name:pact:ames]
+$  mesa-pit-entry  (set lane:pact:ames)
::  $mesa-pending: outbound request tracker
::
+$  mesa-pending  (set mesa-key)
::  $saxos: sponsor ship chain from %saxo effects
::
+$  saxos  (jar ship ship)
::
::  $nails: lanes from %nail effects
::
+$  nails  (map nail-key nail-entry)
+$  nail-key    [at=ship target=ship]
+$  nail-entry  [ames=(list lane:ames) mesa=(list lane:pact:ames)]
::  $knowns: whether shot receiver knows shot sender for event n
::
+$  knowns  (map @ud ?)
::  $pending-sends:  %send's awaiting knownness check
::
+$  pending-sends  (map @ud [sndr=@p way=wire %send lan=lane:ames pac=@])
::  $get-known-queue: queue of knownness check threads
::
+$  get-known-queue  (jar @p [event-id=@ud shot-sndr=@p shot-rcvr=@p])
::  $next-id:  next event id to use
::
+$  next-id  @ud
::
+$  state
  $:  fez=fiefs
      pit=pit-map
      mep=mesa-pending
      sax=saxos
      nas=nails
      kno=knowns
      pen=pending-sends
      keu=get-known-queue
      nid=next-id
  ==
--
::
=|  state
=*  state  -
::
|%
++  emit-aqua-events
  |=  [our=ship aes=(list aqua-event)]
  ^-  (list card:agent:gall)
  [%pass /aqua-events %agent [our %aqua] %poke %aqua-events !>(aes)]~
::
++  handle-saxo
  |=  [our=ship who=ship way=wire %saxo spons=(list ship)]
  ^-  (quip card:agent:gall _state)
  ?~  spons
    `state(sax (~(del by sax) who))
  `state(sax (~(put by sax) who spons))
::
++  handle-nail
  |=  [our=ship who=ship way=wire %nail target=ship lanes=(list lane:ames)]
  ^-  (quip card:agent:gall _state)
  ?~  lanes
    `state(nas (~(del by nas) [who target]))
  =.  nas
    %+  ~(put by nas)  [who target]
    [lanes (turn lanes ames-to-mesa-lane)]
  `state
::
++  handle-fief
  |=  [our=ship who=ship way=wire %fief =fiefs-result:jael]
  ^-  (quip card:agent:gall _state)
  :-  ~
  %=    state
      fez
    %+  ~(put by fez)  who
    (~(uni by (~(gut by fez) who ~)) fiefs-result)
  ==
::
++  handle-restore
  |=  [our=ship who=@p]
  ^-  (quip card:agent:gall _state)
  :_  state
  %+  emit-aqua-events  our
  [%event who [/a/newt/0v1n.2m9vh %born ~]]~
::  +handle-avow: handle knownness thread result
::
++  handle-avow
  |=  [our=@p who=@p way=wire %avow =(avow:khan page)]
  ^-  (quip card:agent:gall _state)
  ?.  ?=([@ @ @ @ ~] way)
    `state
  =/  event-id=@ud  (slav %ud i.t.t.t.way)
  ?:  ?=(%| -.avow)                     ::  shouldn't happen
    `state
  ?~  queue=(flop (~(get ja keu) who))  ::  shouldn't happen
    `state
  ?.  =(event-id event-id.i.queue)      ::  shouldn't happen
    `state
  ?~  got=(~(get by pen) event-id)      ::  shouldn't happen
    `state
  ?~  known=;;((soft ?) q.p.avow)       ::  shouldn't happen
    `state
  =.  pen  (~(del by pen) event-id)
  =.  kno  (~(put by kno) event-id u.known)
  =.  keu  (~(put by keu) who (flop t.queue))
  (handle-send our u.got(way /newt/0v1n.2m9vh/(scot %ud event-id)))
::
++  handle-send
  =,  ames
  |=  [our=ship sndr=@p way=wire %send lan=lane pac=@]
  ^-  (quip card:agent:gall _state)
  =/  rcvr=(unit @p)  (lane-to-ship sndr lan)
  ?~  rcvr
    ~&([%aqua %ames %handle-send "can't resolve lane"] `state)
  =/  hear-lane  (ship-to-lane sndr)
  =/  =shot      (sift-shot pac)
  ?:  &(!sam.shot req.shot)  :: is fine request
    ::  TODO: this skips intermediate hops
    =/  [%0 =peep]  (sift-wail `@ux`content.shot)
    :_  state
    %+  emit-aqua-events  our
    :_  ~
    :-  %read
    [[[u.rcvr rcvr-tick.shot] path.peep] [hear-lane sndr-tick.shot] num.peep]
  =/  event-id=(unit @ud)
    ?.  ?=([@ @ @ ~] way)  ~
    `(slav %ud i.t.t.way)
  =/  is-known=(unit ?)
    ?~  event-id  ~
    (~(get by kno) u.event-id)
  ?:  &(=(u.rcvr rcvr.shot) ?=(~ is-known))
    (get-known our [sndr.shot rcvr.shot] sndr way %send lan pac)
  ::  avoid crashes from treating open packet as shut packet or vice versa
  ::
  ?:  (known-filter is-known u.rcvr [sndr rcvr content]:shot)
    ::~&  >  "skip packet"^event-id=event-id
    :_  state
    %+  emit-aqua-events  our
    (next-known-thread rcvr.shot)
  ::~&  >>   "inject packet"^event-id=event-id
  :_  state
  %+  emit-aqua-events  our
  :_  ?.(=(u.rcvr rcvr.shot) ~ (next-known-thread rcvr.shot))
  [%event u.rcvr /a/newt/0v1n.2m9vh %hear hear-lane pac]
  
::  XX  this should use the (TODO) message layer in %ames
::
++  handle-push
  =,  ames
  |=  [our=@p sndr=@p way=wire %push lan=(list lane:pact) q=@]
  ^-  (quip card:agent:gall _state)
  =|  aes=(list aqua-event)
  ::  process each lane with +push-lane and emit the accumulated events
  ::
  |-
  ?~  lan
    :_  state
    ?~  aes
      ~
    (emit-aqua-events our aes)
  =^  lan-aes=(list aqua-event)  state
    (push-lane sndr i.lan q)
  $(aes (weld lan-aes aes), lan t.lan)
::
++  push-lane
  =,  ames
  |=  [sndr=@p lan=lane:pact q=@]
  |^  ^-  [(list aqua-event) _state]
  =/  pac=pact:pact  (parse-packet:ames-raw q)
  ?-  +<.pac
      %peek  (poke-peek-route sndr lan q name.pac pac)
      %poke  (poke-peek-route sndr lan q ack.pac pac)
      %page
    ::  if there's no events emitted, no ship was reached, so discard
    ::  intermediate state changes
    ::
    =-  ?~  aes
          `state
        [aes new-state]
    ^-  [aes=(list aqua-event) new-state=_state]
    =|  aes=(list aqua-event)
    =|  last-hop=(unit ship)
    =/  this-hop=ship  sndr
    |-
    ::  pop lanes from pending interest table for this hop
    ::
    =/  pits=(list lane:pact)  ~(tap in (~(get ju pit) [this-hop name.pac]))
    =.  pit  (~(del by pit) [this-hop name.pac])
    |-
    ?~  pits
      ::  are there pending outbound requests?
      ::
      ?.  (~(has in mep) [this-hop name.pac])
        [aes state]
      =.  mep  (~(del in mep) [this-hop name.pac])
      ::  if we're the sender, do nothing
      ::
      ?~  last-hop
        [aes state]
      ::  otherwise, inject
      ::
      :_  state
      :_  aes
      [%event this-hop /a/newt/0v1n.2m9vh %heer (mesa-ship-to-lane u.last-hop) q]
    =/  next-hop=(unit @p)  (mesa-lane-to-ship this-hop i.pits)
    ?~  next-hop
      $(pits t.pits)
    ::  update packet routing metadata
    ::
    =/  fwd-pac=pact:pact
      ?~  last-hop  pac
      pac(hop +(hop.pac), next ~[(mesa-ship-to-lane u.last-hop)])
    ::  reassemble
    ::
    =/  fwd-q=@
      ?~  last-hop  q
      p:(fax:plot (en:pact fwd-pac))
    ::  recurse into next hop
    ::
    =^  new-aes=(list aqua-event)  state
      ?>  ?=(%page +<.fwd-pac)
      ^$(last-hop `this-hop, this-hop u.next-hop, pac fwd-pac, q fwd-q)
    ::  update events and move to next PIT lane
    ::
    $(pits t.pits, aes new-aes)
  ==
  ::
  ++  poke-peek-route
    |=  $:  sndr=@p
            lan=lane:pact
            q=@
            key-name=name:pact
            pac=pact:pact
        ==
    ::  if there's no events emitted, no ship was reached, so discard
    ::  intermediate state changes
    ::
    =-  ?~  aes
          `state
        [aes new-state]
    ^-  [aes=(list aqua-event) new-state=_state]
    =/  target=@p  her.key-name
    =/  last-hop=@p  sndr
    =/  this-hop=@p  sndr
    =/  next=(unit @p)  (mesa-lane-to-ship this-hop lan)
    ::  if we can't resolve lane, no-op
    ::
    ?~  next
      `state
    ::  otherwise, add to pending outbound requests
    ::
    =.  mep  (~(put in mep) [sndr key-name])
    ::  move to first hop
    ::
    =.  this-hop  u.next
    =|  aes=(list aqua-event)
    |-
    ::  if we've reached the target ship...
    ::
    ?:  =(target this-hop)
      =/  return=lane:pact  (mesa-ship-to-lane last-hop)
      ::  add to target's PIT
      ::
      =.  pit  (~(put ju pit) [this-hop key-name] return)
      ::  inject event
      ::
      :_  state
      :_  aes
      [%event this-hop /a/newt/0v1n.2m9vh %heer return q]
    ::  get sponsor for target from this hop's perspective
    ::
    =/  sponsor=@p
      ::  use default sponsorship chain for azimuth ship
      ::
      ?.  (is-c-comet this-hop)
        ~&  >>>  [%not-c-comet this-hop=this-hop target=target]
        (rear (^saxo:title target))
      ::  use emitted saxos for Suite C comets
      ::
      =/  saxos=(list @p)  (~(gut by sax) target *(list @p))
      ?~  saxos
          ~&  >>>  [%empty-saxos this-hop=this-hop target=target]
         (rear (^saxo:title target))
      (rear saxos)
    ::  make sure we're their sponsor and can therefore forward
    ::
    ?.  =(this-hop sponsor)
      [aes state]
    ::  get lanes for target from this hop's perspective
    ::
    =/  lanes=(list lane:pact)
      mesa:(~(gut by nas) [this-hop target] *nail-entry)
    ::  add to this hop's PIT
    ::
    =/  return=lane:pact  (mesa-ship-to-lane last-hop)
    =.  pit  (~(put ju pit) [this-hop key-name] return)
    |-
    ?~  lanes
      [aes state]
    =/  next-hop=(unit @p)  (mesa-lane-to-ship this-hop i.lanes)
    ?~  next-hop
      $(lanes t.lanes)
    ::  updating packet routing metadata and reassemble
    ::
    =/  fwd-pac=pact:pact  pac(hop +(hop.pac))
    =/  fwd-q=@    p:(fax:plot (en:pact fwd-pac))
    ::  then give it to the next hop
    ::
    =^  new-aes=(list aqua-event)  state
      ^$(last-hop this-hop, this-hop u.next-hop, pac fwd-pac, q fwd-q)
    ::  update event list and move to next lane
    ::
    $(aes new-aes, lanes t.lanes)
  --
::  +known-filter: test whether packet should be injected
::
++  known-filter
  |=  [is-known=(unit ?) rcvr=@p shot-sndr=@p shot-rcvr=@p content=@]
  ^-  ?
  ?&  ::=-  ~?  -  %is-pawn
      ::    -
      ?=(%pawn (clan:title shot-sndr))
      ::  if this is going to be forwarded, skip checks
      ::
      ::=-  ~?  -  %not-forwarded
      ::    -
      =(rcvr shot-rcvr)
      ::
      =+  ;;(out=(soft [~ signature=@ signed=@]) (mole |.((cue content))))
      =+  ;;(open=(soft [~ open-packet:ames-raw]) (mole |.((cue signed:(need (need out))))))
      ?|  ?&  ?=(~ open)
              ::  if this is not an attestation packet, check that the receiver
              ::  has the peer as known
              ::
              !?=([~ %.y] is-known)
          ==
          ?&  ?=(^ open)
              ::  if this is an attestation packet, check if the rcvr has the comet
              ::  as %known -- this is a workaround to prevent a bail:evil that will
              ::  end up blocking the queue of the %aqua host, when it tries to decrypt
              ::  an open-packet
              ::
              ?=([~ %.y] is-known)
  ==  ==  ==
::  +get-known: get known peers before send
::
++  get-known
    |=  $:  our=@p
            [shot-sndr=@p shot-rcvr=@p]
            sndr=@p
            way=wire
            %send
            lan=lane:ames
            pac=@ux
        ==
    ^-  (quip card:agent:gall _state)
    =/  event-id=@ud  nid
    =.  nid  +(nid)
    =.  pen  (~(put by pen) event-id [sndr way %send lan pac])
    ::  if there's a pending thread, wait until complete
    ::
    ?^  (~(get ja keu) shot-rcvr)
      =.  keu  (~(add ja keu) shot-rcvr [event-id shot-sndr shot-rcvr])
      `state
    ::  otherwise inject thread
    ::
    =.  keu  (~(add ja keu) shot-rcvr [event-id shot-sndr shot-rcvr])
    =/  fyrd  (make-thread shot-sndr)
    :_  state
    %+  emit-aqua-events  our
    [%event shot-rcvr /k/khan/0v1n.2m9vh/1/(scot %ud event-id) %fyrd fyrd]~
::  +make-thread: make knownness discovery thread
::
++  make-thread
  |=  shot-sndr=@p
  ^-  (fyrd:khan cast:khan)
  =/  =page
    :-  %ted-eval
    %-  crip
    """
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  peers=(map @p ?(%alien %known))  bind:m
      (scry (map @p ?(%alien %known)) /ax//peers)
    =/  known=?  
      =/  peer=?(%alien %known)
        (~(gut by peers) {(scow %p shot-sndr)} %alien)
      =(%known peer)
    (pure:m !>(known))
    """
  [%base %khan-eval %noun page]
::  +next-known-thread: send next queued knownness thread
::
++  next-known-thread
  |=  shot-rcvr=@p
  ^-  (list aqua-event)
  ?~  queue=(flop (~(get ja keu) shot-rcvr))
    ~
  =/  fyrd  (make-thread shot-sndr.i.queue)
  [%event shot-rcvr /k/khan/0v1n.2m9vh/1/(scot %ud event-id.i.queue) %fyrd fyrd]~
::  +is-c-comet: check if a ship is a Suite C comet
::
++  is-c-comet
  |=  ship=@p
  ^-  ?
  ?.  ?=(%pawn (clan:title ship))
    %.n
  =/  index=(unit @)  (find ~[ship] comets)
  ?~  index  %.n
  |((lte u.index 2) &((gte u.index 6) (lte u.index 8)))
::  +mesa-lane-to-ship: decode a ship from a mesa lane
::
::    Special-case some comets, since their addresses doesn't fit into a lane.
::
++  mesa-lane-to-ship
  |=  [sndr=@p =lane:pact:ames]
  ^-  (unit ship)
  ?@  lane
    ?.  =(%pawn (clan:title `@p``@`lane))
      (some `@p``@`lane)
    =/  =fiefs-result:jael  (~(gut by fez) sndr ~)
    ?~  got=(~(gut by fiefs-result) `@p``@`lane *(unit fief))
      ~
    ?-    -.u.got
        %is  ~
        %turf
      |-  ^-  (unit ship)
      ?~  p.u.got  ~
      ?^  tuf=(~(get by turfs) i.p.u.got)
        tuf
      $(p.u.got t.p.u.got)
    ::
        %if
      ?.  =(0xdead.beef p.u.got)  ~
      ?.  (lth q.u.got 12)  ~
      (some (snag q.u.got comets))
    ==
  ?-  -.lane
      %is  ~
  ::
      %if
    ?:  ?&  =(0xdead.beef p.lane)
            (lth q.lane 12)
        ==
      (some (snag q.lane comets))
    (some `@p``@`(cat 5 p.lane q.lane))
  ==
::  +mesa-ship-to-lane: encode a lane to look like it came from .ship
::
::    Never shows up as a galaxy, because Vere wouldn't know that either.
::    Special-case a list of comets, since its address doesn't fit into a lane.
::
++  mesa-ship-to-lane
  |=  =ship
  ^-  lane:pact:ames
  =/  index=(unit @ud)  (find ~[ship] comets)
  ?~  index
    [%if (end 5 ship) (rsh 5 ship)]
  [%if `@if``@`0xdead.beef u.index]
::  +lane-to-ship: decode a ship from an aqua lane
::
::    Special-case some comets, since their addresses doesn't fit into a lane.
::
++  lane-to-ship
  |=  [sndr=@p =lane:ames]
  ^-  (unit ship)
  ?-    -.lane
      %&
    ?.  =(%pawn (clan:title p.lane))
      (some p.lane)
    =/  =fiefs-result:jael  (~(gut by fez) sndr ~)
    ?~  got=(~(gut by fiefs-result) p.lane *(unit fief))
      ~
    ?-    -.u.got
        %is  ~
        %turf
      |-  ^-  (unit ship)
      ?~  p.u.got  ~
      ?^  tuf=(~(get by turfs) i.p.u.got)
        tuf
      $(p.u.got t.p.u.got)
    ::
        %if
      ?.  =(0xdead.beef p.u.got)  ~
      ?.  (lth q.u.got 12)  ~
      (some (snag q.u.got comets))
    ==
  ::
      %|
    ?:  ?&  =(0xdead.beef (end 5 p.lane))
            (lth (rsh 5 p.lane) 12)
        ==
      (some (snag (rsh 5 p.lane) comets))
    (some `@p``@`p.lane)
  ==
::  +ship-to-lane: encode a lane to look like it came from .ship
::
::    Never shows up as a galaxy, because Vere wouldn't know that either.
::    Special-case a list of comets, since its address doesn't fit into a lane.
::
++  ship-to-lane
  |=  =ship
  ^-  lane:ames
  :-  %|
  ^-  address:ames  ^-  @
  =/  index=(unit @ud)  (find ~[ship] comets)
  ?~  index
    ship
  (cat 2 0xdead.beef u.index)
::  +ames-to-mesa-lane: convert an ames lane to $lane:pact
::
++  ames-to-mesa-lane
  |=  =lane:ames
  ^-  lane:pact:ames
  ?-  -.lane
      %&  `@ux``@`p.lane
      %|  [%if (end 5 p.lane) (cut 4 [2 1] p.lane)]
  ==
::  +comets: list of hard-coded comets
::
++  comets
  ^~  ^-  (list @p)
  :~  :: %c suite, marbud, 0xdead.beef.cafe tweak
      ~fasteg-dinhet-malrum-ransub--hocduc-digtev-radsut-marbud
      ~daldyl-nildem-dispec-tilryx--dondus-dirmet-tintyl-marbud
      ~dansyr-ponbec-tocfel-laddux--socnut-nisnyx-dinsut-marbud
      :: %b suite, marbud
      ~harrep-podpec-torsut-docnyx--mopsyx-fosdus-ladpen-marbud
      ~liblyn-togrut-tabwel-hodbet--dovbex-parryt-mirbyt-marbud
      ~hidreb-naptev-banben-bicrup--massup-dantus-fodwet-marbud
      :: %c suite, mardev, 0xdead.beef.cafe tweak
      ~molpyx-novtyc-wortyc-noswyd--taltyv-loplev-dabwen-mardev
      ~fosnys-noctyd-talfyl-borryl--davhus-disbyn-fotnec-mardev
      ~tonmep-tabrux-rinbep-firmur--silmex-saldef-pasfer-mardev
      :: %b suite, mardev
      ~holwyx-ramped-tognet-barsyn--navler-ronmeg-topbex-mardev
      ~hacmet-doslyr-narhut-tiptec--micbyl-motnev-worsyn-mardev
      ~ribmut-nopdul-minmet-pardeg--wisfex-rosfus-fogsyn-mardev
  ==
:: +turfs: map from domain to comet
::
++  turfs
  ^~  ^-  (map turf @p)
  %-  ~(gas by *(map turf @p))
  ^-  (list [turf @p])
  =-  (zip - comets)
  ^-  (list turf)
  :~  /marbud/fasteg  /marbud/daldyl  /marbud/dansyr
      /marbud/harrep  /marbud/liblyn  /marbud/hidreb
      /mardev/molpyx  /mardev/fosnys  /mardev/tonmep
      /mardev/holwyx  /mardev/hacmet  /mardev/ribmut
  ==
::
::  +zip: combine two equally long lists into one list of cells
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
--
::
%+  aqua-vane-thread  ~[%nail %saxo %fief %restore %send %push %avow]
|_  =bowl:spider
+*  this  .
++  handle-unix-effect
  |=  [who=@p ue=unix-effect]
  ^-  (quip card:agent:gall _this)
  =^  cards  state
    ?+  -.q.ue  [~ state]
      %nail     (handle-nail our.bowl who ue)
      %saxo     (handle-saxo our.bowl who ue)
      %fief     (handle-fief our.bowl who ue)
      %restore  (handle-restore our.bowl who)
      %send     (handle-send our.bowl who ue)
      %push     (handle-push our.bowl who ue)
      %avow     (handle-avow our.bowl who ue)
    ==
  [cards this]
::
++  handle-arvo-response  |=(* !!)
--
