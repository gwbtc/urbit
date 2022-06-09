::  gnosis-safe.hoon
::
/-  eth-watcher
/+  dbug, default-agent, ethereum, *gnosis-safe, azimuth
=,  ethereum
=,  eth-watcher
|%
+$  versioned-state
    $%  state-0
    ==
::
:: +$  safe-state
  
+$  state-0
    $:  %0
        ~
    ==

+$  card  card:agent:gall
+$  topics  topics:eth-watcher
+$  loglist  (list event-log:rpc:ethereum)
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
  |_  bol=bowl:gall
  +*  this      .
      gc    ~(. +> bol)
      def   ~(. (default-agent this %|) bol)
  ::
  ++  on-init
    ^-  (quip card _this)
    ~&  >  '%gnosis-safe initialized successfully'
    `this
  ++  on-save
    ^-  vase
    !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    ~&  >  '%gnosis-safe recompiled successfully'
    `this(state !<(versioned-state old-state))
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    `this
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
|_  bol=bowl:gall
++  start
  |=  [url=@t safe=address]
  ^-  (list card:agent:gall)
  |^
  =-  :~  weld
          (watch url /safe-txs/[-] [~[safe] ~])
          (watch url /xfers/from/[-] [~[safe] ~[transfer.event-sigs safe ~]])
          (watch url /xfers/to/[-] [~[safe] ~[transfer.event-sigs ~ safe]])
      ==
  (scot %ux safe)
  ::
  ++  watch
    |=  [url=@t =wire addresses=(list address) events=filter batchers=filter tracers=filter]
    ^-  (list card)
    =/  args
    !>
    :+  %watch  wire
    ^-  config:eth-watcher
    :*  url  &  ~m5  ~m30
        100.000
        events
        batchers
        tracers
    ==
    :~  [%pass /wa %agent [our.bol %eth-watcher] %poke %eth-watcher-poke args]
        [%pass wire %agent [our.bol %eth-watcher] %watch [%logs wire]]
    ==
  ::
  --
::
--