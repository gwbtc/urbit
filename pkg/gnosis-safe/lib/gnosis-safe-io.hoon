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
  |%
  ++  trace
    |%
    
    ==
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
