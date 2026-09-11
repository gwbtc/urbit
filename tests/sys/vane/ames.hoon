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
::  a confidential (suite-%c) comet.
::
::    +al-take-proof hands a suite-%c attestation to jael as a %writ
::    rather than registering it locally, so the %writ is the visible
::    sign that a %page reached it.  the tweak's .dat is where
::    +pass-pki-dom reads the committed domain from: a +mat-encoded
::    @tas, which +pit:nu mats a second time on the way in.
::
=/  cc-core  (pit:nu:cric:crypto 512 (shaz 'cc-comet') %c q:(mat %gw-btc))
=/  cc-comet  `@p`fig:ex:cc-core
=/  cc-life2-ring
  ::  Preserve the life-1 ring's immutable public genesis key and .dat,
  ::  but replace its current 32-byte seed.  The resulting core must have
  ::  the same @p and a different live signing/ECDH key.
  ::
  (sew 3 [1 32 (shaz 'cc-comet-life-2')] sec:ex:cc-core)
=/  cc-life2-core  (nol:nu:cric:crypto cc-life2-ring)
=/  cc-mat-dat  (mat q:(mat %gw-btc))
=/  cc-life2-refreshed-ring
  (add cc-life2-ring (lsh [0 (add 520 p.cc-mat-dat)] 0x1234))
=/  cc-life2-refreshed-core
  (nol:nu:cric:crypto cc-life2-refreshed-ring)
=/  cc-life3-ring
  (sew 3 [1 32 (shaz 'cc-comet-life-3')] sec:ex:cc-core)
=/  cc-life3-core  (nol:nu:cric:crypto cc-life3-ring)
=/  cc  ^$:(%*($ ames ahoy-on %.n, +< cc-comet))
=.  now.cc        ~1111.1.1
=.  eny.cc        `@uvJ`0xfeed.face
=.  life.ames-state.cc  1
=.  rift.ames-state.cc  0
=.  rof.cc  |=(* ``[%noun !>(*(list turf))])
=.  saf.ames-state.cc   saf:ex:cc-core
=.  ring.ames-state.cc  sec:ex:cc-core
=.  pass.ames-state.cc  pub:ex:cc-core
::  a second-life instance of the same suite-%c identity, used to prove
::  that routing keys change without changing the sender name.
::
=/  cc-life2  cc
=.  eny.cc-life2        `@uvJ`0xfeed.f00d
=.  life.ames-state.cc-life2  2
=.  saf.ames-state.cc-life2   saf:ex:cc-life2-core
=.  ring.ames-state.cc-life2  sec:ex:cc-life2-core
=.  pass.ames-state.cc-life2  pub:ex:cc-life2-core
::  A second suite-C identity lets the recovery test put both endpoints
::  through the same rotation at once, rather than using a conventional ship
::  whose current life is available from Azimuth.
::
=/  cd-core  (pit:nu:cric:crypto 512 (shaz 'cd-comet') %c q:(mat %gw-btc))
=/  cd-comet  `@p`fig:ex:cd-core
=/  cd-life2-ring
  (sew 3 [1 32 (shaz 'cd-comet-life-2')] sec:ex:cd-core)
=/  cd-life2-core  (nol:nu:cric:crypto cd-life2-ring)
=/  cd-life3-ring
  (sew 3 [1 32 (shaz 'cd-comet-life-3')] sec:ex:cd-core)
=/  cd-life3-core  (nol:nu:cric:crypto cd-life3-ring)
=/  cd  ^$:(%*($ ames ahoy-on %.n, +< cd-comet))
=.  now.cd        ~1111.1.1
=.  eny.cd        `@uvJ`0xcafe.face
=.  life.ames-state.cd  1
=.  rift.ames-state.cd  0
=.  rof.cd  |=(* ``[%noun !>(*(list turf))])
=.  saf.ames-state.cd   saf:ex:cd-core
=.  ring.ames-state.cd  sec:ex:cd-core
=.  pass.ames-state.cd  pub:ex:cd-core
=/  cd-life2  cd
=.  eny.cd-life2        `@uvJ`0xcafe.f002
=.  life.ames-state.cd-life2  2
=.  saf.ames-state.cd-life2   saf:ex:cd-life2-core
=.  ring.ames-state.cd-life2  sec:ex:cd-life2-core
=.  pass.ames-state.cd-life2  pub:ex:cd-life2-core
::  an intentionally misnamed suite-%c signer.  Its packet and Mesa
::  page consistently claim .our-comet, but carry .cc-comet's pass and
::  are signed by .cc-comet's live key.  This isolates the immutable
::  name-binding check from signature and packet-consistency checks.
::
=/  cc-misnamed  ^$:(%*($ ames ahoy-on %.n, +< our-comet))
=.  now.cc-misnamed        ~1111.1.1
=.  eny.cc-misnamed        `@uvJ`0xfeed.bad0
=.  life.ames-state.cc-misnamed  1
=.  rift.ames-state.cc-misnamed  0
=.  rof.cc-misnamed  |=(* ``[%noun !>(*(list turf))])
=.  saf.ames-state.cc-misnamed   saf:ex:cc-core
=.  ring.ames-state.cc-misnamed  sec:ex:cc-core
=.  pass.ames-state.cc-misnamed  pub:ex:cc-core
::
=/  cc-nec-sym
  (derive-symmetric-key:ames pub.saf.ames-state.nec sek.saf.ames-state.cc)
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
::  .cc knows ~nec, so +co-make-page will serve it a page; ~nec holds
::  .cc-comet as an alien chum, which is the state +pe-heer's %page
::  branch routes to +al-take-proof.
::
=.  chums.ames-state.cc
  %+  ~(put by chums.ames-state.cc)  ~nec
  =|  =fren-state:ames
  =.  -.fren-state
    :*  symmetric-key=cc-nec-sym
        life=2
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.nec
        sponsor=~nec
        fief=~
    ==
  =.  lane.fren-state  `[hop=0 `lane:pact:ames``@`~nec]
  [%known fren-state]
::  the life-2 signer serves the same proof path with the same peer setup.
::
=.  chums.ames-state.cc-life2  chums.ames-state.cc
::  the misnamed signer also needs a real recipient relationship in
::  order for %mage to construct and sign a page.
::
=.  chums.ames-state.cc-misnamed  chums.ames-state.cc
::
=.  chums.ames-state.nec
  %+  ~(put by chums.ames-state.nec)  cc-comet
  [%alien *ovni-state:ames]
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
=>  .(cc +:(call:(cc) ~[//unix] ~ %born ~))
=>  .(cc-life2 +:(call:(cc-life2) ~[//unix] ~ %born ~))
=>  .(cd-life2 +:(call:(cd-life2) ~[//unix] ~ %born ~))
=>  .(cc-misnamed +:(call:(cc-misnamed) ~[//unix] ~ %born ~))
::  |ames as the default network core
::
=>  .(nec +:(call:(nec) ~[//unix] ~ %load %ames))
=>  .(bud +:(call:(bud) ~[//unix] ~ %load %ames))
=>  .(comet +:(call:(comet) ~[//unix] ~ %load %ames))
=>  .(comet2 +:(call:(comet2) ~[//unix] ~ %load %ames))
=>  .(cc +:(call:(cc) ~[//unix] ~ %load %ames))
=>  .(cc-life2 +:(call:(cc-life2) ~[//unix] ~ %load %ames))
=>  .(cd-life2 +:(call:(cd-life2) ~[//unix] ~ %load %ames))
=>  .(cc-misnamed +:(call:(cc-misnamed) ~[//unix] ~ %load %ames))
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
++  is-move-writ
  ::  the attestation +al-take-proof forwards to jael for a suite-%c
  ::  comet it does not already know.
  ::
  |=  =move:ames
  ^-  ?
  ?=([%pass [%writ ~] %j %writ *] card.move)
::
++  count-writs
  |=  moves=(list move:ames)
  ^-  @ud
  (lent (skim moves is-move-writ))
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
  ::  the three jael scries a suite-%c self-attestation makes: who
  ::  sponsors the comet, whether an agent serves its domain, and what
  ::  life jael already knows for it.  +dose is deliberately richer
  ::  than a boolean so the tests can distinguish an unregistered domain
  ::  from a registered-but-suspended one, and can prove that malformed
  ::  scry data fails closed.  every other scry keeps the fixtures'
  ::  `(list turf)` stub.
  ::
  |=  [lyf=(unit @ud) dose=?(%unregistered %live %suspended %malformed)]
  ^-  roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?.  =(vis %j)
    ``noun+!>(*(list turf))
  ?+  q.bem  ``noun+!>(*(list turf))
    %sein  ``noun+!>(`ship`~marbud)
    %lyfe  ``noun+!>(lyf)
    %dose
      ?-  dose
        %unregistered  ``noun+!>(`(unit ?)`~)
        %live          ``noun+!>(`(unit ?)`[~ %.y])
        %suspended     ``noun+!>(`(unit ?)`[~ %.n])
        %malformed     ``noun+!>(%not-a-dose)
      ==
  ==
::
++  pki-roof-with-sein
  ::  Override the sponsorship scry while retaining the requested
  ::  domain state, for transport-parity admission tests.
  ::
  |=  [lyf=(unit @ud) dose=?(%unregistered %live %suspended %malformed) sponsor=ship]
  ^-  roof
  =/  base  (pki-roof lyf dose)
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?:  &(=(vis %j) =(%sein q.bem))
    ``noun+!>(sponsor)
  (base lyc pov vis bem)
::
++  saxo-roof
  ::  Give route setup a non-empty sponsor list for an alien |mesa chum.
  ::  The default fixture roof returns an empty list, on which +rear bails.
  ::
  ^-  roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?:  &(=(vis %j) =(%saxo q.bem))
    ``noun+!>(`(list ship)`~[~marbud])
  ``noun+!>(*(list turf))
::
++  sein-roof
  ::  a roof whose +sein answers from .sponsors, so a routing test can
  ::  lay out a real sponsorship chain.  the fixtures' stub roof answers
  ::  every scry with a `(list turf)`, which +sein reads as ~zod, and
  ::  +send-blob-via only relays through a hop that sponsors itself.
  ::  a ship absent from .sponsors sponsors itself.
  ::
  |=  sponsors=(map ship ship)
  ^-  roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?.  ?&  =(vis %j)
          =(%sein q.bem)
          ?=([@ ~] s.bem)
      ==
    ``noun+!>(*(list turf))
  =/  who=ship  (slav %p i.s.bem)
  ``noun+!>(`ship`(~(gut by sponsors) who who))
::
++  peer-route
  ::  .her's route as ames holds it, ~ if we do not know .her
  ::
  |=  [vane=_nec her=ship]
  ^-  (unit [direct=? =lane:ames])
  =/  per  (~(get by peers.ames-state.vane) her)
  ?.  ?=([~ %known *] per)  ~
  route.u.per
::
++  send-lanes
  ::  every lane a batch of moves fires a packet at
  ::
  |=  moves=(list move:ames)
  ^-  (list lane:ames)
  %+  turn  (skim moves is-move-send)
  |=  =move:ames
  ^-  lane:ames
  lane:(move-to-packet move)
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
++  known-chum
  ::  |mesa state for a comet we have already promoted
  ::
  |=  [=symmetric-key:ames lyf=@ud comet=_comet]
  ^-  chum-state:ames
  =|  =fren-state:ames
  =.  -.fren-state
    :*  symmetric-key=symmetric-key
        life=lyf
        rift=0
        [public-keys=pub.saf pass=pass]:ames-state.comet
        sponsor=~marbud
        fief=~
    ==
  =.  lane.fren-state  `[hop=0 `lane:pact:ames``@`cc-comet]
  [%known fren-state]
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
::
++  cue-bomb
  ::  A root jam backreference whose 88-bit cursor cannot be represented
  ::  by +cue's direct-atom index.  Peer-controlled uses must reject it
  ::  structurally, before asking +cue to allocate or follow the cursor.
  ::
  ^-  @
  (can 0 ~[[2 0b11] [8 0b1000.0000] [88 0x11.2233.4455.6677.8899.aabb]])
