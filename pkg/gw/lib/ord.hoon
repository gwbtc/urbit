::/+  wiry
::=>  wiry
::/-  bc=bitcoin, bscr=btc-script, *mip, bio=btcio
/+  bscr=btc-script
/+  *mip
=*  sha  ..shax
=,  crypto
=|  lac=_|
|%
++  debug
  |*  [meg=@t *]
  ?:  lac
    +<+
  ~>  %slog.[0 meg]
  +<+
::
+$  block
  $:  hax=@ux
      reward=@ud
      height=@ud
      txs=(list [txh=@ux tx=dataw:tx])
  ==
::
++  script
  =<  script-label
  |%
  +$  script  (list op)
  +$  script-label  $+(script script)
  +$  op
    $@  $?  %op-nop
            %op-if
            %op-notif
            %op-else
            %op-endif
            %op-verify
            %op-return
        ::
            %op-toaltstack
            %op-fromaltstack
            %op-ifdup
            %op-depth
            %op-drop
            %op-dup
            %op-nip
            %op-over
            %op-pick
            %op-roll
            %op-rot
            %op-swap
            %op-tuck
            %op-2drop
            %op-2dup
            %op-3dup
            %op-2over
            %op-2rot
            %op-2swap
        ::
            %op-cat
            %op-substr
            %op-left
            %op-right
            %op-size
        ::
            %op-invert
            %op-and
            %op-or
            %op-xor
            %op-equal
            %op-equalverify
        ::
            %op-1add
            %op-1sub
            %op-2mul
            %op-2div
            %op-negate
            %op-abs
            %op-not
            %op-0notequal
            %op-add
            %op-sub
            %op-mul
            %op-div
            %op-mod
            %op-lshift
            %op-rshift
            %op-booland
            %op-boolor
            %op-numequal
            %op-numequalverify
            %op-numnotequal
            %op-lessthan
            %op-greaterthan
            %op-lessthanorequal
            %op-greaterthanorequal
            %op-min
            %op-max
            %op-within
        ::
            %op-ripemd160
            %op-sha1
            %op-sha256
            %op-hash160
            %op-hash256
            %op-codeseparator
            %op-checksig
            %op-checksigverify
            %op-checkmultisig
            %op-checkmultisigverify
        ::
            %op-checklocktimeverify
            %op-checksequenceverify
        ::
            %op-pubkeyhash
            %op-pubkey
            %op-invalidopcode
        ::
            %op-reserved
            %op-ver
            %op-verif
            %op-vernotif
            %op-reserved1
            %op-reserved2
        ::
            %op-nop1
            %op-nop4
            %op-nop5
            %op-nop6
            %op-nop7
            %op-nop8
            %op-nop9
            %op-nop10
        ==
     $:  %op-push
         $%  [p=%num octs=[p=%1 q=@]]
             [p=?(~ %1 %2 %4) =octs]
         ==
     ==
  ::
  ++  de
    |=  a=octs
    ^-  (unit script)
    ?:  =(p.a 0)  ~ :: `~
    =/  n  (dec p.a)
    |-  ^-  (unit script)
    =/  op  (cut 3 [n 1] q.a)
    =-  ?~  -  ~
        ?:  =(n.u 0)  `op.u^~
        ?~  rest=%_($ n (dec n.u))  ~
        `op.u^u.rest
    ^-  (unit [=^op n=@])
    ?:  &(!=(0 op) (lte op 0x4b)) :: push next `op` bytes
      ?:  (lth n op)  ~
      =.  n  (sub n op)
      =/  dat  (rev 3 op (cut 3 [n op] q.a))
      `[%op-push ~ op dat]^n
    ?:  ?=(%0x4c op) :: op_pushdata1
      ?:  =(n 0)  ~
      =.  n  (dec n)
      =/  len  (cut 3 [n 1] q.a)
      ?:  (lth n len)  ~
      =.  n  (sub n len)
      =/  dat  (rev 3 len (cut 3 [n len] q.a))
      `[%op-push %1 len dat]^n
    ?:  ?=(%0x4d op) :: op_pushdata2
      ?:  (lth n 2)  ~
      =.  n  (sub n 2)
      =/  len  (rev 3 2 (cut 3 [n 2] q.a))
      ?:  (lth n len)  ~
      =.  n  (sub n len)
      =/  dat  (rev 3 len (cut 3 [n len] q.a))
      `[%op-push %2 len dat]^n
    ?:  ?=(%0x4e op) :: op_pushdata4
      ?:  (lth n 4)  ~
      =.  n  (sub n 4)
      =/  len  (rev 3 4 (cut 3 [n 4] q.a))
      ?:  (lth n len)  ~
      =.  n  (sub n len)
      =/  dat  (rev 3 len (cut 3 [n len] q.a))
      `[%op-push %4 len dat]^n
    =-  ?~(- ~ `u^n)
    ^-  (unit ^op)
    ?:  &((lth 0x50 op) (lte op 0x60))  :: op_1..op_16
      `[%op-push %num %1 (sub op 0x50)]
    ?+  op  ~
      %0     `[%op-push %num %1 0]
      %0x4f  `[%op-push %num %1 81]
      %0x50  `%op-reserved
    ::
      %0x61  `%op-nop
      %0x62  `%op-ver
      %0x63  `%op-if
      %0x64  `%op-notif
      %0x65  `%op-verif
      %0x66  `%op-vernotif
      %0x67  `%op-else
      %0x68  `%op-endif
      %0x69  `%op-verify
      %0x6a  `%op-return
      %0x6b  `%op-toaltstack
      %0x6c  `%op-fromaltstack
      %0x6d  `%op-2drop
      %0x6e  `%op-2dup
      %0x6f  `%op-3dup
      %0x70  `%op-2over
      %0x71  `%op-2rot
      %0x72  `%op-2swap
      %0x73  `%op-ifdup
      %0x74  `%op-depth
      %0x75  `%op-drop
      %0x76  `%op-dup
      %0x77  `%op-nip
      %0x78  `%op-over
      %0x79  `%op-pick
      %0x7a  `%op-roll
      %0x7b  `%op-rot
      %0x7c  `%op-swap
      %0x7d  `%op-tuck
      ::
      %0x7e  `%op-cat
      %0x7f  `%op-substr
      %0x80  `%op-left
      %0x81  `%op-right
      %0x82  `%op-size
      %0x83  `%op-invert
      %0x84  `%op-and
      %0x85  `%op-or
      %0x86  `%op-xor
      %0x87  `%op-equal
      %0x88  `%op-equalverify
      %0x89  `%op-reserved1
      %0x8a  `%op-reserved2
      ::
      %0x8b  `%op-1add
      %0x8c  `%op-1sub
      %0x8d  `%op-2mul
      %0x8e  `%op-2div
      %0x8f  `%op-negate
      %0x90  `%op-abs
      %0x91  `%op-not
      %0x92  `%op-0notequal
      %0x93  `%op-add
      %0x94  `%op-sub
      %0x95  `%op-mul
      %0x96  `%op-div
      %0x97  `%op-mod
      %0x98  `%op-lshift
      %0x99  `%op-rshift
      %0x9a  `%op-booland
      %0x9b  `%op-boolor
      %0x9c  `%op-numequal
      %0x9d  `%op-numequalverify
      %0x9e  `%op-numnotequal
      %0x9f  `%op-lessthan
      %0xa0  `%op-greaterthan
      %0xa1  `%op-lessthanorequal
      %0xa2  `%op-greaterthanorequal
      %0xa3  `%op-min
      %0xa4  `%op-max
      %0xa5  `%op-within
      ::
      %0xa6  `%op-ripemd160
      %0xa7  `%op-sha1
      %0xa8  `%op-sha256
      %0xa9  `%op-hash160
      %0xaa  `%op-hash256
      %0xab  `%op-codeseparator
      %0xac  `%op-checksig
      %0xad  `%op-checksigverify
      %0xae  `%op-checkmultisig
      %0xaf  `%op-checkmultisigverify
      ::
      %0xb1  `%op-checklocktimeverify
      %0xb2  `%op-checksequenceverify
      ::
      %0xfd  `%op-pubkeyhash
      %0xfe  `%op-pubkey
      %0xff  `%op-invalidopcode
      ::
      %0xb0  `%op-nop1
      %0xb3  `%op-nop4
      %0xb4  `%op-nop5
      %0xb5  `%op-nop6
      %0xb6  `%op-nop7
      %0xb7  `%op-nop8
      %0xb8  `%op-nop9
      %0xb9  `%op-nop10
    ==
  --
