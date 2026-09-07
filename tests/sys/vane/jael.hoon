/+  *test
/=  jael-raw  /sys/vane/jael
::
=/  bus  (jael-raw ~bus)
=/  now  ~1111.1.1
=/  eny  `@uvJ`0xdead.beef
=/  gw-duct=duct  [[%gall %use %gw-btc '0' ~] ~]
=/  admin-duct=duct  ~[/admin]
::
=>
|%
++  call
  |=  [vane=_bus =duct wrapped-task=(hobo task:jael)]
  =/  core  (vane now=now eny=eny rof=*roof)
  (call:core duct dud=~ wrapped-task)
::
++  take
  |=  [vane=_bus =wire =duct =sign:bus]
  =/  core  (vane now=now eny=eny rof=*roof)
  (take:core wire duct dud=~ sign)
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
::
++  leave-move
  |=  =duct
  ^-  move:bus
  :*  duct
      %pass
      /gw-btc/writs
      %g
      %deal
      [~bus ~bus /jael]
      %gw-btc
      %leave
      ~
  ==
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
::
::  Banning explicitly leaves the retained Gall watch and snubs the domain's
::  peers.  The tombstone then prevents the compromised agent from registering
::  itself again.
::
++  test-bane-leaves-and-tombstones
  ^-  tang
  =^  first-moves  bus  (call bus gw-duct %anex /writs)
  =^  bane-moves  bus  (call bus admin-duct %bane %gw-btc)
  =/  expected=(list move:bus)
    :~  (leave-move admin-duct)
        [admin-duct %pass /bane %a %snub %deny ~]
    ==
  =/  leave-result  (expect-eq !>(expected) !>(bane-moves))
  =/  tombstone-result
    %-  expect-fail
    |.  (call bus gw-duct %anex /writs)
  (weld leave-result tombstone-result)
::
::  A domain can also have been configured as a legacy local Azimuth source.
::  After %bane, an already-queued generic udiff from that agent must still be
::  ignored: the tombstone wins over the stale legacy-source entry.
::
++  test-bane-drops-queued-dual-role-udiff
  ^-  tang
  =^  listen-moves  bus
    (call bus admin-duct %listen ~ %| %gw-btc)
  =^  first-moves  bus  (call bus gw-duct %anex /writs)
  =^  bane-moves  bus  (call bus admin-duct %bane %gw-btc)
  =/  before  (stay bus)
  =/  =udiffs:point:jael
    :~  [~zod *id:block:jael %spon `~bus]
    ==
  =/  =sign:bus
    [%gall %unto %fact %azimuth-udiffs !>(udiffs)]
  =^  fact-moves  bus
    (take bus /gw-btc/writs ~[/queued-fact] sign)
  =/  after  (stay bus)
  ;:  weld
    (expect-eq !>(*(list move:bus)) !>(fact-moves))
    (expect-eq !>(before) !>(after))
  ==
--
