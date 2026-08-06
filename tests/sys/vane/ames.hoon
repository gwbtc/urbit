/+  *test
/=  ames  /sys/vane/ames
/=  jael  /sys/vane/jael
/*  dojo  %hoon  /app/dojo/hoon
::  construct some test fixtures
::
=/  nec     ^$:(%*($ ames ahoy-on %.n, +< ~nec))
=/  bud     ^$:(%*($ ames ahoy-on %.n, +< ~bud))
=/  marbud  ^$:(%*($ ames ahoy-on %.n, +< ~marbud))
::
=/  our-comet   ~bosrym-podwyl-magnes-dacrys--pander-hablep-masrym-marbud
=/  our-comet2  ~togdut-rosled-fadlev-siddys--botmun-wictev-sapfus-marbud
=/  comet   ^$:(%*($ ames ahoy-on %.n, +< our-comet))
=/  comet2  ^$:(%*($ ames ahoy-on %.n, +< our-comet2))
::
:: =.  ahoy-on.nec    %.n
=.  now.nec        ~1111.1.1
=.  eny.nec        `@uvJ`0xdead.beef
=.  life.ames-state.nec  2
=.  rift.ames-state.nec  0
=.  rof.nec  |=(* ``[%noun !>(*(list turf))])
=+  crypto-core=(pit:nu:cric:crypto 512 (shaz 'nec') %b ~)
=.  saf.ames-state.nec   saf:ex:crypto-core
=.  ring.ames-state.nec  sec:ex:crypto-core
=.  pass.ames-state.nec  pub:ex:crypto-core
::
:: =.  ahoy-on.bud    %.n
=.  now.bud        ~1111.1.1
=.  eny.bud        `@uvJ`0xbeef.dead
=.  life.ames-state.bud  3
=.  rift.ames-state.bud  0
=.  rof.bud  |=(* ``[%noun !>(*(list turf))])
=+  crypto-core=(pit:nu:cric:crypto 512 (shaz 'bud') %b ~)
=.  saf.ames-state.bud   saf:ex:crypto-core
=.  ring.ames-state.bud  sec:ex:crypto-core
=.  pass.ames-state.bud  pub:ex:crypto-core
::
:: =.  ahoy-on.marbud    %.n
=.  now.marbud        ~1111.1.1
=.  eny.marbud        `@uvJ`0xbeef.beef
=.  life.ames-state.marbud  4
=.  rift.ames-state.marbud  0
=.  rof.marbud  |=(* ``[%noun !>(*(list turf))])
=+  crypto-core=(pit:nu:cric:crypto 512 (shaz 'marbud') %b ~)
=.  saf.ames-state.marbud   saf:ex:crypto-core
=.  ring.ames-state.marbud  sec:ex:crypto-core
=.  pass.ames-state.marbud  pub:ex:crypto-core
::
:: =.  ahoy-on.comet    %.n
=.  now.comet        ~1111.1.1
=.  eny.comet        `@uvJ`0xbeef.cafe
=.  life.ames-state.comet  1
=.  rift.ames-state.comet  0
=.  rof.comet  |=(* ``[%noun !>(*(list turf))])
=/  crypto-core
  %-  nol:nu:cric:crypto
  0w9N.5uIvA.Jg0cx.NCD2R.o~MtZ.uEQOB.9uTbp.6LHvg.0yYTP.
  3q3td.T4UF0.d5sDL.JGpZq.S3A92.QUuWg.IHdw7.izyny.j9W92
=.  saf.ames-state.comet   saf:ex:crypto-core
=.  ring.ames-state.comet  sec:ex:crypto-core
=.  pass.ames-state.comet  pub:ex:crypto-core
::
:: =.  ahoy-on.comet2    %.n
=.  now.comet2        ~1111.1.1
=.  eny.comet2        `@uvJ`0xcafe.cafe
=.  life.ames-state.comet2  1
=.  rift.ames-state.comet2  0
=.  rof.comet2  |=(* ``[%noun !>(*(list turf))])
=+  crypto-core=(pit:nu:cric:crypto 512 0v1eb4 %b ~)
=.  saf.ames-state.comet2   saf:ex:crypto-core
=.  ring.ames-state.comet2  sec:ex:crypto-core
=.  pass.ames-state.comet2  pub:ex:crypto-core
::
=/  nec-sym
  (derive-symmetric-key:ames pub.saf.ames-state.bud sek.saf.ames-state.nec)
=/  bud-sym
  (derive-symmetric-key:ames pub.saf.ames-state.nec sek.saf.ames-state.bud)
?>  =(nec-sym bud-sym)
=/  nec-marbud-sym
  (derive-symmetric-key:ames pub.saf.ames-state.marbud sek.saf.ames-state.nec)
::
=/  marbud-sym
  (derive-symmetric-key:ames pub.saf.ames-state.marbud sek.saf.ames-state.comet)
=/  marbud2-sym
  (derive-symmetric-key:ames pub.saf.ames-state.marbud sek.saf.ames-state.comet2)
=/  bud-marbud-sym
  (derive-symmetric-key:ames pub.saf.ames-state.bud sek.saf.ames-state.marbud)
=/  bud-comet-sym
  (derive-symmetric-key:ames pub.saf.ames-state.nec sek.saf.ames-state.comet)
::
=/  comet-sym
  (derive-symmetric-key:ames pub.saf.ames-state.bud sek.saf.ames-state.comet)
::
=.  peers.ames-state.nec
  %+  ~(put by peers.ames-state.nec)  ~bud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=bud-sym
        life=3
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.bud
        sponsor=~nec
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%& ~nec]]
  [%known peer-state]
::
=.  peers.ames-state.nec
  %+  ~(put by peers.ames-state.nec)  ~marbud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=nec-marbud-sym
        life=5
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.marbud
        sponsor=~bud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
::
=.  peers.ames-state.bud
  %+  ~(put by peers.ames-state.bud)  ~nec
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=nec-sym
        life=2
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.nec
        sponsor=~nec
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
::
=.  peers.ames-state.comet
  %+  ~(put by peers.ames-state.comet)  ~marbud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=marbud-sym
        life=5
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.marbud
        sponsor=~bud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
=.  peers.ames-state.comet
  %+  ~(put by peers.ames-state.comet)  ~bud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=bud-marbud-sym
        life=3
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.bud
        sponsor=~bud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
=.  peers.ames-state.comet2
  %+  ~(put by peers.ames-state.comet2)  ~marbud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=marbud2-sym
        life=5
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.marbud
        sponsor=~bud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
=.  peers.ames-state.comet2
  %+  ~(put by peers.ames-state.comet2)  ~bud
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=bud-marbud-sym
        life=3
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.bud
        sponsor=~bud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`%lane-bar]]
  [%known peer-state]
::  alien peers
::
=.  peers.ames-state.bud
  %+  ~(put by peers.ames-state.bud)  our-comet
  [%alien *alien-agenda:ames]
::
=.  chums.ames-state.comet
  %+  ~(put by chums.ames-state.comet)  ~bud
  =|  =fren-state:ames
  =.  -.fren-state
    :*  symmetric-key=bud-comet-sym
        life=3
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.bud
        sponsor=~bud
        fief=~
    ==
  =.  lane.fren-state  `[hop=0 `lane:pact:ames``@`~bud]
  [%known fren-state]
::  metamorphose
::
=>  .(nec +:(call:(nec) ~[//unix] ~ %born ~))
=>  .(bud +:(call:(bud) ~[//unix] ~ %born ~))
=>  .(comet +:(call:(comet) ~[//unix] ~ %born ~))
=>  .(comet2 +:(call:(comet2) ~[//unix] ~ %born ~))
::  |ames as the default network core
::
=>  .(nec +:(call:(nec) ~[//unix] ~ %load %ames))
=>  .(bud +:(call:(bud) ~[//unix] ~ %load %ames))
=>  .(comet +:(call:(comet) ~[//unix] ~ %load %ames))
=>  .(comet2 +:(call:(comet2) ~[//unix] ~ %load %ames))
::  helper core
::
=>
|%
++  move-to-packet
  |=  =move:ames
  ^-  [=lane:ames =blob:ames]
  ::
  ?>  ?=([%give %send *] +.move)
  [lane blob]:+>+.move
::
++  move-to-push
  |=  =move:ames
  ^-  [lane:pact:ames =blob:ames]
  ::
  =;  [l=(list lane:pact:ames) =blob:ames]
    (snag 0 l)^blob
  ?>  ?=([%give %push *] +.move)
  [p q]:+>+.move
::
++  move-to-moke
  |=  =move:ames
  ^-  [space:ames spar:ames path]
  ::
  ?>  ?=([%pass wire=^ %a %moke *] +.move)
  =/  =space:ames  &6:move
  =/  =spar:ames   &7:move
  [space spar |7:move]
::
++  move-to-plea
  |=  =move:ames
  ^-  [ship plea:ames]
  ::
  ?>  ?=([%pass ^ %g %plea *] card.move)
  |5:move
::
++  move-to-ahoy
  |=  =move:ames
  ^-  cage
  ::
  ?>  ?=([%pass [%ahoy ~] %g %deal ^ %hood %poke %ahoy-prob *] +.move)
  ~!  |8:move
  |8:move
::
++  is-move-send
  |=  =move:ames
  ^-  ?
  ?=([%give %send *] card.move)
::
++  is-move-push
  |=  =move:ames
  ^-  ?
  ?=([%give %push *] card.move)
::
++  is-move-moke
  |=  =move:ames
  ^-  ?
  ?=([%pass wire=^ %a %moke *] card.move)
::
++  is-move-ahoy
  |=  =move:ames
  ^-  ?
  ?=([%pass [%ahoy ~] %g %deal ^ %hood %poke %ahoy-prob *] card.move)
::
++  is-move-plea
  |=  =move:ames
  ^-  ?
  ?=([%pass ^ %g %plea *] card.move)
::
++  snag-packet
  |=  [index=@ud moves=(list move:ames)]
  ^-  [=lane:ames =blob:ames]
  ::
  %-  move-to-packet
  %+  snag  index
  (skim moves is-move-send)
::
++  snag-moke
  |=  [index=@ud moves=(list move:ames)]
  ^-  [space:ames spar:ames path]
  ::
  %-  move-to-moke
  %+  snag  index
  (skim moves is-move-moke)
::
++  snag-ahoy
  |=  [index=@ud moves=(list move:ames)]
  ^-  cage
  ::
  %-  move-to-ahoy
  %+  snag  index
  (skim moves is-move-ahoy)
::
++  snag-plea
  |=  [index=@ud moves=(list move:ames)]
  ^-  [ship plea:ames]
  ::
  %-  move-to-plea
  %+  snag  index
  (skim moves is-move-plea)
::
++  snag-push
  |=  [index=@ud moves=(list move:ames)]
  ^-  [=lane:pact:ames =blob:ames]
  ::
  %-  move-to-push
  %+  snag  index
  (skim moves is-move-push)
::
++  make-roof
  |=  [pax=path val=cage]
  ^-  roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?.  ?&  =(s.bem pax)
          ?|  =(vis %x)
              =(vis [%$ %x])
              =(vis [%g %x])
              =(vis [%a %x])
              ?&  =(vis %j)
                  =(%saxo q.bem)
      ==  ==  ==
    [~ ~]
  ``val
::
++  pki-roof
  ::  the two scries a comet self-attestation makes: who sponsors the
  ::  comet (+sein, asserted by +sift-open-packet) and what life jael
  ::  already knows for it (+on-hear-open).  every other scry keeps the
  ::  fixtures' `(list turf)` stub.
  ::
  |=  lyf=(unit @ud)
  ^-  roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?.  =(vis %j)
    ``noun+!>(*(list turf))
  ?+  q.bem  ``noun+!>(*(list turf))
    %sein  ``noun+!>(`ship`~marbud)
    %lyfe  ``noun+!>(lyf)
  ==
::
++  attestation
  ::  a comet self-attestation as it goes on the wire
  ::
  |=  [=open-packet:ames saf=keypairs:ames]
  ^-  blob:ames
  (etch-shot:ames (etch-open-packet:ames open-packet saf))
::
++  known-comet
  ::  peer state for a comet we have already promoted
  ::
  |=  [=symmetric-key:ames lyf=@ud comet=_comet]
  ^-  ship-state:ames
  =|  =peer-state:ames
  =.  -.peer-state
    :*  symmetric-key=symmetric-key
        life=lyf
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.comet
        sponsor=~marbud
        fief=~
    ==
  =.  route.peer-state  `[direct=%.y `lane:ames`[%| `@`0xffff.7f00.0001]]
  [%known peer-state]
::
++  n-frags
  |=  n=@
  ^-  @ux
  ::  6 chosen randomly to get some trailing zeros
  ::
  %+  rsh  10
  %+  rep  13
  %+  turn  (gulf 1 n)
  |=(x=@ (fil 3 1.024 (dis 0xff x)))
::
++  scry
  |=  [vane=_nec car=term bem=beam]
  =/  =roof
    ::  custom scry handler for +test-fine-response.
    ::  could be refined further...
    ::
    |=  [lyc=gang pov=path vis=view bem=beam]
    ^-  (unit (unit cage))
    ?+  vis  ~
        %cp
      =/  black=dict:clay
        %*(. *dict:clay mod.rul %black)
      ``noun+!>([black black])
    ::
        %cz
      ?+  -.r.bem  !!
        %ud  ``noun+!>((n-frags p.r.bem))
      ==
    ::
        %cx
      ``hoon+!>(dojo)
    ==
  =/  vane-core  (vane(rof roof))
  (scry:vane-core ~ / car bem)
::
++  call
  |=  [vane=_nec =duct =task:ames]
  ^-  [moves=(list move:ames) _nec]
  ::
  =/  vane-core  (vane(now `@da`(add ~s1 now.vane)))
  ::
  (call:vane-core duct ~ task)
::
++  take
  |=  [vane=_nec =wire =duct =sign:ames]
  ^-  [moves=(list move:ames) _nec]
  ::
  =/  vane-core  (vane(now `@da`(add ~s1 now.vane)))
  ::
  (take:vane-core wire duct ~ sign)
--
::  test core
::
|%
++  test-packet-encoding  ^-  tang
  ::
  =/  =shot:ames
    :*  [sndr=~nec rcvr=~bud]
        req=&  sam=&
        sndr-tick=0b10
        rcvr-tick=0b11
        origin=~
        content=0xdead.beef
    ==
  ::
  =/  encoded  (etch-shot:ames shot)
  =/  decoded  (sift-shot:ames encoded)
  ::
  %+  expect-eq
    !>  shot
    !>  decoded
::
++  test-origin-encoding  ^-  tang
  ::
  =/  =shot:ames
    :*  [sndr=~nec rcvr=~bud]
        req=&  sam=&
        sndr-tick=0b10
        rcvr-tick=0b11
        origin=`0xbeef.cafe.beef
        content=0xdead.beef
    ==
  ::
  =/  encoded  (etch-shot:ames shot)
  =/  decoded  (sift-shot:ames encoded)
  ::
  %+  expect-eq
    !>  shot
    !>  decoded
::
++  test-shut-packet-encoding  ^-  tang
  ::
  =/  =shut-packet:ames
    :+  bone=17  message-num=18
    [%& num-fragments=1 fragment-num=1 fragment=`@`0xdead.beef]
  ::
  =/  =shot:ames
    (etch-shut-packet:ames shut-packet nec-sym ~marnec ~marbud-marbud 3 17)
  ::
  =/  decoded=(unit shut-packet:ames)  (sift-shut-packet:ames shot nec-sym 3 17)
  ::
  %+  expect-eq
    !>  `shut-packet
    !>  decoded
::
::  Crypto failures are now non-deterministic
::
::  ++  test-shut-packet-associated-data  ^-  tang
::    ::
::    =/  =shut-packet:ames
::      :+  bone=17  message-num=18
::      [%& num-fragments=1 fragment-num=1 fragment=`@`0xdead.beef]
::    ::
::    =/  =packet:ames
::      (encode-shut-packet:ames shut-packet nec-sym ~marnec ~marbud-marbud 3 1)
::    ::
::    %-  expect-fail
::    |.((decode-shut-packet:ames packet nec-sym 3 17))
::
++  test-alien-encounter  ^-  tang
  ::
  =/  lane-foo=lane:ames  [%| `@ux``@`%lane-foo]
  ::
  =/  =plea:ames  [%g /talk [%first %post]]
  ::
  =/  =shut-packet:ames
    :*  bone=1
        message-num=1
        [%& num-fragments=1 fragment-num=0 (jam plea)]
    ==
  ::
  =/  =shot:ames
    %:  etch-shut-packet:ames
      shut-packet
      nec-sym
      ~bus
      ~bud
      sndr-life=4
      rcvr-life=3
    ==
  ::
  =/  ahoy-plea  ahoy-prob/!>(~nec^force-test=|)
  =/  =blob:ames   (etch-shot:ames shot)
  =^  moves1  bud  (call bud ~[//unix] %hear lane-foo blob)
  =^  moves2  bud
    =/  =point:ames
      :*  rift=0
          life=4
          keys=[[life=4 [crypto-suite=1 `@`pass.ames-state.nec]] ~ ~]
          sponsor=`~bus
          fief=~
      ==
    %-  take
    :^  bud  /public-keys  ~[//unix]
    ^-  sign:ames
    [%jael %public-keys %full [n=[~bus point] ~ ~]]
  =^  moves3  bud  (call bud ~[//unix] %hear lane-foo blob)
  ::
  ;:  weld
    %+  expect-eq
      !>  [~[//unix] %pass /public-keys %j %public-keys [~bus ~ ~]]~
      !>  moves1
  ::
    %+  expect-eq
      !>  %-  sy
          :~  :^  ~[//unix]  %pass  /bone/~bus/0/1
              [%g %plea ~bus %g /talk [%first %post]]
          ::
              :^  ~[//unix]  %pass  /qos
              [%d %flog %text "; ~bus is your neighbor"]
          ==
      !>  (sy ,.moves3)
  ==
::
++  test-message-flow  ^-  tang
  ::  ~nec -> %plea -> ~bud
  ::
  =^  moves1  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  ::  ~bud -> %done -> ~nec
  ::
  =^  moves3  bud  (take bud /bone/~nec/0/1 ~[//unix] %g %done ~)
  =^  moves4  nec  (call nec ~[//unix] %hear (snag-packet 0 moves3))
  ::  ~bud -> %boon -> ~nec
  ::
  =^  moves5  bud  (take bud /bone/~nec/0/1 ~[//unix] %g %boon [%post 'first1'])
  =^  moves6  nec  (call nec ~[//unix] %hear (snag-packet 0 moves5))
  ::  ~nec -> %done -> ~bud (just make sure ~bud doesn't crash on ack)
  ::
  =^  moves7  bud  (call bud ~[//unix] %hear (snag-packet 0 moves6))
  ::
  ;:  weld
    %+  expect-eq
      !>  %-  sy
          :~  [~[//unix] %pass /qos %d %flog %text "; ~nec is your neighbor"]
            ::
              :^  ~[//unix]  %pass  /bone/~nec/0/1
              [%g %plea ~nec %g /talk [%get %post]]
          ==
      !>  (sy ,.moves2)
  ::
    %+  expect-eq
      !>  %-  sy
          :~  [~[/ames] %pass /pump/~bud/0 %b %rest ~1111.1.1..00.00.02]
              [~[//unix] %pass /qos %d %flog %text "; ~bud is your neighbor"]
              [~[/g/talk] %give %done error=~]
          ==
      !>  (sy ,.moves4)
  ::
    %+  expect-eq
      !>  [~[/g/talk] %give %boon [%post 'first1']]
      !>  (snag 0 `(list move:ames)`moves6)
  ==
::  +test-comet-message-flow: galaxy<->comet comms
::
::    same as test-message-flow, but ~nec will send a sendkeys packet to
::    request comet's self-attestation directly
::
++  test-comet-message-flow  ^-  tang
  =^  *       nec   (call nec ~[//nemo] %spew ~[%snd %rcv %odd %msg])
  =^  *     comet   (call comet ~[//nemo] %spew ~[%snd %rcv %odd %msg])
  ::
  =^  moves0  nec    (call nec ~[/g/talk] %plea our-comet %g /talk [%get %post])
  =^  moves1  comet  (call comet ~[//unix] %hear (snag-packet 0 moves0))
  =^  moves2  comet
    =/  =point:ames
      :*  rift=1
          life=2
          keys=[[life=2 [crypto-suite=1 `@`pass.ames-state.nec]] ~ ~]
          sponsor=`~nec
          fief=~
      ==
    %-  take
    :^  comet  /public-keys  ~[//unix]
    ^-  sign:ames
    [%jael %public-keys %full [n=[~nec point] ~ ~]]
  ::  give comet's self-attestation to ~nec; at this point, we have
  ::  established a channel, and can proceed as usual
  ::
  =/  post  [%post 'first1!!']
  =^  moves3  nec  (call nec ~[//unix] %hear (snag-packet 0 moves2))
  =^  moves4  nec  (call nec ~[//unix] %hear (snag-packet 1 moves2))
  ::
  =^  moves5  comet  (call comet ~[//unix] %hear (snag-packet 0 moves3))
  =^  moves6  comet  (take comet /bone/~nec/1/1 ~[//unix] %g %done ~)
  =^  moves7  nec    (call nec ~[//unix] %hear (snag-packet 0 moves6))
  =^  moves8  comet  (take comet /bone/~nec/1/1 ~[//unix] %g %boon post)
  =^  moves9  nec    (call nec ~[//unix] %hear (snag-packet 0 moves8))
  ::
  ;:  weld
    %+  expect-eq
      !>  =-  [~[//unix] %pass /qos %d %flog %text -]
              "; ~nec is your neighbor"
      !>  (snag 0 `(list move:ames)`moves5)
  ::
    %+  expect-eq
      !>  =-  [~[//unix] %pass /qos %d %flog %text -]
              "; {<our-comet>} is your neighbor"
      !>  (snag 1 `(list move:ames)`moves7)
  ::
    %+  expect-eq
      !>  [~[/g/talk] %give %boon post]
      !>  (snag 0 `(list move:ames)`moves9)
  ::
    %+  expect-eq
      !>  ~
      !>  moves4
  ==
::
++  test-comet-comet-message-flow  ^-  tang
  ::  same as test-message-flow, but the comets need to exchange
  ::  self-attestations to establish a channel
  ::
  =^  moves0  comet   (call comet ~[/g/talk] %plea our-comet2 %g /talk [%get %post])
  =^  moves1  comet2  (call comet2 ~[//unix] %hear (snag-packet 0 moves0))
  =^  moves2  comet   (call comet ~[//unix] %hear (snag-packet 0 moves1))
  ::  channel is now established; comet also emitted a duplicate
  ::  self-attestation, which we ignore
  ::
  =^  moves3  comet2  (call comet2 ~[//unix] %hear (snag-packet 0 moves2))
  =^  moves4  comet2  (call comet2 ~[//unix] %hear (snag-packet 1 moves2))
  =^  moves5  comet2  (take comet2 /bone/(scot %p our-comet)/0/1 ~[//unix] %g %done ~)
  =^  moves6  comet2  (take comet2 /bone/(scot %p our-comet)/0/1 ~[//unix] %g %boon [%post 'first1!!'])
  =^  moves7  comet   (call comet ~[//unix] %hear (snag-packet 0 moves5))
  =^  moves8  comet   (call comet ~[//unix] %hear (snag-packet 0 moves6))
  ::
  ;:  weld
    %+  expect-eq
      !>  [~[//unix] %pass /qos %d %flog %text "; {<our-comet>} is your neighbor"]
      !>  (snag 1 `(list move:ames)`moves4)
  ::
    %+  expect-eq
      !>  [~[//unix] %pass /qos %d %flog %text "; {<our-comet2>} is your neighbor"]
      !>  (snag 1 `(list move:ames)`moves7)
  ::
    %+  expect-eq
      !>  [~[/g/talk] %give %boon [%post 'first1!!']]
      !>  (snag 0 `(list move:ames)`moves8)
  ==
::
++  test-nack  ^-  tang
  ::  ~nec -> %plea -> ~bud
  ::
  =^  moves1  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  ::  ~bud -> nack -> ~nec
  ::
  =/  =error:ames  [%flub [%leaf "sinusoidal repleneration"]~]
  =^  moves3  bud  (take bud /bone/~nec/0/1 ~[/bud] %g %done `error)
  =^  moves4  nec  (call nec ~[//unix] %hear (snag-packet 0 moves3))
  ::  ~bud -> nack-trace -> ~nec
  ::
  =^  moves5  nec  (call nec ~[//unix] %hear (snag-packet 1 moves3))
  ::  ~nec -> naxplanation -> ~nec
  ::
  =/  sink-naxplanation-plea
    [%deep %sink ~bud bone=0 message-num=1 error]
  =^  moves6  nec  (call nec ~[//unix] sink-naxplanation-plea)
  ::  ~nec -> ack nack-trace -> ~bud
  ::
  =^  moves7  bud  (call bud ~[//unix] %hear (snag-packet 0 moves5))
  ::
  ;:  welp
    %+  expect-eq
      !>  [~[/g/talk] %give %done `error]
      !>  (snag 0 `(list move:ames)`moves6)
    ::
    %+  expect-eq
      !>  [~[//unix] %pass /bone/~bud/0/0 %a sink-naxplanation-plea]
      !>  (snag 0 `(list move:ames)`moves5)
    ::
  ==
::
++  test-boon-lost  ^-  tang
  ::  ~nec -> %plea -> ~bud
  ::
  =^  moves1  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  ::  ~bud -> %done -> ~nec
  ::
  =^  moves3  bud  (take bud /bone/~nec/0/1 ~[//unix] %g %done ~)
  =^  moves4  nec  (call nec ~[//unix] %hear (snag-packet 0 moves3))
  ::  ~bud -> %boon -> ~nec, but we tell ~nec it crashed during the handling
  ::
  =^  moves5  bud  (take bud /bone/~nec/0/1 ~[//unix] %g %boon [%post 'first1'])
  =^  moves6  nec
    =/  vane-core  (nec(now `@da`(add ~s1 now.nec)))
    (call:vane-core ~[//unix] `[%test-error ~] %hear (snag-packet 0 moves5))
  %+  expect-eq
    !>  [~[/g/talk] %give %lost ~]
    !>  (snag 0 `(list move:ames)`moves6)
::
++  test-fine-request
  ^-  tang
  =/  want=path  /c/z/1/kids/sys
  =^  moves1  nec  (call nec ~[/g/talk] %keen ~ ~bud want)
  =/  req=hoot:ames
    %+  snag  0
    %+  murn  ;;((list move:ames) moves1)
    |=  =move:ames
    ^-  (unit hoot:ames)
    ?.  ?=(%give -.card.move)    ~
    ?.  ?=(%send -.p.card.move)  ~
    `;;(@uxhoot blob.p.card.move)
  =/  =shot:ames  (sift-shot:ames `@ux`req)
  ?<  sam.shot
  ?>  req.shot
  =/  =wail:ames
   (sift-wail:ames `@ux`content.shot)
  ~&  wail
  (expect-eq !>(1) !>(1))
::
++  test-fine-hunk
  ^-  tang
  %-  zing
  %+  turn  (gulf 1 10)
  |=  siz=@
  =/  want=path  /~bud/0/3/c/z/(scot %ud siz)/kids/sys
  ::
  =/  =beam  [[~bud %$ da+now:bud] (welp /fine/hunk/1/16.384 want)]
  =/  [=mark =vase]  (need (need (scry bud %x beam)))
  =+  !<(song=(list @uxyowl) vase)
  %+  expect-eq
    !>(siz)
    !>((lent song))
::
++  test-fine-response
  ^-  tang
  ::%-  zing
  ::%+  turn  (gulf 1 50)
  ::|=  siz=@
  ::=/  want=path  /~bud/0/1/c/z/(scot %ud siz)/kids/sys
  =/  want=path  /~bud/0/3/c/x/1/kids/app/dojo/hoon
  =/  dit  (jam %hoon dojo)
  =/  exp  (cat 9 (fil 3 64 0xff) dit)
  =/  siz=@ud  (met 13 exp)
  ^-  tang
  ::
  =/  =beam  [[~bud %$ da+now:bud] (welp /fine/hunk/1/16.384 want)]
  =/  [=mark =vase]  (need (need (scry bud %x beam)))
  =+  !<(song=(list @uxyowl) vase)
  =/   paz=(list have:ames)
    %+  spun  song
    |=  [blob=@ux num=_1]
    ^-  [have:ames _num]
    :_  +(num)
    =/  =meow:ames  (sift-meow:ames blob)
    [num meow]
  ::
  =/  num-frag=@ud  (lent paz)
  ~&  num-frag=num-frag
  =/  ror  (sift-roar:ames num-frag (flop paz))  :: XX rename
  =/   event-core
    ~!  nec
    =/   foo  [*@da *@uvJ rof.nec]
    (ev:ames:(nec foo) foo *duct ames-state.nec)
  =/  dat
    ?>  ?=(^ dat.ror)
    ;;(@ux q.dat.ror)
  ::
  ;:  welp
    (expect-eq !>(`@`dat) !>(`@`dojo))
  ::
    ^-  tang
    %-  zing
    %+  turn  paz
    |=  [fra=@ud sig=@ byts]
    %+  expect-eq
      !>(%.y)
      !>((veri-fra:keys:fi:(abed:pe:event-core ~bud) want fra dat sig))
  ::
    ~&  %verifying-sig
    %+  expect-eq
      !>(%.y)
      !>((meri:keys:fi:(abed:pe:event-core ~bud) want [sig dat]:ror))
  ==
::
++  test-old-ames-wire  ^-  tang
  =^  moves0  bud  (call bud ~[/g/hood] %spew [%odd]~)
  =^  moves1  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  =^  moves3  bud  (take bud /bone/~nec/1 ~[//unix] %g %done ~)
  %+  expect-eq
    !>  1
    !>  (lent `(list move:ames)`moves3)
::
++  test-dangling-bone  ^-  tang
  =^  moves0  bud  (call bud ~[/g/hood] %spew [%odd]~)
  ::  ~nec -> %plea -> ~bud
  ::
  =^  moves1  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  ::  ~bud receives a gift from %jael with ~nec's new rift
  ::
  =^  moves3  bud
    %-  take
    :^  bud  /public-keys  ~[//unix]
    ^-  sign:ames
    [%jael %public-keys %diff who=~nec %rift from=0 to=1]
  ::  %gall has a pending wire with the old rift, so sending a gift to
  ::  %ames on it will drop that request, not producing any moves
  ::
  =^  moves3  bud  (take bud /bone/~nec/0/1 ~[//unix] %g %done ~)
  ::
  %+  expect-eq
    !>  ~
    !>  (sy ,.moves3)
::
++  test-ames-flow-with-new-rift  ^-  tang
  ::  ~nec receives a gift from %jael with ~bud's new rift
  ::
  =^  moves1  nec
    %-  take
    :^  nec  /public-keys  ~[//unix]
    ^-  sign:ames
    [%jael %public-keys %diff who=~bud %rift from=0 to=1]
  ::  now we try a normal message flow using the new rift in the wire
  ::  ~nec -> %plea -> ~bud
  ::
  =^  moves2  nec  (call nec ~[/g/talk] %plea ~bud %g /talk [%get %post])
  =^  moves3  bud  (call bud ~[//unix] %hear (snag-packet 0 moves2))
  ::  ~bud -> %done -> ~nec
  ::
  =^  moves4  bud  (take bud /bone/~nec/1/1 ~[//unix] %g %done ~)
  =^  moves5  nec  (call nec ~[//unix] %hear (snag-packet 0 moves4))
  ::  ~bud -> %boon -> ~nec
  ::
  =^  moves6  bud  (take bud /bone/~nec/1/1 ~[//unix] %g %boon [%post '¡hola!'])
  =^  moves7  nec  (call nec ~[//unix] %hear (snag-packet 0 moves6))
  ::  ~nec -> %done -> ~bud (just make sure ~bud doesn't crash on ack)
  ::
  =^  moves8  bud  (call bud ~[//unix] %hear (snag-packet 0 moves7))
  ::
  ;:  weld
    %+  expect-eq
      !>  :~  [~[//unix] %pass /qos %d %flog %text "; ~nec is your neighbor"]
              :^  ~[//unix]  %pass  /bone/~nec/0/1
              [%g %plea ~nec %g /talk [%get %post]]
          ==
      !>  moves3
  ::
    %+  expect-eq
      !>  %-  sy
          :~  [~[/ames] %pass /pump/~bud/0 %b %rest ~1111.1.1..00.00.03]
              [~[//unix] %pass /qos %d %flog %text "; ~bud is your neighbor"]
              [~[/g/talk] %give %done error=~]
          ==
      !>  (sy ,.moves5)
  ::
    %+  expect-eq
      !>  [~[/g/talk] %give %boon [%post '¡hola!']]
      !>  (snag 0 `(list move:ames)`moves7)
  ==
::
++  test-plug  ^-  tang
  =^  moves  nec
    (call nec ~[/g/talk] %plug /foo)
  =/  expected-key
    3.782.450.905.364.316.746.465.724.430.826.633.339.627.682.402.565.789.971.442.035.627.125.517.743.962.901.817.756.764.395.497.041.697.150.935.487.420.935.470.530.023.121.462.879.251.503.082.973.208.842.762
  %-  zing
  :-  %-  expect-eq
      :_  !>(moves)
      !>  ^-  (list move:ames)
      :~  [~[/g/talk] %give %stub 1 expected-key]
      ==
  =^  moves2  bud
    (call bud ~[/g/talk] %keen `[1 expected-key] ~nec /foo/bar)
  :_  ~
  %-  expect-eq
  :_  !>(moves2)
  !>  ^-  (list move:ames)
  :~  :-  ~[/g/talk]
      :+  %pass  /fine/shut/1
      :-  %a
      :^    %keen
          sec=~
        ship=~nec
      path=/a/x/1//fine/shut/1/0v1.vvaek.7boon.0tp04.21q1h.be1i0.494an.qimof.e2fku.ern01
  ==
::
::  %ahoy tests
::
++  test-old-ames-wire-mesa  ^-  tang
  ::  turn on for verbosity
  :: =^  moves0  bud
  ::   (call bud ~[/g/hood] %spew ~[%fin %for %ges %kay %msg %odd %rcv %rot %snd %sun])
  =/  poke-plea    [%g /talk [%get %post]]
  =^  moves1       nec  (call nec ~[/g/talk] %plea ~bud poke-plea)
  =^  move-ahoy-1  nec  (call nec ~[/g/ahoy] %plea ~bud %$ /mesa-2 %ahoy ~)
  =^  move-ahoy-2  bud  (call bud ~[//unix] %hear (snag-packet 0 move-ahoy-1))
  ?>  ?=([* [^ %pass *] *] move-ahoy-2)
  =^  ack-ahoy  bud
    (call bud `duct`[/bone/~nec/0/5 //unix ~] %deep %ahoy ship=~nec bone=5)
  =^  move-ahoy-4  nec  (call nec ~[//unix] %hear (snag-packet 0 ack-ahoy))
  ::  XX assert move-ahoy-4 == [duct=[i=/g/ahoy t=~] %give p=[%done error=~]]
  ::
  =^  move-ahoy-5  nec  (call nec ~[/g/hood] %mate `~bud dry=|)
  =/  poke-roof
    (make-roof /flow/0/poke/for/~bud/1 message+!>(plea/poke-plea))
  =^  move-ahoy-6  nec
    %+  call  nec(rof poke-roof)
    :+  :+  :-  %ames  ::  added by %arvo when passing a move to %a
            /mesa/flow/ack/for/~bud/0/0
          //unix
        ~
      %moke
    (snag-moke 0 move-ahoy-5)
  =^  moves2  bud  (call bud ~[//unix] %heer (snag-push 0 move-ahoy-6))
  =^  moves3  bud  (take bud /bone/~nec/1 ~[//unix] %g %done ~)
  %+  expect-eq
    !>  1
    !>  (lent `(list move:ames)`moves3)  :: %pass %mage for the ack
::
++  test-comet-sends-mesa
  ::  turn on for verbosity
  ::
  :: =^  moves0  bud
  ::   (call bud ~[/g/hood] %spew ~[%fin %for %ges %kay %msg %odd %rcv %rot %snd %sun])
  ::  load %mesa core into the comet
  ::
  =^  moves1  comet  (call comet ~[/hood] %load %mesa)
  ::  send a %mesa packet to bud that has %ames as the default core
  ::
  =/  poke-plea  [%g /talk [%get %post]]
  =^  moves1  comet  (call comet ~[/g/talk] %plea ~bud poke-plea)
  =/  poke-roof
    (make-roof /flow/0/poke/for/~bud/1 message+!>(plea/poke-plea))
  =^  moves2  comet
    %+  call  comet(rof poke-roof)
    :+  :+  :-  %ames  ::  added by %arvo when passing a move to %a
            /mesa/flow/ack/for/~bud/0/0
          //unix
        ~
      %moke
    (snag-moke 0 moves1)
  =/  comet-roof
    (make-roof /(scot %p our-comet) noun+!>(~[0]))
  =^  moves2  bud
    (call bud(rof comet-roof) ~[//unix] %heer (snag-push 0 moves2))
  =/  [=lane:pact:ames blob=@]  (snag-push 0 moves2)
  =/  =pact:pact:ames
    :-  hop=0
    :-  %peek
    :+  [her=~bosrym-podwyl-magnes-dacrys--pander-hablep-masrym-marbud rif=0]
      [boq=13 wan=~]
    pat=/publ/1/a/x/1//pawn/proof/~bud/3
  %+  expect-eq
    !>  pact
    !>  (parse-packet:bud blob)  :: %pass %peek for the attestation
::
++  test-comet-sends-ames
  ::  turn on for verbosity
  ::
  =^  moves0  bud
    (call bud ~[/g/hood] %spew ~[%fin %for %ges %kay %msg %odd %rcv %rot %snd %sun])
  ::  load %mesa core into the comet
  ::
  =^  moves1  bud  (call bud ~[/hood] %load %mesa)
  =.  peers.ames-state.comet  (~(del by peers.ames-state.bud) our-comet)
  =.  chums.ames-state.bud
    %+  ~(put by chums.ames-state.bud)  our-comet
    [%alien *ovni-state:ames]
  =.  chums.ames-state.comet  (~(del by chums.ames-state.comet) ~bud)
  =.  peers.ames-state.comet
    %+  ~(put by peers.ames-state.comet)  ~bud
    =|  =peer-state:ames
    =.  -.peer-state
      :*  symmetric-key=bud-comet-sym
          life=3
          rift=0
          [public-keys=pub.saf pass=pass]:ames-state.bud
          sponsor=~bud
          fief=~
      ==
    =.  route.peer-state  `[direct=%.y `lane:ames`[%& `@`~bud]]
    [%known peer-state]
  ::  send a %ames packet to bud that has %mesa as the default core
  ::
  =/  poke-plea  [%g /talk [%get %post]]
  =^  moves1  comet  (call comet ~[/g/talk] %plea ~bud poke-plea)
  ::  drop packet, move .chum to .peer, and enqueue %ahoy $plea
  ::
  =^  moves2  bud  (call bud ~[//unix] %hear (snag-packet 0 moves1))
  =/  ahoy-plea  ahoy-prob/!>(our-comet^force-test=|)
  %+  weld
    %+  expect-eq
      +:ahoy-plea
    +:(snag-ahoy 0 moves2)
  %+  expect-eq
    !>  &
    !>  (~(has by peers.ames-state.bud) our-comet)
::  XX this wouldn't happen for comets since they don't breach
::
++  test-comet-bunt-sends-ames
  ::  turn on for verbosity
  ::
  =^  moves0  bud
    (call bud ~[/g/hood] %spew ~[%fin %for %ges %kay %msg %odd %rcv %rot %snd %sun])
  ::  load %mesa core into the comet
  ::
  =^  moves1  bud  (call bud ~[/hood] %load %mesa)
  =.  peers.ames-state.comet  (~(del by peers.ames-state.bud) our-comet)
  =/  crypto-core
    %-  nol:nu:cric:crypto
    0w9N.5uIvA.Jg0cx.NCD2R.o~MtZ.uEQOB.9uTbp.6LHvg.0yYTP.
    3q3td.T4UF0.d5sDL.JGpZq.S3A92.QUuWg.IHdw7.izyny.j9W92
  =.  chums.ames-state.bud
    %+  ~(put by chums.ames-state.bud)  our-comet
    :+  %known
      :*  symmetric-key=bud-comet-sym
          life=1
          rift=0
          [public-keys=pub.saf pass=pass]:ames-state.comet
          sponsor=~bud
          fief=~
      ==
    +:*fren-state:ames
  =.  chums.ames-state.comet  (~(del by chums.ames-state.comet) ~bud)
  =.  peers.ames-state.comet
    %+  ~(put by peers.ames-state.comet)  ~bud
    =|  =peer-state:ames
    =.  -.peer-state
      :*  symmetric-key=bud-comet-sym
          life=3
          rift=0
          [public-keys=pub.saf pass=pass]:ames-state.bud
          sponsor=~bud
          fief=~
      ==
    =.  route.peer-state  `[direct=%.y `lane:ames`[%& `@`~bud]]
    [%known peer-state]
  ::  send a %ames packet to bud that has %mesa as the default core
  ::
  =/  poke-plea  [%g /talk [%get %post]]
  =^  moves1  comet  (call comet ~[/g/talk] %plea ~bud poke-plea)
  ::  inject plea packet, move .chum to .peer, and enqueue %ahoy $plea
  ::
  =^  moves2  bud    (call bud ~[//unix] %hear (snag-packet 0 moves1))
  =/  ahoy-plea  ahoy-prob/!>(our-comet^force-test=|)
  =/  gall-plea  [our-comet poke-plea]
  ;:  weld
    %+  expect-eq
      +:ahoy-plea
    +:(snag-ahoy 0 moves2)
  ::
    %+  expect-eq
      !>  gall-plea
    !>  (snag-plea 0 moves2)
  ::
    %+  expect-eq
      !>  &
      !>  (~(has by peers.ames-state.bud) our-comet)
  ::
  ==
::  additive %snub (decisions-addendum section 9): %set replaces the
::  list wholesale, while %add/%del edit it in place without clobbering
::  a manually-curated blocklist.  see +sy-snub.
::
++  test-snub-set-replaces  ^-  tang
  ::  %set replaces both mode and list wholesale
  ::
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev ~rus]])
  =^  m2  nec  (call nec ~[//unix] [%snub %allow %set ~[~fed]])
  (expect-eq !>([%allow (silt ~[~fed])]) !>(snub.ames-state.nec))
::
++  test-snub-add-preserves-manual  ^-  tang
  ::  a manual deny list must survive an additive add (no clobber)
  ::
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev ~rus]])
  =^  m2  nec  (call nec ~[//unix] [%snub %deny %add ~[~fed]])
  (expect-eq !>([%deny (silt ~[~dev ~rus ~fed])]) !>(snub.ames-state.nec))
::
++  test-snub-del-removes  ^-  tang
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev ~rus ~fed]])
  =^  m2  nec  (call nec ~[//unix] [%snub %deny %del ~[~dev]])
  (expect-eq !>([%deny (silt ~[~rus ~fed])]) !>(snub.ames-state.nec))
::
++  test-snub-mode-mismatch  ^-  tang
  ::  against a %deny list, an %allow %add unblocks (set-difference) and
  ::  an %allow %del blocks (set-union); the list stays in %deny mode.
  ::
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev ~rus]])
  =^  m2  nec  (call nec ~[//unix] [%snub %allow %add ~[~dev]])
  =/  after-add  snub.ames-state.nec
  =^  m3  nec  (call nec ~[//unix] [%snub %allow %del ~[~fed]])
  ;:  weld
    (expect-eq !>([%deny (silt ~[~rus])]) !>(after-add))
    (expect-eq !>([%deny (silt ~[~rus ~fed])]) !>(snub.ames-state.nec))
  ==
::  %stale writ-result (decisions-addendum section 3): a %known peer
::  whose on-chain attestation goes stale is DEMOTED to a fresh %alien
::  (empty agenda), never deleted, and nothing is snubbed.  an already
::  %alien peer is left untouched.  see +sy-sybl.
::
++  test-stale-demotes-known-to-alien  ^-  tang
  =/  snub-before  snub.ames-state.nec
  =^  moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %stale %test-dom ~bud])
  ;:  weld
    ::  ~bud demoted to a fresh alien, not deleted
    ::
    %+  expect-eq
      !>  `[%alien *alien-agenda:ames]
    !>  (~(get by peers.ames-state.nec) ~bud)
    ::  still a known-of ship
    ::
    (expect-eq !>(&) !>((~(has by peers.ames-state.nec) ~bud)))
    ::  staleness is not fraud: the blocklist is untouched
    ::
    (expect-eq !>(snub-before) !>(snub.ames-state.nec))
    ::  no cards emitted (no pump timers to cancel, no snub)
    ::
    (expect-eq !>(~) !>(moves))
  ==
::
++  test-stale-leaves-alien-untouched  ^-  tang
  ::  bud holds our-comet as an %alien; a stale notice is a no-op.
  ::
  =/  before  peers.ames-state.bud
  =/  snub-before  snub.ames-state.bud
  =^  moves  bud
    (take bud /sybl ~[/ames] [%jael %sybl %stale %test-dom our-comet])
  ;:  weld
    (expect-eq !>(before) !>(peers.ames-state.bud))
    (expect-eq !>(snub-before) !>(snub.ames-state.bud))
    (expect-eq !>(~) !>(moves))
  ==
::  A whole POINT carrying a fief must push that fief to the runtime,
::  the way an incremental [%diff @ %fief *] does (+on-publ-fief).
::
::    Only the diff used to, so a route learned from a confidential
::    comet's %writ verdict -- which arrives as [%sybl %full] and lands
::    in +on-publ-full -- was stored in jael, reported by /pynt, and
::    never routed to.  A domain whose identities are confidential
::    publishes no udiffs for them, so the verdict is the ONLY carrier
::    they have and this was all of it.
::
++  test-publ-full-pushes-the-fief  ^-  tang
  =/  fef=fief  [%if .206.189.188.16 49.818]
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-peer') %b ~)
  =/  =sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=`fef
    ==
  =.  unix-duct.ames-state.nec  ~[//newt/0v1n]
  =^  moves  nec  (take nec /sybl ~[/ames] sign)
  =/  want=move:ames
    [~[//newt/0v1n] %give %fief (my [our-comet `fef]~)]
  =/  ms=(list move:ames)  moves
  =/  found=?
    |-  ^-  ?
    ?~  ms  %.n
    ?:  =(i.ms want)  %.y
    $(ms t.ms)
  (expect !>(found))
::
++  test-publ-full-without-a-fief-pushes-nothing  ^-  tang
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-peer2') %b ~)
  =/  =sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet2
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  =.  unix-duct.ames-state.nec  ~[//newt/0v1n]
  =^  moves  nec  (take nec /sybl ~[/ames] sign)
  =/  ms=(list move:ames)  moves
  =/  found=?
    |-  ^-  ?
    ?~  ms  %.n
    ?:  ?=([* %give %fief *] i.ms)  %.y
    $(ms t.ms)
  (expect !>(!found))
::  A packet whose payload is not a well-formed, bounded
::  (jam [signature=@ signed=@]) must be classified WITHOUT calling +cue.
::
::    +cue bails %meme on a backreference index that does not fit in a
::    direct atom, and %meme escapes +mole -- the runtime re-raises any
::    non-%exit ball out of the virtualization frame -- so the whole
::    event dies.  A $shut-packet's SIV ciphertext is pseudorandom and
::    roughly one packet in 500 is such a bomb; because AES-SIV is
::    deterministic the sender then retransmits the identical bytes
::    forever.  Live on mainnet that permanently livelocked two healthy,
::    mutually-attested comets.  The atom below is the real payload of
::    the packet that did it, captured off the wire.
::
++  test-is-open-packet-rejects-a-cue-bomb  ^-  tang
  =/  bomb=@
    0x5f71.d5ce.9153.a875.20f8.fc95.b1d8.533e.3734.3386.
      fc4f.6993.3ba9.766a.001c.9e5d.a8bf.e4e2.4690.aaaf.
      e503.17b8.6203
  ::  a bare backreference: tag %11, then a +mat-encoded 88-bit index
  ::
  =/  synthetic=@
    (can 0 ~[[2 0b11] [8 0b1000.0000] [88 0x11.2233.4455.6677.8899.aabb]])
  ;:  weld
    (expect !>(!(open-jam-shaped:ames bomb)))
    (expect !>(!(open-jam-shaped:ames synthetic)))
    ::  and random-looking ciphertext of assorted lengths is rejected too
    ::
    =/  ns=(list @ud)  (gulf 1 64)
    =/  clean=?
      |-  ^-  ?
      ?~  ns  %.y
      ?:  (open-jam-shaped:ames (shaz (add 0xdead.0000 i.ns)))  %.n
      $(ns t.ns)
    (expect !>(clean))
  ==
::
++  test-is-open-packet-accepts-a-real-attestation  ^-  tang
  ::  the shape +etch-open-packet actually produces: (jam [@ @])
  ::
  ;:  weld
    (expect !>((open-jam-shaped:ames (jam [(shaz 'sig') (shaz 'signed')]))))
    (expect !>((open-jam-shaped:ames (jam [0 0]))))
    ::  ... and nothing else: an atom, a 3-tuple, or trailing bytes
    ::
    (expect !>(!(open-jam-shaped:ames (jam 42))))
    (expect !>(!(open-jam-shaped:ames (jam [1 2 3]))))
    (expect !>(!(open-jam-shaped:ames (lsh [0 1] (jam [1 2])))))
  ==
::  +on-hear-packet routes a comet's packet by SHAPE, and drops what it
::  cannot route.  Four cases, and the obvious fixes break one of them:
::
::    1. unknown comet + valid attestation -> +on-hear-open.  this is
::       the whole comet onboarding path, and the regression a careless
::       fix causes.
::    2. known comet + re-attestation -> +on-hear-open.  a comet
::       re-attests while its domain verifier is still deciding, and a
::       suite-%c comet re-attests at every new life, so attestations
::       do arrive from peers we have already promoted.  routing one to
::       +on-hear-shut feeds plaintext to AES-SIV, which bails %evil;
::       that livelocked two healthy mainnet comets for six hours.
::    3. known comet + $shut-packet -> +on-hear-shut.
::    4. unknown comet + anything else -> DROPPED.  .sndr is
::       unauthenticated and the comet space is 2^128, so "a comet we
::       have never seen" is a label any attacker can wear.  routing on
::       that alone -- as this used to -- handed arbitrary bytes to the
::       bare +cue in +sift-open-packet: one un-catchable %meme bail
::       per packet, pre-auth, with no per-sender state to rate-limit
::       against.
::
::    Note how case 4 fails if it regresses: %meme escapes +mole and
::    +mule, so the test thread CRASHES rather than reporting FAILED.
::
++  test-hear-attestation-from-unknown-comet  ^-  tang
  ::  case 1: first contact.  ~nec has never seen .our-comet, and this
  ::  is a genuine, correctly signed self-attestation.
  ::
  =/  =open-packet:ames
    :*  pass=pass.ames-state.comet
        sndr=our-comet
        sndr-life=1
        rcvr=~nec
        rcvr-life=2
    ==
  =/  =blob:ames  (attestation open-packet saf.ames-state.comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~)) ~[//unix] %hear [%& ~marbud] blob)
  ::  it reached +on-hear-open and the comet was promoted
  ::
  %+  expect-eq
    !>  %.y
  !>  ?=([~ %known *] (~(get by peers.ames-state.nec) our-comet))
::
++  test-hear-reattestation-from-known-comet  ^-  tang
  ::  case 2: ~nec already knows .our-comet at life 1 and it attests
  ::  again.  +on-hear-open recognises the duplicate and ignores it;
  ::  +on-hear-shut would bail %evil on the plaintext.  so simply
  ::  arriving here, with the peer intact, is the assertion.
  ::
  =/  nec-comet-sym
    (derive-symmetric-key:ames pub.saf.ames-state.comet sek.saf.ames-state.nec)
  =.  peers.ames-state.nec
    %+  ~(put by peers.ames-state.nec)  our-comet
    (known-comet nec-comet-sym 1 comet)
  =/  =open-packet:ames
    :*  pass=pass.ames-state.comet
        sndr=our-comet
        sndr-life=1
        rcvr=~nec
        rcvr-life=2
    ==
  =/  =blob:ames  (attestation open-packet saf.ames-state.comet)
  =^  moves  nec
    (call nec(rof (pki-roof `1)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    %+  expect-eq  !>(0)  !>((lent moves))
  ::
    %+  expect-eq
      !>  %.y
    !>  ?=([~ %known *] (~(get by peers.ames-state.nec) our-comet))
  ==
::
++  test-hear-shut-packet-from-known-comet  ^-  tang
  ::  case 3: a comet we know sends real traffic.  it must reach the
  ::  decrypter, not the attestation path.
  ::
  =/  nec-comet-sym
    (derive-symmetric-key:ames pub.saf.ames-state.comet sek.saf.ames-state.nec)
  =/  comet-nec-sym
    (derive-symmetric-key:ames pub.saf.ames-state.nec sek.saf.ames-state.comet)
  =.  peers.ames-state.comet
    %+  ~(put by peers.ames-state.comet)  ~nec
    =|  =peer-state:ames
    =.  -.peer-state
      :*  symmetric-key=comet-nec-sym
          life=2
          rift=0
          [public-keys=pub.saf pass=pass]:ames-state.nec
          sponsor=~nec
          fief=~
      ==
    =.  route.peer-state  `[direct=%.y `lane:ames`[%& ~nec]]
    [%known peer-state]
  =.  peers.ames-state.nec
    %+  ~(put by peers.ames-state.nec)  our-comet
    (known-comet nec-comet-sym 1 comet)
  =/  poke-plea  [%g /talk [%get %post]]
  =^  moves1  comet  (call comet ~[/g/talk] %plea ~nec poke-plea)
  =^  moves2  nec
    (call nec(rof (pki-roof `1)) ~[//unix] %hear (snag-packet 0 moves1))
  ::  ~nec decrypted it and handed the $plea up to gall
  ::
  %+  expect-eq
    !>  [our-comet poke-plea]
  !>  (snag-plea 0 moves2)
::
++  test-hear-drops-unroutable-comet-packet  ^-  tang
  ::  case 4: the attack.  .sndr is spoofed as a comet ~nec has never
  ::  seen, and the payload is the real mainnet packet that %meme
  ::  bombed +cue (see +test-is-open-packet-rejects-a-cue-bomb).
  ::
  =/  bomb=@
    0x5f71.d5ce.9153.a875.20f8.fc95.b1d8.533e.3734.3386.
      fc4f.6993.3ba9.766a.001c.9e5d.a8bf.e4e2.4690.aaaf.
      e503.17b8.6203
  =/  spoof
    |=  cot=@
    ^-  blob:ames
    %-  etch-shot:ames
    :*  [sndr=our-comet2 rcvr=~nec]
        req=&  sam=&
        sndr-tick=0b1
        rcvr-tick=0b10
        origin=~
        content=cot
    ==
  =^  moves1  nec
    (call nec(rof (pki-roof ~)) ~[//unix] %hear [%& ~marbud] (spoof bomb))
  ::  and a payload that IS jam-shaped, but decodes to nothing that
  ::  names the sender -- the guard is not just +open-jam-shaped
  ::
  =^  moves2  nec
    (call nec(rof (pki-roof ~)) ~[//unix] %hear [%& ~marbud] (spoof (jam [0 0])))
  ;:  weld
    ::  the event survived both, and answered neither
    ::
    %+  expect-eq  !>(0)  !>((lent moves1))
    %+  expect-eq  !>(0)  !>((lent moves2))
    ::  and no per-ship state was allocated for the spoofed sender
    ::
    %+  expect-eq
      !>  %.n
    !>  (~(has by peers.ames-state.nec) our-comet2)
  ==
--