+$  address
  $%  [%base58 @uc]
      [%bech32 @tas]
  ==
+$  sats  @ud
+$  txid  byts
++  tx
  |%
  +$  dataw
    $:  is=(list inputw)
        os=(list output)
        locktime=@ud
        nversion=@ud
        segwit=(unit @ud)
    ==
  ::
  +$  data
    $:  is=(list input)
        os=(list output)
        locktime=@ud
        nversion=@ud
        segwit=(unit @ud)
    ==
  ::
  +$  val
    $:  =txid
        pos=@ud
        =address
        value=sats
    ==
  ::  included: whether tx is in the mempool or blockchain
  ::
  +$  info
    $:  included=?
        =txid
        confs=@ud
        recvd=(unit @da)
        inputs=(list val)
        outputs=(list val)
    ==
  ::
  +$  input
    $:  =txid
        pos=@ud
        sequence=byts
        script-sig=(unit byts)
        pubkey=(unit byts)
        value=sats
    ==
  ::
  +$  inputw  [=witness input]
  +$  output
    $:  script-pubkey=byts
        value=sats
    ==
  ::
  +$  witness    (list byts)
  --
+$  txh   @ux   ::  txid
+$  pos   @ud   ::  index in tx output set
+$  off   @ud   ::  sat index in single output amount
+$  pntr  @ud   ::  sat index in total amount of tx outputs
+$  sont  [=txh =pos =off]
::
+$  insc  [=txh idx=@ud]
+$  ordi  [p=@ux q=@ud]
+$  urdi  [p=@ux q=@ud r=@ud]
+$  mail
  $:  mime=$@(~ [p=@ud (each @t @)])    :: tag 1 mimetype
      code=$@(~ [p=@ud (each @t @)])    :: tag 9 content encoding
      pntr=$@(~ [p=@ud (each @ud @)])   :: tag 2 pointer
      rent=$@(~ [p=@ud (each insc @)])  :: tag 3 parent
      gate=$@(~ [p=@ud (each insc @)])  :: tag 11 delegate
      meta=$@(~ octs)                   :: tag 5 metadata (multple pushes)
      prot=$@(~ octs)                   :: tag 7 meta protocol
      data=$@(~ octs)                   :: tag 0 content (all pushed data after push of 0 tag)
  ==
+$  draft  (map @ud octs)
+$  raw-sotx     [raw=octs sot=sotx]
::+$  raw-sotx     [sig=@ raw=octs =sotx]
+$  sotx  [[=ship sig=(unit @)] skim-sotx]
++  skim-sotx
  =<  many
  |%
  +$  many
    $%  single
        [%batch bat=(list single)]
    ==
  +$  single
    $%  [%spawn =pass =sont]
        [%keys =pass breach=?]
        [%escape parent=ship]
        [%cancel-escape parent=ship]
        [%adopt =ship]
        [%reject =ship]
        [%detach =ship]
        [%fief fief=(unit fief)]
        [%set-mang mang=(unit mang)]
    ==
  --
