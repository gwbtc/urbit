|%
  ++  cryc  ::!:
    |_  $%  ::$:  suite=%$
            ::    pub=[cry=@ sgn=@ ~]
            ::    sek=$@(~ [~ cry=@ sgn=@])
            ::==
            $:  suite=%b
                pub=[cry=@ sgn=@ ~]
                sek=$@(~ [sed=@ cry=@ sgn=@])
            ==
            $:  suite=%c
                pub=[cry=@ sgn=@ tw=[ugn=@ dat=@]]
                sek=$@(~ [sed=@ cry=@ sgn=@])
            ==
        ==
    ::                                                  ::  ++ex:cryc:crypto
    ++  ex                                              ::  extract
      |%
      ::                                                ::  ++fig:ex:crub:crypto
      ++  fig                                           ::  fingerprint
        ^-  @uvH
        ?:  ?=(%b suite)  (shaf %bfig pub)
        (shaf %cfig sgn.^pub)
      ::                                                ::  ++pac:ex:crub:crypto
      ++  pac                                           ::  private fingerprint
        ^-  @uvG
        ::?<  ?=(%$ suite)
        ?~  sek  ~|  %pubkey-only  !!
        ?:  ?=(%b suite)  (end 6 (shaf %bcod sed.sek))
        (end 6 (shaf %ccod (can 3 [32 sed.sek] [(met 3 dat.tw.^pub) dat.tw.^pub] ~)))
      ::                                                ::  ++pub:ex:crub:crypto
      ++  pub                                           ::  public key
        ^-  pass
        ::?:  ?=(%$ suite)  (can 3 1^%$ 32^sgn.^pub 32^cry.^pub ~)
        ?:  ?=(%b suite)  (can 3 1^'b' 32^sgn.^pub 32^cry.^pub ~)
        %+  can  3
        :~  [1 %'c']
            [32 ugn.tw.^pub]
            [32 cry.^pub]
            [(met 3 dat.tw.^pub) dat.tw.^pub]
        ==
      ::                                                ::  ++sec:ex:crub:crypto
      ++  sec                                           ::  private key
        ^-  ring
        ::?<  ?=(%$ suite)
        ?~  sek  ~|  %pubkey-only  !!
        ?:  ?=(%b suite)  (can 3 1^'B' 64^sed.sek ~)
        %+  can  3
        :~  [1 %'C']
            [64 sed.sek]
            [(met 3 dat.tw.^pub) dat.tw.^pub]
        ==
      ::
      ++  ven
        ^-  private-keys
        ?~  sek  ~|  %pubkey-only  !!
        [cry.sek sgn.sek]
      ::
      ++  ded
        ^-  public-keys
        [cry.^pub sgn.^pub]
      ::
      ++  saf
        ^-  keypairs
        [ded ven]
      --  ::ex
    ::                                                  ::  ++nu:crub:crypto
    ++  nu                                              ::
      |%
      ::                                                ::  ++pit:nu:crub:crypto
      ++  pit                                           ::  create keypair
        |=  [w=@ seed=@ $%([suite=%b ~] [suite=%c dat=@])]
        ^+  ..nu
        =+  wid=(add (div w 8) ?:(=((mod w 8) 0) 0 1))
        =+  bits=(shal wid seed)
        ~&  bits=`@ux`bits
        %-  nol  ^-  ring
        ?:  ?=(%b suite)  (can 3 1^'B' 1^bits ~)
        (can 3 1^'C' 64^bits (met 3 dat)^dat ~)
      ::                                                ::  ++nol:nu:crub:crypto
      ++  nol                                           ::  activate secret
        |=  a=ring
        ^+  ..nu
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~|  %not-crub-seckey
        ~&  bod=`@ux`bod
        =+  [c=(luck:ed (cut 8 [1 1] bod)) s=(luck:ed (end 8 bod))]
        ~&  nol=[c=[`@ux`pub `@ux`sek]:c s=[`@ux`pub `@ux`sek]:s]
        ?:  =('B' mag)
          ..nu(+<- %b, pub [cry=pub.c sgn=pub.s ~], sek [sed=bod cry=sek.c sgn=sek.s])
        ?>  =('C' mag)
        =/  dat  (rsh [8 2] bod)
        =/  mit  (shax (can 3 [32 pub.s] [(met 3 dat) dat] ~))
        =/  t  (scad:ed pub.s sek.s mit)
        %=  ..nu
          +<-   %c
          pub   [cry=pub.c sgn=pub.t tw=[ugn=pub.s dat=dat]]
          sek   [sed=(cut 8 [0 2] bod) cry=sek.c sgn=sek.t]
        ==
      ::                                                ::  ++com:nu:crub:crypto
      ++  com                                           ::  activate public
        |=  a=pass
        ^+  ..nu
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~|  %not-crub-pubkey
        =+  [cry=(cut 8 [1 1] bod) sgn=(end 8 bod)]
        ?:  =('b' mag)
          ..nu(+<- %b, pub [cry=cry sgn=sgn ~], sek ~)
        ?>  =('c' mag)
        =/  dat  (rsh [8 2] bod)
        =/  mit  (shax (can 3 [32 sgn] [(met 3 dat) dat] ~))
        =/  tgn  (scap:ed sgn mit)
        ..nu(+<- %c, pub [cry=cry sgn=tgn tw=[sgn dat]], sek ~)
    ::
      ::++  ven
      ::  |=  private-keys
      ::  ^+  ..nu
      ::  %=    ..nu
      ::      +<-  %$
      ::      sek  [~ cry sgn]
      ::      pub
      ::    :+  cry=(scalarmult-base:ed:crypto (end 8 cry))
      ::    sgn=(scalarmult-base:ed:crypto (end 8 sgn))  ~
      ::  ==
      ::::
      ::++  ded
      ::  |=  public-keys
      ::  ^+  ..nu
      ::  ..nu(+<- %$, pub [cry sgn ~], sek ~)
      ::::
      ::++  saf
      ::  |=  keypairs
      ::  ^+  ..nu
      ::  ..nu(+<- %$, pub [cry sgn ~]:pub, sek [~ cry sgn]:sek)
      --  ::nu
    ++  cyf
      |%
      ::                                                  ::  ++de:crub:crypto
      ++  de                                              ::  decrypt
        |=  [key=@J txt=@]
        ^-  (unit @)
        =+  ;;([iv=@ len=@ cph=@] (cue txt))
        %^    ~(de sivc:aes (shaz key) ~)
            iv
          len
        cph
      ::                                                  ::  ++dy:crub:crypto
      ++  dy                                              ::  need decrypt
        |=  [key=@J cph=@]
        (need (de key cph))
      ::                                                  ::  ++en:crub:crypto
      ++  en                                              ::  encrypt
        |=  [key=@J msg=@]
        ^-  @
        (jam (~(en sivc:aes (shaz key) ~) msg))
      --
    --  ::crub

