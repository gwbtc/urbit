/+  *ord, *test
|%
++  ord-0-octs  %-  need  %-  de:base16:mimes:html  '204a3ca2cf35f7902df1215f823d977df1174048b062e03a44f71c2ee736a60cc5ac0063036f7264010109696d6167652f706e67004d080289504e470d0a1a0a0000000d49484452000000640000006401030000004a2c071700000006504c5445ffffff00000055c2d37e000002ce4944415438cb95d44b6813411807f0944a13105d14b4146916c1b33d150b7d2ce45ab027295a4b0e1e4a5b4a2b4512fac8563c78509abb68051151aacda1600b4db2a1789162021e046d934dc921859addc4906c92dd9dbf21333b01c143e7f6e39bef3133ecbaceb824acb5d109d4da12b22ed2d68808a1bdb50e94b33ccd006c9ee8d624ac5b8ec4b4aa0464deed50559665a78cacc6ba1539c1044df627c18a76a8a5c668090bac4118440719600dc2a8164086a804d5ac544c84984a5aa1aa950895f7260a556861aade5fea5c559d0d304da2528131ce4ea76a958a86793a9a9437eb65d302531db51cca4c32718de86b02e8d8c13a92b7e5728e2a108031093b4d35370ff31ac80faa19d56dee59e20c8b45afdb3bc5a79f59dec373abc6974b2c2f985d18361e27584df92013d7234b32d5e07ec3ab9f3f59a6b3f487b11191483fd5e02659d7fa1a7b549280f52d898854bd22929a8c6ef628e3188bfb6d3f9520226dc8f03209782d4a84c9bd495e197d8d28bf794554c810d37e43c2b39315a683cc6a776ac95176c1368e131653b0d3dcab751e51758d08a64984e72c26c3e8058eb8aa17b80419bfdf01192a11f8b92d035412b07d5781f32a32c9dfd7a1d25b5a8599d4966150190a36744d110109b16c4b960ad12f62aaa58ed371e2f78fd9f78a2d99776aaaf2a0324165a97f52f1694c5141a94e45bf41a13ac5ce624f5a69b4e4aa92ef4ba35fe70bb4437d73a0789c7bb14d155a216e4bc8a7d86b3ed16d83d4242a0965d3ac3b6710b0928fe655c26e8228cd392316550751888e48d1f9fc5244278b59a65b01a2dbe935a69ed4e1446891c1e58ddf781b8e38ba183b34035b8e041940860b0008dfa9787c22dfe90e1ab1dc1157e0657eb8ad398fef6a5bd31edfe5ffc5748fcf6b71cd020d1eebfad0ccfbc8f5a999c7e57ee4f15d6957319add7995cedde664bb5c684e5d73d4a103a4e8c8650266962bf4e67d24c125dae3f8e73f78b6f5177fb5c56a2d73fc4b0000000049454e44ae42608268'
++  ord-0-script  (de:bscr ord-0-octs)
++  ord-0-mails  (mails:de ord-0-script)
++  ord-0-mail  (head ord-0-mails)
++  make-input
  |=  [txh=@ux pos=@ud val=@ud]
  ^-  inputw:tx:bc
  =+  in=*inputw:tx:bc
  in(txid 32^txh, pos pos, value val)
::
++  make-input-wit
  |=  [txh=@ux pos=@ud val=@ud witness=(list octs)]
  ^-  inputw:tx:bc
  =+  in=*inputw:tx:bc
  in(txid 32^txh, pos pos, value val, witness witness)
::
++  make-ord-insc
  |=  [txh=@ux pos=@ud val=@ud mails=(list mail)]
  (make-input-wit txh pos val ~[(en:bscr (mails-to-script:en mails)) [3 0x1.7355]])
::
++  make-tx
  |=  [is=(list inputw:tx:bc) os=(list @ud)]
  ^-  dataw:tx:bc
  =+  tx=*dataw:tx:bc
  tx(is is, os (turn os |=(@ [2^0xb0b +<])))
--
|%
++  test-insc
  =/  oc  ord-core
  =.  oc  oc(cb-tx [0xb055 ~[[2^0xb0b 30]] 20]) 
  =/  mail  ord-0-mail
  =/  tx  (make-tx [(make-ord-insc 0x123 0 100 mail(pntr [1 %& 92]) ~) ~] ~[50 40]) 
  =.  oc  (handle-tx:oc 0x123 tx)
  ~|  state:oc
  !!
--