::
+$  mang  $%([%sont =sont] [%pass =pass])
+$  point
  $:  ::  domain
      ::
      ::=dominion
      ::
      ::  ownership
      ::
      $=  own
      $:  =sont
          mang=(unit mang)
      ==
      ::
      ::  networking
      ::
      $=  net
      $:  rift=@ud
          =life
          =pass
          sponsor=[has=? who=@p]
          escape=(unit @p)
          fief=(unit fief)
      ==
  ==
::
+$  turf  (list @t)                                     ::  domain, tld first
+$  fief  $%  [%turf p=(list turf) q=@udE]
              [%if p=@ifF q=@udE]
              [%is p=@isH q=@udE]
          ==
::
+$  diff
  $%  [%dns domains=(list @t)]
      $:  %point  =ship
          $%  [%rift =rift]
              [%keys =life =pass]
              [%sponsor sponsor=(unit @p)]
              [%escape to=(unit @p)]
              [%owner =sont]
              ::[%spawn-proxy =sont]
              [%mang mang=(unit mang)]
              ::[%voting-proxy =sont]
              ::[%transfer-proxy =sont]
              ::[%dominion =dominion]
              [%fief fief=(unit fief)]
  ==  ==  ==
::
++  parse-roll
  |=  batch=@
  =|  roll=(list raw-sotx)
  =|  pos=@ud
  =/  las  (met 0 batch)
  |-  ^+  roll
  ?:  (gte pos las)
    (flop roll)
  =/  parse-result  (parse-raw-tx pos batch)
  ::  Parsing failed, abort batch
  ::
  ?~  parse-result
    (debug %parse-failed ~)
  =^  raw-tx  pos  u.parse-result
  $(roll [raw-tx roll])
