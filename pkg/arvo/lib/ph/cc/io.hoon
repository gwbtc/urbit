/+  *ph-cc-util, az=aqua-azimuth
|_  [loud=? tag=@tas]
++  init-ship-core
  |=  [ship=@p fake=? core=?(%ames %mesa)]
  =/  m  (strand:rand ,~)
  ~?  >>  loud  [tag "{(cite:title ship)}: init ship"]
  ;<  ~  bind:m  %*($ init-ship ship ship, fake fake, core core)
  (pure:m ~)
::
++  install-pki
  |=  =ship
  =/  m  (strand:rand ,~)
  ^-  form:m
  ~?  >>  loud  [tag "{(cite:title ship)}: install the fake %test-pki verifier"]
  ;<  ~  bind:m  (mount ship %base)
  ;<  ~  bind:m  (copy-file ship /app/test-pki/hoon pki-agent)
  ;<  ~  bind:m  (dojo ship "|start %test-pki")
  ;<  ~  bind:m  (wait-for-output ship "booted %test-pki")
  ::  Let jael consume the agent's asynchronous %anex card before
  ::  the first attestation reaches ames.
  ;<  ~  bind:m  (sleep ~s2)
  (pure:m ~)
::
++  assert-snubbed
  |=  [=ship who=@p]
  =/  m  (strand:rand ,~)
  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl
  =/  aqua-pax
    %+  weld  /i/(scot %p ship)/ax/(scot %p ship)//(scot %da now.bowl)
    /snubbed/noun
  =+  ;;  val=(unit [form=?(%allow %deny) ships=(list @p)])
      (scry-aqua:util noun our.bowl now.bowl aqua-pax)
  ?>  ?=(^ val)
  ?>  =(%deny form.u.val)
  ?>  (lien ships.u.val |=(her=@p =(who her)))
  ~?  >>  loud  [tag "{(cite:title ship)}: {(cite:title who)} is snubbed"]
  (pure:m ~)
::
++  assert-snobbed
  |=  [=ship who=@p]
  =/  m  (strand:rand ,~)
  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl
  =/  aqua-pax
    %+  weld  /i/(scot %p ship)/ax/(scot %p ship)//(scot %da now.bowl)
    /snobbed/noun
  =+  ;;  val=(unit [form=?(%allow %deny) ships=(list @p)])
      (scry-aqua:util noun our.bowl now.bowl aqua-pax)
  ?>  ?=(^ val)
  ?>  =(%deny form.u.val)
  ?>  (lien ships.u.val |=(her=@p =(who her)))
  ~?  >>  loud  [tag "{(cite:title ship)}: {(cite:title who)} is soft-blocked"]
  (pure:m ~)
::
++  assert-not-snobbed
  |=  [=ship who=@p]
  =/  m  (strand:rand ,~)
  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl
  =/  aqua-pax
    %+  weld  /i/(scot %p ship)/ax/(scot %p ship)//(scot %da now.bowl)
    /snobbed/noun
  =+  ;;  val=(unit [form=?(%allow %deny) ships=(list @p)])
      (scry-aqua:util noun our.bowl now.bowl aqua-pax)
  ?>  ?=(^ val)
  ?>  =(%deny form.u.val)
  ?>  !(lien ships.u.val |=(her=@p =(who her)))
  ~?  >>  loud  [tag "{(cite:title ship)}: {(cite:title who)} is not soft-blocked"]
  (pure:m ~)
::
::  +poke-snob: make .ship's fake %test-pki withdraw its vouch for .who
::
++  poke-snob
  |=  [=ship who=@p]
  =/  m  (strand:rand ,~)
  ^-  form:m
  ~?  >>  loud  [tag "{(cite:title ship)}: %test-pki withdraws its vouch for {(cite:title who)}"]
  ;<  ~  bind:m  (poke-app ship %test-pki %noun [%snob who])
  (pure:m ~)
