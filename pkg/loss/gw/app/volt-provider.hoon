::  volt-provider.hoon
::  LND daemon integration agent
::
/-  volt
/+  server, default-agent, dbug, lnd-rpc
=,  provider:volt
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-0
  ==
::
+$  state-0
  $:  %0
      =host-info
      =node-info
  ==
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%volt-provider initialized successfully'
  :_  this(host-info ['' %.n *(set ship)])
  :~  [%pass /bind %arvo %e %connect [~ /'~volt-channels'] %volt-provider]
      [%pass /bind %arvo %e %connect [~ /'~volt-payments'] %volt-provider]
      [%pass /bind %arvo %e %connect [~ /'~volt-invoices'] %volt-provider]
      [%pass /bind %arvo %e %connect [~ /'~volt-confirms'] %volt-provider]
      [%pass /bind %arvo %e %connect [~ /'~volt-spends'] %volt-provider]
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%volt-provider recompiled successfully'
  `this(state !<(versioned-state old-state))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
  ?+    mark  (on-poke:def mark vase)
      %volt-provider-command
    =+  !<(com=command:provider:volt vase)
    ~|  [mark com]
    ~|  [our.bowl src.bowl]
    ?>  (team:title our.bowl src.bowl)
    (handle-command:hc !<(command:provider:volt vase))
  ::
      %volt-provider-action
    ?>  (team:title our.bowl src.bowl)
    (handle-action:hc !<(action:provider:volt vase))
  ::
      %handle-http-request
    =+  !<([id=@ta =inbound-request:eyre] vase)
    ~|  "volt-provider: blocked http request from {<address.inbound-request>}"
    ?>  ?=([%ipv4 %.127.0.0.1] address.inbound-request)
    (handle-request:hc id inbound-request)
  ==
  [cards this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=(%eyre -.sign-arvo)
    `this
  ?:  ?=([%ping-timer *] wire)
    [do-ping:hc this]
  (on-arvo:def wire sign-arvo)
::
++  on-watch
  |=  pax=path
  ^-  (quip card _this)
  ?+    -.pax  (on-watch:def pax)
      %http-response
    `this
  ::
      %clients
    ?>  (team:title our.bowl src.bowl)
    ~&  >  "volt-provider: accepted client {<src.bowl>}"
    `this(clients.host-info (~(put in clients.host-info) src.bowl))
  ::
     %status
    ~&  >  "volt-provider: accepted client {<src.bowl>}"
    `this
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    -.wire  (on-agent:def wire sign)
      %thread
    ?+    -.sign  (on-agent:def wire sign)
        %poke-ack
      ?~  p.sign
        `this
      %-  (slog leaf+"Thread failed!" u.p.sign)
      `this
    ::
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        =/  err  !<  (pair term tang)  q.cage.sign
        %-  (slog leaf+"Thread failed: {(trip p.err)}" q.err)
        `this
      ::
          %thread-done
        =^  cards  state
          %+  handle-rpc-response:hc  +.wire
          !<(response:rpc:volt q.cage.sign)
        [cards this]
      ==
    ==
  ==
