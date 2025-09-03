::  lib/lnd-rpc.hoon
::
/-  spider, volt
/+  *strandio, bc=bitcoin
=,  strand=strand:spider
|_  =host-info:provider:volt
::
++  bcu  bcu:bc
++  enjs
  =,  enjs:format
  |%
  ++  action
    |=  act=action:rpc:volt
    |^  ^-  json
    ?+  -.act  ~|("Unknown request type" !!)
      %open-channel        (open-channel +.act)
      %send-payment        (send-payment +.act)
      %add-hold-invoice    (add-hold-invoice +.act)
      %settle-invoice      (settle-invoice +.act)
      %cancel-invoice      (cancel-invoice +.act)
      %subscribe-confirms  (subscribe-confirms +.act)
      %subscribe-spends    (subscribe-spends +.act)
    ==
    ++  open-channel
      |=  [=pubkey:volt local-amt=sats:bc push-amt=sats:bc]
      ^-  json
      %-  pairs
      :~  ['node_pubkey' [%s (en:base64:mimes:html pubkey)]]
          ['local_funding_amount' (numb local-amt)]
          ['push_sat' (numb push-amt)]
      ==
    ::
    ++  settle-invoice
      |=  preimage=hexb:bc
      ^-  json
      %-  pairs
      ~[['preimage' [%s (en:base64:mimes:html (flip:byt:bcu preimage))]]]
    ::
    ++  cancel-invoice
      |=  hash=hexb:bc
      ^-  json
      %-  pairs
      ~[['payment_hash' [%s (en:base64:mimes:html hash)]]]
    ::
    ++  send-payment
      |=  [invoice=cord timeout=(unit @dr) fee-limit=(unit sats:bc)]
      ^-  json
      %-  pairs
      :~  ['payment_request' [%s invoice]]
          ['timeout_seconds' (numb (div (fall timeout ~s30) ~s1))]
          ['fee_limit_sat' (numb (fall fee-limit 0))]
      ==
    ::
    ++  add-hold-invoice
      |=  $:  amt=msats:volt
              memo=(unit cord)
              payment-hash=hexb:bc
              expiry=(unit @dr)
          ==
      ^-  json
      %-  pairs
      :~  ['memo' [%s (fall memo '')]]
          ['hash' [%s (en:base64:mimes:html (flip:byt:bcu payment-hash))]]
          ['value_msat' (numb amt)]
          ['expiry' (numb (div (fall expiry ~h1) ~s1))]
      ==
    ::
    ++  subscribe-confirms
      |=  $:  =txid:volt
              script=hexb:bc
              num-confs=@
              height-hint=@
          ==
      ^-  json
      %-  pairs
      :~  ['txid' [%s (en:base64:mimes:html (flip:byt:bcu txid))]]
          ['script' [%s (en:base64:mimes:html (flip:byt:bcu script))]]
          ['num_confs' (numb num-confs)]
          ['height_hint' (numb height-hint)]
      ==
    ::
    ++  subscribe-spends
      |=  $:  o=outpoint:rpc:volt
              script=hexb:bc
              height-hint=@
          ==
      ^-  json
      %-  pairs
      :~  ['outpoint' (outpoint o)]
          ['script' [%s (en:base64:mimes:html (flip:byt:bcu script))]]
          ['height_hint' (numb height-hint)]
      ==
    ::
    ++  outpoint
      |=  o=outpoint:rpc:volt
      ^-  json
      %-  pairs
      :~  ['hash' [%s (en:base64:mimes:html (flip:byt:bcu hash.o))]]
          ['index' (numb index.o)]
      ==
    --
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  base64
    %+  cu  flip:byt:bcu
    %-  su  parse:base64:mimes:html
  ::
  ++  maybe-base64
    |=  jon=json
    ^-  (unit hexb:bc)
    ?>  ?=([%s *] jon)
    ?:  =(p.jon '')
      ~
    %-  some
    %-  flip:byt:bcu:bc
    (need (de:base64:mimes:html p.jon))
  ::
  ++  hex     (su rule:base16:mimes:html)
  ::
  ++  channel-update
    |=  =json
    |^  ^-  channel-update:rpc:volt
    ?+    (update-type json)  ~|('Unknown update type' !!)
        %'OPEN_CHANNEL'
      [%open-channel (open-channel json)]
    ::
        %'CLOSED_CHANNEL'
      [%closed-channel (closed-channel json)]
    ::
        %'ACTIVE_CHANNEL'
      [%active-channel (active-channel json)]
    ::
        %'INACTIVE_CHANNEL'
      [%inactive-channel (inactive-channel json)]
    ::
        %'PENDING_OPEN_CHANNEL'
      [%pending-channel (pending-channel json)]
    ==
    ++  update-type
      %-  ot  ['type' so]~
    ::
    ++  channel-data
      |*  [k=cord a=fist]
      %-  ot  [k a]~
    ::
    ++  active-channel
      %+  channel-data  'active_channel'
      %-  ot
      :~  ['funding_txid_bytes' base64]
          ['output_index' ni]
      ==
    ::
    ++  inactive-channel
      %+  channel-data  'inactive_channel'
      %-  ot
      :~  ['funding_txid_bytes' base64]
          ['output_index' ni]
      ==
    ::
    ++  closed-channel
      %+  channel-data  'closed_channel'
      %-  ot
      :~  ['channel_point' so]
          ['chan_id' (su dim:ag)]
          ['chain_hash' so]
          ['closing_tx_hash' so]
          ['remote_pubkey' hex]
          ['close_type' so]
      ==
    ::
    ++  pending-channel
      %+  channel-data  'pending_open_channel'
      %-  ot
      :~  ['txid' base64]
          ['output_index' ni]
      ==
    ::
    ++  open-channel
      %+  channel-data  'open_channel'
      %-  ot
      :~  ['active' bo]
          ['remote_pubkey' hex]
          ['channel_point' so]
          ['chan_id' (su dim:ag)]
          ['capacity' (su dim:ag)]
          ['local_balance' (su dim:ag)]
          ['remote_balance' (su dim:ag)]
          ['commit_fee' (su dim:ag)]
          ['total_satoshis_sent' (su dim:ag)]
      ==
    --
  ::
  ++  payment
    |=  =json
    |^  ^-  payment:rpc:volt
    %.  json
    %-  ot
    :~  ['payment_hash' hex]
        ['payment_preimage' hex]
        ['value_msat' (su dim:ag)]
        ['fee_msat' (su dim:ag)]
        ['payment_request' so]
        ['status' (cu payment-status:rpc:volt so)]
        ['failure_reason' (cu payment-failure-reason:rpc:volt so)]
        ['creation_time_ns' unix-ns]
    ==
    ++  unix-ns
      %+  cu
        |=  a=@
        %-  from-unix-ms:chrono:userlib
          (div a 1.000)
      (su dim:ag)
    --
  ::
  ++  wallet-balance-response
    %-  ot
    :~  ['total_balance' (su dim:ag)]
        ['confirmed_balance' (su dim:ag)]
        ['unconfirmed_balance' (su dim:ag)]
    ==
  ::
  ++  add-hold-invoice-response
    %-  ot
    ~[['payment_request' so]]
  ::
  ++  invoice
    =,  chrono:userlib
    |^
    %-  ot
    :~  ['memo' so]
        ['r_preimage' maybe-base64]
        ['r_hash' base64]
        ['value_msat' (su dim:ag)]
        ['settled' bo]
        ['creation_date' unix-date]
        ['settle_date' unix-date]
        ['expiry' seconds]
        ['payment_request' so]
        ['add_index' (su dim:ag)]
        ['settle_index' (su dim:ag)]
        ['amt_paid_msat' (su dim:ag)]
        ['state' state]
    ==
    ++  state  (cu state:invoice:rpc:volt so)
    ++  unix-date      (cu from-unix (su dim:ag))
    ++  seconds        (cu |=(a=@ (mul a ~s1)) (su dim:ag))
    --
  ::
  ++  result
    |=  [act=action:rpc:volt jon=json]
    |^  ^-  result:rpc:volt
    ?-    -.act
        %get-info
      =/  info=[version=@t commit-hash=@t pubkey=hexb:bc]
        (node-info jon)
      :*  %get-info
        version.info
        commit-hash.info
        (decompress-point:secp256k1:secp:crypto dat.pubkey.info)
      ==
    ::
        %wallet-balance
      =/  [total=msats:volt confirmed=msats:volt unconfirmed=msats:volt]
      %-  wallet-balance-response  jon
      [%wallet-balance total confirmed unconfirmed]
    ::
        %open-channel
      [%open-channel (channel-point jon)]
    ::
        %add-hold-invoice
      [%add-hold-invoice (add-hold-invoice-response jon)]
    ::
        %close-channel       [%close-channel ~]
        %send-payment        [%send-payment ~]
        %cancel-invoice      [%cancel-invoice ~]
        %settle-invoice      [%settle-invoice ~]
        %subscribe-confirms  [%subscribe-confirms ~]
        %subscribe-spends    [%subscribe-spends ~]
    ==
    ++  node-info
      %-  ot
      :~  [%version so]
          ['commit_hash' so]
          ['identity_pubkey' hex]
      ==
    ::
    ++  channel-point
      %-  ot
      :~  ['funding_txid_bytes' (su parse:base64:mimes:html)]
          ['output_index' ni]
      ==
    --
  ::
  ++  error
    |=  jon=json
    ^-  error:rpc:volt
    %.  jon
    %-  ot
    :~  [%code ni]
        [%message so]
    ==
  ::
  ++  confirmation-event
    |=  jon=json
    ^-  confirmation-event:rpc:volt
    %.  jon
    %-  ot
    :~  ['raw_tx' base64]
        ['block_hash' base64]
        ['block_height' ni]
        ['tx_index' ni]
    ==
  ::
  ++  spend-event
    |=  jon=json
    ^-  spend-event:rpc:volt
    %.  jon
    %-  ot
    :~  ['spending_outpoint' outpoint]
        ['raw_spending_tx' base64]
        ['spending_tx_hash' base64]
        ['spending_input_index' ni]
        ['spending_height' ni]
    ==
  ::
  ++  outpoint  (ot ~[['hash' base64] ['index' ni]])
  --
