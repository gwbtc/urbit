/+  btcio, rpc=json-rpc, strandio
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
~&  %wtf
=/  req  (need !<((unit [@t (unit @t) wut=(each @ud @ux) ?]) args))
;<  res=(unit block:btcio)  bind:m
  %.  req(wut `@`+.wut.req)
  ?:(?=(%& -.wut.req) get-block-by-height:btcio get-block:btcio)

(pure:m !>(res))
