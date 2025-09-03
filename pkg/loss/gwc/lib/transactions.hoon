/-  *bolt
/+  *utilities, bip69-cltv
/+  btc-script, script
|%
++  anchor-size           330
++  anchor-output-weight  3
++  commitment-tx-weight  724
++  anchor-commit-weight  1.124
++  htlc-success-weight   703
++  htlc-timeout-weight   663
++  htlc-output-weight    172
::
++  received-htlc-trim-threshold
  |=  [=dust-limit=sats:bc feerate=sats:bc anchor=?]
  ^-  sats:bc
  =+  weight=htlc-success-weight
  =?  weight  anchor  (add weight 3)
  %+  add  dust-limit-sats
  (fee-by-weight feerate weight)
::
++  offered-htlc-trim-threshold
  |=  [=dust-limit=sats:bc feerate=sats:bc anchor=?]
  ^-  sats:bc
  =+  weight=htlc-timeout-weight
  =?  weight  anchor  (add weight 3)
  %+  add  dust-limit-sats
  (fee-by-weight feerate weight)
::
++  fee-for-htlc-output
  |=  feerate=sats:bc
  ^-  sats:bc
  (fee-by-weight feerate htlc-output-weight)
::
++  is-trimmed
  |=  [=direction =amount=msats feerate=sats:bc =dust-limit=sats:bc anchor=?]
  ^-  ?
  =+  ^=  threshold
      ^-  sats:bc
      ?-    direction
          %sent
        %^    offered-htlc-trim-threshold
            dust-limit-sats
          feerate
        anchor
      ::
          %received
        %^    received-htlc-trim-threshold
            dust-limit-sats
          feerate
        anchor
      ==
  (lth (msats-to-sats amount-msats) threshold)
::
++  calculate-commitment-fee
  |=  $:  num-htlcs=@ud
          feerate=sats:bc
          anchors=?
          round=?
      ==
  ^-  sats:bc
  =+  ^=  overall
      %+  add
        commitment-tx-weight
      (mul num-htlcs htlc-output-weight)
  =?  overall  anchors
    (add overall 400)
  =+  fee=(fee-by-weight feerate overall)
  =?  fee  anchors
    (add fee 660)
  =?  fee  round
    (mul (div fee 1.000) 1.000)
  fee
::
++  commitment-fee
  |=  $:  num-htlcs=@ud
          feerate=sats:bc
          is-local-initiator=?
          anchors=?
          round=?
      ==
  ^-  (map owner sats:bc)
  =+  ^=  fee
    %:  calculate-commitment-fee
      num-htlcs=num-htlcs
      feerate=feerate
      anchors=anchors
      round=round
    ==
  %-  malt
  %-  limo
  :~  [%local ?:(is-local-initiator fee 0)]
      [%remote ?.(is-local-initiator fee 0)]
  ==
::  +funding-output: generate multisig output
::
++  funding-output
  |=  [=local=pubkey =remote=pubkey =funding=sats:bc]
  |^  ^-  output:psbt
  =|  =output:psbt
  %=  output
    script-pubkey  script-pubkey
    value          funding-sats
  ==
  ++  script-pubkey
    =,  secp256k1:secp:crypto
    %-  p2wsh:script
    %+  funding-output:script
      local-pubkey
    remote-pubkey
  --
::  +funding-input: generate spend from multisig output
::
++  funding-input
  =,  secp256k1:secp:crypto
  |=  $:  =local-funding=pubkey
          =remote-funding=pubkey
          =funding=outpoint
          sequence=@
      ==
  |^  ^-  input:psbt
  =|  =input:psbt
  %=  input
    prevout         [txid=txid.funding-outpoint idx=pos.funding-outpoint]
    nsequence       sequence
    witness-script  `witness-script
    trusted-value   `sats.funding-outpoint
    script-type     %p2wsh
    num-sigs        2
    pubkeys
      %+  sort  ~[local-funding-pubkey remote-funding-pubkey]
      |=  [a=pubkey b=pubkey]
      (lte (compress-point a) (compress-point b))
  ==
  ++  witness-script
    %-  en:btc-script
    %+  funding-output:script
      local-funding-pubkey
    remote-funding-pubkey
  --
