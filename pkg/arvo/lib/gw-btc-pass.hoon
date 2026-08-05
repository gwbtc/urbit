::  Codec for the suite-%c pass format owned by the %gw-btc PKI domain,
::  protocol kelvin 9.
::
::    This is a reduced mirror of the canonical implementation, which
::    lives in the groundwire desk as lib/gw-btc-pass.hoon and
::    sur/self-attestation.hoon.  It carries only what the in-kernel
::    Aqua simulation needs -- the immutable tweak data, the custody-log
::    molds, and the commitment checks -- and drops everything that
::    would drag in the desk's bitcoin libraries (taproot trees, script
::    building, OP_RETURN publications).  Keep it in step with the desk;
::    both are pinned by the shared golden vectors in
::    groundwire/vectors/gw-kelvin-9.json.
::
::    The immutable tweak data is:
::
::        dat   = (can 0 (mat %gw-btc) (mat 9) [256 d] ~)
::        d     = H_tag("gw/spawn-commit", (jam spawn-sont) || blind)
::        blind = H_tag("gw/spawn-blind", seed)
::
::    Ames reads only the leading mat to route the pass to %gw-btc.  The
::    kelvin is plaintext.  d is a hiding commitment: the spawn satpoint
::    is learned only from an explicit $blind-opening, never parsed out
::    of dat.  Trailing data after d is rejected.  The pass's xtr tail
::    is excluded from the key tweak, so the custody log may grow
::    without changing the comet's name.
::
::    Byte conventions, pinned by the golden vectors: H_tag is the
::    BIP-340 tagged hash over big-endian byte strings; a jammed noun
::    enters a hash message as its minimal LITTLE-ENDIAN byte dump (the
::    ordinary serialization of a jam), never byte-reversed; blind and d
::    are exactly 32 bytes.
::
|%
++  domain  %gw-btc
++  kelvin  9
::  $sont: satpoint -- the outpoint that created a sat, plus its offset
::
+$  sont  [txid=@ux vout=@ud off=@ud]
::  $snapshot: the complete per-identity state committed on-chain
::
::    every snapshot change increments life, and a rift increment
::    implies a life increment, so life totally orders a ship's states.
::    .key is the messaging half (cry.pub) of the suite-%c pass; the
::    signing half fixing the @p is immutable.  an absent sponsor
::    projects to self-sponsorship in the jael udiff.
::
+$  snapshot
  $:  life=@ud
      rift=@ud
      key=@
      sponsor=(unit @p)
      fief=(unit fief)
  ==
::  $blind-opening: opens the pass's hiding dat commitment
::
::    start-height is transport metadata, not part of the commitment
::    preimage: it names the block containing the transaction that
::    created the spawn satpoint.
::
+$  blind-opening  [spawn=sont start-height=@ud blind=@ux]
::  $opening: reveals the state committed at one custody hop
::
+$  opening
  $:  internal-key=@ux
      =snapshot
      blind-opening=(unit blind-opening)
  ==
::
+$  custody-entry  [txid=@ux height=@ud opening=(unit opening)]
::  $custody-log: the pass's mutable xtr payload, oldest entry first
::
::    each entry names a transaction spending the current sat.  exactly
::    one entry -- entry 0, the spawn -- additionally opens the dat
::    commitment via $blind-opening.
::
+$  custody-log  (list custody-entry)
::  +tag-hash: BIP-340 tagged hash over big-endian byte strings
::
++  tag-hash  tagged-hash:schnorr:secp256k1:secp:crypto
::  +jam-octs: a jammed noun as a byte string (minimal LE byte dump)
::
++  jam-octs
  |=  n=*
  ^-  [wid=@ud dat=@ux]
  =/  jm   (jam n)
  =/  wid  (met 3 jm)
  [wid `@ux`(rev 3 wid jm)]
::  +make-blind: the recommended seed-derived blind
::
::    deterministic from the master seed alone, so the opening is
::    recoverable without extra stored state.  the seed enters as its
::    minimal little-endian byte dump.
::
++  make-blind
  |=  seed=@
  ^-  @ux
  =/  wid  (met 3 seed)
  `@ux`(tag-hash 'gw/spawn-blind' [wid (rev 3 wid seed)])
::  +spawn-commit: d, the hiding commitment to the spawn satpoint
::
++  spawn-commit
  |=  [spawn=sont blind=@ux]
  ^-  @ux
  =/  jb  (jam-octs spawn)
  %-  tag-hash
  ['gw/spawn-commit' (add wid.jb 32) (can 3 ~[[32 blind] jb])]
::  +make-dat: the full immutable tweak data
::
++  make-dat
  |=  [spawn=sont blind=@ux]
  ^-  @
  (can 0 ~[(mat domain) (mat kelvin) [256 (spawn-commit spawn blind)]])
::  +parse-dat: domain tag, kelvin, and commitment -- nothing more
::
::    rejects trailing data: a dat must be exactly the two mat items
::    followed by 256 bits of commitment.
::
++  parse-dat
  |=  dat=@
  ^-  (unit [dom=@tas kel=@ud d=@ux])
  %-  mole
  |.
  =/  hed  (rub 0 dat)
  =/  kel  (rub p.hed dat)
  =/  pos  (add p.hed p.kel)
  =/  d  `@ux`(cut 0 [pos 256] dat)
  ?>  (lte (met 0 dat) (add pos 256))
  [`@tas`q.hed `@ud`q.kel d]
::  +verify-dat: check a blind-opening against a dat
::
++  verify-dat
  |=  [dat=@ open=blind-opening]
  ^-  ?
  =/  psd  (parse-dat dat)
  ?~  psd  |
  ?&  =(domain dom.u.psd)
      =(kelvin kel.u.psd)
      =(d.u.psd (spawn-commit spawn.open blind.open))
  ==
--
