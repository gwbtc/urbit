/+  *test
/=  jael-raw  /sys/vane/jael
::
=/  bus  (jael-raw ~bus)
=/  now  ~1111.1.1
=/  eny  `@uvJ`0xdead.beef
=/  gw-duct=duct  [[%gall %use %gw-btc '0' ~] ~]
::
::  suite-%c %gw-btc pass, kelvin 9: the dat tweak whose leading +mat is
::  the pki domain that +dome and +pass-pki-dom:ames read back out.
::
=/  gw-dat=@  (can 0 ~[(mat %gw-btc) (mat 9) [256 0xdead.beef.cafe]])
=>
|%
++  call
  |=  [vane=_bus =duct wrapped-task=(hobo task:jael)]
  =/  core  (vane now=now eny=eny rof=*roof)
  (call:core duct dud=~ wrapped-task)
::
++  stay
  |=  vane=_bus
  =/  core  (vane now=now eny=eny rof=*roof)
  stay:core
::
++  watch-move
  |=  =duct
  ^-  move:bus
  :*  duct
      %pass
      /gw-btc/writs
      %g
      %deal
      [~bus ~bus /jael]
      %gw-btc
      %watch
      /writs
  ==
::  +mk-c-pass: a suite-%c pass committing the %gw-btc dat tweak
::
++  mk-c-pass
  |=  sed=@
  ^-  pass
  =<  pub:ex
  (pit:nu:cric:crypto 512 (shaz sed) %c gw-dat 0x1234)
::  +mk-b-pass: an ordinary suite-%b pass (no dat tweak)
::
++  mk-b-pass
  |=  sed=@
  ^-  pass
  =<  pub:ex
  (pit:nu:cric:crypto 512 (shaz sed) %b ~)
::  +point-for: a minimal jael point holding .pass at life 1
::
++  point-for
  |=  =pass
  ^-  point:jael
  [rift=0 life=1 keys=(malt ~[[1 [crypto-suite=2 pass]]]) sponsor=~ fief=~]
::  +with-point: inject a point into the pos registry (state surgery)
::
++  with-point
  |=  [vane=_bus who=@p =point:jael]
  ^+  bus
  vane(pos.zim.pki.lex (~(put by pos.zim.pki.lex.vane) who point))
::  +with-dom: register a pki domain (dos entry) by hand
::
++  with-dom
  |=  [vane=_bus dom=@tas =desk liv=? hep=(set ship)]
  ^+  bus
  vane(dos.lex (~(put by dos.lex.vane) dom [/writs desk liv hep]))
::  +point-with-fief: the same minimal point, plus a committed route
::
++  point-with-fief
  |=  [=pass fef=fief]
  ^-  point:jael
  [rift=0 life=1 keys=(malt ~[[1 [crypto-suite=2 pass]]]) sponsor=~ fief=`fef]
::  +with-fel: install a general (whos=~) %fief subscriber duct
::
::    ames subscribes exactly this way in +sy-init ([hen %pass /fief %j
::    %fief ~]), which is what lands its duct in fel.zim.
::
++  with-fel
  |=  [vane=_bus =duct]
  ^+  bus
  vane(fel.zim.pki.lex (~(put in fel.zim.pki.lex.vane) duct))
::  +with-syl: install a %writ-result (sybl) subscriber duct
::
++  with-syl
  |=  [vane=_bus =duct]
  ^+  bus
  vane(syl.zim.pki.lex (~(put in syl.zim.pki.lex.vane) duct))
::  +dome: scry a ship's committed pki domain, ~ if none/unknown
::
++  dome
  |=  [vane=_bus who=@p]
  ^-  (unit @tas)
  =/  core  (vane now=now eny=eny rof=*roof)
  =/  res=(unit (unit cage))
    %-  scry:core
    :*  lyc=~  pov=/  car=%$
        bem=[[~bus %dome [%da now]] ~[(scot %p who)]]
    ==
  ?~  res  ~
  ?~  u.res  ~
  ;;((unit @tas) q.q.u.u.res)
::  +take-fact: hand jael a %fact from a domain agent on wire /app
::
++  take-fact
  |=  [vane=_bus app=@tas =mark =vase]
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core ~[app] gw-duct dud=~ [%gall %unto %fact mark vase])
::  +take-tire: hand jael a clay %tire zest change for .desk
::
++  take-tire
  |=  [vane=_bus =desk zst=?(%dead %live %held)]
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core /tire gw-duct dud=~ [%clay %tire %| %zest desk zst])
--
::
|%
::  Repeating the exact registration is an idempotent request to restore
::  Jael's Gall watch.  It must not mutate the retained registration.
::
++  test-anex-exact-duplicate-rewatches
  ^-  tang
  =^  first-moves  bus  (call bus gw-duct %anex /writs)
  =/  before  (stay bus)
  =^  duplicate-moves  bus  (call bus gw-duct %anex /writs)
  =/  after  (stay bus)
  =/  expected=(list move:bus)  [(watch-move gw-duct) ~]
  ;:  weld
    (expect-eq !>(expected) !>(duplicate-moves))
    (expect-eq !>(before) !>(after))
  ==
::
::  An existing domain may only repeat its original path.  A different path
::  is a conflicting registration, even when it comes from the same agent.
::
++  test-anex-conflicting-path-rejected
  ^-  tang
  =^  first-moves  bus  (call bus gw-duct %anex /writs)
  %-  expect-fail
  |.  (call bus gw-duct %anex /other)
::  %dome scry (decisions-addendum section 10): a suite-%c ship resolves
::  to its committed pki domain; a suite-%b ship and an unknown ship both
::  resolve to ~.  Mirrors +pass-pki-dom:ames.
::
++  test-dome-suite-c
  ^-  tang
  =/  b  (with-point bus ~wes (point-for (mk-c-pass 'c')))
  (expect-eq !>(`%gw-btc) !>((dome b ~wes)))
