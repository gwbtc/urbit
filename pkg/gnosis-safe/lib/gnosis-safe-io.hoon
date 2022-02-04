/+  *ethereum
|%
++  rpc-url  'https://api.archivenode.io/wghgt69z1ul3ejgljwghgt6cmtr59vbn/erigon'
++  trace
  =<  trace
  |%
  ++  result
    =<  result
    |%
    +$  result
      $%  [%create create]
          [%call call]
      ==
    +$  create  [gas-used=@ud code=@ux address=@ux]
    +$  call  [gas-used=@ux output=@ux]
    --
  +$  trace-ir
    $:  =action
        result=(unit result)
        =details
    ==
  +$  details
    $:  =trace-address=(list @ud)
        =tx-pos=(unit @ud)
        tx-hash=(unit @ux)
        block-number=@ud
        block-hash=@ux
    ==
  ::
  +$  call-type  ?(%call %callcode %staticcall %delegatecall)
  ++  action
    =<  $%  call
            [%create create]
            [%suicide suicide]
            [%reward reward]
        ==
    |%
    +$  call  [call-type from=@ux to=@ux value=@ud gas=@ud input=@ux call:result]
    +$  call-type  ?(%call %callcode %staticcall %delegatecall)
    +$  create  [from=@ux value=@ud gas=@ud init=@ux create:result]
    +$  suicide  [address=@ux refund-address=@ux balance=@ud]
    +$  reward  [author=@ux value=@ud type=?(%block %uncle %external %empty-step)]
    --
  ::
  ++  action-ir
    =<  $%  [%call call]
            [%create create]
            [%suicide suicide:action]
            [%reward reward:action]
        ==
    |%
    +$  call  [type=(unit call-type) from=@ux to=@ux value=@ud gas=@ud input=@ux]
    +$  create  [from=@ux value=@ud gas=@ud init=@ux]
    --
  ::
  --
++  dejs
  =,  dejs:format
  |%
  ++  trace
    =<  trace
    |%
    ++  trace
      %-  ot
      :~  from+(cu hex-to-num so)
          action+json
          'blockHash'^(cu hex-to-num so)
          'blockNumber'^ni
          result+json
          subtraces+ni
          'traceAddress'^(ar ni)
          'transactionHash'^(cu hex-to-num so)
          'transactionPosition'^ni
          type+so
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
++  debug
  |%
  ++  trace
    =<  trace
    |%
    +$  trace
        $:  depth=@ud
            error=@t
            gas=@ud
            memory=(list @ux)
            =op
            pc=@ud
            stack=(list @ux)
            stor=(map @ux @ux)
        ==
    ::
    +$  op
        $%  %stop  %add  %sub  %mul  %div  %sdiv  %mod  %smod  %exp  %not
            %lt  %gt  %slt  %sgt  %eq  %iszero  %and  %or  %xor  %byte  %shl
            %shr  %sar  %addmod  %mulmod  %signextend  %keccak256  %pc  %pop
            %mload  %mstore  %mstore8  %sload  %sstore  %msize  %gas  %address
            %balance  %selfbalance  %caller  %callvalue  %calldataload
            %calldatasize  %calldatacopy  %codesize  %codecopy  %extcodesize
            %extcodecopy  %returndatasize  %returndatacopy  %extcodehash  %create
            %create2  %call  %callcode  %delegatecall  %staticcall  %return
            %revert  %selfdestruct  %invalid  %log0  %log1  %log2  %log3  %log4
            %chainid  %basefee  %origin  %gasprice  %blockhash  %coinbase
            %timestamp  %number  %difficulty  %gaslimit
        ==
    ::
    --
  ::
  --
--
