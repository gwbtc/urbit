::  eth-watcher: ethereum event log collector
::
/-  spider, *eth-watcher
/+  strandio, ethio, azimuth, eth-trace-io, eth-trace
=,  ethereum-types
=,  jael
::
::  Main loop: get updates since last checked
::
|=  args=vase
|^
=+  !<([~ pup=watchpup] args)
=/  m  (strand:strandio ,vase)
^-  form:m
;<  =latest=block  bind:m  (get-latest-block:ethio url.pup)
;<  pup=watchpup   bind:m  (zoom pup number.id.latest-block)
;<  [vows=disavows pup=watchpup]  bind:m  (crawl pup number.id.latest-block)
;<  pup=watchpup   bind:m  (drench pup)
(pure:m !>([vows pup]))
::
++  crawl
  |=  [pup=watchpup =latest=number:block]
  =/  m  (strand:strandio ,[disavows watchpup])
  ^-  form:m
  ?.  eager.pup  (pure:m [~ pup])
  =|  vows=disavows
  |-  ^-  form:m
  =*  loop  $
  ?:  (gth number.pup latest-number)
    (pure:m [~ pup])
  ;<  =block  bind:m                (get-block-by-number:ethio url.pup number.pup)
  ;<  [=new=disavows pup=watchpup]  bind:m  (take-block pup block)
  %=  loop
    pup   pup
    vows  (weld vows new-disavows)
  ==
::
::  Process a block, detecting and handling reorgs
::
++  take-block
  |=  [pup=watchpup =block]
  =/  m  (strand:strandio ,[disavows watchpup])
  ^-  form:m
  ::  if this next block isn't direct descendant of our logs, reorg happened
  ?:  &(?=(^ blocks.pup) !=(parent-hash.block hash.id.i.blocks.pup))
    (rewind pup block)
  =,  pup
  =/  contracts
    %-  merge-ux
    %+  murn  filters
    |=  =filter
    ?~  addresses.filter  ~
    `addresses.filter
  =/  topics
    %-  unify-topics
    %+  murn  filters
    |=  =filter
    ?~  topics.filter  ~
    `topics.filter
  ;<  =new=loglist  bind:m  ::  oldest first
    (get-logs-by-hash:ethio url.pup hash.id.block contracts topics)
  %-  pure:m
  :-  ~
  %_  pup
    number        +(number.id.block)
    pending-logs  (~(put by pending-logs.pup) number.id.block new-loglist)
    blocks        [block blocks.pup]
  ==
::
::  Reorg detected, so rewind until we're back in sync
::
++  rewind
  ::  block: wants to be head of blocks.pup, but might not match
  |=  [pup=watchpup =block]
  =/  m  (strand:strandio ,[disavows watchpup])
  =*  blocks  blocks.pup
  =|  vows=disavows
  |-  ^-  form:m
  =*  loop  $
  ::  if we have no further history to rewind, we're done
  ?~  blocks
    (pure:m (flop vows) pup(blocks [block blocks]))
  ::  if target block is directly after "latest", we're done
  ?:  =(parent-hash.block hash.id.i.blocks)
    (pure:m (flop vows) pup(blocks [block blocks]))
  ::  next-block: the new target block
  ;<  =next=^block  bind:m
    (get-block-by-number:ethio url.pup number.id.i.blocks)
  =.  pending-logs.pup  (~(del by pending-logs.pup) number.id.i.blocks)
  =.  vows  [id.block vows]
  loop(block next-block, blocks t.blocks)
::
::  Zoom forward to near a given block number.
::
::    Zooming doesn't go forward one block at a time.  As a
::    consequence, it cannot detect and handle reorgs.  Only use it
::    at a safe distance -- 100 blocks ago is probably sufficient.
::
++  zoom
  |=  [pup=watchpup =latest=number:block]
  =/  m  (strand:strandio ,watchpup)
  ^-  form:m
  =/  zoom-margin=number:block  30
  =/  zoom-step=number:block    100.000
  ?:  (lth latest-number (add number.pup zoom-margin))
    (pure:m pup)
  =/  up-to-number=number:block
    (min (add 10.000.000 number.pup) (sub latest-number zoom-margin))
  |-
  =*  loop  $
  ?:  (gth number.pup up-to-number)
    (pure:m pup(blocks ~))
  =/  to-number=number:block
    =;  step
      (min up-to-number (add number.pup step))
    ::  Between "launch" (6.784.800) and "public" (7.033.765) blocks,
    ::  there are a lot events belo=/  connging to all the pre-ethereum ships
    ::  being established on-chain. By reducing the step, we avoid crashing.
    ::
    ?.  =(contracts:azimuth mainnet-contracts:azimuth)
      zoom-step
    ?:  ?|  &((gte number.pup 6.951.132) (lth number.pup 6.954.242))
            &((gte number.pup 7.011.857) (lth number.pup 7.021.881))
        ==
      50
    ?:  ?&  (gte number.pup launch:mainnet-contracts:azimuth)
            (lth number.pup public:mainnet-contracts:azimuth)
        ==
      500
    zoom-step
  ;<  =loglist  bind:m  ::  oldest first
    =,  pup
    =/  contracts
      %-  merge-ux
      %+  murn  filters
      |=  =filter
      ?~  addresses.filter  ~
      `addresses.filter
    =/  topics
      %-  unify-topics
      %+  murn  filters
      |=  =filter
      ?~  topics.filter  ~
      `topics.filter
    %:  get-logs-by-range:ethio
      url.pup
      contracts
      topics
      number.pup
      to-number
    ==
  =?  pending-logs.pup  ?=(^ loglist)
    (~(put by pending-logs.pup) to-number loglist)
  loop(number.pup +(to-number))
