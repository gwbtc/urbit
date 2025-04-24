/+  der, scr=btc-script
|%
+$  point  point:secp256k1:secp:crypto
+$  txid  @ux
+$  pos  @ud
+$  sats  @ud
+$  outpoint  [=txid =pos]
+$  keypair  [pub=point priv=@]
+$  pubkey  @
++  sighash
  |%
  ++  default                   0x1
  ++  all                       0x1
  ++  none                      0x2
  ++  single                    0x3
  ++  anyonecanpay              0x80
  --
++  tx
  |%
  +$  in
    $:  prevout=outpoint
        nsequence=$~(0xffff.fffe @ux)
        script-witness=(list octs)
    ==
  ::
  +$  out
    $:  value=sats
        script-pubkey=octs
    ==
  ::
  +$  tx
    $:  vin=(list in)
        vout=(list out)
        nversion=$~(2 @)
        nlocktime=@
    ==
  --
+$  input
  $:  =in:tx
      utxo=output
      sig-hash=$~(0x1 @ux)
      =keypair
  ==
+$  output
  $:  =out:tx
      spend-script=(unit script:scr)
      internal-key=(unit pubkey)
  ==
+$  transaction
  $:  tx:tx
      inputs=(list input)
      outputs=(list output)
  ==
::
++  build
  |_  t=transaction
  ::
  ++  add-input
    |=  $:  prev=outpoint
            from=output
            keys=keypair
            sigh=(unit @ux)
            nseq=(unit @ux)
        ==
    ^-  transaction
    =|  n=input
    =.  n
      %_  n
        utxo               from
        prevout.in         prev
        keypair            keys
        sig-hash           (fall sigh sig-hash.n)
        nsequence.in       (fall nseq nsequence.in.n)
      ==
    t(inputs (snoc inputs.t n))
  ::
  ++  add-output
    |=  $:  v=sats
            k=(unit pubkey)
            s=(unit script:scr)
        ==
    ^-  transaction
    =|  o=output
    =.  o
      %_  o
        value.out          v
        internal-key       k
        spend-script       s
        script-pubkey.out  ~(scriptpubkey p2tr k s)
      ==
    t(outputs (snoc outputs.t o))
  ::
  ++  finalize-input
    |=  i=@
    ^-  transaction
    =/  n=input  (snag i inputs.t)
    ?.  =(~ script-witness.in.n)
      t
    =+  int-key=(fall internal-key.utxo.n x.pub.keypair.n)
    =/  sig=octs  (sign-input t i priv.keypair.n)
    ?~  spend-script.utxo.n
      =.  script-witness.in.n  ~[sig]
      t(inputs (snap inputs.t i `input`n))
    =.  script-witness.in.n
      [sig ~(scriptspend p2tr `int-key spend-script.utxo.n)]
    t(inputs (snap inputs.t i `input`n))
  ::
  ++  finalize
    ^-  transaction
    =|  i=@
    |-
    ?:  =((lent inputs.t) i)
      t
    =/  n=input  (snag i inputs.t)
      ::  todo: add checks - value (fees), sighash_single, valid nseq and nlock
    ?.  =(~ script-witness.in.n)
      $(i +(i), t t(vin (snoc vin.t in.n)))
    =/  sig=octs  (sign-input t i priv.keypair.n)
    ?~  spend-script.utxo.n
      =.  script-witness.in.n  ~[sig]
      =.  inputs.t  (snap inputs.t i `input`n)
      $(i +(i))
    =+  int-key=(fall internal-key.utxo.n x.pub.keypair.n)
    =.  script-witness.in.n  [sig ~(scriptspend p2tr `int-key spend-script.utxo.n)]
    =.  vin.t  (snoc vin.t in.n)
    $(t t(inputs (snap inputs.t i `input`n)), i +(i))
  --
::
++  encode
  |%
  ++  transaction
    |=  t=tx:tx
    ^-  octs
    %-  catb  %-  zing
    ^-  (list (list octs))
    :~  ~[(flipb 4^nversion.t)]
        ~[1^0x0 1^0x1]
        ~[(encode-compact-size (lent vin.t))]
        (turn vin.t input)
        ~[(encode-compact-size (lent vout.t))]
        (turn vout.t output)
        (witness vin.t)
    ==
  ::
  ++  input
    |=  =in:tx
    ^-  octs
    %-  catb
    :~  (flipb (to-octs txid.prevout.in))
        (flipb 4^pos.prevout.in)
        1^0x0
        (flipb 4^nsequence.in)
    ==
  ::
  ++  output
    |=  =out:tx
    ^-  octs
    %-  catb
    :~  (flipb 8^value.out)
        (encode-compact-size p.script-pubkey.out)
        script-pubkey.out
    ==
  ::
  ++  witness
    |=  v=(list in:tx)
    ^-  (list octs)
    %+  turn  v
    |=  =in:tx
    ^-  octs
    ?~  script-witness.in
      0^0x0
    %-  catb
    :-  (encode-compact-size (lent script-witness.in))
    %-  zing  %+  turn  script-witness.in
    |=  o=octs
    ^-  (list octs)
    ?:  =(0 p.o)
      ~[1^0x0]
    ~[(encode-compact-size p.o) o]
  --
