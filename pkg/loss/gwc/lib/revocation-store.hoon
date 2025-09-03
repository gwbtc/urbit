::  revocation-store.hoon: BOLT-03 revocation storage
::
/-  *bolt
/+  bc=bitcoin, secret=commitment-secret
|_  r=revocation-store
::
++  start-index
  ^-  @ud
  (dec (bex 48))
::
++  add-next
  |=  hash=@
  ^-  revocation-store
  =+  element=[idx=idx.r secret=hash]
  =+  bucket=(count-trailing-zeros idx.r)
  =|  i=@ud
  |-
  ?:  =(i 0)
    :*
      idx=(dec idx.r)
      buckets=(~(put by buckets.r) bucket element)
    ==
  =/  this=shachain-element      (~(got by buckets.r) i)
  =/  e=(unit shachain-element)  (shachain-derive element idx.this)
  ~|  %hash-not-derivable
  ?>  =(`this e)
  $(i +(i))
::
++  retrieve
  |=  idx=@u
  ^-  @
  ?>  (lte idx start-index)
  ~|  %unable-to-derive-secret
  =+  i=0
  |-
  =/  bucket=shachain-element          (~(got by buckets.r) i)
  =/  element=(unit shachain-element)  (shachain-derive bucket idx)
  ?~  element  $(i +(i))
  ?>  (lte i 48)
  secret.u.element
::
++  shachain-derive
  |=  [e=shachain-element to-index=@]
  |^  ^-  (unit shachain-element)
  =+  zeros=(count-trailing-zeros idx.e)
  ?.  =(idx.e (get-prefix to-index zeros))
    ~
  %-  some
  :*
    idx=to-index
    secret=(generate-from-seed:secret secret.e to-index `zeros)
  ==
  ++  get-prefix
    |=  [idx=@ud pos=@ud]
    =+  mask=(lsh [0 64] 1)
    =.  mask  (sub mask 1)
    =.  mask  (sub mask (sub (lsh [0 pos] 1) 1))
    (dis idx mask)
  --
::
++  count-trailing-zeros
  |=  idx=@u
  ^-  @u
  =+  a=idx
  =|  n=@u
  |-
  ?:  =(1 (dis a 1))
    n
  ?:  =(n 48)
    n
  $(a (rsh [0 1] a), n +(n))
--
