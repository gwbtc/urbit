/+  *ethereum, eth-trace
|%
+$  safe-state
  $:  owners=(set @ux)
      members=(set @p)
      safe-txs=(list raw-trace:eth-trace)
      asset-txs=(list asset-tx)
      safe-events=(list safe-event)
  ==
+$  state-0
    $:  %0
        safes=(map @ux safe-state)
        last-block=@ud
    ==
+$  asset-tx
  $%  [%erc20 token=@ux from=@ux to=@ux val=@ud]
      [%erc721 token=@ux from=@ux to=@ux id=@ud]
      [%eth from=@ux to=@ux val=@ud]
  ==
+$  safe-event
    $%  $:  %safe-setup
            initiator=address
            owners=(list address)
            threshold=@ud
            initializer=address
            fallback=address
        ==
        [%hash-approved hash=@ux owner=address]
        [%message-signed hash=@ux]
        [%exec-success hash=@ux val=@ud]
        [%exec-failure hash=@ux val=@ud]
        [%safe-received sender=address val=@ud]
        [%owner-added owner=address]
        [%owner-removed owner=address]
        [%threshold-changed threshold=@ud]
        [%fallback-changed fallback=address]
        [%guard-changed guard=address]
        [%module-enabled module=address]
        [%module-disabled module=address]
        [%module-exec-success module=address]
        [%module-exec-failure module=address]
    ==
--