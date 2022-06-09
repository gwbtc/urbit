/-  eth-trace
/+  eth-trace-io, ethereum, ethio, strandio
=,  ethereum-types
=,  jael
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
=+  [~ rpc-url txh]=!<([~ @t @ux] args)
;<  res=raw-trace:eth-trace  bind:m
  (trace-tx:eth-trace-io rpc-url txh)
(pure:m !>(res))