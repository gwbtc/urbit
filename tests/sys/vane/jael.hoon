/+  *test
/=  jael-raw  /sys/vane/jael
::
=/  bus  (jael-raw ~bus)
=/  now  ~1111.1.1
=/  eny  `@uvJ`0xdead.beef
=/  dom-duct=duct  [[%gall %use %test-dom '0' ~] ~]
::
::  a suite-%c dat: a +mat-encoded pki domain, then opaque domain data.
::
::    The leading +mat is the whole of the kernel's contract with a dat --
::    it is what +dome and +pass-pki-dom:ames read back out, and the
::    kernel never looks past it.  What follows is the domain's business,
::    so this test says nothing about its shape.
::
=/  test-dat=@  (can 0 ~[(mat %test-dom) [32 0xdead.beef]])
=/  cc-core
  (pit:nu:cric:crypto 512 (shaz 'jael-cc-own') %c test-dat 0x1234)
=/  cc-comet  `@p`fig:ex:cc-core
=/  cc-life2-ring
  (sew 3 [1 32 (shaz 'jael-cc-life-2')] sec:ex:cc-core)
=/  cc-life2-core  (nol:nu:cric:crypto cc-life2-ring)
=/  cc-evidence-core
  ::  Same immutable name and live key as .cc-core, different opaque xtr.
  (pit:nu:cric:crypto 512 (shaz 'jael-cc-own') %c test-dat 0xbeef)
=/  cc-life3-ring
  (sew 3 [1 32 (shaz 'jael-cc-life-3')] cc-life2-ring)
=/  foreign-ring
  sec:ex:(pit:nu:cric:crypto 512 (shaz 'jael-foreign-cc') %c test-dat 0x1234)
=/  foreign-comet  `@p`fig:ex:(nol:nu:cric:crypto foreign-ring)
=/  cc-bus  (jael-raw cc-comet)
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
::  +point-at: an exact single-life public authorization
::
++  point-at
  |=  [lyf=life =pass]
  ^-  point:jael
  [rift=0 life=lyf keys=(malt [[lyf [crypto-suite=2 pass]] ~]) sponsor=~ fief=~]
::  +keys-udiff: one generic source update suitable for a fresh point
::
++  keys-udiff
  |=  [who=ship lyf=life crypto-suite=@ud =pass]
  ^-  [=ship =udiff:point:jael]
  [who *id:block:jael %keys [lyf crypto-suite pass] %.n]
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
::  +take-boon: hand jael a generic remote public-key result
::
++  take-boon
  |=  [vane=_bus =public-keys-result:jael]
  ^-  [(list move:bus) _bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core /public-keys dom-duct dud=~ [%ames %boon [%public-keys-result public-keys-result]])
::
++  is-public-keys-move
  |=  =move:bus
  ^-  ?
  ?=([* %give %public-keys *] move)
::
++  is-private-keys-move
  |=  =move:bus
  ^-  ?
  ?=([* %give %private-keys *] move)
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
::  Registering a confidential-PKI domain authorizes only its scoped
::  verdict protocol.  Without an ordinary %listen selection, generic
::  udiffs from that same app cannot rewrite an unrelated numeric ship.
::
++  test-domain-registration-does-not-authorize-generic-udiffs
  ^-  tang
  =/  =pass  (mk-b-pass 'unselected-udiff')
  =/  updates=udiffs:point:jael
    [(keys-udiff ~wes 1 1 pass) ~]
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  moves  b
    (take-fact b %test-dom %azimuth-udiffs !>(updates))
  ;:  weld
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) ~wes)))
    (expect-eq !>(~) !>(moves))
  ==
