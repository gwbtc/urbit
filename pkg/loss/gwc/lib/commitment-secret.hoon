/-  *bolt
=,  secp256k1:secp:crypto
|%
+$  index          @
+$  seed           @
+$  commit-secret  @
++  first-index    (dec (bex 48))
::
++  compute-commitment-point
  |=  =commit-secret
  ^-  point
  %+  mul-point-scalar
    g.domain.curve
  commit-secret
::
++  generate-from-seed
  |=  [=seed i=index bits=(unit @ud)]
  |^  ^-  commit-secret
  =/  p=@    seed
  =/  b=@ud  (fall bits 48)
  |-
  =.  b  (dec b)
  =?  p  (test-bit b i)
    %+  shay  32
    %+  flip-bit  b  p
  ?:  =(0 b)
    (swp 3 p)
  $(b b, p p)
  ::
  ++  test-bit
    |=  [n=@ p=@]
    =(1 (get-bit n p))
  ::
  ++  get-bit
    |=  [n=@ p=@]
    =/  byt=@  (div n 8)
    =/  bit=@  (mod n 8)
    %+  dis  0x1
    %+  rsh  [0 bit]
    %+  rsh  [3 byt]
    p
  ::
  ++  flip-bit
    |=  [n=@ b=@]
    =/  byt=@  (div n 8)
    =/  bit=@  (mod n 8)
    %+  mix  b
    %+  lsh  [0 bit]
    %+  lsh  [3 byt]
    1
  --
--