++  crub
    =,  crypto
    =|  [pub=[cry=@ sgn=@] sek=(unit [cry=@ sgn=@])]
    |%
    ::                                                  ::  ++as:crub:crypto
    ++  as                                              ::
      |%
      ::                                                ::  ++sign:as:crub:
      ++  sign                                          ::
        |=  msg=@
        ^-  @ux
        (jam [(sigh msg) msg])
      ::                                                ::  ++sigh:as:crub:
      ++  sigh                                          ::
        |=  msg=@
        ^-  @ux
        ?~  sek  ~|  %pubkey-only  !!
        (sign:ed msg sgn.u.sek)
      ::                                                ::  ++sure:as:crub:
      ++  sure                                          ::
        |=  txt=@
        ^-  (unit @ux)
        =+  ;;([sig=@ msg=@] (cue txt))
        ?.  (safe sig msg)  ~
        (some msg)
      ::                                                ::  ++safe:as:crub:
      ++  safe
        |=  [sig=@ msg=@]
        ^-  ?
        (veri:ed sig msg sgn.pub)
      ::                                                ::  ++seal:as:crub:
      ++  seal                                          ::
        |=  [bpk=pass msg=@]
        ^-  @ux
        ?~  sek  ~|  %pubkey-only  !!
        ?>  =('b' (end 3 bpk))
        =+  pk=(rsh 8 (rsh 3 bpk))
        =+  shar=(shax (shar:ed pk cry.u.sek))
        =+  smsg=(sign msg)
        (jam (~(en siva:aes shar ~) smsg))
      ::                                                ::  ++tear:as:crub:
      ++  tear                                          ::
        |=  [bpk=pass txt=@]
        ^-  (unit @ux)
        ?~  sek  ~|  %pubkey-only  !!
        ?>  =('b' (end 3 bpk))
        =+  pk=(rsh 8 (rsh 3 bpk))
        =+  shar=(shax (shar:ed pk cry.u.sek))
        =+  ;;([iv=@ len=@ cph=@] (cue txt))
        =+  try=(~(de siva:aes shar ~) iv len cph)
        ?~  try  ~
        (sure:as:(com:nu:crub bpk) u.try)
      --  ::as
    ::                                                  ::  ++de:crub:crypto
    ++  de                                              ::  decrypt
      |=  [key=@J txt=@]
      ^-  (unit @ux)
      =+  ;;([iv=@ len=@ cph=@] (cue txt))
      %^    ~(de sivc:aes (shaz key) ~)
          iv
        len
      cph
    ::                                                  ::  ++dy:crub:crypto
    ++  dy                                              ::  need decrypt
      |=  [key=@J cph=@]
      (need (de key cph))
    ::                                                  ::  ++en:crub:crypto
    ++  en                                              ::  encrypt
      |=  [key=@J msg=@]
      ^-  @ux
      (jam (~(en sivc:aes (shaz key) ~) msg))
    ::                                                  ::  ++ex:crub:crypto
    ++  ex                                              ::  extract
      |%
      ::                                                ::  ++fig:ex:crub:crypto
      ++  fig                                           ::  fingerprint
        ^-  @uvH
        (shaf %bfig pub)
      ::                                                ::  ++pac:ex:crub:crypto
      ++  pac                                           ::  private fingerprint
        ^-  @uvG
        ?~  sek  ~|  %pubkey-only  !!
        (end 6 (shaf %bcod sec))
      ::                                                ::  ++pub:ex:crub:crypto
      ++  pub                                           ::  public key
        ^-  pass
        (cat 3 'b' (cat 8 sgn.^pub cry.^pub))
      ::                                                ::  ++sec:ex:crub:crypto
      ++  sec                                           ::  private key
        ^-  ring
        ?~  sek  ~|  %pubkey-only  !!
        (cat 3 'B' (cat 8 sgn.u.sek cry.u.sek))
      --  ::ex
    ::                                                  ::  ++nu:crub:crypto
    ++  nu                                              ::
      |%
      ::                                                ::  ++pit:nu:crub:crypto
      ++  pit                                           ::  create keypair
        |=  [w=@ seed=@]
        =+  wid=(add (div w 8) ?:(=((mod w 8) 0) 0 1))
        =+  bits=(shal wid seed)
        ~&  bits=`@ux`bits
        =+  [c=(rsh 8 bits) s=(end 8 bits)]
        ..nu(pub [cry=(puck:ed c) sgn=(puck:ed s)], sek `[cry=c sgn=s])
      ::                                                ::  ++nol:nu:crub:crypto
      ++  nol                                           ::  activate secret
        |=  a=ring
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~&  bod=`@ux`bod
        ~|  %not-crub-seckey  ?>  =('B' mag)
        =+  [c=(rsh 8 bod) s=(end 8 bod)]
        ~&  nol=[sek=[`@ux`c `@ux`s] pub=[cry=`@ux`(puck:ed c) sgn=`@ux`(puck:ed c)]]
        ..nu(pub [cry=(puck:ed c) sgn=(puck:ed s)], sek `[cry=c sgn=s])
      ::                                                ::  ++com:nu:crub:crypto
      ++  com                                           ::  activate public
        |=  a=pass
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~|  %not-crub-pubkey  ?>  =('b' mag)
        ..nu(pub [cry=(rsh 8 bod) sgn=(end 8 bod)], sek ~)
      --  ::nu
    -- 
--
