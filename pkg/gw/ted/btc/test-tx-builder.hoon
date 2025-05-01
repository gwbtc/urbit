/+  *ord, *test, gw=groundwire, *script, bip32, b173, rpc=json-rpc
=<
^-  thread:spider
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
=/  =req-to:btcio  (need !<((unit req-to:btcio) args))
;<  =bowl:spider  bind:m  get-bowl:io
=/  =wallet  (make-wallet bowl)
;<  mined=(unit (list octs))  bind:m  (mine-to-address:btcio req-to ~ addr.ext.wallet)
?~  mined  ~|(%mine-block-fail !!)
;<  block=(unit block:btcio)  bind:m  (get-block:btcio req-to ~ q:(head u.mined))
?~  block  ~|(%wtf !!)
?~  txs.block  ~|(%wtf !!)
=/  commit=transaction:gw
  %:  build-commit-tx
    [-<.txs.block 0]
    ext.wallet
    value.-<.txs.block 
    own.wallet
  ==
=/  commit-hex=octs  (encode:gw commit)
=/  commit-txhash=octs  (shay [32 commit-hex])
=/  reveal=transaction:gw
  %:  build-reveal-tx
    [commit-txhash 0]
    (snag 0 outputs.commit)
    internal.own.wallet
  ==
=/  reveal-hex=octs  (encode:gw reveal)
;<  comres=(unit @ux)  bind:m  (send-raw-transaction req-to ~ commit-hex)
?~  comres  ~!(%commit-tx-failed !!)
;<  revres=(unit @ux)  bind:m  (send-raw-transaction req-to ~ reveal-hex)
?~  revres  ~!(%reveal-tx-failed !!)
(pure:m !>(revres))
::
|%
+$  spender
  $:  internal=keypair:gw
      tweaked=keypair:gw
      address=cord
  ==
+$  wallet  
  $:  seed=@ux
      ext=spender
      own=spender
  ==
++  compress-point  compress-point:secp256k1:secp:crypto
::
++  ord-0-octs  %-  need  %-  de:base16:mimes:html  '204a3ca2cf35f7902df1215f823d977df1174048b062e03a44f71c2ee736a60cc5ac0063036f7264010109696d6167652f706e67004d080289504e470d0a1a0a0000000d49484452000000640000006401030000004a2c071700000006504c5445ffffff00000055c2d37e000002ce4944415438cb95d44b6813411807f0944a13105d14b4146916c1b33d150b7d2ce45ab027295a4b0e1e4a5b4a2b4512fac8563c78509abb68051151aacda1600b4db2a1789162021e046d934dc921859addc4906c92dd9dbf21333b01c143e7f6e39bef3133ecbaceb824acb5d109d4da12b22ed2d68808a1bdb50e94b33ccd006c9ee8d624ac5b8ec4b4aa0464deed50559665a78cacc6ba1539c1044df627c18a76a8a5c668090bac4118440719600dc2a8164086a804d5ac544c84984a5aa1aa950895f7260a556861aade5fea5c559d0d304da2528131ce4ea76a958a86793a9a9437eb65d302531db51cca4c32718de86b02e8d8c13a92b7e5728e2a108031093b4d35370ff31ac80faa19d56dee59e20c8b45afdb3bc5a79f59dec373abc6974b2c2f985d18361e27584df92013d7234b32d5e07ec3ab9f3f59a6b3f487b11191483fd5e02659d7fa1a7b549280f52d898854bd22929a8c6ef628e3188bfb6d3f9520226dc8f03209782d4a84c9bd495e197d8d28bf794554c810d37e43c2b39315a683cc6a776ac95176c1368e131653b0d3dcab751e51758d08a64984e72c26c3e8058eb8aa17b80419bfdf01192a11f8b92d035412b07d5781f32a32c9dfd7a1d25b5a8599d4966150190a36744d110109b16c4b960ad12f62aaa58ed371e2f78fd9f78a2d99776aaaf2a0324165a97f52f1694c5141a94e45bf41a13ac5ce624f5a69b4e4aa92ef4ba35fe70bb4437d73a0789c7bb14d155a216e4bc8a7d86b3ed16d83d4242a0965d3ac3b6710b0928fe655c26e8228cd392316550751888e48d1f9fc5244278b59a65b01a2dbe935a69ed4e1446891c1e58ddf781b8e38ba183b34035b8e041940860b0008dfa9787c22dfe90e1ab1dc1157e0657eb8ad398fef6a5bd31edfe5ffc5748fcf6b71cd020d1eebfad0ccfbc8f5a999c7e57ee4f15d6957319add7995cedde664bb5c684e5d73d4a103a4e8c8650266962bf4e67d24c125dae3f8e73f78b6f5177fb5c56a2d73fc4b0000000049454e44ae42608268'
++  ord-0-script  (de:bscr ord-0-octs)
++  ord-0-mails  (mails:de ord-0-script)
++  ord-0-mail  (head ord-0-mails)
::
++  make-wallet
  |=  =bowl:spider
  ^-  keys
  =+  seed=(~(raw og eny.bowl) 256)
  =+  init=(derive-sequence:(from-seed:bip32 32^seed) ~[1.337 0 0])
  =/  =keypair:gw  [pub=pub.ext priv=prv.ext]
  =/  tweaked=keypair:gw  ~(tweak-keypair p2tr:gw `x.pub.keypair ~ `priv.keypair)
  =/  addr=cord  (need (encode-pubkey:b173 %regtest 33^(compress-point pub.tweaked)))
  =/  ext=spender  [keypair tweaked addr]
  =+  owner=(derive-sequence:(from-seed:bip32 32^seed) ~[1.338 0 0])
  =/  k=keypair:gw  [pub=pub.owner priv=prv.owner]
  =/  tweak=point:gw  ~(tweak-keypair p2tr:gw `x.pub.k ~ `priv.k)
  =/  address=cord  (need (encode-pubkey:b173 %regtest 33^(compress-point pub.tweak)))
  [seed ext [k tweak address]]