::
++  pact-to-blob
  |=  =pact:pact:ames
  ^-  blob:ames
  p:(fax:plot (en:pact:ames pact))
::
++  cc-attestation-at
  |=  [sender=_cc claimed=ship lyf=@ud]
  (cc-attestation-for sender claimed lyf ~nec 2)
::
++  cc-attestation-for
  |=  [sender=_cc claimed=ship lyf=@ud rcvr=ship rcvr-life=@ud]
  ^-  blob:ames
  %-  attestation
  :*  [pass.ames-state.sender claimed lyf rcvr rcvr-life]
      saf.ames-state.sender
  ==
::
++  cc-proof-push
  (cc-proof-push-at cc cc-comet 1 pass.ames-state.cc)
::
++  cc-life2-proof-push
  (cc-proof-push-at cc-life2 cc-comet 2 pass.ames-state.cc-life2)
::
++  cc-misnamed-proof-push
  (cc-proof-push-at cc-misnamed our-comet 1 pass.ames-state.cc-misnamed)
::
++  cc-malformed-proof-push
  ::  The outer page is genuine and signed, but the embedded suite-%c
  ::  pass is deliberately too short to carry even its domain +mat.
  ::
  (cc-proof-push-at cc cc-comet 1 'c')
::
++  cc-malformed-inner-proof-push
  ::  A genuine proof page whose outer gage advertises %open-packet but
  ::  whose payload cannot be cast to $open-packet.
  ::
  (cc-proof-push-with cc !>(42))
::
++  cc-proof-push-at
  ::  the %page a suite-%c vane pushes when ~nec peeks for its
  ::  self-attestation:
  ::  a real signed suite-%c proof, built by the vane that signs it
  ::  rather than assembled by hand, so the receiver's checks in
  ::  +al-take-proof all have something genuine to verify.
  ::
  |=  [sender=_cc claimed=ship lyf=@ud =pass]
  ^-  [lane:pact:ames blob:ames]
  =/  =open-packet:ames  [pass claimed lyf ~nec 2]
  (cc-proof-push-with sender !>(open-packet))
::
++  cc-proof-push-with
  |=  [sender=_cc payload=vase]
  ^-  [lane:pact:ames blob:ames]
  ::  `%publ 1` and `/proof/1` deliberately mirror +al-peek-proof:
  ::  that namespace coordinate is fixed even after the sender rotates.
  ::  The current sender life is carried inside the signed open packet.
  ::
  =/  proof-path=path
    /a/x/1//pawn/proof/1/[(scot %p ~nec)]/[(scot %ud 2)]
  ::  the two scries %mage makes outside the vane.
  ::
  ::    +get-sponsor asks jael who sponsors the recipient.  the
  ::    fixtures' stub roof answers every scry with a (list turf),
  ::    which it reads as an empty (list ship) and +rear bails on.
  ::
  ::    +peek-publ fetches the page's contents back through %ames as
  ::    an ordinary %ax scry, and signs what comes back.  on a live
  ::    ship that lands in +peek-pawn; a vane gate in a test has no
  ::    arvo under it to route through, so answer with the
  ::    $open-packet +peek-pawn would have built.
  ::
  =/  cc-roof=roof
    |=  [lyc=gang pov=path vis=view bem=beam]
    ^-  (unit (unit cage))
    ?:  &(=(vis %j) =(%saxo q.bem))
      ``noun+!>(`(list ship)`~[~nec])
    ?:  ?=([%pawn %proof *] s.bem)
      ``[%open-packet payload]
    [~ ~]
  ::  %mage only answers a duct from %ames itself
  ::
  =^  moves  sender
    (call sender(rof cc-roof) ~[/ames] [%mage [%publ 1] ~nec proof-path])
  (snag-push 0 moves)
::
++  cc-life2-proof-poke
  ::  The other established proof carrier: +al-poke-proof answers an
  ::  existing |mesa request with a %poke whose ack and payload paths
  ::  cross-bind both ships and lives.  Build it through %moke so the
  ::  packet, page hash, and signature are all genuine.
  ::
  ^-  [lane:pact:ames blob:ames]
  =/  poof-path=path
    :~  %pawn  %proof
        (scot %ud 2)
        (scot %p ~nec)
        (scot %ud 2)
    ==
  =/  mut-path=path
    :~  %a  %x  %'1'  %$  %muth
        (scot %ud 2)
        (scot %p cc-comet)
        (scot %ud 2)
    ==
  =/  poke-path=path
    :*  %a  %x  %'1'  %$
        poof-path
    ==
  =/  proof-roof=roof
    =/  =open-packet:ames
      [pass.ames-state.cc-life2 cc-comet 2 ~nec 2]
    |=  [lyc=gang pov=path vis=view bem=beam]
    ^-  (unit (unit cage))
    ?:  &(=(vis %j) =(%saxo q.bem))
      ``noun+!>(`(list ship)`~[~nec])
    ?:  ?=([%pawn %proof *] s.bem)
      ``[%open-packet !>(open-packet)]
    [~ ~]
  =^  moves  cc-life2
    %:  call
      cc-life2(rof proof-roof)
      ~[/ames]
      [%moke [%publ 2] [~nec mut-path] poke-path]
    ==
  (snag-push 0 moves)
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
++  test-suite-c-life-key-model  ^-  tang
  =/  one  cc-core
  =/  two  cc-life2-core
  ?>  ?=(%c suite.+<.one)
  ?>  ?=(%c suite.+<.two)
  =/  one-keys  ded:ex:one
  =/  two-keys  ded:ex:two
  =/  msg  (jam [%cc-life-key-model cc-comet])
  =/  one-sig  (sigh:as:one msg)
  =/  two-sig  (sigh:as:two msg)
  =/  two-nec-sym
    (derive-symmetric-key:ames pub.saf.ames-state.nec sek.saf.ames-state.cc-life2)
  ;:  weld
    ::  the immutable name and genesis commitment survive rotation
    ::
    (expect-eq !>(cc-comet) !>(`@p`fig:ex:one))
    (expect-eq !>(fig:ex:one) !>(fig:ex:two))
    (expect-eq !>(ugn.tw.pub.+<.one) !>(ugn.tw.pub.+<.two))
    (expect-eq !>(dat.tw.pub.+<.one) !>(dat.tw.pub.+<.two))
    ::  life 1 is the compatibility key; life 2 is genuinely rotated
    ::
    (expect-eq !>(ugn.tw.pub.+<.one) !>(cry.pub.+<.one))
    (expect !>(!=(ugn.tw.pub.+<.two cry.pub.+<.two)))
    (expect-eq !>(-.one-keys) !>(+.one-keys))
    (expect-eq !>(-.two-keys) !>(+.two-keys))
    (expect !>(!=(-.one-keys -.two-keys)))
    ::  signatures and channel agreement both use the current-life key
    ::
    (expect !>((safe:as:one one-sig msg)))
    (expect !>(!(safe:as:two one-sig msg)))
    (expect !>((safe:as:two two-sig msg)))
    (expect !>(!(safe:as:one two-sig msg)))
    (expect !>(!=(cc-nec-sym two-nec-sym)))
  ==