::
++  on-peek   on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::
|_  =bowl:gall
++  handle-action
  |=  =action:provider:volt
  ^-  (quip card _state)
  ?.  ?|(connected.host-info ?=(%ping -.action))
    ~&  >>>  "not connected to LND"
    `state
  ?-    -.action
      %ping
    [(do-rpc [%get-info ~]) state]
  ::
      %add-hold-invoice
    [(do-rpc [%add-hold-invoice +.action]) state]
  ::
      %settle-invoice
    [(do-rpc [%settle-invoice preimage.action]) state]
  ::
      %cancel-invoice
    [(do-rpc [%cancel-invoice payment-hash.action]) state]
  ::
      %subscribe-confirms
    [(do-rpc [%subscribe-confirms +.action]) state]
  ::
      %subscribe-spends
    [(do-rpc [%subscribe-spends +.action]) state]
  ==
::
++  handle-command
  |=  =command
  ^-  (quip card _state)
  ?-    -.command
      %set-url
    :_  state(host-info [api-url.command %.n *(set ship)])
    %-  zing
    :~  ~[(give-status %disconnected)]
        do-ping
    ==
  ::
      %open-channel
    :_  state
    %-  do-rpc
    [%open-channel +.command]
  ::
      %close-channel
    :_  state
    %-  do-rpc
    [%close-channel +.command]
  ::
      %send-payment
    ~&  >>>  "%volt-provider: sending payment {<+.command>}"
    :_  state
    %-  do-rpc
    [%send-payment +.command]
  ==
::
++  handle-request
  |=  [id=@ta =inbound-request:eyre]
  |^  ^-  (quip card _state)
  %+  fall
    %+  bind  (request-json request.inbound-request)
    |=  =json
    ?:  =(url.request.inbound-request '/~volt-channels')
      %+  handle-channel-update  id
      %-  channel-update:dejs:lnd-rpc
      json
    ::
    ?:  =(url.request.inbound-request '/~volt-payments')
      %+  handle-payment-update  id
      %-  payment:dejs:lnd-rpc
      json
    ::
    ?:  =(url.request.inbound-request '/~volt-invoices')
      %+  handle-invoice-update  id
      %-  invoice:dejs:lnd-rpc
      json
    ::
    ?:  =(url.request.inbound-request '/~volt-confirms')
      %+  handle-confirmation-notification  id
      %-  confirmation-event:dejs:lnd-rpc
      json
    ::
    ?>  =(url.request.inbound-request '/~volt-spends')
      %+  handle-spend-notification  id
      %-  spend-event:dejs:lnd-rpc
      json
  [(no-content id) state]
  ::
  ++  request-json
    |=  =request:http
    ^-  (unit json)
    %+  biff  body.request
    |=  =octs
    =/  body=@t  +.octs
    (de:json:html body)
  --
::
++  handle-channel-update
  |=  [id=@ta =channel-update:rpc:volt]
  ^-  (quip card _state)
  ?-    -.channel-update
      %open-channel
    ~&  >  "open channel: {<chan-id.channel-update>}"
    :_  state
    :-  (give-update [%res %channel-update channel-update])
        (no-content id)
  ::
      %closed-channel
    ~&  >  "channel closed: {<chan-id.channel-update>}"
    :_  state
    :-  (give-update [%res %channel-update channel-update])
        (no-content id)
  ::
      %active-channel
    =/  =txid   funding-txid.channel-update
    =/  ix=@ud  output-index.channel-update
    ~&  >  "active channel: {<txid>}:{<ix>}"
    :_  state
    :-  (give-update [%res %channel-update channel-update])
        (no-content id)
  ::
      %inactive-channel
    =/  =txid   funding-txid.channel-update
    =/  ix=@ud  output-index.channel-update
    ~&  >  "inactive channel: {<txid>}:{<ix>}"
    :_  state
    :-  (give-update [%res %channel-update channel-update])
        (no-content id)
  ::
      %pending-channel
    =/  =txid   txid.channel-update
    =/  ix=@ud  output-index.channel-update
    ~&  >  "pending channel: {<txid>}:{<ix>}"
    :_  state
    :-  (give-update [%res %channel-update channel-update])
        (no-content id)
  ==
::
++  handle-payment-update
  |=  [id=@ta =payment:rpc:volt]
  ^-  (quip card _state)
  :_  state
  :-  (give-update [%res %payment-update payment])
      (no-content id)
::
++  handle-invoice-update
  |=  [id=@ta =invoice:rpc:volt]
  ^-  (quip card _state)
  :_  state
  :-  (give-update [%res %invoice-update invoice])
      (no-content id)
::
++  handle-confirmation-notification
  |=  [id=@ta =confirmation-event:rpc:volt]
  ^-  (quip card _state)
  :_  state
  :-  (give-update [%res %confirmation-event confirmation-event])
      (no-content id)
::
++  handle-spend-notification
  |=  [id=@ta =spend-event:rpc:volt]
  ^-  (quip card _state)
  :_  state
  :-  (give-update [%res %spend-event spend-event])
      (no-content id)
::
++  handle-rpc-response
  |=  [=wire =response:rpc:volt]
  ^-  (quip card _state)
  ?-  -.response
    %res  (handle-rpc-result wire +.response)
    %err  (handle-rpc-error wire +.response)
  ==
::
++  handle-rpc-result
  |=  [=wire =result:rpc:volt]
  ^-  (quip card _state)
  ?+    -.wire  ~|("Unexpected RPC result" !!)
      %get-info
    ?>  ?=([%get-info *] result)
    :_  state(connected.host-info %.y, node-info +.result)
    :~  (give-status `status`%connected)
        (give-update `update`[%res %node-info +.result])
        (give-info +.result)
    ==
  ::
      %open-channel
    ?>  ?=([%open-channel *] result)
    ~&  >  "%volt-provider: opening channel: funding-txid={<funding-txid.result>}"
    `state
  ::
      %close-channel
    ?>  ?=([%close-channel *] result)
    `state
  ::
      %add-hold-invoice
    ?>  ?=([%add-hold-invoice *] result)
    :_  state(connected.host-info %.y)
    :~  (give-status %connected)
        (give-update [%res %hold-invoice +.result])
    ==
  ::
      %settle-invoice
    ?>  ?=([%settle-invoice *] result)
    `state
  ::
      %cancel-invoice
    ?>  ?=([%cancel-invoice *] result)
    `state
  ::
      %send-payment
    ?>  ?=([%send-payment *] result)
    `state
  ::
      %subscribe-confirms
    ?>  ?=([%subscribe-confirms ~] result)
    `state
  ::
      %subscribe-spends
    ?>  ?=([%subscribe-spends ~] result)
    `state
  ==
