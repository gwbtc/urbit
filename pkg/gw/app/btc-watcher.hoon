::  btc-watcher: btc block source
::
/-  *btc-watcher, spider
/+  nothereum, default-agent, verb, dbug
=,  nothereum-types
=,  jael
::
=>  |%
    +$  card  card:agent:gall
    +$  app-state
      $:  %0
          syncs=(map @ud [rc=@ud to=(map num:block)])
          ted=(unit [since=@ud =tid:spider])
          con=config
          at=(unit id:block)
      ==
    ::
    ::+$  context  [=path dog=watchdog]
    ::+$  watchdog
    ::  $:  config
    ::      running=(unit [since=@da =tid:spider])
    ::      blocks=bap
    ::      id:block
    ::  ==
    ::::
    ::::  history: newest block first, oldest event first
    ::+$  history  (list loglist)
    --
::
::  Helpers
::
=>  |%
    ++  wait
      |=  [=path now=@da time=@dr]
      ^-  card
      [%pass [%timer path] %arvo %b %wait (add now time)]
    ::
    ++  wait-shortcut
      |=  [=path now=@da]
      ^-  card
      [%pass [%timer path] %arvo %b %wait now]
    ::
    ++  poke-spider
      |=  [=path our=@p =cage]
      ^-  card
      [%pass [%running path] %agent [our %spider] %poke cage]
    ::
    ++  watch-spider
      |=  [=path our=@p =sub=path]
      ^-  card
      [%pass [%running path] %agent [our %spider] %watch sub-path]
    ::
    ++  leave-spider
      |=  [=path our=@p]
      ^-  card
      [%pass [%running path] %agent [our %spider] %leave ~]
    --
::
::  Main
::
%-  agent:dbug
^-  agent:gall
=|  state=app-state
%+  verb  |
=<
|_  bol=bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bol)
    cor  ~(. +> bol)
::
++  on-init
  ^-  (quip card _this)
  [~ this]