::
++  test-anew-cannot-restore-an-old-life-key  ^-  tang
  ::  Model a delayed response prepared at life 1: its un-tweaked xtr
  ::  changed, but it still carries the old life key.  Once Ames is at
  ::  life 2, accepting it would make .pass disagree with .saf.
  ::
  =/  stale-core
    (pit:nu:cric:crypto 512 (shaz 'cc-comet') %c [q:(mat %gw-btc) 0x1234])
  =/  stale-pass  pub:ex:stale-core
  =/  pass-before  pass.ames-state.cc-life2
  =/  saf-before  saf.ames-state.cc-life2
  =^  moves  cc-life2
    (take cc-life2 /sybl ~[/ames] [%jael %sybl %anew %gw-btc stale-pass])
  ;:  weld
    (expect !>(!=(stale-pass pass-before)))
    (expect-eq !>(pass-before) !>(pass.ames-state.cc-life2))
    (expect-eq !>(saf-before) !>(saf.ames-state.cc-life2))
    (expect-eq !>(2) !>(life.ames-state.cc-life2))
  ==
::
++  test-private-key-resend-cannot-undo-anew  ^-  tang
  ::  A valid %anew changes only suite C's opaque evidence tail.  Jael's
  ::  cached active ring can still contain the previous tail, so a later
  ::  %resend of that exact ring must be a no-op instead of restoring its
  ::  stale public pass in Ames.
  ::
  =/  refreshed-pass  pub:ex:cc-life2-refreshed-core
  ?>  =(cc-comet `@p`fig:ex:cc-life2-refreshed-core)
  ?>  =(saf:ex:cc-life2-core saf:ex:cc-life2-refreshed-core)
  ?>  !=(pass.ames-state.cc-life2 refreshed-pass)
  =/  old-ring  ring.ames-state.cc-life2
  =/  [anew-moves=(list move:ames) after-anew=_cc-life2]
    (take cc-life2 /sybl ~[/ames] [%jael %sybl %anew %gw-btc refreshed-pass])
  =/  vein=(map life ring)  (my [2 old-ring] ~)
  =/  [resend-moves=(list move:ames) after-resend=_cc-life2]
    (take after-anew /private-keys ~[/ames] [%jael %private-keys 2 vein])
  ;:  weld
    (expect-eq !>(~) !>(anew-moves))
    (expect-eq !>(~) !>(resend-moves))
    (expect-eq !>(refreshed-pass) !>(pass.ames-state.after-anew))
    (expect-eq !>(refreshed-pass) !>(pass.ames-state.after-resend))
    (expect-eq !>(old-ring) !>(ring.ames-state.after-resend))
    (expect-eq !>(2) !>(life.ames-state.after-resend))
  ==
::
++  test-private-keys-cannot-replace-active-life  ^-  tang
  ::  Even with the same immutable suite-C name, a different seed at the
  ::  already-active life is never a second candidate for that life.
  ::
  =/  alternate-ring
    (sew 3 [1 32 (shaz 'cc-comet-alternate-life-2')] cc-life2-ring)
  =/  pass-before  pass.ames-state.cc-life2
  =/  ring-before  ring.ames-state.cc-life2
  =/  saf-before  saf.ames-state.cc-life2
  =/  vein=(map life ring)  (my [2 alternate-ring] ~)
  =/  [moves=(list move:ames) after=_cc-life2]
    (take cc-life2 /private-keys ~[/ames] [%jael %private-keys 2 vein])
  ;:  weld
    (expect-eq !>(~) !>(moves))
    (expect-eq !>(pass-before) !>(pass.ames-state.after))
    (expect-eq !>(ring-before) !>(ring.ames-state.after))
    (expect-eq !>(saf-before) !>(saf.ames-state.after))
    (expect-eq !>(2) !>(life.ames-state.after))
  ==
::
++  test-private-keys-cannot-roll-ames-back  ^-  tang
  =/  pass-before  pass.ames-state.cc-life2
  =/  ring-before  ring.ames-state.cc-life2
  =/  saf-before  saf.ames-state.cc-life2
  =/  vein=(map life ring)
    (malt ~[[1 sec:ex:cc-core]])
  =^  moves  cc-life2
    (take cc-life2 /private-keys ~[/ames] [%jael %private-keys 1 vein])
  ;:  weld
    (expect-eq !>(2) !>(life.ames-state.cc-life2))
    (expect-eq !>(pass-before) !>(pass.ames-state.cc-life2))
    (expect-eq !>(ring-before) !>(ring.ames-state.cc-life2))
    (expect-eq !>(saf-before) !>(saf.ames-state.cc-life2))
  ==
::
++  test-private-keys-cannot-rename-a-comet  ^-  tang
  ::  Even a numerically newer gift is inert if its suite-C ring derives
  ::  another immutable @p.
  ::
  =/  foreign
    (pit:nu:cric:crypto 512 (shaz 'foreign-cc-comet') %c q:(mat %gw-btc))
  =/  pass-before  pass.ames-state.cc-life2
  =/  ring-before  ring.ames-state.cc-life2
  =/  saf-before  saf.ames-state.cc-life2
  =/  vein=(map life ring)
    (malt ~[[3 sec:ex:foreign]])
  =^  moves  cc-life2
    (take cc-life2 /private-keys ~[/ames] [%jael %private-keys 3 vein])
  ;:  weld
    (expect !>(!=(cc-comet `@p`fig:ex:foreign)))
    (expect-eq !>(2) !>(life.ames-state.cc-life2))
    (expect-eq !>(pass-before) !>(pass.ames-state.cc-life2))
    (expect-eq !>(ring-before) !>(ring.ames-state.cc-life2))
    (expect-eq !>(saf-before) !>(saf.ames-state.cc-life2))
  ==
::
++  test-pki-domain-state-is-tristate  ^-  tang
  ;:  weld
    %+  expect-eq  !>(%none)
    !>  (pki-dom-state:ames (pki-roof ~ %unregistered) ~nec now.nec %gw-btc)
    %+  expect-eq  !>(%live)
    !>  (pki-dom-state:ames (pki-roof ~ %live) ~nec now.nec %gw-btc)
    %+  expect-eq  !>(%dead)
    !>  (pki-dom-state:ames (pki-roof ~ %suspended) ~nec now.nec %gw-btc)
    ::  a present but ill-typed %dose result is not "unregistered"
    ::
    %+  expect-eq  !>(%dead)
    !>  (pki-dom-state:ames (pki-roof ~ %malformed) ~nec now.nec %gw-btc)
  ==
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
::  Verifier outcomes cannot override an operator/domain hard blocklist.
::
++  test-sybl-full-keeps-snub  ^-  tang
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'verified-peer') %b ~)
  =/  verdict=sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  ::  a manually curated deny list that also holds our-comet
  ::
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev our-comet]])
  =^  m2  nec  (take nec /sybl ~[/ames] verdict)
  ;:  weld
    ::  a verifier result cannot override the hard policy
    ::
    (expect-eq !>([%deny (silt ~[~dev our-comet])]) !>(snub.ames-state.nec))
    ::  and the verified point was applied: the ship is now %known
    ::
    %+  expect-eq  !>(&)
    !>  ?|  ?=([~ %known *] (~(get by peers.ames-state.nec) our-comet))
            ?=([~ %known *] (~(get by chums.ames-state.nec) our-comet))
        ==
  ==
::
++  test-sybl-fail-cannot-prepoison-an-unknown-ship  ^-  tang
  ::  A claimed identity is attacker-controlled until a positive writ
  ::  result.  A negative result for an unknown name must allocate no
  ::  durable peer or blocklist state.
  ::
  =/  peers-before  peers.ames-state.nec
  =/  chums-before  chums.ames-state.nec
  =/  snub-before   snub.ames-state.nec
  =^  moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %fail %test-dom our-comet2])
  ;:  weld
    (expect-eq !>(peers-before) !>(peers.ames-state.nec))
    (expect-eq !>(chums-before) !>(chums.ames-state.nec))
    (expect-eq !>(snub-before) !>(snub.ames-state.nec))
  ==
::
++  test-sybl-full-keeps-an-allow-list-snub  ^-  tang
  ::  In allow-list mode absence is the hard policy.  A verifier cannot
  ::  add the ship and thereby override it.
  ::
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'allow-peer') %b ~)
  =/  verdict=sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  =^  m1  nec  (call nec ~[//unix] [%snub %allow %set ~[~dev]])
  =^  m2  nec  (take nec /sybl ~[/ames] verdict)
  (expect-eq !>([%allow (silt ~[~dev])]) !>(snub.ames-state.nec))
::
++  test-sybl-full-leaves-an-unsnubbed-ship-alone  ^-  tang
  ::  a verdict for a ship we never snubbed must not edit the list.
  ::
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'quiet-peer') %b ~)
  =/  verdict=sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev ~rus]])
  =^  m2  nec  (take nec /sybl ~[/ames] verdict)
  (expect-eq !>([%deny (silt ~[~dev ~rus])]) !>(snub.ames-state.nec))