::  Fetch trace and/or tx data
::
++  drench
  |=  pup=watchpup
  =/  m  (strand:strandio ,watchpup)
  =|  res=(list [number:block loglist])
  =/  pending=(list [=number:block =loglist])  ~(tap by pending-logs.pup)
  |-  ^-  form:m
  =*  loop  $
  ?~  pending
    (pure:m pup(pending-logs (malt res)))
  ;<  logs=(list event-log:rpc:ethereum)  bind:m
    (drench-log pup loglist.i.pending)
  =.  res  [[number.i.pending logs] res]
  loop(pending t.pending)
::  Fetch trace and/or tx data for a log
::
++  drench-log
  |=  [pup=watchpup logs=(list event-log:rpc:ethereum)]
  =/  m  (strand:strandio ,(list event-log:rpc:ethereum))
  =|  res=(list event-log:rpc:ethereum)
  |-  ^-  form:m
  =*  loop  $
  ?~  logs
    (pure:m (flop res))
  ;<  log=event-log:rpc:ethereum  bind:m  (fetch-input pup i.logs)
  ;<  log=event-log:rpc:ethereum  bind:m  (fetch-trace pup i.logs)
  =.  res  [log res]
  loop(logs t.logs)
::
++  unify-topics
  |=  lat=(list (list ?(@ux (list @ux))))
  =-  (turn - |=(topic=?(@ux (list @ux)) ?^(topic (merge-ux ~[topic]) topic)))
  %+  roll  lat
  |=  [topics=(list ?(@ux (list @ux))) out=(list ?(@ux (list @ux)))]
  =|  rout=_out
  |-  ^-  _out
  ?~  topics  (flop rout)
  =/  topic=?(@ux (list @ux))
    ?:  ?=(?(~ [~ *]) out)  i.topics
    ?~  i.topics  i.out
    ?~  i.out  i.topics
    ?^  i.out  ?^(i.topics (weld i.topics i.out) [i.topics i.out])
    ?^  i.topics  [i.out i.topics]  ~[i.topics i.out]
  %_  $
    rout  [topic rout]
    topics  t.topics
    out  ?~(out ~ t.out)
  ==
::
++  merge-ux
  |=  uxes=(list (list @ux))
  %~  tap  in
  %+  reel  uxes
  |=  [=(list @ux) =(set @ux)]
  ?~  list  set
  (~(gas in set) list)
::  Fetch input for a log
::
++  fetch-input
  |=  [pup=watchpup log=event-log:rpc:ethereum]
  =/  m  (strand:strandio ,event-log:rpc:ethereum)
  ^-  form:m
  ?~  mined.log
    (pure:m log)
  ?^  tx.u.mined.log
    (pure:m log)
  ?.  (filter-event filters.pup log %tx)
    (pure:m log)
  ;<  res=transaction-result:rpc:ethereum  bind:m
    (get-tx-by-hash:ethio url.pup transaction-hash.u.mined.log)
  (pure:m log(tx.u.mined `[from.res to.res (data-to-hex input.res)]))
::  Fetch trace data for a log
::
++  fetch-trace
  |=  [pup=watchpup log=event-log:rpc:ethereum]
  =/  m  (strand:strandio ,event-log:rpc:ethereum)
  ^-  form:m
  ?~  mined.log
    (pure:m log)
  ?^  trace.u.mined.log
    (pure:m log)
  ?.  (filter-event filters.pup log %trace)
    (pure:m log)
  =+  [~ rpc-url txh]=!<([~ @t @ux] args)
  ;<  trace=raw-trace:eth-trace  bind:m
    (trace-tx:eth-trace-io url.pup transaction-hash.u.mined.log)
  (pure:m log(trace.u.mined `trace))
::
++  filter-event
  |=  [filters=(list filter) log=event-log:rpc:ethereum fac=?(%trace %tx)]
  |^  ^-  ?
  %+  lien  filters
  |=  =filter
  ?&  (lien addresses.filter |=(=@ux =(ux address.log)))
      (filter-topics topics.log filter)
  ==
  ::
  ++  filter-topics
    |=  [topics=(list @ux) =filter]
    |-  ^-  ?
    ?.  |(&(=(fac %tx) tx.filter) &(=(fac %trace) trace.filter))  |
    ?~  topics.filter  &
    ?~  topics  |
    ?~  i.topics.filter  $(topics.filter t.topics.filter, topics t.topics)
    ?:  ?=(@ i.topics.filter)  &(=(i.topics.filter i.topics) $(topics.filter t.topics.filter, topics t.topics))
    &((lien `(list @ux)`i.topics.filter |=(=@ux =(ux i.topics))) $(topics.filter t.topics.filter, topics t.topics))
  --
::
++  data-to-hex
  |=  data=@t
  ^-  @ux
  ?~  data  *@ux
  ?:  =(data '0x')  *@ux
  (hex-to-num:ethereum data)
--