::
++  action-to-request
  |=  act=action:rpc:volt
  |^  ^-  request:http
  ?-    -.act
      %get-info
    %-  get-request
    %+  url  '/getinfo'  ''
  ::
      %open-channel
    %+  post-request
    %+  url  '/channel'  ''
    act
  ::
      %close-channel
    =/  txid=@t  (~(en base64:mimes:html & &) funding-txid.act)
    =/  oidx=@t  (scot %ud output-index.act)
    =/  parms    (cat 3 (cat 3 txid '/') oidx)
    %-  delete-request
    %+  url  '/channel/'  parms
  ::
      %wallet-balance
    %-  get-request
    %+  url  '/wallet_balance'  ''
  ::
      %send-payment
    %+  post-request
    %+  url  '/payment'  ''
    act
  ::
      %add-hold-invoice
    %+  post-request
    %+  url  '/invoice'  ''
    act
  ::
      %settle-invoice
    %+  post-request
    %+  url  '/settle_invoice'  ''
    act
  ::
      %cancel-invoice
    %-  delete-request
    %+  url  '/invoice/'
    %-  ~(en base64:mimes:html & &)
    %-  flip:byt:bcu  payment-hash.act
  ::
      %subscribe-confirms
    %+  post-request
    %+  url  '/confirms'  ''
    act
  ::
      %subscribe-spends
    %+  post-request
    %+  url  '/spends'  ''
    act
  ==
  ++  url
    |=  [route=@t params=@t]
    %^    cat
        3
      (cat 3 api-url.host-info route)
    params
  ::
  ++  get-request
    |=  url=@t
    ^-  request:http
    [%'GET' url ~ ~]
  ::
  ++  delete-request
    |=  url=@t
    ^-  request:http
    [%'DELETE' url ~ ~]
  ::
  ++  post-request
    |=  [url=@t act=action:rpc:volt]
    ^-  request:http
    :*  %'POST'
        url
        ['Content-Type' 'application/json']~
        =,  html
        %-  some
        %-  as-octt:mimes
        %-  trip
        %-  en:json
        (action:enjs act)
    ==
  --
::
++  status-code
  |=  =client-response:iris
  =/  m  (strand ,@ud)
  ^-  form:m
  ?>  ?=(%finished -.client-response)
  (pure:m status-code.response-header.client-response)
::
++  send
  |=  act=action:rpc:volt
  =/  m              (strand ,response:rpc:volt)
  =/  =request:http  (action-to-request act)
  ^-  form:m
  ;<  ~                      bind:m  (send-request request)
  ;<  =client-response:iris  bind:m  take-client-response
  ;<  status=@ud             bind:m  (status-code client-response)
  ;<  body=@t                bind:m  (extract-body client-response)
  =/  jon=(unit json)  (de:json:html body)
  ?~  jon
    %-  (slog leaf+"{<body>}")
    (strand-fail:strand %json-parse-error ~)
  %-  pure:m
    ?:  =(status 200)
      [%res (result:dejs act u.jon)]
    [%err (error:dejs u.jon)]
--