::
++  start-cc-comet
  |=  [comet=@p core=?(%ames %mesa) =onchain]
  =.  onchain  (sort-onchain onchain)
  =/  m  (strand:rand ,~)
  ~?  >>  loud  [tag "{(cite:title comet)}: init"]
  ;<  ~  bind:m  %*($ init-ship ship comet, fake |, core core)
  ~?  >>  loud  [tag "{(cite:title comet)}: mount %base"]
  ;<  ~  bind:m  (mount comet %base)
  ~?  >>  loud  [tag "{(cite:title comet)}: copy udiff agent"]
  ;<  ~  bind:m  (copy-file comet /app/test-udiff/hoon udiff-agent)
  ~?  >>  loud  [tag "{(cite:title comet)}: copy udiff mark"]
  ;<  ~  bind:m  (copy-file comet /mar/test-udiffs/hoon udiffs-mark)
  ~?  >>  loud  [tag "{(cite:title comet)}: start udiff agent"]
  ;<  ~  bind:m  (dojo comet "|start %test-udiff")
  ;<  ~  bind:m  (wait-for-output comet "booted %test-udiff")
  |-  ^-  form:m
  =*  loop  $
  ?~  onchain
    (pure:m ~)
  ;<  ~  bind:m  (poke-all-udiffs comet i.onchain)
  loop(onchain t.onchain)
  ::
