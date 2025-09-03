/-  spider, bp=btc-provider
/+  strand, io=strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
=/  =action:bp  !<(action:bp arg)
|^  ^-  form:m
:: ;<  eny=@uvJ  bind:m  get-entropy:io
:: =.  id.action  eny
=/  id  (scot %uv id.action)
;<  ~  bind:m  (watch-our:io /btcp-update/[id] %bitcoin-rpc /clients/[id])
;<  =update:bp  bind:m  (request action)
(pure:m !>(update))
::
++  request
  |=  act=action:bp
  =/  m  (strand ,update:bp)
  ^-  form:m
  =/  fail-after  3
  =|  try=@
  =/  id  (scot %uv id.action)
  |-  =*  loop  $
  :: ~&  "inside request loop"
  ;<  ~  bind:m  (backoff:io try ~m1)
  :: ~&  "after backoff"
  ;<  ~  bind:m  (poke-our:io %bitcoin-rpc [%btc-provider-action !>(act)])
  :: ~&  >  "attempt {<try>} to poke btcp"
  ;<  =cage  bind:m  (take-fact:io /btcp-update/[id])
  =/  =update:bp  !<(update:bp q.cage)
  :: ~&  >  "thread received fact from btcp"
  ?:  ?=(%& -.update)
    :: ~&  >  "btcp successful result"
    (pure:m update)
  :: ~&  >  "%volt: attempt {<try>} at %btc-provider action failed with"
  :: ~&  >  "{<+.+.update>}"
  ?:  (lte try fail-after)
    loop(try +(try))
  :: ~&  >  "%volt: %btc-provider action permanently failed"
  (pure:m update)
--