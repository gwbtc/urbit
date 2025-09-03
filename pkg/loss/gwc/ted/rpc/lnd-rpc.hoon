::  ted/lnd-rpc.hoon
/-  spider, *volt
/+  *strandio, lnd-rpc
=,  strand=strand:spider
^-  thread:spider
|=  v=vase
=+  !<([~ [=host-info:provider =action:rpc]] v)
=/  m  (strand ,vase)
;<  =response:rpc  bind:m  (~(send lnd-rpc host-info) action)
(pure:m !>(response))