::  Once selected for that numeric ship, the same app is its ordinary
::  chain source and its update is applied.
::
++  test-selected-app-source-can-update-a-numeric-ship
  ^-  tang
  =/  =pass  (mk-b-pass 'selected-udiff')
  =/  point=point:jael
    [rift=0 life=1 keys=(malt ~[[1 [1 pass]]]) sponsor=~ fief=~]
  =/  updates=udiffs:point:jael
    [(keys-udiff ~wes 1 1 pass) ~]
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  listen-moves  b
    (call b dom-duct [%listen (silt ~[~wes]) [%| %test-dom]])
  =^  moves  b
    (take-fact b %test-dom %azimuth-udiffs !>(updates))
  (expect-eq !>(`point) !>((~(get by pos.zim.pki.lex.b) ~wes)))
::  A selected generic source still has no authority over a comet.
::  Suite-C comet points enter only through the domain-verdict path.
::
++  test-selected-app-source-cannot-inject-a-comet-point
  ^-  tang
  =/  updates=udiffs:point:jael
    [(keys-udiff cc-comet 1 2 pub:ex:cc-core) ~]
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  listen-moves  b
    (call b dom-duct [%listen (silt ~[cc-comet]) [%| %test-dom]])
  =^  moves  b
    (take-fact b %test-dom %azimuth-udiffs !>(updates))
  ;:  weld
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(moves))
  ==
::  A generic remote source is no more authoritative for a comet than a
::  selected local udiff source.  Filter comet entries out of a mixed %full
::  snapshot while retaining the ordinary Azimuth point beside them.
::
++  test-remote-full-cannot-inject-a-comet-point
  ^-  tang
  =/  az-pass  (mk-b-pass 'remote-azimuth')
  =/  az-point=point:jael
    [rift=0 life=1 keys=(malt ~[[1 [1 az-pass]]]) sponsor=~ fief=~]
  =/  cc-point  (point-at 1 pub:ex:cc-core)
  =/  points=(map ship point:jael)
    (malt ~[[~wes az-point] [cc-comet cc-point]])
  =/  b  bus
  =^  listen-moves  b  (call b dom-duct [%listen ~ [%& ~zod]])
  =^  moves  b  (take-boon b [%full points])
  ;:  weld
    (expect-eq !>(`az-point) !>((~(get by pos.zim.pki.lex.b) ~wes)))
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
  ==
