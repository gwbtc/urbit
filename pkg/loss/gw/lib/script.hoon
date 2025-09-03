/-  *bolt
/+  bc=bitcoin, btc-script
|%
++  bcu  bcu:bc
++  compress-point  compress-point:secp256k1:secp:crypto
::
++  p2wsh
  |=  s=script:btc-script
  ^-  hexb:bc
  %-  en:btc-script
  :~  %op-0
      :-  %op-pushdata
      %-  sha256:bcu  (en:btc-script s)
  ==
::
++  p2wpkh
  |=  p=pubkey
  ^-  hexb:bc
  %-  en:btc-script
  :~  %op-0
      [%op-pushdata (hash-160:bcu 33^(compress-point p))]
  ==
::
++  p2wpkh-spend
  |=  p=pubkey
  ^-  hexb:bc
  %-  en:btc-script
  :~  %op-dup
      %op-hash160
      [%op-pushdata (hash-160:bcu 33^(compress-point p))]
      %op-equalverify
      %op-checksig
  ==
::
++  funding-output
  |=  [p1=pubkey p2=pubkey]
  ^-  script:btc-script
  =+  a=33^(compress-point p1)
  =+  b=33^(compress-point p2)
  ;:  welp
    ~[%op-2]
    ?:  (lte +.a +.b)
      :~  [%op-pushdata a]
          [%op-pushdata b]
      ==
    :~  [%op-pushdata b]
        [%op-pushdata a]
    ==
    ~[%op-2 %op-checkmultisig]
  ==
::
++  local-output
  |=  [=revocation=pubkey =local-delayed=pubkey delay=@ud]
  ^-  script:btc-script
  :~  %op-if
      [%op-pushdata 33^(compress-point revocation-pubkey)]
      %op-else
      [%op-pushdata (flip:byt:bcu 2^delay)]
      %op-checksequenceverify
      %op-drop
      [%op-pushdata 33^(compress-point local-delayed-pubkey)]
      %op-endif
      %op-checksig
  ==
:: ::
:: ++  local-output-spend
::   |=  [=revocation=pubkey =local-delayed=pubkey delay=@ud]
::   ^-  hexb:bc
::   %-  en:btc-script
::   :~  
::
++  remote-output
  |=  =pubkey
  ^-  script:btc-script
  :~  [%op-pushdata 33^(compress-point pubkey)]
      %op-checksigverify
      %op-1
      %op-checksequenceverify
  ==
::
++  anchor-output
  |=  =pubkey
  ^-  script:btc-script
  :~  [%op-pushdata 33^(compress-point pubkey)]
      %op-checksig
      %op-ifdup
      %op-notif
      %op-16
      %op-checksequenceverify
      %op-endif
  ==
::
++  htlc-prefix
  |=  [=revocation=pubkey =remote-htlc=pubkey]
  ^-  script:btc-script
  :~  %op-dup
      %op-hash160
      [%op-pushdata (hash-160:bcu 33^(compress-point revocation-pubkey))]
      %op-equal
      %op-if
      %op-checksig
      %op-else
      [%op-pushdata 33^(compress-point remote-htlc-pubkey)]
      %op-swap
      %op-size
      [%op-pushdata [1 32]]
      %op-equal
  ==
::
++  htlc-offered
  |=  $:  =local-htlc=pubkey
          =remote-htlc=pubkey
          =revocation=pubkey
          payment-hash=hexb:bc
          confirmed-spend=?
      ==
  ^-  script:btc-script
  ;:  welp
    %+  htlc-prefix  revocation-pubkey  remote-htlc-pubkey
    :~  %op-notif
        %op-drop
        %op-2
        %op-swap
        [%op-pushdata 33^(compress-point local-htlc-pubkey)]
        %op-2
        %op-checkmultisig
        %op-else
        %op-hash160
        [%op-pushdata [20 (ripemd-160:ripemd:crypto payment-hash)]]
        %op-equalverify
        %op-checksig
        %op-endif
    ==
    ?:  confirmed-spend
      :~  %op-1
          %op-checksequenceverify
          %op-drop
          %op-endif
      ==
    ~[%op-endif]
  ==
::
++  htlc-received
  |=  $:  =local-htlc=pubkey
          =remote-htlc=pubkey
          =revocation=pubkey
          payment-hash=hexb:bc
          cltv-expiry=@ud
          confirmed-spend=?
      ==
  ^-  script:btc-script
  ;:  welp
    %+  htlc-prefix  revocation-pubkey  remote-htlc-pubkey
    :~  %op-if
        %op-hash160
        [%op-pushdata [20 (ripemd-160:ripemd:crypto payment-hash)]]
        %op-equalverify
        %op-2
        %op-swap
        [%op-pushdata 33^(compress-point local-htlc-pubkey)]
        %op-2
        %op-checkmultisig
        %op-else
        %op-drop
        [%op-pushdata (flip:byt:bcu 2^cltv-expiry)]
        %op-checklocktimeverify
        %op-drop
        %op-checksig
        %op-endif
    ==
    ?.  confirmed-spend  ~
    :~  %op-1
        %op-checksequenceverify
        %op-drop
    ==
    ~[%op-endif]
  ==
::
++  htlc-witness
  |=  $:  =direction
          =local-htlc=pubkey
          =remote-htlc=pubkey
          =remote-revocation=pubkey
          payment-hash=hexb:bc
          cltv-expiry=(unit blocks)
          confirmed-spend=?
      ==
  ^-  script:btc-script
  ?:  =(direction %received)
    %:  htlc-received
      local-htlc-pubkey=local-htlc-pubkey
      remote-htlc-pubkey=remote-htlc-pubkey
      revocation-pubkey=remote-revocation-pubkey
      payment-hash=payment-hash
      cltv-expiry=(need cltv-expiry)
      confirmed-spend=confirmed-spend
    ==
  %:  htlc-offered
    local-htlc-pubkey=local-htlc-pubkey
    remote-htlc-pubkey=remote-htlc-pubkey
    revocation-pubkey=remote-revocation-pubkey
    payment-hash=payment-hash
    confirmed-spend=confirmed-spend
  ==
::
++  htlc-spend
  |=  $:  =revocation=pubkey
          =local-delayed=pubkey
          to-self-delay=@ud
      ==
  ^-  script:btc-script
  :~  %op-if
      [%op-pushdata 33^(compress-point revocation-pubkey)]
      %op-else
      [%op-pushdata (flip:byt:bcu 2^to-self-delay)]
      %op-checksequenceverify
      %op-drop
      [%op-pushdata 33^(compress-point local-delayed-pubkey)]
      %op-endif
      %op-checksig
  ==
--
