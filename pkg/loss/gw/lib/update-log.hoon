::  update-log.hoon: update-log manipulation
::
/-  *bolt
|_  log=update-log
::
++  entries
  ^-  (list update)
  list.log
::
++  append-update
  |=  =update
  ^-  update-log
  ?>  =(index.update update-count.log)
  %=  log
    list          (snoc list.log update)
    update-index  (~(put by update-index.log) update-count.log update)
    update-count  +(update-count.log)
  ==
::
++  append-htlc
  |=  =update
  ^-  update-log
  ?>  ?=([%add-htlc *] update)
  ?>  =(index.update update-count.log)
  ?>  =(htlc-id.update htlc-count.log)
  %=  log
    list          (snoc list.log update)
    update-count  +(update-count.log)
    htlc-index    (~(put by htlc-index.log) htlc-count.log update)
    htlc-count    +(htlc-count.log)
  ==
::
++  lookup-htlc
  |=  =htlc-id
  ^-  (unit update)
  (~(get by htlc-index.log) htlc-id)
::
++  remove-update
  |=  index=@
  ^-  update-log
  =+  entry=(~(get by update-index.log) index)
  ?~  entry  log
  =+  offset=(find ~[u.entry] list.log)
  ?~  offset  log
  %=  log
    list          (oust [u.offset 1] list.log)
    update-index  (~(del by update-index.log) index)
  ==
::
++  remove-htlc
  |=  =htlc-id
  ^-  update-log
  =+  entry=(~(get by htlc-index.log) htlc-id)
  ?~  entry  log
  =+  index=(find ~[u.entry] list.log)
  ?~  index  log
  %=  log
    list            (oust [u.index 1] list.log)
    htlc-index      (~(del by htlc-index.log) htlc-id)
    modified-htlcs  (~(del in modified-htlcs.log) htlc-id)
  ==
::
++  mark-htlc-as-modified
  |=  =htlc-id
  ^-  update-log
  log(modified-htlcs (~(put in modified-htlcs.log) htlc-id))
--
