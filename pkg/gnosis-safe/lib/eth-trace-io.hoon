/+  eth=ethereum, ethio, lib=eth-trace, strandio
|%
++  trace-tx
  =,  dejs:format
  |=  [url=@ta txh=@ux]
  =/  m  (strand:strandio raw-trace:lib)
  ^-  form:m
  ;<  =json  bind:m
    %^  request-rpc:ethio  url  `'trace-tx'
    [%trace-transaction txh]
  %-  pure:m
  %-  reduce-traces:lib
  ((ar trace:dejs:lib) json)
++  trace-filter
  =,  dejs:format
  |=  [url=@ta =trace-filter:rpc:eth]
  =/  m  (strand:strandio (list raw-trace:lib))
  ^-  form:m
  ;<  =json  bind:m
    %^  request-rpc:ethio  url  `'trace-filter'
    [%trace-filter trace-filter]
::   ~|  json
  %-  pure:m
  %+  turn 
    %-  split-traces-by-tx:lib
    ((ar trace:dejs:lib) json)
  reduce-traces:lib
--