::  +commitment-outputs: outputs for commitment tx
::    also returns the sorted cltvs
::
++  commitment-outputs
  |=  $:  fees-per-participant=(map owner sats:bc)
          =local-funding=pubkey
          =remote-funding=pubkey
          =local-amount=msats
          =remote-amount=msats
          local-script=hexb:bc
          remote-script=hexb:bc
          htlcs=(list ^htlc)
          =dust-limit=sats:bc
          anchor=?
      ==
  |^
  ^-  (list output:psbt)
  %+  turn
    (sort-outputs:bip69-cltv outputs cltvs)
  from-output:txout:psbt
  ++  local-fee
    ^-  sats:bc
    (~(gut by fees-per-participant) %local 0)
  ::
  ++  remote-fee
    ^-  sats:bc
    (~(gut by fees-per-participant) %remote 0)
  ::
  ++  to-local-amount
    ^-  sats:bc
    =+  amount=(msats-to-sats local-amount-msats)
    ?:  (gth local-fee amount)
      0
    (sub amount local-fee)
  ::
  ++  to-remote-amount
    ^-  sats:bc
    =+  amount=(msats-to-sats remote-amount-msats)
    ?:  (gth remote-fee amount)
      0
    (sub amount remote-fee)
  ::
  ++  to-local
    ^-  out:tx:psbt
    =|  =out:tx:psbt
    out(script-pubkey local-script, value to-local-amount)
  ::
  ++  to-remote
    ^-  out:tx:psbt
    =|  =out:tx:psbt
    out(script-pubkey remote-script, value to-remote-amount)
  ::
  ++  htlc-outputs
    ^-  (list out:tx:psbt)
    (turn htlcs htlc-output)
  ::
  ++  anchor-outputs
    ^-  (list out:tx:psbt)
    ?.  anchor  ~
    %-  zing
    :~
      ?:  (gte to-local-amount dust-limit-sats)
        ~[(anchor-output local-funding-pubkey)]
      ~
      ::
      ?:  (gte to-remote-amount dust-limit-sats)
        ~[(anchor-output remote-funding-pubkey)]
      ~
    ==
  ::
  ++  cltvs
    ^-  (list blocks)
    %-  zing
    :~
      ?:  (gte to-local-amount dust-limit-sats)
        ~[0]
      ~
      ::
      ?:  (gte to-remote-amount dust-limit-sats)
        ~[0]
      ~
      ::
      %+  turn     htlcs
      |=  h=^htlc  timeout.h
      ::
      %+  turn    anchor-outputs
      |=  =out:tx:psbt  0
    ==
  ::
  ++  outputs
    ^-  (list out:tx:psbt)
    %-  zing
    :~
      htlc-outputs
      ?:  (gte to-local-amount dust-limit-sats)
        ~[to-local]
      ~
      ?:  (gte to-remote-amount dust-limit-sats)
        ~[to-remote]
      ~
      anchor-outputs
    ==
  --
::  +commitment: generate commitment transaction and cltvs
::
++  commitment
  |=  $:  =commitment-number
          =local-funding=pubkey
          =remote-funding=pubkey
          =remote-payment=pubkey
          funder-payment-basepoint=point
          fundee-payment-basepoint=point
          =revocation=pubkey
          =delayed=pubkey
          to-self-delay=blocks
          =funding=outpoint
          local-amount=msats
          remote-amount=msats
          =dust-limit=sats:bc
          anchor-outputs=?
          htlcs=(list ^htlc)
          fees-per-participant=(map owner sats:bc)
      ==
  |^
  ^-  psbt:psbt
  =|  =psbt:psbt
  %=  psbt
    inputs     ~[input]
    outputs    outputs
    nversion   2
    nlocktime  locktime
  ==
  ++  obscured-commitment-number
    ^-  @ud
    %^    obscure-commitment-number
        commitment-number
      funder-payment-basepoint
    fundee-payment-basepoint
  ::
  ++  locktime
    ^-  @ud
    %+  con  (lsh [3 3] 0x20)
    (dis 0xff.ffff obscured-commitment-number)
  ::
  ++  sequence
    ^-  @
    %+  con  (lsh [3 3] 0x80)
    %+  rsh  [3 3]
    (dis 0xffff.ff00.0000 obscured-commitment-number)
  ::
  ++  input
    %:  funding-input
      local-funding-pubkey
      remote-funding-pubkey
      funding-outpoint
      sequence
    ==
  ::
  ++  outputs
    ^-  (list output:psbt)
    %:  commitment-outputs
      fees-per-participant=fees-per-participant
      local-funding-pubkey=local-funding-pubkey
      remote-funding-pubkey=remote-funding-pubkey
      local-amount-msats=local-amount
      remote-amount-msats=remote-amount
      local-script=local-script
      remote-script=remote-script
      htlcs=htlcs
      dust-limit-sats=dust-limit-sats
      anchor=anchor-outputs
    ==
  ::
  ++  local-script
    ^-  hexb:bc
    %-  p2wsh:script
    %^    local-output:script
        revocation-pubkey
      delayed-pubkey
    to-self-delay
  ::
  ++  remote-script
    ^-  hexb:bc
    ?:  anchor-outputs
      %-  p2wsh:script
      (remote-output:script remote-payment-pubkey)
    (p2wpkh:script remote-payment-pubkey)
  --
