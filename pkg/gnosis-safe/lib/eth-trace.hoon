/-  sur=eth-trace
/+  *ethereum
=,  sur
|%
++  split-traces-by-tx
  |=  traces=(list rpc:raw-trace)
  ~&  traces
  ^-  (list (list rpc:raw-trace))
  =/  block-hash  ?~(traces 0x0 block-hash.details.i.traces)
  ?~  block-hash  ~
  =/  tx-hash
    ?>  ?=(^ traces)
    =+  tx-hash=tx-hash.details.i.traces
    ?>  ?=(^ tx-hash)  u.tx-hash
  =|  out=[i=(list rpc:raw-trace) t=(list (list rpc:raw-trace))]
  |-
  ?~  traces  [(flop i.out) t.out]
  =/  new-block  block-hash.details.i.traces
  =/  new-tx-hash
    ?>  ?=(^ traces)
    =+  tx-hash=tx-hash.details.i.traces
    ?>  ?=(^ tx-hash)  u.tx-hash
  ?:  &(=(block-hash new-block) =(tx-hash new-tx-hash))
    $(traces t.traces, i.out [i.traces i.out])
  %_  $
    traces  t.traces
    out  [[i.traces ~] (flop i.out) t.out]
    block-hash  new-block
    tx-hash  new-tx-hash
  ==
::
++  reduce-traces
  |*  traces=(list _*rpc:(build-trace-mold))
  |^  ^-  trace
  ?~  traces  !!
  =+  details.i.traces
  :*  block-hash
      block-number
      tx-hash
      tx-pos
      action.i.traces
      ?~(t.traces ~ (reduce-subtraces t.traces))
  ==
  +$  data-mold  _?>(?=(^ traces) ?>(?=([%call *] action.i.traces) input.action.i.traces))
  +$  subtraces  subtraces:trace
  +$  callstack  (tree [key=@ud val=subtraces])
  ++  trace  (build-trace-mold data-mold)
  ++  orm  ((ordered-map @ud subtraces) gth)
  ++  reduce-subtraces
    |=  traces=(list rpc:trace)
    =/  depth  1
    =|  =callstack
    =-  (collapse -)
    |-
    ?~  traces  callstack
    =/  new-depth  (lent trace-address.details.i.traces)
    ?:  =(depth new-depth)
      ~|  lateral+[depth+depth new-depth+new-depth]
      %_    $                                               :: lateral
          traces  t.traces
          callstack
        %^  put:orm  callstack  depth
        [[action.i.traces ~] (fall (get:orm callstack depth) ~)]
      ==
    ?:  (lth depth new-depth)
      ~|  descend+[depth+depth new-depth+new-depth]
      %_    $                                               :: descend
          depth  new-depth
          traces  t.traces
          callstack  (put:orm callstack new-depth ~[[action.i.traces ~]])
      ==
    ~|  ascend+[depth+depth new-depth+new-depth]
    %_    $                                                 :: ascend
        depth  new-depth
        traces  t.traces
        callstack
      %^  put:orm  (lot:orm callstack `depth ~)  new-depth
      =/  upper  (got:orm callstack new-depth)
      :-  [action.i.traces ~]
      ?>  ?=(^ upper)
      upper(subtraces.i (weld subtraces.i.upper (collapse (lot:orm callstack ~ `new-depth))))
    ==
  ++  collapse
    |=  =callstack
    =/  stack  (turn (tap:orm callstack) |=([* =subtraces] subtraces))
    |-  ^-  subtraces
    ?>  ?=(^ stack)
    ?~  t.stack  (flop i.stack)
    ?>  ?=(^ i.t.stack)
    =/  lower  i.stack
    =/  upper  i.t.stack
    ?>  ?=(^ upper)
    ~!  i.upper
    $(stack [upper(i i.upper(subtraces (weld subtraces.i.upper (flop lower)))) t.t.stack])
  --
++  rpc-url  'https://api.archivenode.io/wghgt69z1ul3ejgljwghgt6cmtr59vbn/erigon'
++  dejs
  =,  dejs:format
  |%
  ++  trace
    =<  trace
    |%
    ++  trace
      |=  jon=json
      ^-  trace:rpc
      =/  details  (trace-details jon)
      ?+  type.details    ~|  %unexpected-action-type  !!
          %create
        =/  action  (create-action action.details)
        =/  result  (create-result result.details)
        =+  action
        [details.details [%create from value gas init result]]
          %call
        =/  action  (call-action action.details)
        =/  result  (call-result result.details)
        =+  action
        [details.details -.action from to value gas input result]
          %suicide
        =/  action  (suicide-action action.details)
        [details.details %suicide action]
        ::   %reward
        :: !!
      ==
    ::
    ++  trace-details
      ^-  $-(json [=type:trace:rpc action=json result=json details=details:trace:rpc])
      %-  ou
      :~  type+(un (cu type:trace:rpc so))
          action+(un json)
          result+(un json)
          subtraces+(un ni)
          'traceAddress'^(un (ar ni))
          'transactionPosition'^(uf ~ (mu ni))
          'transactionHash'^(uf ~ (mu (cu hex-to-num so)))
          'blockNumber'^(un ni)
          'blockHash'^(un (cu hex-to-num so))
      ==
    ::
    ++  call-action
      ^-  $-(json call:action-ir:trace:rpc)
      %-  ot
      :~  'callType'^(cu call-type:trace:rpc so)
          from+(cu hex-to-num so)
          to+(cu hex-to-num so)
          value+(cu hex-to-num so)
          gas+(cu hex-to-num so)
          input+(cu hex-to-num so)
      ==
    ++  create-action
      ^-  $-(json create:action-ir:trace:rpc)
      %-  ot
      :~  from+(cu hex-to-num so)
          gas+(cu hex-to-num so)
          init+(cu hex-to-num so)
          value+(cu hex-to-num so)
      ==
    ++  suicide-action
      %-  ot
      :~  address+(cu hex-to-num so)
          'refundAddress'^(cu hex-to-num so)
          balance+(cu hex-to-num so)
      ==
    ::
    ++  call-result
      ^-  $-(json call:result:trace:rpc)
      %-  ot
      :~  'gasUsed'^(cu hex-to-num so)
          output+(cu hex-to-num so)
      ==
    ++  create-result
      ^-  $-(json create:result:trace:rpc)
      %-  ot
      :~  'gasUsed'^(cu hex-to-num so)
          code+(cu hex-to-num so)
          address+(cu hex-to-num so)
      ==
    --
  ++  of-key
    |*  [key=cord wer=(pole [cord fist])]
    |=  jom=json
    ?>  ?=([%o *] jom)
    =/  val  (so (~(got by p.jom) key))
    ((of-key-raw val wer) jom)
  ::
  ++  of-key-raw
    |*  [val=cord wer=(pole [cord fist])]
    |=  jom=json
    ?>  ?=([%o *] jom)
    ?-    wer                                         :: mint-vain on empty
      :: [[key=@t wit=*] t=*]
      [[key=@t *] t=*]
    =>  .(wer [[* wit] *]=wer)
    ~|  finding-key+val
    ?:  =(key.wer val)
      ~|(key+key.wer (wit.wer jom))
    ?~  t.wer  ~|(bad-key+key.wer !!):: ++  of-key
    ((of-key-raw val t.wer) jom)
    ==
  ::
  ++  si                                              ::  string as integer
    |=  jon=json
    ?>  ?=([%s *] jon)
    (rash p.jon dem)
  ::
  --
--
