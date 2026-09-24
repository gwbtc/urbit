::  +with-jael: answer %j scries from a real, empty jael
::
::    unit tests run vanes without jael, so a jael scry from the vane
::    under test would otherwise hit whatever stub roof the test passed
::    in.  jael only answers scries for its own ship at its own time, so
::    we build a fresh one per scry from the beam; with no state, it
::    answers the way a real jael does for ships it has no point for
::    (e.g. %sein gives the default sponsor).  all other scries go to
::    .roof unchanged.
::
/=  jael-raw  /sys/vane/jael
|%
++  with-jael
  |=  =roof
  ^-  ^roof
  |=  [lyc=gang pov=path vis=view bem=beam]
  ^-  (unit (unit cage))
  ?.  &(=(%j vis) ?=([%da @] r.bem))
    (roof lyc pov vis bem)
  =/  jael-core  ((jael-raw p.bem) p.r.bem `@uvJ`0 *^roof)
  (scry:jael-core lyc pov %$ bem)
--