++  poke-all-udiffs
  |=  $:  =ship
          for=@p
          =life
          =rift
          spon=(unit @p)
          fef=?(~ %turf %is %if)
      ==
  =/  m  (strand:rand ,~)
  ^-  form:m
  =/  =pass  pub:ex:(get-keys:az for life)
  =/  =udiffs:point:jael
    :~  (keys-udiff for life)
        (fief-udiff for fef)
        (rift-udiff for rift)
        (spon-udiff for ?~(spon `for spon))
    ==
  ~?  >>  loud  [tag "{(cite:title ship)}: inject udiffs for {(cite:title for)}"]
  ;<  ~  bind:m  (poke-app ship %test-udiff %test-udiffs udiffs)
  ;<  ~  bind:m  (wait-for-output ship ":test-udiff &test-udiffs")
  (pure:m ~)
::  
++  poke-keys-udiff
  |=  [=ship for=@p new-life=life]
  =/  m  (strand:rand ,~)
  ^-  form:m
  =/  =udiff:point:jael  udiff:(keys-udiff for new-life)
  ~?  >>  loud  [tag "{(cite:title ship)}: inject rekey udiff for {(scow %p for)}"]
  ;<  ~  bind:m  (poke-app ship %test-udiff %test-udiffs [for udiff]~)
  ;<  ~  bind:m  (wait-for-output ship ":test-udiff &test-udiffs")
  (pure:m ~)
::
++  poke-udiffs
  |=  [=ship for=@p =udiffs:point:jael]
  =/  m  (strand:rand ,~)
  ^-  form:m
  ~?  >>  loud  [tag "{(cite:title ship)}: inject udiffs for {(scow %p for)}"]
  ;<  ~  bind:m  (poke-app ship %test-udiff %test-udiffs udiffs)
  ;<  ~  bind:m  (wait-for-output ship ":test-udiff &test-udiffs")
  (pure:m ~)
::
++  poke-rekey
  |=  [=ship new-life=life]
  =/  m  (strand:rand ,~)
  ^-  form:m
  =/  =ring  sec:ex:(get-keys:az ship new-life)
  =/  =feed:jael
    [[%2 ~] ship *rift [new-life ring]~]
  =/  sed=@t  (scot %uw (jam feed))
  ~?  >>  loud  [tag "{(cite:title ship)}: rekey at life {(scow %ud new-life)}"]
  ;<  ~  bind:m  (poke-app ship %hood %helm-rekey sed)
  ;<  ~  bind:m  (wait-for-output ship ":hood &helm-rekey")
  (pure:m ~)
::
++  must-timeout
  =/  m  (strand:rand ,~)
  |=  [time=@dr computation=form:m]
  ^-  form:m
  ;<  now=@da  bind:m  get-time
  =/  when  (add now time)
  =/  =card:agent:gall
    [%pass /timeout/(scot %da when) %arvo %b %wait when]
  ;<  ~        bind:m  (send-raw-card card)
  |=  tin=strand-input:strand
  =*  loop  $
  ?:  ?&  ?=([~ %sign [%timeout @ ~] %behn %wake *] in.tin)
          =((scot %da when) i.t.wire.u.in.tin)
      ==
    ~?  >>  loud  [tag "timed out after {(scow %dr time)}"]
    `[%done ~]
  =/  c-res  (computation tin)
  ?:  ?=(%cont -.next.c-res)
    c-res(self.next ..loop(computation self.next.c-res))
  ?:  ?=(%done -.next.c-res)
    ~?  >>  loud  [tag "finished before {(scow %dr time)} timeout"]
    :_  [%fail %no-timeout ~]
    [%pass /timeout/(scot %da when) %arvo %b %rest when]~
  c-res
::
++  send-hi
  |=  [=ship target=ship]
  ~?  >>  loud  [tag "{(cite:title ship)}: send hi to {(cite:title target)}"]
  (^send-hi ship target)
::
++  cc-breach
  |=  [who=@p new-life=life new-rift=rift core=?(%ames %mesa) =onchain]
  =/  m  (strand:rand ,^onchain)
  ~?  >>  loud  [tag "{(cite:title who)}: perform breach"]
  =/  =ring  sec:ex:(get-keys:az who new-life)
  =/  =feed:jael
    [[%2 ~] who new-rift [new-life ring]~]
  ~&  >  "starting {<who>}"
  ;<  ~  bind:m  (send-events (init:util who | `feed core))
  ;<  ~  bind:m  (check-ship-booted who)
  =/  new-onchain=^onchain
    %-  sort-onchain
    %+  turn  onchain
    |=  dat=[peer=@p =life =rift spon=(unit @p) fef=?(~ %turf %is %if)]
    ?.  =(who peer.dat)  dat
    dat(life new-life, rift new-rift)
  ~?  >>  loud  [tag "{(cite:title who)}: mount %base"]
  ;<  ~  bind:m  (mount who %base)
  ~?  >>  loud  [tag "{(cite:title who)}: copy udiff agent"]
  ;<  ~  bind:m  (copy-file who /app/test-udiff/hoon udiff-agent)
  ~?  >>  loud  [tag "{(cite:title who)}: copy udiff mark"]
  ;<  ~  bind:m  (copy-file who /mar/test-udiffs/hoon udiffs-mark)
  ~?  >>  loud  [tag "{(cite:title who)}: start udiff agent"]
  ;<  ~  bind:m  (dojo who "|start %test-udiff")
  ;<  ~  bind:m  (wait-for-output who "booted %test-udiff")
  =/  oc-1  new-onchain
  =/  oc-2  new-onchain
  |-  ^-  form:m
  =*  loop-1  $
  ?~  oc-1
    =/  =udiffs:point:jael
      :~  (rift-udiff who new-rift)
          (keys-udiff who new-life)
      ==
    |-  ^-  form:m
    =*  loop-2  $
    ?~  oc-2
      (pure:m new-onchain)
    ?:  =(who peer.i.oc-2)
      loop-2(oc-2 t.oc-2)
    ;<  ~  bind:m  (poke-udiffs peer.i.oc-2 who udiffs)
    ;<  ~  bind:m  (sleep ~s10)
    loop-2(oc-2 t.oc-2)
  ;<  ~  bind:m  (poke-all-udiffs who i.oc-1)
  loop-1(oc-1 t.oc-1)
::
--
