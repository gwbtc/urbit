/+  *test
/=  jael-raw  /sys/vane/jael
::
=/  bus  (jael-raw ~bus)
=/  now  ~1111.1.1
=/  eny  `@uvJ`0xdead.beef
=/  dom-duct=duct  [[%gall %use %test-dom '0' ~] ~]
::  the duct a /public-keys plea to a ship source is answered on
::
=/  pk-duct=duct  ~[/gall/sys/era /dill //term/1]
::
::  a suite-%c dat: a +mat-encoded pki domain, then opaque domain data.
::
::    The leading +mat is the whole of the kernel's contract with a dat --
::    it is what +dome and +pass-pki-dom:ames read back out, and the
::    kernel never looks past it.  What follows is the domain's business,
::    so this test says nothing about its shape.
::
=/  test-dat=@  (can 0 ~[(mat %test-dom) [32 0xdead.beef]])
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
      /test-dom/writs
      %g
      %deal
      [~bus ~bus /jael]
      %test-dom
      %watch
      /writs
  ==
::  +mk-c-pass: a suite-%c pass committing the %test-dom dat tweak
::
++  mk-c-pass
  |=  sed=@
  ^-  pass
  =<  pub:ex
  (pit:nu:cric:crypto 512 (shaz sed) %c test-dat 0x1234)
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
  (take:core ~[app] dom-duct dud=~ [%gall %unto %fact mark vase])
::  +take-tire: hand jael a clay %tire zest change for .desk
::
++  take-tire
  |=  [vane=_bus =desk zst=?(%dead %live %held)]
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core /tire dom-duct dud=~ [%clay %tire %| %zest desk zst])
::  +take-boon: a ship source answers our /public-keys plea
::
++  take-boon
  |=  [vane=_bus payload=*]
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core /public-keys pk-duct dud=~ [%ames %boon payload])
::  +take-lost: ames lost the reply to our /public-keys plea
::
++  take-lost
  |=  vane=_bus
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core /public-keys pk-duct dud=~ [%ames %lost ~])
::  +stock-full: a %full result as a stock (mainnet) jael sends it:
::  its points carry no fief
::
++  stock-full
  |=  [who=ship =pass spon=(unit @p)]
  ^-  *
  :+  %public-keys-result  %full
  %-  my
  :_  ~
  :-  who
  [rift=0 life=1 keys=(malt ~[[1 [crypto-suite=2 pass]]]) sponsor=spon]
::  +our-full: the same result as this kernel sends it
::
++  our-full
  |=  [who=ship =point:jael]
  ^-  *
  [%public-keys-result %full (my [who point]~)]
--
::
|%
::  Repeating the exact registration is an idempotent request to restore
::  Jael's Gall watch.  It must not mutate the retained registration.
::
++  test-anex-exact-duplicate-rewatches
  ^-  tang
  =^  first-moves  bus  (call bus dom-duct %anex /writs)
  =/  before  (stay bus)
  =^  duplicate-moves  bus  (call bus dom-duct %anex /writs)
  =/  after  (stay bus)
  =/  expected=(list move:bus)  [(watch-move dom-duct) ~]
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
  =^  first-moves  bus  (call bus dom-duct %anex /writs)
  %-  expect-fail
  |.  (call bus dom-duct %anex /other)