::
++  test-sybl-fail-drops-only-the-alien-candidate  ^-  tang
  ::  .cc-comet begins as an alien |mesa chum.  A failed verification
  ::  discards that retryable candidate, but cannot alter the
  ::  operator's hard blocklist.
  ::
  =^  m1  nec  (call nec ~[//unix] [%snub %deny %set ~[~dev]])
  =^  m2  nec
    (take nec /sybl ~[/ames] [%jael %sybl %fail %test-dom cc-comet])
  ;:  weld
    (expect-eq !>(%.n) !>((~(has by chums.ames-state.nec) cc-comet)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
    (expect-eq !>([%deny (silt ~[~dev])]) !>(snub.ames-state.nec))
  ==
::
++  test-sybl-fail-keeps-a-known-peer  ^-  tang
  =.  chums.ames-state.nec
    %+  ~(put by chums.ames-state.nec)  cc-comet
    (known-chum cc-nec-sym 1 cc)
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %fail %test-dom cc-comet])
  ;:  weld
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
    (expect-eq !>([%deny `(set @p)`~]) !>(snub.ames-state.nec))
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
::
++  test-sybl-full-preserves-known-peer-qos  ^-  tang
  ::  Replaying an unchanged whole point refreshes PKI fields, not transport
  ::  liveness.  A known peer's established QoS must survive intact.
  ::
  =/  live-qos  [%live now.nec]
  =/  known  (known-chum cc-nec-sym 1 cc)
  ?>  ?=(%known -.known)
  =/  =fren-state:ames  +.known
  =.  qos.fren-state  live-qos
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) cc-comet [%known fren-state])
  =/  point
    :*  rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=2 pass.ames-state.cc]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %full %test-dom cc-comet point])
  =/  after  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  (expect-eq !>(live-qos) !>(qos.+.after))