::
::  taproot spending and construction methods
++  sign-input
  |=  [t=transaction i=@ priv=@]
  ^-  octs
  =+  n=(snag i inputs.t)
  =/  neone=?  =(anyonecanpay:sighash (dis sig-hash.n 0x80))
  =/  single=?  =(single:sighash (dis sig-hash.n 3))
  =/  none=?  =(none:sighash (dis sig-hash.n 3))
  |^
  =/  msghash=@uvI  (shay (flipb taproot-preimage))
  =+  (ecdsa-raw-sign:secp256k1:secp:crypto msghash priv)
  (catb ~[(flipb (en:der [%seq ~[[%int r] [%int s]]])) 1^sig-hash.n])
  ::
  ++  taproot-preimage
    ^-  octs
    %-  catb
    ;:  welp
      tx-fields
      input-fields
      output-fields
      ext-fields
    ==
  ::
  ++  tx-fields
    |^  ^-  (list octs)
    =/  fields=(list octs)
      :~  (flipb 4^sig-hash.n)
          (flipb 4^nversion.t)
          (flipb 4^nlocktime.t)
      ==
    =?  fields  !neone
      %+  welp  fields
      :~  sha-prevouts
          sha-amounts
          sha-scriptpubkeys
          sha-sequences
      ==
    =?  fields  &(!single !none)
      (snoc fields sha-outputs)
    fields
    ::
    ++  sha-prevouts
      ^-  octs
      =/  preimage=octs
        (catb (turn inputs.t |=(n=input (encode-outpoint prevout.in.n))))
      [32 (shay (flipb preimage))]
    ::
    ++  sha-amounts
      ^-  octs
      =/  preimage=octs
        (catb (turn inputs.t |=(n=input (flipb 8^value.out.utxo.n))))
      [32 (shay (flipb preimage))]
    ::
    ++  sha-scriptpubkeys
      ^-  octs
      =/  preimage=octs
        %-  catb
        (turn inputs.t |=(n=input (encode-scriptpubkey script-pubkey.out.utxo.n)))
      [32 (shay (flipb preimage))]
    ::
    ++  sha-sequences
      ^-  octs
      =/  preimage=octs
        (catb (turn inputs.t |=(n=input (flipb 4^nsequence.in.n))))
      [32 (shay (flipb preimage))]
    ::
    ++  sha-outputs
      ^-  octs
      =/  preimage=octs
        %-  catb  %+  turn  outputs.t
        |=  o=output
        ~!  o
        (output:encode out.o)
      [32 (shay (flipb preimage))]
    --
  ::
  ++  input-fields
    ::  assume no annex
    ::  assume known ext_flag as of BIP342 (0 for keyspends, 1 for scriptspends)
    ^-  (list octs)
    =/  enc-out=octs  (encode-outpoint prevout.in.n)
    =/  fields=(list octs)
      :~  (catb ~[(encode-compact-size p.enc-out) enc-out])
          (flipb 8^value.out.utxo.n)
          (catb ~[(encode-compact-size 35) script-pubkey.out.utxo.n])
          (flipb 4^nsequence.in.n)
      ==
    =?  fields  !neone  (into fields 0 (flipb 4^i))
    ?:  (gte (lent script-witness.in.n) 2)
      (into fields 0 1^2)  :: 2 or 1? check BIP
    (into fields 0 1^0)
  ::
  ++  output-fields
    ^-  (list octs)
    ?.  single
      ~
    ~[(output:encode out:(snag i outputs.t))]
  ::
  ++  ext-fields
    ::  assume no OP_CODESEPARATORs
    ^-  (list octs)
    ?.  (gte (lent script-witness.in.n) 2)
      ~
    =/  ser-script=octs
      (snag (sub (lent script-witness.in.n) 2) script-witness.in.n)
    =/  [n=@ s=octs]  (read-compact-size ser-script)
    :~  32^~(tapleaf-hash p2tr ~ `(de:scr s))
        1^0
        4^0xffff.ffff
    ==
  --
::
:: +$  p2tr  [ik=(unit pubkey) ts=(unit script:scr)]
++  p2tr
  ::  current: single tapleaf
  =,  secp256k1:secp:crypto
  |_  [p=(unit pubkey) s=(unit script:scr)]
  ::
  ++  scriptpubkey
    ^-  octs
    35^(cat 3 0x1 q.q:tweaked-pubkey)
  ::
  ++  tweaked-pubkey
    ^-  (pair @ octs)
    =/  pt=point
      ?~  p
        nums-point
      (need (lift-x:schnorr u.p))
    =/  t=@I
      ?~  s
        (tagged-hash:schnorr 'TapTweak' (to-octs x.pt))
      (tagged-hash:schnorr 'TapTweak' (to-octs (mix x.pt tapleaf-hash)))
    =/  tweaked=point
      (add-points pt (mul-point-scalar g.domain.curve t))
    =/  parity=@  ?:  =(0 (mod y.tweaked 2))  0  1
    [parity (to-octs x.tweaked)]
  ::
  ++  tapleaf-hash
    ^-  @I
    =/  scrbyt=octs  (en:scr (need s))
    %+  tagged-hash:schnorr  'TapLeaf'
    (to-octs (mix 0xc0 q:(catb ~[(encode-compact-size p.scrbyt) scrbyt])))
  ::
  ++  scriptspend
    :: pre-signing (no script inputs, only ser-script and control block)
    :: |=  sin=(list octs)
    ^-  (list octs)
    =/  sscr=octs  (en:scr (need s))
    =+  cbyt=(mix 0xc0 p:tweaked-pubkey)
    =/  control-block=octs
      %-  catb
      :~  (to-octs cbyt)
          q:tweaked-pubkey
          :: additional merkle hashes for multileaf taptree would go here - irrelevant for inscriptions rn
      ==
    :: %+  welp  (flipb sin)  :: assume script inputs provided in regular exec order
    :~  (catb ~[(encode-compact-size p.sscr) sscr])
        control-block
    ==
  ::
  ++  nums-point
    ^-  point
    =/  pt=point
      %-  need
      %-  lift-x:schnorr
      0x5092.9b74.c1a0.4954.b78b.4b60.35e9.7a5e.078a.5a0f.28ec.96d5.47bf.ee9a.ce80.3ac0
    (add-points pt (mul-point-scalar g.domain.curve x.pt))
  --
::
:: consolidated bitcoin utils
:: hex
++  catb
  |=  dats=(list octs)
  ^-  octs
  (roll dats |=([a=octs b=octs] (add p.a p.b)^(cat 3 q.a q.b)))
::
++  to-octs
  |=  dat=@
  ^-  octs
  [(met 3 dat) dat]
::
++  flipb
  |=  o=octs
  ^-  octs
  [p.o (rev 3 o)]
::
++   splitb
  |=  [n=@ o=octs]
  ^-  [octs octs]
  =+  rest=(sub p.o n)
  :-  [n (rsh [3 (sub p.o n)] q.o)]
  [rest (end [3 rest] q.o)]
::
:: encoding
++  encode-compact-size
  |=  a=@ 
  ^-  octs
  =+  n=(met 3 a)
  ?:  =(n 0)     1^a
  ?:  =(n 1)     1^a
  ?:  =(n 2)     (catb ~[1^0xfd (flipb 2^a)])
  ?:  (lte n 4)  (catb ~[1^0xfe (flipb 4^a)])
  ?:  (lte n 8)  (catb ~[1^0xff (flipb 8^a)])
  ~|(%invalid-compact-size !!)
::
++  read-compact-size
  |=  b=octs
  ^-  [a=@ rest=octs]
  =^  s  b  (splitb 1 b)
  ?:  (lth +.s 0xfd)  [+.s b]
  ~|  %invalid-compact-size
  =/  len=bloq
    ?+  +.s  !!
      %0xfd  1
      %0xfe  2
      %0xff  3
    ==
  =^  k  b  (splitb (bex len) b)
  :_  b
  q:(flipb k)
::
++  encode-outpoint
  |=  o=outpoint
  ^-  octs
  %-  catb
  :~  (flipb 32^txid.o)
      (flipb 4^pos.o)
  ==
::
++  encode-scriptpubkey
  |=  spk=octs
  (catb ~[(encode-compact-size 35) spk])
--