::
++  parse-raw-tx
  |=  [pos=@ud batch=@]
  ^-  (unit [raw-sotx pos=@ud])
  |^
  ::=^  sig  pos  (take 3 65)
  =/  res=(unit [tx=sotx pos=@ud])  parse-tx
  ?~  res  ~
  =/  dif  (sub pos.u.res pos)
  =/  len  =>((dvr dif 8) ?:(=(0 q) p +(p)))
  :-  ~  :_  pos.u.res
  [[len (cut 0 [pos dif] batch)] tx.u.res]
  ::[sig [len (cut 0 [pos dif] batch)] tx.u.res]
  ::
  ++  parse-tx
    ^-  (unit [sotx pos=@ud])
    =^  pad               pos  (take 0 5)
    =^  sig  pos  take-sig
    =^  from-ship=ship    pos  (take 0 128)
    =-  ?~  res
          ~
        `[[[from-ship sig] skim-sotx.u.res] pos.u.res]
    |-  ^-  res=(unit [=skim-sotx pos=@ud])
    =^  op   pos  (take 0 7)
    ?+    op  (debug %strange-opcode ~)
      ::  %0
      ::=^  reset=@         pos  (take 0)
      ::=^  =sont        pos  (take 3 20)
      ::`[[%transfer-point sont =(0 reset)] pos]
    ::
        %1
      =^  pad=@     pos  (take 0)
      =^  =pass     pos  take-atom
      =^  sont      pos  take-sont
      ?~  sont  ~
      `[[%spawn pass u.sont] pos]
    ::
        %2
      =^  breach=@        pos  (take 0)
      =^  =pass     pos  take-atom
      `[[%keys pass =(0 breach)] pos]
    ::
        %3   =^(res pos take-ship `[[%escape res] pos])
        %4   =^(res pos take-ship `[[%cancel-escape res] pos])
        %5   =^(res pos take-ship `[[%adopt res] pos])
        %6   =^(res pos take-ship `[[%reject res] pos])
        %7   =^(res pos take-ship `[[%detach res] pos])
        %8   =^(res pos take-mang ?~(res ~ `[[%set-mang u.res] pos]))
        ::%9   =^(res pos take-sont `[[%set-spawn-proxy res] pos])
        %10
      =^  len  pos  take-atom
      =|  bat=(list single:skim-sotx)
      |-  ^+  ^$
      ?:  =(len 0)  ~^[%batch (flop bat)]^pos
      =/  one  ,:^$
      ?~  one  ~
      ?:  ?=([%batch *] -.u.one)  ~
      =^  one  pos  u.one
      $(len (dec len), bat one^bat)
    ::
        %11
      =^  pad=@   pos   (take 0)
      =^  typ     pos   (take 0 2)
      ?+  typ  ~
          %0
        `[fief/~ pos]
          %1
        !!
        ::=^  len  pos  (take 0 2)
        ::?:  (lth 3 len)  ~
        ::=|  tufs=(list turf)
        ::|-  ^+  ^$
        ::?:  =(len 0)  `[fief/[%turf tufs]]
        ::=^  let  pos  take-atom
        ::=;  tuf
        ::  =^
        ::=|  i=@ud
        ::|-  @ud
        ::=^  car  pos  (take 3)
        ::?.  |(=('-' car) =('.' car) (gte 'a'
      ::
          %2
        =^  pip  pos  (take 3 4)
        =^  por  pos  (take 3 2)
        `[fief/`[%if pip por] pos]
      ::
          %3
        =^  pip  pos  (take 0 128)
        =^  por  pos  (take 3 2)
        `[fief/`[%is pip por] pos]
      ==
    ==
  ::
  ::  Take a bite
  ::
  ++  take
    |=  =bite
    ^-  [@ @ud]
    =/  =step
      ?@  bite  (bex bite)
      (mul step.bite (bex bloq.bite))
    [(cut 0 [pos step] batch) (add pos step)]
  ::
  ++  take-mang
    ^-  [(unit (unit mang)) @ud]
    =^  typ  pos  (take 2)
    ?+    typ  [~ pos]
        %0  [[~ ~] pos]
        %1
      =^  sont  pos  take-sont
      ?~  sont  [~ pos]
      [``[%sont u.sont] pos]
        %2
      =^  pass  pos  (take 0 256)
      [``[%pass pass] pos]
    ==
  ::
  ++  take-atom
    ^-  [@ @ud]
    =/  m  (rub pos batch)
    [q.m (add pos p.m)]
  ::  Encode ship and sont
  ::
  ++  take-sont
    ^-  [(unit sont) @ud]
    =^  pad=@  pos  (take 0)
    ?.  =(pad 0)  ~^pos
    =^  txh    pos  (take 0 256)
    =^  idx    pos   take-atom
    =^  off    pos   take-atom
    [`[txh idx off] pos]
  ::  Encode escape-related txs
  ::
  ++  take-ship
    ^-  [ship @ud]
    =^  pad=@       pos  (take 0)
    =^  other=ship  pos  (take 0 128)
    [other pos]
  ::
  ++  take-sig
    ^-  [(unit @) @ud]
    =^  typ  pos  (take 1)
    ?:  =(typ 0)  [~ pos]
    =^  sig  pos  (take 0 512)
    [`sig pos]
  --
::
++  en
  |%
  ++  unv-to-script
    |=  dat=@
    ^-  script
    =/  len  (met 3 dat)
    :*  [%op-push %num %1 %0]
        %op-if
        op-push+~+3+'urb'
        (push-data len dat) 
     ==
  ::
  ++  mails-to-script
    |=  mails=(list mail)
    ^-  script
    (zing (turn mails mail-to-script))
  ::
  ++  mail-to-script
    |=  =mail
    ^-  script
    (draft-to-script (mail-to-draft mail))
  ::
  ++  mail-to-draft
    |=  =mail
    |^  ^-  draft
    %-  ~(gas by *draft)
    %-  zing
    ^-  (list (list (pair @ud octs)))
    :~  ?~(mime.mail ~ [1 p.mime.mail p.+.mime.mail]^~)
        ?~(code.mail ~ [9 p.code.mail p.+.code.mail]^~)
        ?~(pntr.mail ~ [2 p.pntr.mail p.+.pntr.mail]^~)
        ?~(rent.mail ~ [3 (insc rent.mail)]^~)
        ?~(gate.mail ~ [11 (insc gate.mail)]^~)
        ?~(meta.mail ~ [5 meta.mail]^~)
        ?~(prot.mail ~ [7 prot.mail]^~)
        ?~(data.mail ~ [0 data.mail]^~)
    ==
    :::~  ?~(mime.mail ~ [1 p.mime.mail (rev 3 p.mime.mail p.+.mime.mail)]^~)
    ::    ?~(code.mail ~ [9 p.code.mail (rev 3 p.code.mail p.+.code.mail)]^~)
    ::    ?~(pntr.mail ~ [2 p.pntr.mail (rev 3 p.pntr.mail p.+.pntr.mail)]^~)
    ::    ?~(rent.mail ~ [3 (insc rent.mail)]^~)
    ::    ?~(gate.mail ~ [11 (insc gate.mail)]^~)
    ::    ?~(meta.mail ~ [5 p.meta.mail (rev 3 p.meta.mail q.meta.mail)]^~)
    ::    ?~(prot.mail ~ [7 p.prot.mail (rev 3 p.prot.mail q.prot.mail)]^~)
    ::    ?~(data.mail ~ [0 p.data.mail (rev 3 p.data.mail q.data.mail)]^~)
    ::==
    ::
    ++  insc
      |=  [p=@ud oid=(each ^insc @)]
      ^-  octs
      :-  p
      ::?.  ?=(%& -.oid)  (rev 3 p p.oid)
      ::(con (lsh [3 (sub p 32)] (rev 3 32 txh.p.oid)) (rev 3 (sub p 32) idx.p.oid))
      ?.  ?=(%& -.oid)  p.oid
      (con (lsh [3 (sub p 32)] txh.p.oid) idx.p.oid)
    --
  ::
  ++  rip-octs
    |=  octs
    ^-  (list octs)
    =/  met-q  (met 3 q)
    ?>  (lte met-q p) :: todo: prob unnecessary
    =/  ripped=(list octs)
      (turn (rip [3 520] q) |=(@ [(met 3 +<) +<]))
    ?:  =(p met-q)  ripped
    =/  nzeros  (dvr (sub p met-q) 520)
    =-  (weld - ripped)
    ^-  (list octs)
    =/  zero-520s=(list octs)  ?:(=(p.nzeros 0) ~ (turn (gulf 1 p.nzeros) |=(* [520 0])))
    ?:  =(0 q.nzeros)  zero-520s
    [q.nzeros 0]^zero-520s
  ::
  ++  push-data
    |=  data=octs
    =/  ripped  (rip-octs data)
    ?:  =(ripped ~)  !! ::~|(%en-draft-push-no-content !!)
    |-  ^-  script
    ?~  ripped  [%op-endif ~]
    :-  (push-one-data i.ripped)
    $(ripped t.ripped)
  ::
  ++  push-one-data
    |=  octs
    ^-  op:script
    ?>  !=(0 p)
    ?>  (lte p 520)
    ?:  (lte p 0x4b)  op-push+~+p^q
    ?:  (lte p 0xff)  op-push+1+p^q
    op-push+2+p^q
  ::
  ++  draft-to-script
    |=  =draft
    ^-  script
    =/  data  (~(get by draft) 0)
    =/  meta  (~(get by draft) 5)
    =.  draft  (~(del by (~(del by draft) 0)) 5)
    =/  tags  (sort ~(tap by draft) |=([[a=@ *] [b=@ *]] (lth a b)))
    =-  [op-push+num+1+0 %op-if op-push+~+3+'ord' -]
    |^  ^-  script
    ?~  tags  push-meta
    :+  op-push+num+1+p.i.tags
      (push-one-data q.i.tags)
    $(tags t.tags)
    ::
    ++  push-meta
      ^-  script
      ?~  meta  push-data
      =/  ripped  (rip-octs u.meta)
      |-  ^-  script
      ?~  ripped  push-data
      :+  op-push+num+1+5
        (push-one-data i.ripped)
      $(ripped t.ripped)
    ::
    ++  push-data
      ^-  script
      ?~  data  [%op-endif ~]
      =-  [op-push+num+1+0 -]
      (^push-data u.data)
    --
  --
::
++  de
  |%
  ++  mails
    |=  =script
    (turn (drafts script) draft-to-mail)
  ::
  ++  draft-to-mail
    |=  =draft
    ^-  mail
    :*  (biff (~(get by draft) 1) ascii)  :: tag 1 mimetype 
        (biff (~(get by draft) 9) ascii)  :: tag 9 content encoding
        (biff (~(get by draft) 2) pntr)   :: tag 2 pointer (sat index in outputs of reveal tx)
        (biff (~(get by draft) 3) insc)   :: tag 3 parent
        (biff (~(get by draft) 11) insc)  :: tag 11 delegate
        (fall (~(get by draft) 5) ~)      :: tag 5 metadata (multple pushes)
        (fall (~(get by draft) 7) ~)      :: tag 7 meta protocol
        (fall (~(get by draft) 0) ~)      :: tag 0 content (all pushed data after push of 0 tag)
    ==
  ::
  :: gates don't return a unit but biffing them above compiles. sarpen: "I have committed more wet gate atrocities than anyone." ok
  ++  ascii
    |=  octs
    ^-  [p=@ud (each @t @)]
    ?.  (levy (rip 3 q) |=(@ (lth +< 128)))  [p |+q]
    [p &+q]
  ::
  ++  pntr
    |=  octs
    ^-  [p=@ud (each @ud @)]
    ?.  &((lte p 5) (lte q 0xffff.ffff))  [p |+q]
    ::[p &+(rev 3 p q)]
    [p &+q]
  ::
  ++  insc
    |=  octs
    ^-  [p=@ud (each ^insc @)]
    ?.  (lth p 33)  [p |+q]
    ::=/  tx  (rev 3 32 (cut 3 [(sub p 32) 32] q))
    =/  tx  (cut 3 [(sub p 32) 32] q)
    =/  ilen  (sub p 32)
    ::[p &+[tx (rev 3 ilen (cut 3 [0 ilen] q))]]
    [p &+[tx (cut 3 [0 ilen] q)]]
  ::
  ++  drafts
    |=  =script
    ^-  (list draft)
    ?~  script  ~
    ?.  ?=([[%op-push * * %0] %op-if [%op-push * * %'ord'] *] script)  $(script t.script)
    =>  .(script t.t.t.script)
    |^  ^-  (list draft)
    =^  tags  script  fetch-tags
    ?~  tags  ^$  [u.tags ^$]
    ::
    ++  fetch-tags
      ^-  [(unit draft) ^script]
      ?>  ?=(^ script)
      =|  tags=(map @ud (list octs))
      |-  ^+  fetch-tags
      ?:  ?=(%op-endif i.script)
        :_  t.script
        `(~(run by tags) |=((list octs) (roll +< |=([a=octs b=octs] (add p.a p.b)^(cat 3 q.a q.b)))))
      ?>  ?=(^ t.script)
      ?.  ?=([[%op-push *] [%op-push *] * *] script)
        =>  .(script `(lest op:^script)`t.script)
        |-  ^+  fetch-tags
        ?:  ?=(%op-endif -.script)  ~^t.script
        ?>  ?=(^ t.script)
        $(script t.script)
      =*  tag  q.octs.i.script
      =*  dat  octs.i.t.script
      ?.  =(tag 0)
        %_  $
          script  t.t.script
          tags
            ?~  d=(~(get by tags) tag)  (~(put by tags) tag dat^~)
            ?.  =(tag 5)  tags
            (~(put by tags) tag dat^u.d)
        ==
      =|  dats=(list octs)
      =>  .(script `(lest op:^script)`t.script)
      |-  ^+  fetch-tags
      ?.  ?=(%op-endif i.script)
        ?>  ?=([[%op-push *] ^] script)
        $(dats octs.i.script^dats, script t.script) 
      :_  t.script
      :-  ~
      %-  ~(run by (~(put by tags) 0 dats))
      |=((list octs) (roll +< |=([a=octs b=octs] (add p.a p.b)^(cat 3 q.a q.b))))
    --
  ::
  ++  unv
    |=  =script
    ^-  (list @)
    ?~  script  ~
    ?.  ?=([[%op-push * * %0] %op-if [%op-push * * %'urb'] *] script)
      $(script t.script)
    =>  .(script t.t.t.script)
    |^  ^-  (list @)
    =^  unv  script  fetch-unv
    ?~  unv  ~  [p:(fax:plot bloq=3 u.unv) ^$]
    ::
    ++  fetch-unv
      ^-  [(unit (list plat:plot)) ^script]
      ?>  ?=(^ script)
      |-  ^-  [(unit (list plat:plot)) ^script]
      ?:  ?=(%op-endif i.script)  [~ ~]^~
      ?.  ?=([[%op-push *] ^] script)  ~^~
      =/  rest  $(script t.script)
      ?~  -.rest  ~^~
      [~ octs.i.script u.-.rest]^+.rest
    --
  --
::
++  shan
  |=  a=*
  ?@  a  (shax:sha (cat 3 %atom a)) 
  (shax:sha (rap 3 %cell $(a -.a) $(a +.a) ~))
::
++  si
  |%
  ++  get
    |=  [a=sont-map =txh =pos =off]
    ^-  (unit [com=(unit @p) ins=(set insc)])
    ?~  b=(~(get by a) txh)  ~
    (~(get bi u.b) pos off)
  ::
  ++  put-none
    |=  [a=sont-map =txh =pos =off]
    ^-  sont-map
    !!
    ::%+  ~(put by a)  txh
    ::=/  b  (~(gut by a) txh ~)
    ::=/  c=[com=(unit @p) ins=(set insc)]  (~(gut bi b) pos off [~ ~])
  ::
  ++  put-all
    |=  [a=sont-map =txh =pos =off com=(unit @p) ins=(set insc)]
    ^-  sont-map
    %+  ~(put by a)  txh
    =/  b  (~(gut by a) txh ~)
    =/  c=[com=(unit @p) ins=(set insc)]  (~(gut bi b) pos off [~ ~])
    (~(put bi b) pos off c(com com, ins (~(uni in ins.c) ins)))
  ::
  ++  put-ins
    |=  [a=sont-map =txh =pos =off ins=(set insc)]
    ^-  sont-map
    %+  ~(put by a)  txh
    =/  b  (~(gut by a) txh ~)
    =/  c=[com=(unit @p) ins=(set insc)]  (~(gut bi b) pos off [~ ~])
    (~(put bi b) pos off c(ins (~(uni in ins.c) ins)))
  ::
  ++  put-com
    |=  [a=sont-map =txh =pos =off com=@p]
    ^-  sont-map
    %+  ~(put by a)  txh
    =/  b  (~(gut by a) txh ~)
    =/  c=[com=(unit @p) ins=(set insc)]  (~(gut bi b) pos off [~ ~])
    (~(put bi b) pos off c(com `com))
  ::
  ++  del
    |=  [a=sont-map =txh =pos =off]
    ^-  sont-map
    ?~  b=(~(get by a) txh)  a
    ?~  c=(~(del bi u.b) pos off)  (~(del by a) txh)
    (~(put by a) txh c)
  --
::++  ming
::  |%
::  ++  add-ship
::    |=  [mangs=mang-map =pass who=@p]
::    ^+  mangs
::    %+  ~(put by mangs)  pass
::    =+((~(got by mangs) pass) [txh (~(put in whos) who)])
::  ::
::  ++  del-ship
::    |=  [mangs=mang-map =pass who=@p]
::    ^+  mangs
::    =/  m  =+((~(got by mangs) pass) [txh (~(del in whos) who)])
::    ?~  whos.m  (~(del by mangs) pass)
::    (~(put by mangs) pass m)
::  ::
::  ++  init
::    |=  [old=mang-map new=mang-map txh=pass who=@p]
::    ^+  mangs
::    %+  ~(put by mangs)  pass
::    =+((~(got by mangs) pass) [txh (~(put in whos) who)])
::  --
::::
::+$  mang-map  (map pass [=txh whos=(set @p)])
+$  sont-map  (map txh (mip pos off [com=(unit @p) ins=(set insc)]))
+$  insc-ids  (map insc [=sont =mail])
+$  unv-ids   (map @p point)
+$  state     $:  =sont-map
                  =insc-ids
                  =unv-ids
              ==
::
++  pointer-to-sont
  =|  pos=@ud
  |=  [pntr=@ud outs=(list output:tx)]
  ^-  $@(~ [pos=@ud off=@ud])
  ?~  outs  ~
  ?:  (lth pntr value.i.outs)  [pos pntr]
  $(pos +(pos), pntr (sub pntr value.i.outs))
::
++  update-ins
  |=  [state oids=(set insc) =sont]
  =*  state  +<-
  ?:  =(~ oids)  state
  %-  ~(rep in oids)
  |:  [*=insc state]
  =/  dat  (~(got by insc-ids) insc)
  state(insc-ids (~(put by insc-ids) insc dat(sont sont)))
::
++  update-com
  |=  [state com=@p =sont]
  =*  state  +<-
  =/  point  (~(got by unv-ids) com)
  state(unv-ids (~(put by unv-ids) com point(sont.own sont)))
::
++  update-ids
  |=  [state [com=(unit @p) oids=(set insc)] =sont]
  =*  state  +<-
  =.  state  (update-ins state oids sont)
  ?~  com  state
  (update-com state u.com sont)
::
+$  effect
  $%  diff
      [%xfer from=sont to=sont]
      [%insc =insc sont=$@(~ sont) =mail]
  ==
::
++  conol
  |=  a=pass
  ^-  @p
  =+  [mag=(end 3 a) bod=(rsh 3 a)]
  =+  [cry=(cut 8 [1 1] bod) sgn=(end 8 bod)]
  ?:  =('b' mag)  (shaf:sha %bfig a)
  ?>  =('c' mag)
  =/  dat  (rsh [8 2] bod)
  =/  mit  (shax:sha (can 3 [32 sgn] [(met 3 dat) dat] ~))
  =/  tgn  (scap:ed sgn mit)
  (shaf:sha %cfig tgn)
::
++  ord-core
  =|  state
  =*  state  -
  |_  $:  ::
          :: cards=(list card:agent:gall)
          fx=(list effect)
          cb-tx=[=txh os=(list output:tx) val=@ud]
          ::n-map=_n-map
      ==
  +*  cor  .
  ++  handle-block
    |=  block
    ^+  cor
    ?>  ?=(^ txs)
    =>  .(txs t.txs, cb-tx cb-tx(txh txh.i.txs, os os.tx.i.txs, val reward))
    |-  ^+  cor
    ?~  txs  cor
    =.  cor  (handle-tx i.txs)
    $(txs t.txs)
  ::
  ++  handle-tx
    =|  val=@ud
    =|  idx=@ud
    |=  [=txh tx=dataw:tx]
    ^+  cor
    =/  sum-out  (roll os.tx |=([[* a=@] b=@] (add a b)))
    =/  sum-in  (roll is.tx |=([a=inputw:^tx b=@] (add value.a b)))
    =/  is  is.tx
    ?~  is  cor
    |^  ^+  cor
    =.  cor  sont-track-input
    =.  cor  check-for-insc
    next-input
    ::
    ++  check-for-unv
      :::: this arm is not called yet
      ^+  cor
      =/  raw-script=(unit octs)
        =/  rwit  (flop witness.i.is)
        ?.  ?=([* ^] rwit)  ~
        ?.  =+(i.rwit &(!=(0 wid) =(0x50 (cut 3 [(dec wid) 1] dat))))
          `i.t.rwit
        ?~(t.t.rwit ~ `i.t.rwit)
      ?~  raw-script  cor
      ?~  dscr=(de:script u.raw-script)  cor
      ~|  [=+(u.raw-script [p `@ux`q]) =+((en:bscr u.dscr) [p `@ux`q])]
      ?>  =(u.raw-script (en:bscr u.dscr))
      =/  unvs=(unit (list @))  (some (unv:de u.dscr))
      ?~  unvs  cor
      =/  sots=(list raw-sotx)  (zing (turn u.unvs parse-roll))
      |-  ^+  cor
      ?~  sots  cor
      =*  raw  raw.i.sots
      =*  sot  sot.i.sots
      =*  our  ship.sot
      =*  sig   sig.sot
      =-  $.+(cor -, sots t.sots)
      =/  sots=(list single:skim-sotx)
        ?:(?=(%batch +<.sot) bat.sot ~[+.sot])
      |^  ^+  cor
      =^  point  cor  get-owned-point
      |-  ^+  cor
      ?~  sots  cor
      =*  sot  i.sots
      ?:  ?=(%spawn -.sot)
        :: XX: more ordering constraints?
        ?^  point  cor
        ?.  (spending-sont sont.sot)  $(sots t.sots)
        ?:  (~(has by unv-ids) our)  $(sots t.sots)
        ?.  =(our (conol pass.sot))  $(sots t.sots)
        =/  sponsor  `@p`(end 4 our)
        =/  =^point
          :*  own=[sont.sot ~]
              rift=0
              life=1
              pass=pass.sot
              sponsor=[& sponsor]
              escape=~
              fief=~
          ==
        =*  sont  sont.sot
        %_    $
            point    `point
            sots     t.sots
            sont-map  (put-com:si sont-map txh.sont pos.sont off.sont our)
            unv-ids   (~(put by unv-ids) our point)
            fx
          :*  [%point our %owner sont]
              [%point our %sponsor `sponsor]
              [%point our %keys 1 pass.sot]
              fx
          ==
        ==
      ?~  point  cor
      ?-    -.sot
          %set-mang
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) our u.point)
            fx
          :_  fx
          [%point our %mang mang.sot]
        ==
      ::
          %fief
        =.  fief.net.u.point  fief.sot
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) our u.point)
            fx
          :_  fx
          [%point our %fief fief.sot]
        ==
      ::
          %escape
        =.  escape.net.u.point  `parent.sot
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) our u.point)
            fx
          :_  fx
          [%point our %escape `parent.sot]
        ==
      ::
          %cancel-escape
        ?.  =([~ parent.sot] escape.net.u.point)  $(sots t.sots)
        =.  escape.net.u.point  ~
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) our u.point)
            fx
          :_  fx
          [%point our %escape ~]
        ==
      ::
          %detach
        ?~  child=(~(get by unv-ids) ship.sot)  $(sots t.sots)
        ?.  =([& our] sponsor.net.u.child)  $(sots t.sots)
        =.  sponsor.net.u.child  |/our
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) ship.sot u.child)
            fx
          :_  fx
          [%point ship.sot %sponsor ~]
        ==
      ::
          %adopt
        ?~  child=(~(get by unv-ids) ship.sot)  $(sots t.sots)
        ?.  =([~ our] escape.net.u.child)  $(sots t.sots)
        =.  escape.net.u.child  ~
        =.  sponsor.net.u.child  &/our
        =.  sponsor.net.u.child  &/our
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) ship.sot u.child)
            fx
          :_  fx
          [%point ship.sot %sponsor `our]
        ==
      ::
          %reject
        ?~  child=(~(get by unv-ids) ship.sot)  $(sots t.sots)
        ?.  =([~ our] escape.net.u.child)  $(sots t.sots)
        =.  escape.net.u.child  ~
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) ship.sot u.child)
            fx
          :_  fx
          [%point ship.sot %escape ~]
        ==
      ::
          %keys
        =.  net.u.point
          net.u.point(pass pass.sot, life +(life.net.u.point))
        =?  rift.net.u.point  breach.sot  +(rift.net.u.point)
        %_    $
            sots     t.sots
            unv-ids   (~(put by unv-ids) our u.point)
            fx
          :*  [%point our %keys life.net.u.point pass.sot]
              ?.  breach.sot  fx
              [%point our %rift rift.net.u.point]^fx
          ==
        ==
      ::
      ==
      ::
      ++  get-owned-point
        ^-  [(unit point) _cor]
        ?~  point=(~(get by unv-ids) our)  ~^cor
        ?:  &(?=(~ sig) (spending-sont sont.own.u.point))
          point^cor
        ?~  sig  [~ cor]
        ?.  ?=([~ %pass *] mang.own.u.point)  [~ cor]
        ?:  =(txh (cut 8 [1 1] pass.u.mang.own.u.point))  [~ cor]
        =/  pub  (end 8 pass.u.mang.own.u.point)
        =/  tw  (scap:ed pub (shax:sha pass.u.mang.own.u.point))
        ?.  (veri-octs:ed u.sig raw tw)  [~ cor]
        =.  pass.u.mang.own.u.point  (can 8 [1 pub] [1 txh] ~)
        [point cor(unv-ids (~(put by unv-ids) our u.point))]
      ::
      ++  spending-sont
        |=  =sont
        =|  val=@ud
        |-  ^-  ?
        ?~  is.tx  |
        ?.  =([txh pos]:sont [dat.txid pos]:i.is)
          $(is.tx t.is.tx, val (add val value.i.is)) 
        !(lth off.sont value.i.is)
      --
    ::
    ++  check-for-insc
      ^+  cor
      =/  raw-script=(unit octs)
        =/  rwit  (flop witness.i.is)
        ?.  ?=([* ^] rwit)  ~
        ?.  =+(,.-.rwit &(!=(0 wid) =(0x50 (rsh [3 (dec wid)] dat))))  `i.t.rwit
        ?~(t.t.rwit ~ `i.t.rwit)
      ?~  raw-script  cor
      ::=/  scr  (mole |.((de:script u.raw-script)))
      :: XX: make crash-proof
      ::=/  scr  (de:script u.raw-script)
      ?~  scr=(de:script u.raw-script)  cor
      ?>  =(u.raw-script (en:bscr u.scr))
      =/  mails=(list mail)  (mails:de u.scr)
      |-  ^+  cor
      ?~  mails  cor
      =/  pntr=@ud  ?:(?=([* %& *] pntr.i.mails) p.+.pntr.i.mails 0)
      =/  =insc  txh^idx
      =/  nsont  (pntr-to-sont pntr)
      ?~  nsont
        :: the ordinals docs suggests that if the pointer index is
        :: invalid, then it is treated normally i.e. on 0 index
        %_  $
          idx     +(idx)
          mails   t.mails
          insc-ids   (~(put by insc-ids) insc [[txh 0 0] i.mails])
          fx      [%insc insc ~ i.mails]^fx
        ==
      %_  $
        idx     +(idx)
        mails   t.mails
        sont-map  (put-ins:si sont-map txh.nsont pos.nsont off.nsont insc^~^~)
        insc-ids   (~(put by insc-ids) insc [nsont i.mails])
        fx      [%insc insc nsont i.mails]^fx
       ==
     ::
    ++  pntr-to-sont
      |=  pntr=@ud
      ^-  $@(~ sont)
      ?.  (lth pntr sum-out)
        =/  sont  (pointer-to-sont (add val.cb-tx (sub pntr sum-out)) os.cb-tx)
        ?:  |(=(~ sont) (lte sum-in pntr))  ~
        ?>  ?=(^ sont)
        [txh.cb-tx pos.sont off.sont]
      ?~  sont=(pointer-to-sont pntr os.tx)  !!
      [dat.txid.i.is pos.sont off.sont]
      ::=/  =txh  dat.txid.i.is
      ::  check for pointer validity here
      ::?.  &(?=([* %& *] pntr) (lth p.+.pntr sum-outs))
      ::  ?~  tracked=(off-to-sont idx)  ~
      ::  [txh tracked]
      ::?~  tagged=(pointer-to-sont p.+.pntr os.tx)  !!
      ::[txh tagged]
    ::
    ::++  inscription-to-sont
    ::  |=  mail
    ::  ^-  $@(~ sont)
    ::  =/  =txhash  dat.txid.i.is
    ::  ::  check for pointer validity here
    ::  ?.  &(?=([* %& *] pntr) (lth p.+.pntr sum-outs))
    ::    ?~  tracked=(off-to-sont idx)  ~
    ::    [txhash tracked]
    ::  ?~  tagged=(pointer-to-sont p.+.pntr os.tx)  !!
    ::  [txhash tagged]
    ::
    ++  off-to-sont
      |=  off=@ud
      ^-  $@(~ sont)
      ::  todo: double check this shorter code does what's intended
      (pntr-to-sont (add val off))
    ::  ?.  (lth (add val off) sum-out)
    ::    ?~  sont=(pointer-to-sont (add val.cb-tx (sub (add val off) sum-out)) os.cb-tx)
    ::      ~
    ::    [txh.cb-tx pos.sont off.sont]
    ::  ?~  sont=(pointer-to-sont (add val off) os.tx)  !!
    ::  [txh pos.sont off.sont]
    ::
    ++  sont-track-input
      ^+  cor
      ?~  itxo=(~(get bi sont-map) dat.txid.i.is pos.i.is)  cor
      =.  sont-map  (~(del bi sont-map) dat.txid.i.is pos.i.is)
      =/  isonts  ~(tap by u.itxo)
      |-  ^+  cor
      ?~  isonts  cor
      =/  osont=sont  [dat.txid.i.is pos.i.is p.i.isonts] 
      ?~  nsont=(off-to-sont p.i.isonts)
        =.  state  (update-ids state q.i.isonts [0x0 0 0])
        %_  $
          isonts  t.isonts
          fx     [%xfer osont [0x0 0 0]]^fx
        ==
      =.  state  (update-ids state q.i.isonts nsont)
      %_  $
        isonts   t.isonts
        sont-map  (put-all:si sont-map txh.nsont pos.nsont off.nsont q.i.isonts)
        fx      [%xfer osont nsont]^fx
      ==
    ::
    ++  next-input
      ^+  cor
      =<  ?~(t.is cor $(is t.is)) 
      ?.  (lth sum-out (add val value.i.is))  .(val (add val value.i.is))
      .(val.cb-tx (add val.cb-tx (sub (add val value.i.is) sum-out)), val sum-out)
    --
  --
--