::  %dome scry (decisions-addendum section 10): a suite-%c ship resolves
::  to its committed pki domain; a suite-%b ship and an unknown ship both
::  resolve to ~.  Mirrors +pass-pki-dom:ames.
::
++  test-dome-suite-c
  ^-  tang
  =/  b  (with-point bus ~wes (point-for (mk-c-pass 'c')))
  (expect-eq !>(`%test-dom) !>((dome b ~wes)))
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
  =.  b  (with-dom b %test-dom %test-dom-desk %.y (silt ~[~wes ~dev]))
  =.  b  (with-point b ~wes (point-for (mk-c-pass 'wes')))
  =.  b  (with-syl b dom-duct)
  =^  moves  b  (take-fact b %test-dom %stale-notice !>([%test-dom ~wes]))
  ;:  weld
    ::  point gone from pos
    ::
    (expect-eq !>(%.n) !>((~(has by pos.zim.pki.lex.b) ~wes)))
    ::  ~wes removed from the domain's peer set, ~dev retained
    ::
    %+  expect-eq
      !>  (silt ~[~dev])
    !>  hep:(~(got by dos.lex.b) %test-dom)
    ::  a %sybl %stale gift to the lone subscriber, no snub
    ::
    %+  expect-eq
      !>  ~[[dom-duct %give %sybl %stale %test-dom ~wes]]
    !>  moves
  ==
::
++  test-stale-notice-ignores-unregistered
  ::  a stale-notice naming an unknown domain is dropped with no effect
  ::
  ^-  tang
  =/  b  bus
  =.  b  (with-point b ~wes (point-for (mk-c-pass 'wes')))
  =^  moves  b  (take-fact b %test-dom %stale-notice !>([%test-dom ~wes]))
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
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y (silt ~[~wes]))
  =^  moves  b  (take-tire b %test-dom-desk %dead)
  ;:  weld
    %+  expect-eq
      !>  ~[[dom-duct %pass /gost %a %snub %deny %add ~[~wes]]]
    !>  moves
    ::  the domain is now marked suspended
    ::
    (expect-eq !>(%.n) !>(liv:(~(got by dos.lex.b) %test-dom)))
  ==
::
++  test-tire-live-dels-snub
  ^-  tang
  ::  a suspended domain's desk coming back live unsnubs its peers
  ::
  =/  b  (with-dom bus %test-dom %test-dom-desk %.n (silt ~[~wes]))
  =^  moves  b  (take-tire b %test-dom-desk %live)
  ;:  weld
    %+  expect-eq
      !>  ~[[dom-duct %pass /ghul %a %snub %deny %del ~[~wes]]]
    !>  moves
    (expect-eq !>(%.y) !>(liv:(~(got by dos.lex.b) %test-dom)))
  ==
::  A %verdict carrying a point with a committed FIEF must publish
::  that fief to %fief subscribers, exactly as a %fief udiff does.  A
::  domain whose identities are confidential has no udiff stream to
::  carry them, so the verdict is the only route by which such a comet's
::  committed lane can reach the runtime at all.  Live on mainnet a
::  comet's verified fief became a jael point, showed up in /pynt, and
::  never became a route.
::
++  test-verdict-publishes-the-fief
  ^-  tang
  =/  fef=fief  [%if .206.189.188.16 49.818]
  =/  pt  (point-with-fief (mk-c-pass 'wes') fef)
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =.  b  (with-fel b dom-duct)
  =^  moves  b  (take-fact b %test-dom %verdict !>([%test-dom ~wes `pt]))
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
++  test-verdict-without-a-fief-publishes-nothing
  ^-  tang
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =.  b  (with-fel b dom-duct)
  =^  moves  b
    (take-fact b %test-dom %verdict !>([%test-dom ~wes `(point-for (mk-c-pass 'wes'))]))
  %-  expect
  !>  ?!
      %+  lien  moves
      |=(=move:bus ?=([* %give %fief *] move))
::  A stock jael (mainnet) answers a /public-keys plea with points that
::  have no fief.  Jael must lift them rather than crash the event.
::
++  test-stock-point-is-lifted
  ^-  tang
  =/  pas  (mk-b-pass 'marzod')
  =/  b  bus
  =^  moves  b  (take-boon b (stock-full ~marzod pas `~nec))
  %+  expect-eq
    !>  ^-  (unit point:jael)
        `[rift=0 life=1 keys=(malt ~[[1 [crypto-suite=2 pas]]]) sponsor=`~nec fief=~]
  !>  `(unit point:jael)`(~(get by pos.zim.pki.lex.b) ~marzod)
::  A stock point sponsored by ~zod is the one noun both shapes accept
::  ([0 0] tail).  A planet always has a sponsor, so it is read as
::  stock and keeps ~zod.
::
++  test-stock-point-under-zod-keeps-its-sponsor
  ^-  tang
  =/  pas  (mk-b-pass 'marzod')
  =/  b  bus
  =^  moves  b  (take-boon b (stock-full ~marzod pas `~zod))
  %+  expect-eq
    !>  ^-  (unit point:jael)
        `[rift=0 life=1 keys=(malt ~[[1 [crypto-suite=2 pas]]]) sponsor=`~zod fief=~]
  !>  `(unit point:jael)`(~(get by pos.zim.pki.lex.b) ~marzod)
::  ... whereas a galaxy has no sponsor, so its [0 0] tail is our own
::  [sponsor=~ fief=~] and must not be misread as sponsored by ~zod.
::
++  test-our-galaxy-point-keeps-no-sponsor
  ^-  tang
  =/  pas  (mk-b-pass 'zod')
  =/  b  bus
  =^  moves  b  (take-boon b (our-full ~zod (point-for pas)))
  %+  expect-eq
    !>  `(unit point:jael)``(point-for pas)
  !>  `(unit point:jael)`(~(get by pos.zim.pki.lex.b) ~zod)
::  Our own shape, sponsor and fief present, passes through unchanged.
::
++  test-our-point-passes-through
  ^-  tang
  =/  pt  (point-with-fief (mk-c-pass 'wes') [%if .206.189.188.16 49.818])
  =.  sponsor.pt  `~marzod
  =/  b  bus
  =^  moves  b  (take-boon b (our-full ~wes pt))
  %+  expect-eq
    !>  `(unit point:jael)``pt
  !>  `(unit point:jael)`(~(get by pos.zim.pki.lex.b) ~wes)
::  A reply in neither shape is logged and dropped, not crashed on.
::
++  test-unrecognized-boon-is-ignored
  ^-  tang
  =/  b  bus
  =^  moves  b  (take-boon b [%public-keys-result %bogus 1])
  ;:  weld
    (expect-eq !>(~) !>(moves))
    (expect-eq !>(%.n) !>((~(has by pos.zim.pki.lex.b) ~marzod)))
  ==
::  A %lost reply (the boon crashed on the way in) resends the plea on
::  the nack timer instead of crashing jael.
::
++  test-lost-boon-resends-the-plea
  ^-  tang
  =/  b  bus
  =^  moves  b  (take-lost b)
  ;:  weld
    %-  expect
    !>  %+  lien  moves
        |=  =move:bus
        ?=([* %pass [%public-keys ~] %b %wait *] move)
    (expect-eq !>(%.y) !>(?=(^ +.tim.lex.b)))
  ==
--