::
++  test-sybl-full-breaches-known-peer-on-rift-increase  ^-  tang
  ::  A domain verdict is a complete authoritative point, and can arrive
  ::  without Jael's per-ship subscription having first supplied a separate
  ::  %breach gift.  Its higher rift must therefore cross the continuity
  ::  boundary here instead of preserving live transport state.
  ::
  =/  live-qos  [%live now.nec]
  =/  known  (known-chum cc-nec-sym 1 cc)
  ?>  ?=(%known -.known)
  =/  =fren-state:ames  +.known
  =.  qos.fren-state  live-qos
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) cc-comet [%known fren-state])
  =/  point
    :*  rift=1
        life=1
        keys=(malt ~[[1 [crypto-suite=2 pass.ames-state.cc]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %full %test-dom cc-comet point])
  ::  The default transport is legacy Ames, so breach deliberately migrates
  ::  the reset peer back to that table before the whole point rehydrates it.
  ::
  =/  after  (~(got by peers.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  ;:  weld
    (expect-eq !>(1) !>(rift.+.after))
    (expect-eq !>([%unborn now.nec]) !>(qos.+.after))
  ==
::
++  test-publ-full-breaches-known-peer-on-rift-increase  ^-  tang
  ::  The same guarantee belongs to the common whole-point installation
  ::  path: an initial public-key subscription can return a higher-rift %full
  ::  without any preceding %breach notification.
  ::
  =/  live-qos  [%live now.nec]
  =/  known  (known-comet cc-nec-sym 1 cc)
  ?>  ?=(%known -.known)
  =/  =peer-state:ames  +.known
  =.  qos.peer-state  live-qos
  =.  chums.ames-state.nec
    (~(del by chums.ames-state.nec) cc-comet)
  =.  peers.ames-state.nec
    (~(put by peers.ames-state.nec) cc-comet [%known peer-state])
  =/  point
    :*  rift=1
        life=1
        keys=(malt ~[[1 [crypto-suite=2 pass.ames-state.cc]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  moves  nec
    %:  take
      nec
      /public-keys
      ~[//unix]
      [%jael %public-keys %full [n=[cc-comet point] ~ ~]]
    ==
  =/  after  (~(got by peers.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  ;:  weld
    (expect-eq !>(1) !>(rift.+.after))
    (expect-eq !>([%unborn now.nec]) !>(qos.+.after))
  ==
::
++  test-publ-full-initializes-qos-after-breach  ^-  tang
  ::  Breach deliberately replaces the transport tail with its default QoS.
  ::  A later whole point must timestamp that sentinel as a fresh connection,
  ::  not preserve the meaningless default time zero.
  ::
  =/  live-qos  [%live now.nec]
  =/  known  (known-comet cc-nec-sym 1 cc)
  ?>  ?=(%known -.known)
  =/  =peer-state:ames  +.known
  =.  qos.peer-state  live-qos
  =.  chums.ames-state.nec
    (~(del by chums.ames-state.nec) cc-comet)
  =.  peers.ames-state.nec
    (~(put by peers.ames-state.nec) cc-comet [%known peer-state])
  =^  breach-moves  nec
    (take nec /public-keys ~[//unix] [%jael %public-keys %breach cc-comet])
  =/  breached  (~(got by peers.ames-state.nec) cc-comet)
  ?>  ?=(%known -.breached)
  =/  point
    :*  rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=2 pass.ames-state.cc]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  full-moves  nec
    %:  take
      nec
      /public-keys
      ~[//unix]
      [%jael %public-keys %full [n=[cc-comet point] ~ ~]]
    ==
  =/  after  (~(got by peers.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  ;:  weld
    (expect-eq !>(*qos:ames) !>(qos.+.breached))
    (expect-eq !>([%unborn now.nec]) !>(qos.+.after))
  ==
::
++  test-sybl-full-rederives-known-mesa-paths-on-rotation  ^-  tang
  ::  A whole-point verifier verdict is also the remote rekey event for
  ::  a suite-C comet.  Existing encrypted |mesa requests must move to
  ::  paths derived from the new shared key, exactly as for an ordinary
  ::  incremental %keys update.
  ::
  =/  live-qos  [%live now.nec]
  =/  known  (known-chum cc-nec-sym 1 cc)
  ?>  ?=(%known -.known)
  =/  =fren-state:ames  +.known
  =.  qos.fren-state  live-qos
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) cc-comet [%known fren-state])
  =.  rof.nec  saxo-roof
  =^  request-moves  nec
    (call nec ~[/rotation-test] [%chum cc-comet /rotation-test])
  =/  before  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.before)
  =/  before-pit=(map path request-state:ames)  pit.+.before
  =/  pt
    :*  rift=0
        life=2
        keys=(malt ~[[2 [crypto-suite=2 pass.ames-state.cc-life2]]])
        sponsor=`~marbud
        fief=~
    ==
  =/  verdict=sign:ames
    [%jael %sybl %full %test-dom cc-comet pt]
  =^  rotation-moves  nec  (take nec /sybl ~[/ames] verdict)
  =/  after  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  ;:  weld
    (expect !>(?=(^ before-pit)))
    (expect !>(!=(before-pit pit.+.after)))
    (expect !>(?=(^ pit.+.after)))
    (expect-eq !>(2) !>(life.+.after))
    (expect-eq !>(pass.ames-state.cc-life2) !>(pass.+.after))
    (expect-eq !>(live-qos) !>(qos.+.after))
  ==
::
++  test-sybl-same-key-evidence-refresh-preserves-mesa-state  ^-  tang
  ::  A same-life suite-C verdict may replace only mutable evidence.  Since
  ::  the live key did not change, it must not take the rekey path and discard
  ::  an in-flight Mesa request's partial page state while rederiving paths.
  ::
  =/  life2-sym
    (derive-symmetric-key:ames pub.saf.ames-state.cc-life2 sek.saf.ames-state.nec)
  =/  known  (known-chum life2-sym 2 cc-life2)
  ?>  ?=(%known -.known)
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) cc-comet known)
  =.  rof.nec  saxo-roof
  =^  request-moves  nec
    (call nec ~[/evidence-refresh-test] [%chum cc-comet /evidence-refresh-test])
  =/  staged  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.staged)
  =/  =fren-state:ames  +.staged
  =.  qos.fren-state  [%live now.nec]
  =.  pit.fren-state
    %-  ~(run by pit.fren-state)
    |=  req=request-state:ames
    req(ps `*pact-state:ames)
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) cc-comet [%known fren-state])
  =/  before  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.before)
  ?>  ?=(^ pit.+.before)
  =/  transport-before  +>.+.before
  =/  point
    :*  rift=0
        life=2
        keys=(malt ~[[2 [crypto-suite=2 pub:ex:cc-life2-refreshed-core]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  refresh-moves  nec
    (take nec /sybl ~[/ames] [%jael %sybl %full %test-dom cc-comet point])
  =/  after  (~(got by chums.ames-state.nec) cc-comet)
  ?>  ?=(%known -.after)
  ;:  weld
    (expect-eq !>(2) !>(life.+.after))
    (expect-eq !>(pub:ex:cc-life2-refreshed-core) !>(pass.+.after))
    (expect-eq !>(pub.saf.ames-state.cc-life2) !>(public-keys.+.after))
    (expect-eq !>(life2-sym) !>(symmetric-key.+.after))
    (expect-eq !>(transport-before) !>(+>.+.after))
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
  ::  Wrapping the synthetic bomb as .signed gives the outer packet the
  ::  exact expected [@ @] shape.  +open-jam-shaped must still inspect
  ::  the inner jam before any caller cues it.
  ::
  =/  wrapped=@  (jam [0 cue-bomb])
  ;:  weld
    (expect !>(!(open-jam-shaped:ames bomb)))
    (expect !>(!(jam-safe:ames cue-bomb)))
    (expect !>(!(open-jam-shaped:ames cue-bomb)))
    (expect !>(!(open-jam-shaped:ames wrapped)))
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
  ::  Exercise the actual suite-%c encoder as well as minimal [@ @]
  ::  shapes.  The outer jam and its signed inner jam must both pass.
  ::
  =/  blob  (cc-attestation-at cc cc-comet 1)
  =/  =shot:ames  (sift-shot:ames blob)
  =/  [signature=@ signed=@]
    ;;([signature=@ signed=@] (cue content.shot))
  ;:  weld
    (expect !>((open-jam-shaped:ames content.shot)))
    (expect !>((jam-safe:ames signed)))
    (expect !>((is-open-packet:ames shot)))
    (expect !>((open-jam-shaped:ames (jam [(shaz 'sig') (jam 42)]))))
    (expect !>((open-jam-shaped:ames (jam [0 (jam 0)]))))
    ::  ... and nothing else: an atom, a 3-tuple, or trailing bytes
    ::
    (expect !>(!(open-jam-shaped:ames (jam 42))))
    (expect !>(!(open-jam-shaped:ames (jam [1 2 3]))))
    (expect !>(!(open-jam-shaped:ames (lsh [0 1] (jam [1 2])))))
  ==
::
++  test-sift-open-rejects-a-raw-malformed-suite-c-pass  ^-  tang
  ::  The low three bits announce suite %c, but this atom ends before
  ::  the domain +mat at bit 520.  Reaching +com with it is unsafe; the
  ::  raw shape gate must turn that into a catchable structural reject.
  ::
  =/  bad-pass=pass  'c'
  =/  =open-packet:ames  [bad-pass cc-comet 1 ~nec 2]
  =/  signed=@  (jam open-packet)
  =/  =shot:ames
    :*  [sndr=cc-comet rcvr=~nec]
        req=&  sam=&
        sndr-tick=0b1
        rcvr-tick=0b10
        origin=~
        content=(jam [signature=0 signed])
    ==
  =/  tried=(unit open-packet:ames)
    %-  mole
    |.  (sift-open-packet:ames [(pki-roof ~ %live) ~nec now.nec] shot ~nec 2)
  ;:  weld
    (expect !>((open-jam-shaped:ames content.shot)))
    (expect !>((is-open-packet:ames shot)))
    (expect-eq !>(~) !>((pass-pki-dom:ames bad-pass)))
    (expect !>(!(pass-shaped:ames bad-pass)))
    (expect !>(?=(~ tried)))
  ==
::  +on-hear-packet routes a comet's packet by SHAPE, and drops what it
::  cannot route.  Four cases, and the obvious fixes break one of them:
::
::    1. unknown comet + valid attestation -> +on-hear-open.  this is
::       the whole comet onboarding path, and the regression a careless
::       fix causes.
  ::    2. known comet + re-attestation -> +on-hear-open.  a retransmitted
  ::       attestation can arrive after a local Jael gift has promoted the
  ::       peer, and a suite-%c comet sends one at every new life, so an
  ::       attestation can arrive from a peer we already classify as known.
  ::       This local routing race is not a competing-rotation protocol.
  ::       Routing the attestation to
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
++  test-hear-suite-c-name-is-always-bound  ^-  tang
  ::  The packet is internally consistent and correctly signed by the
  ::  pass's life key, but the claimed @p is not +fig of that pass.  A
  ::  live domain cannot override this immutable name binding.
  ::
  =/  blob  (cc-attestation-at cc-misnamed our-comet 1)
  =/  tried
    %-  mole
    |.  (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  (expect !>(?=(~ tried)))
::
++  test-hear-suite-c-life1-falls-back-without-agent  ^-  tang
  ::  At life 1 .ugn equals .cry, so an explicitly unregistered domain
  ::  admits the ship exactly as an ordinary comet and emits no writ.
  ::
  =.  chums.ames-state.nec  (~(del by chums.ames-state.nec) cc-comet)
  =/  blob  (cc-attestation-at cc cc-comet 1)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((count-writs moves)))
    %+  expect-eq  !>(&)
    !>  ?=([~ %known *] (~(get by peers.ames-state.nec) cc-comet))
  ==
::
++  test-hear-suite-c-life1-fallback-rechecks-a-new-live-domain  ^-  tang
  ::  Local fallback is compatibility state, not permanent authority.
  ::  If the domain later registers, the same life-1 attestation must be
  ::  offered to its verifier even though Ames already knows the peer.
  ::
  =.  chums.ames-state.nec  (~(del by chums.ames-state.nec) cc-comet)
  =/  blob  (cc-attestation-at cc cc-comet 1)
  =^  fallback-moves  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] blob)
  =/  after-fallback  (~(get by peers.ames-state.nec) cc-comet)
  =^  verify-moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((count-writs fallback-moves)))
    (expect !>(?=([~ %known *] after-fallback)))
    (expect-eq !>(1) !>((count-writs verify-moves)))
    (expect !>(?=([~ %known *] (~(get by peers.ames-state.nec) cc-comet))))
  ==
::
++  test-hear-suite-c-accepts-bootstrap-receiver-life  ^-  tang
  ::  An unknown responder to legacy %keys can know only the requester's
  ::  four-bit tick, so its signed attestation uses receiver life 1 as the
  ::  bootstrap coordinate.  A rotated receiver still verifies the sender's
  ::  full life and forwards the candidate to its live domain.
  ::
  =/  blob  (cc-attestation-for cc-life2 cc-comet 2 ~nec 1)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  (expect-eq !>(1) !>((count-writs moves)))
::
++  test-hear-suite-c-rejects-unrelated-receiver-life  ^-  tang
  ::  Life 1 is the only bootstrap exception; another stale or future value
  ::  is still rejected rather than inferred from the unauthenticated tick.
  ::
  =/  blob  (cc-attestation-for cc-life2 cc-comet 2 ~nec 3)
  =/  tried
    %-  mole
    |.  (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  (expect !>(?=(~ tried)))
::
++  test-hear-bootstrap-replay-of-known-current-peer-is-idempotent  ^-  tang
  ::  The bootstrap coordinate changes only receiver-life admission.  Once
  ::  Ames and Jael already hold this exact life, replay neither mutates the
  ::  peer nor starts another verifier job.
  ::
  =/  replay-nec  nec
  =.  chums.ames-state.replay-nec
    (~(del by chums.ames-state.replay-nec) cc-comet)
  =/  sym
    (derive-symmetric-key:ames pub.saf.ames-state.cc-life2 sek.saf.ames-state.nec)
  =.  peers.ames-state.replay-nec
    %+  ~(put by peers.ames-state.replay-nec)  cc-comet
    (known-comet sym 2 cc-life2)
  =/  before  (~(get by peers.ames-state.replay-nec) cc-comet)
  =/  blob  (cc-attestation-for cc-life2 cc-comet 2 ~nec 1)
  =^  moves  replay-nec
    (call replay-nec(rof (pki-roof `2 %live)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((count-writs moves)))
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by peers.ames-state.replay-nec) cc-comet)))
  ==
::
++  test-legacy-keys-bootstrap-completes-a-reciprocal-attestation  ^-  tang
  ::  A life-2 suite-C comet asks an unknown life-1 comet for its keys.
  ::  The responder necessarily answers for receiver life 1.  Accepting that
  ::  signed bootstrap response promotes it; the ordinary meet path then sends
  ::  our full life-2 attestation back, which reaches the domain verifier.
  ::
  =/  request=blob:ames
    (etch-shot:ames (encode-keys-packet:ames cc-comet our-comet 2))
  =/  responder  comet
  ::  Before learning the requester's PKI point, legacy Ames can only route
  ::  its answer through the numerical sponsor encoded in the comet @p.
  ::  Prime that relay with the fixture's existing direct sponsor route.
  ::
  =/  legacy-sponsor  (^sein:title cc-comet)
  =.  peers.ames-state.responder
    %+  ~(put by peers.ames-state.responder)  legacy-sponsor
    (~(got by peers.ames-state.responder) ~marbud)
  =^  reply-moves  responder
    (call responder(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& legacy-sponsor] request)
  =/  reply  (snag-packet 0 reply-moves)
  =/  reply-shot=shot:ames  (sift-shot:ames +.reply)
  =/  reply-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof ~ %unregistered) cc-comet now.cc-life2]
        reply-shot
        cc-comet
        2
    ==
  =/  requester  cc-life2
  ::  The ordinary meet path emits our reciprocal attestation through the
  ::  newly learned comet's numerical sponsor before recording the incoming
  ::  direct lane.  Give the fixture that existing relay relationship too.
  ::
  =/  reply-sponsor  (^sein:title our-comet)
  =.  peers.ames-state.requester
    %+  ~(put by peers.ames-state.requester)  reply-sponsor
    (~(got by peers.ames-state.nec) ~marbud)
  =^  meet-moves  requester
    (call requester(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] +.reply)
  =/  reciprocal  (snag-packet 0 meet-moves)
  =/  reciprocal-shot=shot:ames  (sift-shot:ames +.reciprocal)
  =/  reciprocal-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof ~ %live) our-comet now.responder]
        reciprocal-shot
        our-comet
        1
    ==
  =^  verify-moves  responder
    (call responder(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] +.reciprocal)
  ;:  weld
    (expect-eq !>([our-comet 1 cc-comet 1]) !>([sndr sndr-life rcvr rcvr-life]:reply-open))
    (expect-eq !>([cc-comet 2 our-comet 1]) !>([sndr sndr-life rcvr rcvr-life]:reciprocal-open))
    (expect-eq !>(1) !>((count-writs verify-moves)))
    (expect !>(?=([~ %known *] (~(get by peers.ames-state.requester) our-comet))))
  ==
::
++  test-known-suite-c-simultaneous-rotation-recovers-with-keys  ^-  tang
  ::  Both endpoints know each other at life 2, then independently activate
  ::  life 3 before either receives the other's proactive announcement.  Each
  ::  stored view is consequently stale.  A reactive %keys answer cannot use
  ::  that stored life as the signed receiver coordinate: the requester is
  ::  already at life 3 and would reject it.  The fixed life-1 sentinel lets
  ::  both current, life-3 signatures reach the domain verifier in one shot.
  ::
  =/  a  cc-life2
  =/  b  cd-life2
  =.  peers.ames-state.a  *(map ship ship-state:ames)
  =.  chums.ames-state.a  *(map ship chum-state:ames)
  =.  peers.ames-state.b  *(map ship ship-state:ames)
  =.  chums.ames-state.b  *(map ship chum-state:ames)
  =/  a-b-life2-sym
    (derive-symmetric-key:ames pub.saf.ames-state.cd-life2 sek.saf.ames-state.a)
  =/  b-a-life2-sym
    (derive-symmetric-key:ames pub.saf.ames-state.cc-life2 sek.saf.ames-state.b)
  =.  peers.ames-state.a
    %+  ~(put by peers.ames-state.a)  cd-comet
    (known-comet a-b-life2-sym 2 cd-life2)
  =.  peers.ames-state.b
    %+  ~(put by peers.ames-state.b)  cc-comet
    (known-comet b-a-life2-sym 2 cc-life2)
  ::
  ::  Activate both private life-3 rings.  The separate proactive call sites
  ::  continue to bind their announcements to the exact stored peer life 2.
  ::  We deliberately lose those packets to model simultaneous/offline rekey.
  ::
  =/  a-vein=(map life ring)  (my [3 cc-life3-ring]~)
  =^  a-proactive-moves  a
    (take a /private-keys ~[/ames] [%jael %private-keys 3 a-vein])
  =/  a-proactive  (snag-packet 0 a-proactive-moves)
  =/  a-proactive-shot=shot:ames  (sift-shot:ames +.a-proactive)
  =/  a-proactive-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof `2 %live) cd-comet now.b]
        a-proactive-shot
        cd-comet
        2
    ==
  =/  b-vein=(map life ring)  (my [3 cd-life3-ring]~)
  =^  b-proactive-moves  b
    (take b /private-keys ~[/ames] [%jael %private-keys 3 b-vein])
  =/  b-proactive  (snag-packet 0 b-proactive-moves)
  =/  b-proactive-shot=shot:ames  (sift-shot:ames +.b-proactive)
  =/  b-proactive-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof `2 %live) cc-comet now.a]
        b-proactive-shot
        cc-comet
        2
    ==
  ::  Local rotation necessarily rederives the still-life-2 channels with the
  ::  new local secret.  Snapshot after that legitimate change so the next
  ::  comparison isolates the %keys/proof exchange itself.
  ::
  =/  a-peer-life2  (~(get by peers.ames-state.a) cd-comet)
  =/  b-peer-life2  (~(get by peers.ames-state.b) cc-comet)
  ::
  ::  Each life-3 endpoint now asks for the other's current attestation.  The
  ::  request carries only a wrapping tick; both responders still store life
  ::  2 for the requester, but sign their answers for bootstrap life 1.
  ::
  =/  request-a=blob:ames
    (etch-shot:ames (encode-keys-packet:ames cc-comet cd-comet 3))
  =/  request-b=blob:ames
    (etch-shot:ames (encode-keys-packet:ames cd-comet cc-comet 3))
  =^  reply-to-a-moves  b
    (call b(rof (pki-roof `2 %live)) ~[//unix] %hear [%& cc-comet] request-a)
  =^  reply-to-b-moves  a
    (call a(rof (pki-roof `2 %live)) ~[//unix] %hear [%& cd-comet] request-b)
  =/  reply-to-a  (snag-packet 0 reply-to-a-moves)
  =/  reply-to-b  (snag-packet 0 reply-to-b-moves)
  =/  reply-to-a-shot=shot:ames  (sift-shot:ames +.reply-to-a)
  =/  reply-to-b-shot=shot:ames  (sift-shot:ames +.reply-to-b)
  =/  reply-to-a-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof `2 %live) cc-comet now.a]
        reply-to-a-shot
        cc-comet
        3
    ==
  =/  reply-to-b-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof `2 %live) cd-comet now.b]
        reply-to-b-shot
        cd-comet
        3
    ==
  =^  verify-a-moves  a
    (call a(rof (pki-roof `2 %live)) ~[//unix] %hear [%& cd-comet] +.reply-to-a)
  =^  verify-b-moves  b
    (call b(rof (pki-roof `2 %live)) ~[//unix] %hear [%& cc-comet] +.reply-to-b)
  =/  a-peer-pending  (~(get by peers.ames-state.a) cd-comet)
  =/  b-peer-pending  (~(get by peers.ames-state.b) cc-comet)
  ::
  ::  Model the two successful domain verdicts.  Until these arrive Ames has
  ::  retained the life-2 channels verbatim; afterward each side advances to
  ::  the signed life-3 pass and derives the matching current channel key.
  ::
  =/  point-b
    :*  rift=0
        life=3
        keys=(malt ~[[3 [crypto-suite=2 pub:ex:cd-life3-core]]])
        sponsor=`~marbud
        fief=~
    ==
  =/  point-a
    :*  rift=0
        life=3
        keys=(malt ~[[3 [crypto-suite=2 pub:ex:cc-life3-core]]])
        sponsor=`~marbud
        fief=~
    ==
  =^  verdict-a-moves  a
    (take a /sybl ~[/ames] [%jael %sybl %full %gw-btc cd-comet point-b])
  =^  verdict-b-moves  b
    (take b /sybl ~[/ames] [%jael %sybl %full %gw-btc cc-comet point-a])
  =/  a-peer-life3  (~(got by peers.ames-state.a) cd-comet)
  =/  b-peer-life3  (~(got by peers.ames-state.b) cc-comet)
  ?>  ?=(%known -.a-peer-life3)
  ?>  ?=(%known -.b-peer-life3)
  =/  a-b-life3-sym
    (derive-symmetric-key:ames pub.saf.ames-state.b sek.saf.ames-state.a)
  =/  b-a-life3-sym
    (derive-symmetric-key:ames pub.saf.ames-state.a sek.saf.ames-state.b)
  ;:  weld
    (expect-eq !>([cc-comet 3 cd-comet 2]) !>([sndr sndr-life rcvr rcvr-life]:a-proactive-open))
    (expect-eq !>([cd-comet 3 cc-comet 2]) !>([sndr sndr-life rcvr rcvr-life]:b-proactive-open))
    (expect-eq !>(1) !>((lent a-proactive-moves)))
    (expect-eq !>(1) !>((lent b-proactive-moves)))
    (expect-eq !>([cd-comet 3 cc-comet 1]) !>([sndr sndr-life rcvr rcvr-life]:reply-to-a-open))
    (expect-eq !>([cc-comet 3 cd-comet 1]) !>([sndr sndr-life rcvr rcvr-life]:reply-to-b-open))
    (expect-eq !>(pass.ames-state.b) !>(pass.reply-to-a-open))
    (expect-eq !>(pass.ames-state.a) !>(pass.reply-to-b-open))
    (expect-eq !>(1) !>((lent reply-to-a-moves)))
    (expect-eq !>(1) !>((lent reply-to-b-moves)))
    (expect-eq !>(1) !>((count-writs verify-a-moves)))
    (expect-eq !>(1) !>((count-writs verify-b-moves)))
    (expect-eq !>(2) !>((lent verify-a-moves)))
    (expect-eq !>(2) !>((lent verify-b-moves)))
    (expect-eq !>(a-peer-life2) !>(a-peer-pending))
    (expect-eq !>(b-peer-life2) !>(b-peer-pending))
    (expect-eq !>(%.n) !>((~(has by chums.ames-state.a) cd-comet)))
    (expect-eq !>(%.n) !>((~(has by chums.ames-state.b) cc-comet)))
    (expect-eq !>(3) !>(life.+.a-peer-life3))
    (expect-eq !>(3) !>(life.+.b-peer-life3))
    (expect-eq !>(pub:ex:cd-life3-core) !>(pass.+.a-peer-life3))
    (expect-eq !>(pub:ex:cc-life3-core) !>(pass.+.b-peer-life3))
    (expect-eq !>(a-b-life3-sym) !>(symmetric-key.+.a-peer-life3))
    (expect-eq !>(b-a-life3-sym) !>(symmetric-key.+.b-peer-life3))
  ==
::
++  test-legacy-keys-from-known-mesa-peer-gets-attestation  ^-  tang
  ::  A peer's transport state cannot hide the legacy bootstrap control
  ::  packet.  ~nec is known only as a Mesa chum, but its %keys request must
  ::  still receive our ordinary, current-life signed attestation without
  ::  migrating or resetting either peer-table entry.
  ::
  =/  before-chum  (~(get by chums.ames-state.cc-life2) ~nec)
  =/  before-peer  (~(get by peers.ames-state.cc-life2) ~nec)
  =/  request=blob:ames
    (etch-shot:ames (encode-keys-packet:ames ~nec cc-comet 2))
  =^  moves  cc-life2
    (call cc-life2(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] request)
  =/  reply  (snag-packet 0 moves)
  =/  reply-shot=shot:ames  (sift-shot:ames +.reply)
  =/  reply-open=open-packet:ames
    %-  sift-open-packet:ames
    :*  [(pki-roof ~ %live) ~nec now.cc-life2]
        reply-shot
        ~nec
        2
    ==
  =/  expected-open=open-packet:ames
    [pass.ames-state.cc-life2 cc-comet 2 ~nec 1]
  ;:  weld
    (expect-eq !>(1) !>((lent moves)))
    (expect-eq !>(expected-open) !>(reply-open))
    (expect-eq !>(before-chum) !>((~(get by chums.ames-state.cc-life2) ~nec)))
    (expect-eq !>(before-peer) !>((~(get by peers.ames-state.cc-life2) ~nec)))
  ==
::
++  test-hear-suite-c-life2-needs-agent  ^-  tang
  ::  The same @p with a rotated, valid signer is not an ordinary comet:
  ::  without its committed domain agent there is no authority for life 2.
  ::
  =/  blob  (cc-attestation-at cc-life2 cc-comet 2)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
  ==
::
++  test-hear-suite-c-suspended-domain-fails-closed  ^-  tang
  ::  Suspension is deliberately distinct from absence: even the
  ::  otherwise-compatible life-1 pass must not fall back.
  ::
  =/  blob  (cc-attestation-at cc cc-comet 1)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %suspended)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
  ==
::
++  test-hear-suite-c-malformed-dose-fails-closed  ^-  tang
  =/  blob  (cc-attestation-at cc cc-comet 1)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %malformed)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
  ==
::
++  test-hear-suite-c-live-domain-routes-current-key  ^-  tang
  ::  A live agent is the authority that makes the rotated life-2 key
  ::  eligible for on-chain verification.  Ames queues exactly one writ.
  ::  This fixture already has an alien |mesa chum, which must remain in
  ::  place rather than being mirrored into the legacy peer table.
  ::
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =/  blob  (cc-attestation-at cc-life2 cc-comet 2)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(1) !>((count-writs moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
  ==
::
++  test-hear-suite-c-higher-life-from-known-mesa-routes-writ  ^-  tang
  ::  +sy-priv announces a rotated key with a legacy plaintext
  ::  attestation even when the relationship already lives in |mesa.
  ::  The outer dispatcher must let that structurally-open packet reach
  ::  +on-hear-open instead of treating it as migrated application data.
  ::
  =.  chums.ames-state.nec
    %+  ~(put by chums.ames-state.nec)  cc-comet
    (known-chum cc-nec-sym 1 cc)
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =/  blob  (cc-attestation-at cc-life2 cc-comet 2)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %hear [%& ~marbud] blob)
  ;:  weld
    (expect-eq !>(1) !>((count-writs moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
    (expect-eq !>(%.n) !>((~(has by peers.ames-state.nec) cc-comet)))
  ==
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
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] blob)
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
    (call nec(rof (pki-roof `1 %unregistered)) ~[//unix] %hear [%& ~marbud] blob)
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
    (call nec(rof (pki-roof `1 %unregistered)) ~[//unix] %hear (snag-packet 0 moves1))
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
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] (spoof bomb))
  ::  and a payload that IS jam-shaped, but decodes to nothing that
  ::  names the sender -- the guard is not just +open-jam-shaped
  ::
  =^  moves2  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %hear [%& ~marbud] (spoof (jam [0 0])))
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
::  The fixed life-1 proof namespace is a bootstrap coordinate, not a
::  claim about the publisher's current life.  A life-2 comet must serve
::  its current, genuinely signed gage there, and the receiver must admit
::  that gage through the normal one-fragment proof path.
::
++  test-mage-life1-proof-endpoint-serves-a-life2-gage  ^-  tang
  =/  [=lane:pact:ames blob=@]  cc-life2-proof-push
  =/  =pact:pact:ames  (parse-packet:nec blob)
  ?>  ?=(%page +<.pact)
  =/  =gage:mess:ames  ;;(gage:mess:ames (cue dat.data.pact))
  ?>  ?=(^ gage)
  ?>  ?=(%open-packet p.gage)
  =/  open  ;;(open-packet:ames q.gage)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer lane blob)
  ;:  weld
    (expect-eq !>(1) !>((div (add tob.data.pact 1.023) 1.024)))
    (expect !>((jam-safe:ames dat.data.pact)))
    (expect-eq !>(cc-comet) !>(sndr.open))
    (expect-eq !>(2) !>(sndr-life.open))
    (expect-eq !>(pass.ames-state.cc-life2) !>(pass.open))
    (expect-eq !>(1) !>((count-writs moves)))
  ==
::
++  test-heer-drops-a-malformed-inner-open-packet  ^-  tang
  ::  Keep the same recognized proof path and genuine page signature as the
  ::  valid fixtures.  Only the noun inside the advertised %open-packet gage
  ::  is malformed; its failed cast must leave Ames unchanged.
  ::
  =/  [=lane:pact:ames blob=@]  cc-malformed-inner-proof-push
  =/  =pact:pact:ames  (parse-packet:nec blob)
  ?>  ?=(%page +<.pact)
  =/  =gage:mess:ames  ;;(gage:mess:ames (cue dat.data.pact))
  ?>  ?=(^ gage)
  ?>  ?=(%open-packet p.gage)
  =/  maybe-open=(unit open-packet:ames)
    (mole |.(;;(open-packet:ames q.gage)))
  =/  before  ames-state.nec
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer lane blob)
  ;:  weld
    (expect !>((jam-safe:ames dat.data.pact)))
    (expect !>(?=(~ maybe-open)))
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>(ames-state.nec))
  ==
::
++  test-heer-drops-a-one-fragment-gage-cue-bomb  ^-  tang
  ::  Keep the generated page's authenticated path and one-fragment
  ::  envelope, but replace its anonymous body with the hostile jam
  ::  backreference.  The event must survive and allocate no peer state.
  ::
  =/  [=lane:pact:ames blob=@]  cc-proof-push
  =/  =pact:pact:ames  (parse-packet:nec blob)
  ?>  ?=(%page +<.pact)
  =.  tob.data.pact  (met 3 cue-bomb)
  =.  dat.data.pact  cue-bomb
  =/  bad-blob  (pact-to-blob pact)
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer lane bad-blob)
  ;:  weld
    (expect-eq !>(1) !>((div (add tob.data.pact 1.023) 1.024)))
    (expect !>(!(jam-safe:ames dat.data.pact)))
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
  ==
::
++  test-heer-rejects-a-raw-malformed-suite-c-pass  ^-  tang
  ::  %mage signed the page itself, so this reaches the embedded pass
  ::  guard rather than failing outer page authentication.  As on the
  ::  legacy path, the raw suite-%c atom must be rejected before +com.
  ::
  =/  [=lane:pact:ames blob=@]  cc-malformed-proof-push
  =/  =pact:pact:ames  (parse-packet:nec blob)
  ?>  ?=(%page +<.pact)
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer lane blob)
  ;:  weld
    (expect !>((jam-safe:ames dat.data.pact)))
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
  ==
::  A snub holds on |mesa too, and only on the ship it names.
::
::    +pe-hear tests .ships.snub the moment it has a $shot, before it
::    classifies anything, so nothing from a snubbed sender reaches the
::    |ames receive path.  +pe-heer's %page branch needs the same rule:
::    a snubbed comet must not re-attest over |mesa and mutate its
::    verified key/peer state behind a transport-wide hard policy.
::
::    The regression the gate risks is the exact opposite, and it is
::    worse: a %page from an UNSNUBBED alien is the whole comet
::    onboarding path, so first contact breaks if the gate is keyed on
::    the wrong ship or placed above the wrong branch.  Both verdicts
::    are asserted below, in both modes -- the test is mode-sensitive
::    because the gate is: on a %deny list a snub is membership in
::    .ships.snub, on an %allow list it is absence from it.
::
++  test-heer-page-from-snubbed-comet-is-dropped  ^-  tang
  =^  m0  nec  (call nec ~[//unix] [%snub %deny %set ~[cc-comet]])
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-proof-push)
  ;:  weld
    ::  dropped outright: no writ, and nothing else either
    ::
    %+  expect-eq  !>(0)  !>((count-writs moves))
    %+  expect-eq  !>(0)  !>((lent moves))
    ::  and it was not promoted behind the gate's back
    ::
    %+  expect-eq
      !>  %.n
    !>  ?=([~ %known *] (~(get by chums.ames-state.nec) cc-comet))
  ==
::
++  test-heer-page-from-unsnubbed-comet-attests  ^-  tang
  ::  first contact, unimpeded: the gate must not cost us this.
  ::
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-proof-push)
  %+  expect-eq  !>(1)  !>((count-writs moves))
::
++  test-heer-page-snubbed-on-an-allow-list  ^-  tang
  ::  .cc-comet is absent from an %allow list, which is what a snub
  ::  looks like in that mode.
  ::
  =^  m0  nec  (call nec ~[//unix] [%snub %allow %set ~[~dev]])
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-proof-push)
  ;:  weld
    %+  expect-eq  !>(0)  !>((count-writs moves))
    %+  expect-eq  !>(0)  !>((lent moves))
  ==
::
++  test-heer-page-allowed-on-an-allow-list  ^-  tang
  ::  ... and present on one is not a snub, so the attestation lands.
  ::
  =^  m0  nec  (call nec ~[//unix] [%snub %allow %set ~[cc-comet]])
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-proof-push)
  %+  expect-eq  !>(1)  !>((count-writs moves))
::
++  test-heer-suite-c-name-is-always-bound  ^-  tang
  ::  The page signature, packet sender, and page publisher all agree
  ::  on .our-comet, but the carried pass hashes to .cc-comet.  Even a
  ::  live domain cannot substitute one immutable identity for another.
  ::
  =.  chums.ames-state.nec
    (~(put by chums.ames-state.nec) our-comet [%alien *ovni-state:ames])
  =/  tried
    %-  mole
    |.  (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-misnamed-proof-push)
  (expect !>(?=(~ tried)))
::
++  test-heer-suite-c-rejects-an-ineligible-sponsor  ^-  tang
  ::  Legacy and Mesa admission share the same sponsorship invariant:
  ::  a comet may be sponsored only by a star or another comet.  ~bus
  ::  is a galaxy, so even a valid proof under a live domain is dropped.
  ::
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =/  bad-roof  (pki-roof-with-sein ~ %live ~bus)
  =^  moves  nec
    (call nec(rof bad-roof) ~[//unix] %heer cc-proof-push)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
  ==
::
++  test-heer-suite-c-life1-falls-back-without-agent  ^-  tang
  =^  moves  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %heer cc-proof-push)
  ;:  weld
    (expect-eq !>(0) !>((count-writs moves)))
    %+  expect-eq  !>(&)
    !>  ?=([~ %known *] (~(get by chums.ames-state.nec) cc-comet))
  ==
::
++  test-heer-suite-c-life2-needs-agent  ^-  tang
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %unregistered)) ~[//unix] %heer cc-life2-proof-push)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
    %+  expect-eq  !>(%.n)
    !>  ?=([~ %known *] (~(get by chums.ames-state.nec) cc-comet))
  ==
::
++  test-heer-suite-c-suspended-domain-fails-closed  ^-  tang
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %suspended)) ~[//unix] %heer cc-proof-push)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
  ==
::
++  test-heer-suite-c-malformed-dose-fails-closed  ^-  tang
  =/  before  (~(get by chums.ames-state.nec) cc-comet)
  =^  moves  nec
    (call nec(rof (pki-roof ~ %malformed)) ~[//unix] %heer cc-proof-push)
  ;:  weld
    (expect-eq !>(0) !>((lent moves)))
    (expect-eq !>(before) !>((~(get by chums.ames-state.nec) cc-comet)))
  ==
::
++  test-heer-suite-c-live-domain-routes-current-key  ^-  tang
  =^  moves  nec
    (call nec(rof (pki-roof ~ %live)) ~[//unix] %heer cc-life2-proof-push)
  ;:  weld
    (expect-eq !>(1) !>((count-writs moves)))
    %+  expect-eq  !>(%.n)
    !>  ?=([~ %known *] (~(get by chums.ames-state.nec) cc-comet))
  ==
::  A committed $fief must give a conventionally sponsored peer a route.
::
::    +sy-put-ship has always set route=[%& ship] when =(ship (sein
::    ship)), so a galaxy -- and a comet whose point names itself
::    sponsor -- has always resolved through the runtime, which looks a
::    fief up the same way it looks up a galaxy's domain.  A comet under
::    a star or under another comet kept route=~: +send-blob-via traced
::    "no route to" and relayed every packet through the sponsor, while
::    the address its holder committed to went unused.
::
++  test-fief-routes-a-sponsored-peer  ^-  tang
  =/  fef=fief  [%if .192.168.7.7 31.337]
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-route') %b ~)
  =/  =sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=`fef
    ==
  =.  rof.nec  (sein-roof (my [our-comet ~bud]~))
  =^  moves   nec  (take nec /sybl ~[/ames] sign)
  =^  moves2  nec
    (call nec ~[/g/talk] %plea our-comet [%g /talk [%get %post]])
  =/  lanes    (send-lanes moves2)
  =/  bud-rot  (need (peer-route nec ~bud))
  ;:  weld
    ::  the fief is a route now, and indirect on purpose: publishing an
    ::  address is not evidence of being at it today
    ::
    %+  expect-eq
      !>  `[direct=%.n lane=`lane:ames`[%& our-comet]]
    !>  (peer-route nec our-comet)
    ::  a plea reaches the comet at its own address
    ::
    %+  expect-eq  !>(%.y)
    !>  (lien lanes |=(=lane:ames =(lane [%& our-comet])))
    ::  and still goes through the sponsor as well, so a fief that has
    ::  gone stale on chain cannot black-hole the peer
    ::
    %+  expect-eq  !>(%.y)
    !>  (lien lanes |=(=lane:ames =(lane lane.bud-rot)))
  ==
::  Without a fief, nothing changes: sponsor relay is the normal path
::  for every comet and must not regress.
::
++  test-no-fief-still-relays-via-sponsor  ^-  tang
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-route-none') %b ~)
  =/  =sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet2
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  =.  rof.nec  (sein-roof (my [our-comet2 ~bud]~))
  =^  moves   nec  (take nec /sybl ~[/ames] sign)
  =^  moves2  nec
    (call nec ~[/g/talk] %plea our-comet2 [%g /talk [%get %post]])
  =/  lanes    (send-lanes moves2)
  =/  bud-rot  (need (peer-route nec ~bud))
  ;:  weld
    (expect-eq !>(~) !>((peer-route nec our-comet2)))
    ::  the packet goes to the sponsor, and only there
    ::
    %+  expect-eq  !>(%.y)
    !>  (lien lanes |=(=lane:ames =(lane lane.bud-rot)))
    %+  expect-eq  !>(%.n)
    !>  (lien lanes |=(=lane:ames =(lane [%& our-comet2])))
  ==
::  A ship that sponsors itself keeps the direct route it already had,
::  fief or no fief.  This is the case that always worked, and the case
::  that made the gap hard to see live.
::
++  test-fief-leaves-a-self-sponsor-direct  ^-  tang
  =/  fef=fief  [%turf ~[~['org' 'urbit']] 13.337]
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-self') %b ~)
  =/  with=sign:ames
    :*  %jael  %sybl  %full  %test-dom  ~marzod
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~marzod
        fief=`fef
    ==
  =/  sans=sign:ames
    :*  %jael  %sybl  %full  %test-dom  ~marzod
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~marzod
        fief=~
    ==
  ::  an empty map: every ship sponsors itself
  ::
  =.  rof.nec  (sein-roof ~)
  =/  want  `[direct=%.y lane=`lane:ames`[%& ~marzod]]
  ;:  weld
    %+  expect-eq  !>(want)
    !>  (peer-route +:(take nec /sybl ~[/ames] with) ~marzod)
    %+  expect-eq  !>(want)
    !>  (peer-route +:(take nec /sybl ~[/ames] sans) ~marzod)
  ==
::  A fief that arrives on its own -- the incremental [%diff @ %fief *]
::  a public scanner publishes -- must route a peer we already know.
::  +sy-put-ship only sees the whole points.
::
++  test-fief-diff-routes-a-known-peer  ^-  tang
  =/  fef=fief  [%if .10.0.0.9 12.345]
  =/  =pass  pub:ex:(pit:nu:cric:crypto 512 (shaz 'fief-diff') %b ~)
  =/  =sign:ames
    :*  %jael  %sybl  %full  %test-dom  our-comet
        rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pass]]])
        sponsor=`~bud
        fief=~
    ==
  =.  rof.nec  (sein-roof (my [our-comet ~bud]~))
  =^  moves   nec  (take nec /sybl ~[/ames] sign)
  =/  before  (peer-route nec our-comet)
  =^  moves2  nec
    %^  take  nec  /public-keys
    [~[/ames] %jael %public-keys %diff our-comet %fief ~ `fef]
  =/  ms=(list move:ames)  moves2
  ;:  weld
    (expect-eq !>(~) !>(before))
    %+  expect-eq
      !>  `[direct=%.n lane=`lane:ames`[%& our-comet]]
    !>  (peer-route nec our-comet)
    ::  and the runtime still learns the address itself
    ::
    %+  expect-eq  !>(%.y)
    !>  (lien ms |=(=move:ames ?=([* %give %fief *] move)))
  ==
--