::  The same boundary applies to incremental generic updates for a comet
::  whose domain-authorized point is already present.
::
++  test-remote-diff-cannot-update-a-comet-point
  ^-  tang
  =/  old  (point-at 1 pub:ex:cc-core)
  =/  b  (with-point bus cc-comet old)
  =/  dif=diff:point:jael  [%rift 0 1]
  =^  moves  b  (take-boon b [%diff cc-comet dif])
  ;:  weld
    (expect-eq !>(`old) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(moves))
  ==
::  Even an explicit remote-source selection for a comet cannot replace an
::  existing domain-authorized point.  No subscriber may see such a result.
::
++  test-selected-remote-source-cannot-replace-a-comet-point
  ^-  tang
  =/  old  (point-at 1 pub:ex:cc-core)
  =/  b  (with-point bus cc-comet old)
  =^  listen-moves  b
    (call b dom-duct [%listen (silt ~[cc-comet]) [%& ~zod]])
  =^  subscribe-moves  b
    (call b dom-duct [%public-keys (silt ~[cc-comet])])
  =/  points  (malt ~[[cc-comet (point-at 2 pub:ex:cc-life2-core)]])
  =^  full-moves  b  (take-boon b [%full points])
  =^  breach-moves  b  (take-boon b [%breach cc-comet])
  ;:  weld
    (expect-eq !>(`old) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(full-moves))
    (expect-eq !>(~) !>(breach-moves))
  ==
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
::  %snob-notice fact: the domain agent can no longer vouch for a
::  verified ship's attestation and asks it to attest again.  Jael keeps
::  both the point and the domain's peer membership, and gives Ames a
::  [%sybl %snob] so it can soft-block and solicit without losing flows.
::
++  test-snob-notice-retains-point
  ^-  tang
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y (silt ~[~wes ~dev]))
  =/  point  (point-for (mk-c-pass 'wes'))
  =.  b  (with-point b ~wes point)
  =.  b  (with-syl b dom-duct)
  =^  moves  b  (take-fact b %test-dom %snob-notice !>([%test-dom ~wes]))
  ;:  weld
    ::  identity and current keys remain authoritative while it re-attests
    ::
    (expect-eq !>(`point) !>((~(get by pos.zim.pki.lex.b) ~wes)))
    ::  membership is retained, so suspension/revival still includes it
    ::
    %+  expect-eq
      !>  (silt ~[~wes ~dev])
    !>  hep:(~(got by dos.lex.b) %test-dom)
    ::  one soft-block/re-attestation request to the lone subscriber
    ::
    %+  expect-eq
      !>  ~[[dom-duct %give %sybl %snob %test-dom ~wes]]
    !>  moves
  ==
::
++  test-snob-notice-ignores-unregistered
  ::  a snob-notice naming an unknown domain is dropped with no effect
  ::
  ^-  tang
  =/  b  bus
  =/  point  (point-for (mk-c-pass 'wes'))
  =.  b  (with-point b ~wes point)
  =^  moves  b  (take-fact b %test-dom %snob-notice !>([%test-dom ~wes]))
  ;:  weld
    (expect-eq !>(`point) !>((~(get by pos.zim.pki.lex.b) ~wes)))
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
::  A positive domain verdict must identify an actual nonzero current
::  life.  Life zero is state initialization, never a usable key epoch.
::
++  test-verdict-rejects-life-zero
  ^-  tang
  =/  point=point:jael
    :*  rift=0
        life=0
        keys=(malt ~[[0 [crypto-suite=2 pub:ex:cc-core]]])
        sponsor=~
        fief=~
    ==
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `point]))
  ;:  weld
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(moves))
  ==
::  A domain verdict cannot smuggle an ineligible sponsor into Jael's
::  authoritative point.  Comets may be sponsored only by stars or comets.
::
++  test-verdict-rejects-ineligible-sponsor
  ^-  tang
  =/  point  (point-at 1 pub:ex:cc-core)
  =.  sponsor.point  `~bus
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `point]))
  ;:  weld
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(moves))
  ==
::  The answering domain, claimed ship, suite number, and current-life
::  key slot are each part of the positive verdict's authority.  None
::  may be supplied inconsistently by userspace.
::
++  test-verdict-rejects-mismatched-authority
  ^-  tang
  =/  valid  (point-at 1 pub:ex:cc-core)
  =/  wrong-suite=point:jael
    :*  rift=0
        life=1
        keys=(malt ~[[1 [crypto-suite=1 pub:ex:cc-core]]])
        sponsor=~
        fief=~
    ==
  =/  missing-current=point:jael
    :*  rift=0
        life=1
        keys=(malt ~[[2 [crypto-suite=2 pub:ex:cc-life2-core]]])
        sponsor=~
        fief=~
    ==
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =.  b  (with-dom b %other-dom %other-dom-desk %.y ~)
  =^  wrong-domain-moves  b
    (take-fact b %other-dom %verdict !>([%other-dom cc-comet `valid]))
  =^  wrong-name-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom foreign-comet `valid]))
  =^  wrong-suite-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `wrong-suite]))
  =^  missing-key-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `missing-current]))
  ;:  weld
    (expect-eq !>(~) !>(wrong-domain-moves))
    (expect-eq !>(~) !>(wrong-name-moves))
    (expect-eq !>(~) !>(wrong-suite-moves))
    (expect-eq !>(~) !>(missing-key-moves))
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>((~(get by pos.zim.pki.lex.b) foreign-comet)))
  ==
::  At a fixed life, the live cry is immutable.  The domain may refresh
::  opaque evidence and independently raise the rift, but may not swap
::  the signing key under the same life number.
::
++  test-verdict-same-life-keeps-cry-but-can-refresh-evidence
  ^-  tang
  =/  old  (point-at 1 pub:ex:cc-core)
  =/  changed-cry  (point-at 1 pub:ex:cc-life2-core)
  =/  refreshed  (point-at 1 pub:ex:cc-evidence-core)
  =.  rift.refreshed  1
  =/  b  (with-dom bus %test-dom %test-dom-desk %.y ~)
  =^  initial-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `old]))
  =^  changed-cry-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `changed-cry]))
  =/  after-rejected  (~(get by pos.zim.pki.lex.b) cc-comet)
  =^  refresh-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `refreshed]))
  ;:  weld
    (expect !>(!=(pub:ex:cc-core pub:ex:cc-evidence-core)))
    %+  expect-eq
      !>(cry.pub.+<.cc-core)
    !>(cry.pub.+<.cc-evidence-core)
    (expect !>(!=(cry.pub.+<.cc-core cry.pub.+<.cc-life2-core)))
    (expect-eq !>(`old) !>(after-rejected))
    (expect-eq !>(~) !>(changed-cry-moves))
    (expect-eq !>(`refreshed) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
  ==
::  Life and rift are independently monotone across positive verdicts.
::
++  test-verdict-rejects-counter-rollbacks
  ^-  tang
  =/  old  (point-at 2 pub:ex:cc-life2-core)
  =.  rift.old  2
  =/  old-life  (point-at 1 pub:ex:cc-core)
  =.  rift.old-life  2
  =/  old-rift  (point-at 3 pub:ex:cc-life2-core)
  =.  rift.old-rift  1
  =/  b  (with-point bus cc-comet old)
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =^  life-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `old-life]))
  =^  rift-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `old-rift]))
  ;:  weld
    (expect-eq !>(`old) !>((~(get by pos.zim.pki.lex.b) cc-comet)))
    (expect-eq !>(~) !>(life-moves))
    (expect-eq !>(~) !>(rift-moves))
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
  =/  =pass  (mk-c-pass 'fief-verdict')
  =/  who  `@p`fig:ex:(com:nu:cric:crypto pass)
  =/  pt  (point-with-fief pass fef)
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =.  b  (with-fel b dom-duct)
  =^  moves  b  (take-fact b %test-dom %verdict !>([%test-dom who `pt]))
  ;:  weld
    ::  the route is now in jael's own fief registry
    ::
    (expect-eq !>(`fef) !>((~(get by fes.zim.pki.lex.b) who)))
    ::  ... and was pushed to the %fief subscriber
    ::
    %-  expect
    !>  %+  lien  moves
        |=  =move:bus
        =(+.move [%give %fief (my [who `fef]~)])
  ==