::
++  make-spend-script
  ^-  script:scr
  =/  mail  ord-0-mail
  =/  mails  mail(pntr [1 %& 92])
  ~[(en:bscr (mails-to-script:en mails)) [3 0x1.7355]]
::
++  build-commit-tx
  |=  $:  =outpoint:gw
          from=spender
          val=@ud
          owner=spender
      ==
  ^-  transaction:gw
  =|  tx=transaction:gw
  =/  =output:gw  [val ~(scriptpubkey p2tr:gw `x.pub.from ~ ~) ~ ~]
  =/  spend-script=script:scr:gw  make-spend-script
  =.  tx
    %:  ~(add-input build:gw tx)
      outpoint
      output
      `internal.from
      ~  ~
      :: by passing ~ we default to SIGHASH_ALL (and no nsequence constraint) so when we sign this input later we'll commit to all and only
      :: the inputs and outputs we've added to the transaction up to that point
    ==
  =.  tx
    %^  ~(add-output build:gw tx)
        (sub val 150)  :: a tx with 1 keypath-spend input and 1 P2TR output should weigh approximately 103vB
      `internal.owner
    `spend-script
  ~(finalize build:gw tx)
::
++  build-reveal-tx
  |=  $:  =outpoint:gw
          =output:gw
          =keypair:gw
      ==
  ^-  transaction:gw
  =|  reveal=transaction:gw
  =.  reveal
    %:  ~(add-input build:gw reveal)
      outpoint
      output
      `keypair
      ~  ~
    ==
  ?~  spend-script.output  !!
  =.  reveal
    %^  ~(add-output build:gw reveal)
        (sub val.out.output (add (lent spend-script.output) 180))
      `keypair
    ~
  ~(finalize build:gw reveal)
::
++  make-txs
  |=  [=outpoint:gw =keypair:gw val=@ud]
  =/  owner=keypair:gw  make-keys
  =/  commit=transaction:gw  (build-commit-tx outpoint keypair val owner)
  =/  commit-hex=octs  (encode:gw commit)
  =/  commit-txhash=octs  (shay [32 commit-hex])
  =/  reveal=transaction:gw
    %^  build-reveal-tx
        [dat.commit-txhash 0]
      (snag 0 outputs.commit)
    owner
  =/  reveal-hex=octs  (encode:gw reveal)
  [commit reveal]