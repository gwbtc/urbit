/-  eth-trace
/+  eth-trace-io, ethereum, ethio, strandio
=,  ethereum-types
=,  jael
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
=+  [~ rpc-url trace-filter]=!<([~ @t trace-filter:rpc:ethereum] args)
;<  res=(list raw-trace:eth-trace)  bind:m
  (trace-filter:eth-trace-io rpc-url trace-filter)
(pure:m !>(res))