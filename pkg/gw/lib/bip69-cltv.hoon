/-  *bolt, psbt
|%
++  output-lte
  |=  [a=(pair out:tx:psbt blocks) b=(pair out:tx:psbt blocks)]
  ?.  =(value.p.a value.p.b)
    (lth value.p.a value.p.b)
  ?.  =(dat.script-pubkey.p.a dat.script-pubkey.p.b)
    (lte dat.script-pubkey.p.a dat.script-pubkey.p.b)
  (lte q.a q.b)
::
++  sort-outputs
  |=  [os=(list out:tx:psbt) cltvs=(list blocks)]
  |^  ^-  (list out:tx:psbt)
  %+  turn
    %+  sort  pairs  output-lte
  |=  pir=(pair out:tx:psbt blocks)
  p.pir
  ::
  ++  pairs
    ^-  (list (pair out:tx:psbt blocks))
    =/  outs=(list out:tx:psbt)  os
    =/  vals=(list blocks)       cltvs
    =|  pirs=(list (pair out:tx:psbt blocks))
    |-
    ?~  outs  pirs
    %=  $
      outs   +.outs
      vals   +.vals
      pirs  :-([p=(head outs) q=(head vals)] pirs)
    ==
  --
--
