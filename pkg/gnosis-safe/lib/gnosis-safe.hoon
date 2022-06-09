/-  *gnosis-safe
/+  *ethereum
=,  abi
=/  event-sigs
  =>  |%
      ++  keccak  :(corl @ux keccak-256:keccak:crypto as-octs:mimes:html)
      --
  :*  safe-setup=(keccak 'SafeSetup(address,address[],uint256,address,address)')
      hash-approved=(keccak 'ApproveHash(bytes32,address)')
      message-signed=(keccak 'SignMsg(bytes32)')
      exec-success=(keccak 'ExecutionFailure(bytes32,uint256)')
      exec-failure=(keccak 'ExecutionSuccess(bytes32,uint256)')
      safe-received=(keccak 'SafeReceived(address,uint256)')
      owner-added=(keccak 'AddedOwner(address)')
      owner-removed=(keccak 'RemovedOwner(address)')
      threshold-changed=(keccak 'ChangedThreshold(uint256)')
      fallback-changed=(keccak 'ChangedFallbackHandler(address)')
      guard-changed=(keccak 'ChangedGuard(address)')
      module-enabled=(keccak 'EnabledModule(address')
      module-disabled=(keccak 'DisabledModule(address')
      module-exec-success=(keccak 'ExecutionFromModuleSuccess(address)')
      module-exec-failure=(keccak 'ExecutionFromModuleFailure(address)')
      transfer=(keccak 'Transfer(address,address,uint256)') :: works for erc20 and erc721
  ==
|%
++  parse-event
  |=  log=event-log:rpc
  ^-  safe-event
  ?>  ?=(^ topics.log)
  ?:  =(safe-setup.event-sigs i.topics.log)
    :*  %safe-setup
        (decode-topics t.topics.log ~[%address])
        (decode-results data.log ~[[%array %address] %uint %address %address])
    ==
  ?:  =(hash-approved.event-sigs i.topics.log)
    =-  [%hash-approved -(- q.-<)]
    (decode-topics t.topics.log ~[[%bytes-n 32] %address])
  ?:  =(message-signed.event-sigs i.topics.log)
    =-  [%message-signed q.-]
    (decode-topics t.topics.log ~[[%bytes-n 32]])
  ?:  =(exec-success.event-sigs i.topics.log)
    =-  [%exec-success -(- q.-<)]
    (decode-results data.log ~[[%bytes-n 32] %uint])
  ?:  =(exec-failure.event-sigs i.topics.log)
  =-  [%exec-failure -(- q.-<)]
    (decode-results data.log ~[[%bytes-n 32] %uint])
  ?:  =(safe-received.event-sigs i.topics.log)
    :-  %safe-received
    (decode-topics t.topics.log ~[%address %uint])
  ?:  =(owner-added.event-sigs i.topics.log)
    :-  %owner-added
    (decode-results data.log ~[%address])
  ?:  =(owner-removed.event-sigs i.topics.log)
    :-  %owner-removed
    (decode-results data.log ~[%address])
  ?:  =(threshold-changed.event-sigs i.topics.log)
    :-  %threshold-changed
    (decode-results data.log ~[%uint])
  ?:  =(fallback-changed.event-sigs i.topics.log)
    :-  %fallback-changed
    (decode-results data.log ~[%address])
  ?:  =(guard-changed.event-sigs i.topics.log)
    :-  %guard-changed
    (decode-results data.log ~[%address])
  ?:  =(module-enabled.event-sigs i.topics.log)
    :-  %module-enabled
    (decode-results data.log ~[%address])
  ?:  =(module-disabled.event-sigs i.topics.log)
    :-  %module-disabled
    (decode-results data.log ~[%address])
  ?:  =(module-exec-success.event-sigs i.topics.log)
    :-  %module-exec-success
    (decode-topics t.topics.log ~[%address])
  ?:  =(module-exec-failure.event-sigs i.topics.log)
    :-  %module-exec-failure
    (decode-topics t.topics.log ~[%address])
  ~|  unexpected-log+log  !!

++  data-names
  =<  data-name
    |%
    ++  data-name
      $%  [%| name=@t]
          [%& name=@t names=data-name-list]
      ==
    ++  data-name-list  $@(~ [i=data-name t=data-name-list])
    --
++  named-data
  =<  named-data
  |%
  ++  named-data
    $%  [name=@t $<(%tuple data)]
        [name=@t %tuple p=named-data-list]
    ==
  ++  named-data-list  $@(~ [i=named-data t=named-data-list])
  --
++  add-names
  |=  [names=(list data-names) data=(list data)]
  ^-  (list named-data)
  |-
  ?~  data  ~
  ?>  ?=(^ names)
  ?.  ?=([%tuple *] i.data)
    ?>  ?=(%| -.i.names)
    :-  [name.i.names i.data]
    $(data t.data, names t.names)
  :_  $(data t.data, names t.names)
  ?>  ?=(%& -.i.names)
  :*  name.i.names
      %tuple
      $(data p.i.data, names names.i.names)
  ==
--