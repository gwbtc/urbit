/-  spider, volt
/+  strand, io=strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
=/  p  !<([~ invoice-and-pay-params:volt] arg)
;<  =bowl:spider  bind:m  get-bowl:io
=/  get-inv=action:volt
  [%get-invoice amount.p `(scot %p our.bowl) `net.p]
;<  ~  bind:m  (watch:io /volt [who.p %volt] /latest-invoice/(scot %p our.bowl))
;<  ~  bind:m  (poke:io [who.p %volt] %volt-action !>(get-inv))
;<  c1=cage  bind:m  (take-fact:io /volt)
?>  =(%volt-update p.c1)
=+  !<(upd=update:volt q.c1)
~|  upd
?>  ?=(%new-invoice -.upd)
=/  com=command:volt  [%send-payment payreq.payment-request.upd `who.p]
;<  ~  bind:m  (watch-our:io /pay %volt /latest-payment)
;<  ~  bind:m  (poke-our:io %volt %volt-command !>(com))
;<  c2=cage  bind:m  (take-fact:io /pay)
?>  =(%volt-update p.c2)
(pure:m q.c2)