::
++  test-dome-suite-b-is-null
  ^-  tang
  =/  b  (with-point bus ~wes (point-for (mk-b-pass 'b')))
  (expect-eq !>(~) !>((dome b ~wes)))
::
++  test-dome-unknown-is-null
  ^-  tang
  (expect-eq !>(~) !>((dome bus ~wes)))
::  %stale-notice fact (decisions-addendum section 3): the domain agent
::  reports a verified ship's attestation went out of date on-chain.
::  jael drops the point from pos and from the domain's hep set and gives
::  a [%sybl %stale] to its writ subscribers -- never a snub.
::
++  test-stale-notice-drops-point
  ^-  tang
  =/  b  bus
  =.  b  (with-dom b %gw-btc %gw-btc-desk %.y (silt ~[~wes ~dev]))
  =.  b  (with-point b ~wes (point-for (mk-c-pass 'wes')))
  =.  b  (with-syl b gw-duct)
  =^  moves  b  (take-fact b %gw-btc %stale-notice !>([%gw-btc ~wes]))
  ;:  weld
    ::  point gone from pos
    ::
    (expect-eq !>(%.n) !>((~(has by pos.zim.pki.lex.b) ~wes)))
    ::  ~wes removed from the domain's peer set, ~dev retained
    ::
    %+  expect-eq
      !>  (silt ~[~dev])
    !>  hep:(~(got by dos.lex.b) %gw-btc)
    ::  a %sybl %stale gift to the lone subscriber, no snub
    ::
    %+  expect-eq
      !>  ~[[gw-duct %give %sybl %stale %gw-btc ~wes]]
    !>  moves
  ==
::
++  test-stale-notice-ignores-unregistered
  ::  a stale-notice naming an unknown domain is dropped with no effect
  ::
  ^-  tang
  =/  b  bus
  =.  b  (with-point b ~wes (point-for (mk-c-pass 'wes')))
  =^  moves  b  (take-fact b %gw-btc %stale-notice !>([%gw-btc ~wes]))
  ;:  weld
    (expect-eq !>(%.y) !>((~(has by pos.zim.pki.lex.b) ~wes)))
    (expect-eq !>(~) !>(moves))
  ==
::  %tire additive snub (the fixed arm): a registered domain's desk going
::  %dead %add's its peers to ames's blocklist (never clobbering it); the
::  desk coming back %live %del's them.
::
++  test-tire-dead-adds-snub
  ^-  tang
  =/  b  (with-dom bus %gw-btc %gw-btc-desk %.y (silt ~[~wes]))
  =^  moves  b  (take-tire b %gw-btc-desk %dead)
  ;:  weld
    %+  expect-eq
      !>  ~[[gw-duct %pass /gost %a %snub %deny %add ~[~wes]]]
    !>  moves
    ::  the domain is now marked suspended
    ::
    (expect-eq !>(%.n) !>(liv:(~(got by dos.lex.b) %gw-btc)))
  ==
::
++  test-tire-live-dels-snub
  ^-  tang
  ::  a suspended domain's desk coming back live unsnubs its peers
  ::
  =/  b  (with-dom bus %gw-btc %gw-btc-desk %.n (silt ~[~wes]))
  =^  moves  b  (take-tire b %gw-btc-desk %live)
  ;:  weld
    %+  expect-eq
      !>  ~[[gw-duct %pass /ghul %a %snub %deny %del ~[~wes]]]
    !>  moves
    (expect-eq !>(%.y) !>(liv:(~(got by dos.lex.b) %gw-btc)))
  ==
::  A %writ-response carrying a point with a committed FIEF must publish
::  that fief to %fief subscribers, exactly as a %fief udiff does.  This
::  is the only route by which a CONFIDENTIAL comet's on-chain route can
::  reach the runtime at all: %gw-btc deliberately keeps confidential
::  identities out of its udiffs, so the verdict is the only carrier.
::  Live on mainnet a comet's verified fief became a jael point, showed
::  up in /pynt, and never became a route.
::
++  test-writ-response-publishes-the-fief
  ^-  tang
  =/  fef=fief  [%if .206.189.188.16 49.818]
  =/  pt  (point-with-fief (mk-c-pass 'wes') fef)
  =/  b  bus
  =.  b  (with-dom b %gw-btc %gw-btc-desk %.y ~)
  =.  b  (with-fel b gw-duct)
  =^  moves  b  (take-fact b %gw-btc %writ-response !>([%gw-btc ~wes `pt]))
  ;:  weld
    ::  the route is now in jael's own fief registry
    ::
    (expect-eq !>(`fef) !>((~(get by fes.zim.pki.lex.b) ~wes)))
    ::  ... and was pushed to the %fief subscriber
    ::
    %-  expect
    !>  %+  lien  moves
        |=  =move:bus
        =(+.move [%give %fief (my [~wes `fef]~)])
  ==
::
++  test-writ-response-without-a-fief-publishes-nothing
  ^-  tang
  =/  b  bus
  =.  b  (with-dom b %gw-btc %gw-btc-desk %.y ~)
  =.  b  (with-fel b gw-duct)
  =^  moves  b
    (take-fact b %gw-btc %writ-response !>([%gw-btc ~wes `(point-for (mk-c-pass 'wes'))]))
  %-  expect
  !>  ?!
      %+  lien  moves
      |=(=move:bus ?=([* %give %fief *] move))
--
