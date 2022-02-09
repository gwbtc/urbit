|%
++  raw-trace  (build-trace-mold @ux)
++  build-trace-mold
  |*  data-mold=mold
  =<  full-trace
  |%
  +$  full-trace
    $:  block-hash=@ux
        block-number=@ud
        tx-hash=(unit @ux)
        tx-pos=(unit @ud)
        trace
    ==
  +$  trace  [=action =subtraces]
  +$  subtraces  $@(~ [i=trace t=(list trace)])
  +$  action
    $%  call
        [%create create:action:trace:rpc]
        [%suicide suicide:action:trace:rpc]
        [%reward reward:action:trace:rpc]
    ==
  +$  call
    $:  call-type:trace:rpc
        from=@ux
        to=@ux
        value=@ud
        gas=@ud
        input=data-mold
        gas-used=@ud
        output=data-mold
    ==
  --
::
++  rpc
  |%
  ++  trace
    =<  trace
    |%
    +$  trace  [=details =action]
    ++  result
        |%
        +$  result
        $%  [%create create]
            [%call call]
        ==
        +$  create  [gas-used=@ud code=@ux address=@ux]
        +$  call  [gas-used=@ud output=@ux]
        --
    +$  type  ?(%create %call %suicide %reward)
    +$  details
        $:  subtraces=@ud
            trace-address=(list @ud)
            tx-pos=(unit @ud)
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
        +$  create  [from=@ux value=@ud gas=@ud init=@ux create:result]
        +$  suicide  [address=@ux refund-address=@ux balance=@ud]
        +$  reward  [author=@ux value=@ud type=?(%block %uncle %external %empty-step)]
        --
    ::
    ++  action-ir
        |%
        +$  call  [type=call-type from=@ux to=@ux value=@ud gas=@ud input=@ux]
        +$  create  [from=@ux value=@ud gas=@ud init=@ux]
        --
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
  ::
  --
--