::  +htlc-output: output for htlc
::
++  htlc-output
  |=  h=^htlc
  ^-  out:tx:psbt
  =|  =out:tx:psbt
  %=  out
    script-pubkey  script-pubkey.h
    value          (msats-to-sats amount-msats.h)
  ==
::  +anchor-output: output for anchor
::
++  anchor-output
  |=  =pubkey
  ^-  out:tx:psbt
  =+  ^=  script-pubkey
      ^-  hexb:bc
      %-  p2wsh:script
      %-  anchor-output:script
      pubkey
  =|  =out:tx:psbt
  %=  out
    script-pubkey  script-pubkey
    value          anchor-size
  ==
::  +htlc: generate HTLC transaction for commitment
::
++  htlc
  |=  $:  =direction
          htlc=add-htlc:update
          =commitment=outpoint
          =delayed=pubkey
          =other-revocation=pubkey
          =htlc=pubkey
          =other-htlc=pubkey
          to-self-delay=blocks
          feerate-per-kw=sats:bc
          anchor-outputs=?
      ==
  |^  ^-  psbt:psbt
  =|  tx=psbt:psbt
  %=  tx
    inputs     [input]~
    outputs    [output]~
    nlocktime  timeout.htlc
    nversion   2
  ==
  ++  weight
    ^-  @ud
    ?:  ?&(anchor-outputs =(direction %received))
      (add htlc-timeout-weight 3)
    ?:  =(direction %received)
      htlc-timeout-weight
    ?:  anchor-outputs
      (add htlc-success-weight 3)
    htlc-success-weight
  ::
  ++  fee
    ^-  sats:bc
    (fee-by-weight feerate-per-kw weight)
  ::
  ++  input
    ^-  input:psbt
    =|  =input:psbt
    %=  input
      prevout         [txid=txid.commitment-outpoint idx=pos.commitment-outpoint]
      nsequence       ?:(anchor-outputs 0x1 0x0)
      witness-script  `witness-script
      trusted-value   `(msats-to-sats amount-msats.htlc)
    ==
  ::
  ++  output
    ^-  output:psbt
    =|  =output:psbt
    =+  ^=  script-pubkey
        %-  p2wsh:script
        %:  htlc-spend:script
          revocation-pubkey=other-revocation-pubkey
          local-delayed-pubkey=delayed-pubkey
          to-self-delay=to-self-delay
        ==
    =+  amount-sats=(msats-to-sats amount-msats.htlc)
    %=  output
      script-pubkey  script-pubkey
      value          ?:((lth amount-sats fee) 0 (sub amount-sats fee))
    ==
  ::
  ++  witness-script
    ^-  hexb:bc
    %-  en:btc-script
    %:  htlc-witness:script
      direction=direction
      local-htlc-pubkey=htlc-pubkey
      remote-htlc-pubkey=other-htlc-pubkey
      remote-revocation-pubkey=other-revocation-pubkey
      payment-hash=payment-hash.htlc
      cltv-expiry=`timeout.htlc
      confirmed-spend=anchor-outputs
    ==
  --
::
++  closing
  |=  $:  =local-funding=pubkey
          =remote-funding=pubkey
          =funding=outpoint
          outputs=(list output:psbt)
      ==
  ^-  psbt:psbt
  =|  tx=psbt:psbt
  =+  ^=  input
      %:  funding-input
        local-funding-pubkey
        remote-funding-pubkey
        funding-outpoint
        0xffff.ffff
      ==
  %=  tx
    inputs     ~[input]
    outputs    outputs
    nlocktime  0
    nversion   2
  ==
--
