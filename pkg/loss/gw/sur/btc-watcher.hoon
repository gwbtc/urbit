::  eth-watcher: ethereum event log collector
::
/-  bc=bitcoin
=*  block  block:bc
|%
+$  config
  $:  ::  url: ethereum node rpc endpoint
      ::  eager: if true, give logs asap, send disavows in case of reorg
      ::  refresh-rate: rate at which to check for updates
      ::  timeout-time: time an update check is allowed to take
      ::  from: oldest block number to look at
      ::  to: optional newest block number to look at
      ::  contracts: contract addresses to look at
      ::  topics: event descriptions to look for
      ::
      url=@ta
      ::eager=?
      refresh-rate=@dr
      timeout-time=@dr
      from=num:block
      to=[lat=? and=(list num:block)]
      at=id:block
  ==
::
::+$  watchpup
::  $:  config
::      blocks=bap
::  ==
++  bon  ((on num:block block) lte)
++  bap  ((mop num:block block) lte)
::
::  disavows: newest block first
+$  disavows  (list id:block)
::
+$  poke
  $%  ::  %watch: configure a watchdog and fetch initial logs
      ::
      [%watch from=num:block to=(unit num:block)]
      [%config config]
      ::  %clear: remove a watchdog
      ::
      [%clear =path]
  ==
::
+$  diff
  $@  %done
  $%  [%blocks blocks=bap]
      [%disavow id:block]
  ==
--
