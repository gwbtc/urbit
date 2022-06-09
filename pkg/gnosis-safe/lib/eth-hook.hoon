::  lib/eth-hook: helper for creating a push hook
::  
::   lib/eth-hook is a helper for automatically pulling data from a
::   corresponding push-hook to a store. 
::   
::   ## Interfacing notes:
::
::   The inner door may interact with the library by producing cards.
::   Do not pass any cards on a wire beginning with /helper as these
::   wires are reserved by this library. Any watches/pokes/peeks not
::   listed below will be routed to the inner door.
::
::   ##  Subscription paths
::
::   /tracking: The set of resources we are pulling
::
::   ##  Pokes
::
::   %eth-hook-action: Add/remove a resource from pulling.
::
/-  *eth-hook
/+  default-agent, resource, versioning, agentio, eth-hook-virt
::
|%
+$  card   card:agent:gall
::
::  $config: configuration for the pull hook
::
::    .store-name: name of the store to send subscription updates to.
::    .update-mark: mark that updates will be tagged with, without
::    version number
::    .push-hook-name: name of the corresponding push-hook
::    .no-validate: If true, don't validate that resource/wire/src match
::    up
::
+$  config
  $:  store-name=term
      update=mold
      update-mark=term
      version=@ud
      min-version=@ud
      no-validate=_|
  ==
::  
::  $base-state-0: state for the pull hook
::
::    .tracking: a map of resources we are pulling, and the ships that
::    we are pulling them from.
::    .inner-state: state given to internal door
::
+$  track
  [=ship =status]
::
+$  status
  $%  [%active ~]
      [%failed-kick ~]
      [%pub-ver ver=@ud]
      [%sub-ver ver=@ud]
  ==
::
++  versioned-state
  =|  config=config-0
  |@
  ++  hook  (eth-hook config)
  +$  on-event-form  _*eval-form:eval:(strand ,vase)
  +$  on-block-form    eval-form:eval:(strand (quip diff-mold _^|(..on-init:agent:hook)))
  
  --
::
+$  state-0  [%0 base-state-0]
::
+$  versioned-state 
  $%  state-0
  ==
++  eth-hook
  |*  config
  $_  ^|
  |_  bowl:gall
  ::  +on-reorg: handle failed pull subscription
  ::
  ::    This arm is called when a pull subscription fails. lib/eth-hook
  ::    will automatically delete the resource from .tracking by the
  ::    time this arm is called.
  ::
  ++  on-reorg
    |~  [=block]
    *[(list card) _^|(..on-init)]
  ::
  ++  on-event
    |~  [=event]
    *eval-form:eval:(strand (quip cards _^|(..on-init)))
  ::  from agent:gall
  ++  on-init
    *[(list card) _^|(..on-init)]
  ::
  ++  on-save
    *vase
  ::
  ++  on-load
    |~  vase
    *[(list card) _^|(..on-init)]
  ::
  ++  on-poke
    |~  [mark vase]
    *[(list card) _^|(..on-init)]
  ::
  ++  on-watch
    |~  path
    *[(list card) _^|(..on-init)]
  ::
  ++  on-leave
    |~  path
    *[(list card) _^|(..on-init)]
  ::
  ++  on-peek
    |~  path
    *(unit (unit cage))
  ::
  ++  on-agent
    |~  [wire sign:agent:gall]
    *[(list card) _^|(..on-init)]
  ::
  ++  on-arvo
    |~  [wire sign-arvo]
    *[(list card) _^|(..on-init)]
  ::
  ++  on-fail
    |~  [term tang]
    *[(list card) _^|(..on-init)]
  --
