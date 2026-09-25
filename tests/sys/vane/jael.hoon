/+  *test
/=  jael-raw  /sys/vane/jael
::
=/  bus  (jael-raw ~bus)
=/  now  ~1111.1.1
=/  eny  `@uvJ`0xdead.beef
=/  gw-duct=duct  [[%gall %use %gw-btc '0' ~] ~]
::
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
--