::
++  handle-rpc-error
  |=  [=wire =error:rpc:volt]
  ^-  (quip card _state)
  %-  (slog leaf+"RPC Error: {(trip message.error)}" ~)
  :_  state
  ~[(give-update [%err %rpc-error error])]
::
++  do-rpc
  |=  =action:rpc:volt
  ^-  (list card)
  =/  tid     `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
  =/  args     [~ `tid byk.bowl(r da+now.bowl) %rpc-lnd-rpc !>([~ host-info.state action])]
  =/  wire     (rpc-wire action)
  :~
    :*  %pass   wire
        %agent  [our.bowl %spider]
        %watch  /thread-result/[tid]
    ==
    :*  %pass   wire
        %agent  [our.bowl %spider]
        %poke   %spider-start  !>(args)
    ==
  ==
::
++  rpc-wire
  |=  =action:rpc:volt
  ^-  wire
  =/  ta-now  `@ta`(scot %da now.bowl)
  /thread/[-.action]/[ta-now]
::
++  no-content
  |=  id=@ta
  ^-  (list card)
  :~  [%give %fact ~[/http-response/[id]] [%http-response-header !>([201 ~])]]
      [%give %kick ~[/http-response/[id]] ~]
  ==
::
++  is-client
  |=  who=@p
  ^-  ?
  (~(has in clients.host-info) who)
::
++  start-ping-timer
  |=  interval=@dr
  ^-  card
  :*  %pass  /ping-timer
      %arvo  %b
      %wait  (add now.bowl interval)
  ==
::
++  do-ping
  ^-  (list card)
  =/  ping=action:provider  [%ping ~]
  :~  :*  %pass   /ping/[(scot %da now.bowl)]
          %agent  [our.bowl %volt-provider]
          %poke   %volt-provider-action  !>(ping)
      ==
      (start-ping-timer ~s30)
  ==
::
++  give-update
  |=  =update
  ^-  card
  %-  ?:  ?=(%res -.update)
        same
      ~&(>> "volt-provider: error: {<update>}" same)
  [%give %fact ~[/clients] %volt-provider-update !>(update)]
::
++  give-info
  |=  info=^node-info
  ^-  card
  :*  %give
      %fact  ~[/status]
      %volt-provider-update  !>(`update`[%res %node-info info])
  ==
::
++  give-status
  |=  =status
  ^-  card
  [%give %fact ~[/status] %volt-provider-status !>(status)]
--