++  agent
  |*  =config
  |=  =(eth-hook config)
  =|  state-0
  =*  state  -
  ^-  agent:gall
  =<
    |_  =bowl:gall
    +*  this  .
        og   ~(. eth-hook bowl)
        hc   ~(. +> bowl)
        def  ~(. (default-agent this %|) bowl)
        :: ver  ~(. versioning [bowl [update-mark version min-version]:config])
        io   ~(. agentio bowl)
        pass  pass:io
    ::
    ++  on-init
      ^-  [(list card:agent:gall) agent:gall]
      =^  cards  eth-hook
        on-init:og
      [cards this]
    ::
    ++  on-load
      |=  =old=vase
      =/  old
        !<(versioned-state old-vase)
      =|  cards=(list card:agent:gall)
      ?-  -.old
          %0
        =^  og-cards   eth-hook
          (on-load:og inner-state.old)
      ==
    ::
    ++  on-save
      ^-  vase
      =:  inner-state       on-save:og
          prev-min-version  min-version.config
          prev-version      version.config
        ==
      !>(state)
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  [(list card:agent:gall) agent:gall]
      ?+   mark
        =^  cards  eth-hook
          (on-poke:og mark vase)
        [cards this]
        ::
          %eth-hook-action
        ?>  (team:title [our src]:bowl)
        =^  [cards=(list card) hook=_eth-hook]  state
          tr-abet:(tr-hook-act:track-engine:hc !<(action vase))
        =.  eth-hook  hook
        [cards this]
      ::
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  [(list card:agent:gall) agent:gall]
      ?>  (team:title our.bowl src.bowl)
      ?+    path
      ::  forward by default
        =^  cards  eth-hook
          (on-watch:og path)
        [cards this]
      ::
        [%nack ~]  `this
      ::
          [%tracking ~]
        :_  this
        ~[give-update]
      ==
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  [(list card:agent:gall) agent:gall]
      ?.  ?=([%helper %eth-hook @ *] wire)
        =^  cards  eth-hook
          (on-agent:og wire sign)
        [cards this]
      ?:  ?=([%version ~] t.t.wire)
        =^  [cards=(list card) hook=_eth-hook]  state
          (take-version:hc src.bowl sign)
        =.  eth-hook  hook
        [cards this]
      `this
    ::
    ++  on-leave
      |=  =path
      ^-  [(list card:agent:gall) agent:gall]
      =^  cards  eth-hook
        (on-leave:og path)
      [cards this]
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  [(list card:agent:gall) agent:gall]
      =^  cards  eth-hook
        (on-arvo:og wire sign-arvo)
      [cards this]
    ::
    ++  on-fail
      |=  [=term =tang]
      ^-  [(list card:agent:gall) agent:gall]
      =^  cards  eth-hook
        (on-fail:og term tang)
      [cards this]
    ::
    ++  on-peek   
      |=  =path
      ^-  (unit (unit cage))
      ?:  =(/x/dbug/state path)
        ``noun+(slop !>(state(inner-state *vase)) on-save:og)
      ?.  =(/x/tracking path)
        (on-peek:og path)
      ``noun+!>(~(key by tracking))
    --
  |_  =bowl:gall
  +*  og   ~(. eth-hook bowl)
      io   ~(. agentio bowl)
      pass  pass:io
      virt  ~(. eth-hook-virt bowl)
      ver  ~(. versioning [bowl [update-mark version min-version]:config])
  ::
  ++  take-input
    ~/  %take-input
    |=  [=yarn input=(unit input:strand)]
    ^-  (quip card ^state)
    !!
  ::
  ++  start-thread
    ~/  %start-thread
    |=  [=yarn =thread]
    ^-  (quip card ^state)
    =/  =vase  vase:(~(got by starting.state) yarn)
    ?<  (has-yarn running.state yarn)
    =/  m  (strand ,^vase)
    =/  res  (mule |.((thread vase)))
    ?:  ?=(%| -.res)
      (thread-fail-not-running (yarn-to-tid yarn) %false-start p.res)
    =/  =eval-form:eval:m
      (from-form:eval:m p.res)
    =:  starting.state  (~(del by starting.state) yarn)
        running.state   (put-yarn running.state yarn eval-form)
      ==
    (take-input yarn ~)
  ::
  ++  on-watch
    |=  [=tid =path]
    (take-input (~(got by tid.state) tid) ~ %watch path)
  ::
  ++  handle-sign
    ~/  %handle-sign
    |=  [=tid =wire =sign-arvo]
    =/  yarn  (~(get by tid.state) tid)
    ?~  yarn
      %-  (slog leaf+"spider got sign for non-existent {<tid>}" ~)
      `state
    (take-input u.yarn ~ %sign wire sign-arvo)
  ::
  ++  on-agent
    |=  [=tid =wire =sign:agent:gall]
    =/  yarn  (~(get by tid.state) tid)
    ?~  yarn
      %-  (slog leaf+"spider got agent for non-existent {<tid>}" ~)
      `state
    (take-input u.yarn ~ %agent wire sign)
  ::
  --
++  config
  $:  diff-mold=mold
  ==
+$  card
++  eth-hook
  |*  =config
  |%
  +$  card
    $%  card:agent:gall
        [%sub =wire =eth-config]
        [%unsub =wire]
    ==
  ++  agent
    $_  ^|
    |_  bowl:gall
    :: ++  on-rein
    ::   |~  [=wire =sub-mold.diff]
    ::   *eval-form:eval:(strand (quip hook-card _^|(..on-init)))
    :: ::
    ++  on-reorg
      |~  [=wire =block]
      *[(list diff-mold) _^|(..on-init)]
    ::
    ++  on-event
      |~  [=wire =event]
      *eval-form:eval:(strand (quip diff-mold _^|(..on-init)))
    ::
    ++  on-block
      |~  [=wire =block diffs=(list diff-mold)]
      *eval-form:eval:(strand (quip card _^|(..on-init)))
    ::  from agent:gall
    ++  on-init
      *(quip card _^|(..on-init))
    ::
    ++  on-save
      *vase
    ::
    ++  on-load
      |~  vase
      *(quip card _^|(..on-init))
    ::
    ++  on-poke
      |~  [mark vase]
      *(quip card _^|(..on-init))
    ::
    ++  on-watch
      |~  path
      *(quip card _^|(..on-init))
    ::
    ++  on-leave
      |~  path
      *(quip card _^|(..on-init))
    ::
    ++  on-peek
      |~  path
      *(unit (unit cage))
    ::
    ++  on-agent
      |~  [wire sign:agent:gall]
      *(quip card _^|(..on-init))
    ::
    ++  on-arvo
      |~  [wire sign-arvo]
      *(quip card _^|(..on-init))
    ::
    ++  on-fail
      |~  [term tang]
      *(quip card _^|(..on-init))
    --
  --
::
--