::
++  on-save   !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  =+  !<(old=app-state old)
  `this(state old)
::
++  on-poke
  |=  [=mark =vase]
  ?>  (team:title [our src]:bol)
  ?:  ?=(%noun mark)
    ~&  state
    `this
  ?.  ?=(%btc-watcher-poke mark)
    (on-poke:def mark vase)
  ::
  =+  !<(=poke vase)
  ?-  -.poke
      %watch
    =.  syncs
      =/  syncs-from=_(~(got by syncs) *num:block)
        (~(gut by syncs) from.poke [0 ~])
      %+  ~(put by syncs)  from.poke
      ?~  to.poke
        syncs-from(ref +(ref.syncs-from))
      =/  syncs-to=@ud  (~(gut by to.syncs-from) u.to.poke 0)
      syncs-from(to (~(put by to.syncs-from) u.to.poke +(syncs-to)))
    ?.  &(?=(~ at) ?=(~ ted))  `this
    =^  card  state  ted-start
    [~[card] this]
  ::
      %clear
    =.  syncs
      =/  syncs-from=_(~(got by syncs) *num:block)
        (~(gut by syncs) from.poke [0 ~])
      =.  syncs-from
        ?~  to.poke
          syncs-from(ref (dec ref.syncs-from))
        =/  syncs-to=@ud  (dec (~(gut by to.syncs-from) u.to.poke 0))
        ?:  =(0 syncs-to)
          syncs-from(to (~(del by to.syncs-from) u.to.poke))
        syncs-from(to (~(put by to.syncs-from) u.to.poke syncs-to))
      ?:  &(=(0 ref.syncs-from) =(~ to.syncs-from))
        (~(del by syncs) from.poke)
      (~(put by syncs) from.poke syncs-from)

    =.  dogs.state  (~(del by dogs.state) path.poke)
    [~ this]
  ==
::
::  +on-watch: subscribe & get initial subscription data
::
::    /logs/some-path:
::
++  on-watch
  |=  =path
  ^-  (quip card agent:gall)
  ?.  ?=([%logs ^] path)
    ~|  [%invalid-subscription-path path]
    !!
  :_  this  :_  ~
  :*  %give  %fact  ~  %btc-watcher-diff  !>
      :-  %history
      ^-  loglist
      %-  zing
      %-  flop
      =<  history
      (~(gut by dogs.state) t.path *watchdog)
  ==
::
++  on-leave  on-leave:def
::
::  +on-peek: get diagnostics data
::
::    /block/some-path: get next block number to check for /some-path
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  ~
      [%x %block ^]
    ?.  (~(has by dogs.state) t.t.path)  ~
    :+  ~  ~
    :-  %atom
    !>(number:(~(got by dogs.state) t.t.path))
  ::
      [%x %dogs ~]
    ``noun+!>(~(key by dogs.state))
  ::
      [%x %dogs %configs ~]
    ``noun+!>((~(run by dogs.state) |=(=watchdog -.watchdog)))
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  |^
  ^-  (quip card agent:gall)
  ?.  ?=([%running *] wire)
    (on-agent:def wire sign)
  ?-    -.sign
      %poke-ack
    ?~  p.sign
      [~ this]
    %-  (slog leaf+"btc-watcher couldn't start thread" u.p.sign)
    :_  (clear-running t.wire)  :_  ~
    (leave-spider t.wire our.bol)
  ::
      %watch-ack
    ?~  p.sign
      [~ this]
    %-  (slog leaf+"btc-watcher couldn't start listening to thread" u.p.sign)
    ::  TODO: kill thread that may have started, although it may not
    ::  have started yet since we get this response before the
    ::  %start-spider poke is processed
    ::
    [~ (clear-running t.wire)]
  ::
      %kick  [~ (clear-running t.wire)]
      %fact
    =*  path  t.wire
    =/  dog  (~(get by dogs.state) path)
    ?~  dog
      [~ this]
    ?+    p.cage.sign  (on-agent:def wire sign)
        %thread-fail
      =+  !<([=term =tang] q.cage.sign)
      %-  (slog leaf+"btc-watcher failed; will retry" leaf+<term> tang)
      [~ this(dogs.state (~(put by dogs.state) path u.dog(running ~)))]
    ::
        %thread-done
      ::  if empty, that means we cancelled this thread
      ::
      ?:  =(*vase q.cage.sign)
        `this
      =+  !<([vows=disavows pup=watchpup] q.cage.sign)
      =.  u.dog
        %_  u.dog
          -             -.pup
          number        number.pup
          blocks        blocks.pup
          pending-logs  pending-logs.pup
        ==
      =^  cards-1  u.dog  (disavow path u.dog vows)
      =^  cards-2  u.dog  (release-logs path u.dog)
      =.  dogs.state  (~(put by dogs.state) path u.dog(running ~))
      [(weld cards-1 cards-2) this]
    ==
  ==
  ::
  ++  clear-running
    |=  =path
    =/  dog  (~(get by dogs.state) path)
    ?~  dog
      this
    this(dogs.state (~(put by dogs.state) path u.dog(running ~)))
  ::
  ++  disavow
    |=  [=path dog=watchdog vows=disavows]
    ^-  (quip card watchdog)
    =/  history-ids=(list [id:block loglist])
      %+  murn  history.dog
      |=  logs=loglist
      ^-  (unit [id:block loglist])
      ?~  logs
         ~
      `[[block-hash block-number]:(need mined.i.logs) logs]
    =/  actual-vows=disavows
      %+  skim  vows
      |=  =id:block
      (lien history-ids |=([=history=id:block *] =(id history-id)))
    =/  actual-history=history
      %+  murn  history-ids
      |=  [=id:block logs=loglist]
      ^-  (unit loglist)
      ?:  (lien actual-vows |=(=vow=id:block =(id vow-id)))
        ~
      `logs
    :_  dog(history actual-history)
    %+  turn  actual-vows
    |=  =id:block
    [%give %fact [%logs path]~ %btc-watcher-diff !>([%disavow id])]
  ::
  ++  release-logs
    |=  [=path dog=watchdog]
    ^-  (quip card watchdog)
    ?:  (lth number.dog 30)
      `dog
    =/  numbers=(list number:block)  ~(tap in ~(key by pending-logs.dog))
    =.  numbers  (sort numbers lth)
    =^  logs=(list event-log:rpc:btcereum)  dog
      |-  ^-  (quip event-log:rpc:nothereum watchdog)
      ?~  numbers
        `dog
      =^  rel-logs-1  dog
        =/  =loglist  (~(get ja pending-logs.dog) i.numbers)
        =.  pending-logs.dog  (~(del by pending-logs.dog) i.numbers)
        ?~  loglist
          `dog
        =.  history.dog  [loglist history.dog]
        [loglist dog]
      =^  rel-logs-2  dog  $(numbers t.numbers)
      [(weld rel-logs-1 rel-logs-2) dog]
    :_  dog
    ?~  logs
      ~
    ^-  (list card:agent:gall)
    [%give %fact [%logs path]~ %btc-watcher-diff !>([%logs logs])]~
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card agent:gall)
  ?+    +<.sign-arvo  ~|([%strange-sign-arvo -.sign-arvo] !!)
      %wake
    ?.  ?=([%timer *] wire)  ~&  weird-wire=wire  [~ this]
    =*  path  t.wire
    ?.  (~(has by dogs.state) path)
      [~ this]
    =/  dog=watchdog
      (~(got by dogs.state) path)
    ?^  error.sign-arvo
      ::  failed, try again.  maybe should tell user if fails more than
      ::  5 times.
      ::
      %-  (slog leaf+"btc-watcher failed; will retry" ~)
      [[(wait path now.bol refresh-rate.dog)]~ this]
    ::  maybe kill a timed-out update thread, maybe start a new one
    ::
    =^  stop-cards=(list card)  dog
      ::  if still running beyond timeout time, kill it
      ::
      ?.  ?&  ?=(^ running.dog)
            ::
              %+  gth  now.bol
              (add since.u.running.dog timeout-time.dog)
          ==
        `dog
      ::
      %-  (slog leaf+"btc-watcher {(spud path)} timed out; will restart" ~)
      =/  =cage  [%spider-stop !>([tid.u.running.dog |])]
      :_  dog(running ~)
      :~  (leave-spider path our.bol)
          [%pass [%starting path] %agent [our.bol %spider] %poke cage]
      ==
    ::
    =^  start-cards=(list card)  dog
      ::  if not (or no longer) running, start a new thread
      ::
      ?^  running.dog
        `dog
      :: if reached the to-block, don't start a new thread
      ::
      ?:  ?&  ?=(^ to.dog)
              (gte number.dog u.to.dog)
          ==
        `dog
      ::
      =/  new-tid=@ta
        (cat 3 'btc-watcher--' (scot %uv eny.bol))
      :_  dog(running `[now.bol new-tid])
      =/  args
        :*  ~  `new-tid  bec  %btc-watcher
            !>([~ `watchpup`[- number pending-logs blocks]:dog])
        ==
      :~  (watch-spider path our.bol /thread/[new-tid]/blocks)
          (poke-spider path our.bol %spider-start !>(args))
      ==
    ::
    :-  [(wait path now.bol refresh-rate.dog) (weld stop-cards start-cards)]
    this(dogs.state (~(put by dogs.state) path dog))
  ==
::
++  on-fail   on-fail:def
--
|_  bol=bowl
+*  bec   byk.bol(r da+now.bol)
++  ted-start
  ^-  (quip card _state)
  ?>  ?=(~ ted)
  =/  tid=@ta
    (cat 3 'btc-watcher--' (scot %uv eny.bol))
  =|  *shed:khan
  :_  state(ted `[now tid])
  =/  args  [~ `tid bec shed]
  :~  (watch-spider /watcher-ted our.bol /thread/[tid]/blocks)
      (poke-spider /watcher-ted our.bol %spider-inline !>(args))
  ==
--
