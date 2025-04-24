/+  btcio, rpc=json-rpc, strandio
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
;<  res=(unit block:btcio)  bind:m
  %-  get-block-by-height:btcio
  (need !<((unit [@t (unit @t) @ud ?]) args))
(pure:m !>(res))