::
++  test-verdict-without-a-fief-publishes-nothing
  ^-  tang
  =/  =pass  (mk-c-pass 'no-fief-verdict')
  =/  who  `@p`fig:ex:(com:nu:cric:crypto pass)
  =/  b  bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =.  b  (with-fel b dom-duct)
  =^  moves  b
    (take-fact b %test-dom %verdict !>([%test-dom who `(point-for pass)]))
  %-  expect
  !>  ?!
      %+  lien  moves
      |=(=move:bus ?=([* %give %fief *] move))
::  Own suite-C keys become active only when Jael holds both halves of
::  the same chain life.  A point arriving first publishes normally but
::  does not advance the private-key life until the matching ring lands.
::
++  test-own-key-reconcile-point-first
  ^-  tang
  =/  pt  (point-at 2 pub:ex:cc-life2-core)
  =/  b  cc-bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =^  init-moves  b  (call b dom-duct [%private-keys ~])
  =^  point-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `pt]))
  =/  before-ring  b
  =^  ring-moves  b  (call b dom-duct [%rekey 2 cc-life2-ring])
  ;:  weld
    (expect-eq !>(`pt) !>((~(get by pos.zim.pki.lex.before-ring) cc-comet)))
    (expect-eq !>(0) !>(lyf.own.pki.lex.before-ring))
    (expect-eq !>(~) !>((~(get by jaw.own.pki.lex.before-ring) 2)))
    (expect-eq !>(~) !>(point-moves))
    (expect-eq !>(2) !>(lyf.own.pki.lex.b))
    (expect-eq !>(`cc-life2-ring) !>((~(get by jaw.own.pki.lex.b) 2)))
    (expect-eq !>(1) !>((lent ring-moves)))
    (expect !>((is-private-keys-move (snag 0 ring-moves))))
  ==
::  If the ring arrives first it is cached but inert.  The later point
::  must publish before Jael tells Ames to use the newly-authorized ring.
::
++  test-own-key-reconcile-ring-first
  ^-  tang
  =/  pt  (point-at 2 pub:ex:cc-life2-core)
  =/  b  cc-bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =^  private-init  b  (call b dom-duct [%private-keys ~])
  =^  public-init  b
    (call b dom-duct [%public-keys (silt ~[cc-comet])])
  =^  ring-moves  b  (call b dom-duct [%rekey 2 cc-life2-ring])
  =/  before-point  b
  =^  point-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `pt]))
  ;:  weld
    (expect-eq !>(~) !>(ring-moves))
    (expect-eq !>(0) !>(lyf.own.pki.lex.before-point))
    (expect-eq !>(`cc-life2-ring) !>((~(get by jaw.own.pki.lex.before-point) 2)))
    (expect-eq !>(2) !>(lyf.own.pki.lex.b))
    (expect-eq !>(2) !>((lent point-moves)))
    (expect !>((is-public-keys-move (snag 0 point-moves))))
    (expect !>((is-private-keys-move (snag 1 point-moves))))
  ==
::  Future private material is harmless cache state.  Neither a ring
::  for a different comet nor a ring beyond the authorized point may
::  advance the active life; replacing the exact point-life slot with
::  its matching ring then activates it once, after which that active
::  slot cannot be overwritten by a different ring.
::
++  test-own-key-reconcile-rejects-wrong-and-future-rings
  ^-  tang
  =/  pt  (point-at 2 pub:ex:cc-life2-core)
  =/  b  cc-bus
  =.  b  (with-dom b %test-dom %test-dom-desk %.y ~)
  =^  init-moves  b  (call b dom-duct [%private-keys ~])
  =^  point-moves  b
    (take-fact b %test-dom %verdict !>([%test-dom cc-comet `pt]))
  =^  wrong-moves  b  (call b dom-duct [%rekey 2 foreign-ring])
  =^  future-moves  b  (call b dom-duct [%rekey 3 cc-life3-ring])
  =/  before-correct  b
  =^  correct-moves  b  (call b dom-duct [%rekey 2 cc-life2-ring])
  =^  overwrite-moves  b  (call b dom-duct [%rekey 2 foreign-ring])
  ;:  weld
    (expect-eq !>(~) !>(wrong-moves))
    (expect-eq !>(~) !>(future-moves))
    (expect-eq !>(0) !>(lyf.own.pki.lex.before-correct))
    (expect-eq !>(`foreign-ring) !>((~(get by jaw.own.pki.lex.before-correct) 2)))
    (expect-eq !>(`cc-life3-ring) !>((~(get by jaw.own.pki.lex.before-correct) 3)))
    (expect-eq !>(2) !>(lyf.own.pki.lex.b))
    (expect-eq !>(`cc-life2-ring) !>((~(get by jaw.own.pki.lex.b) 2)))
    (expect-eq !>(1) !>((lent correct-moves)))
    (expect !>((is-private-keys-move (snag 0 correct-moves))))
    (expect-eq !>(~) !>(overwrite-moves))
  ==
--
