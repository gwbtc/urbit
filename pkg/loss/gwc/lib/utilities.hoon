/-  *bolt
/+  bc=bitcoin, bolt11
/+  der, psbt, ring
|%
++  bcu  bcu:bc
++  mainnet-hash
  ^-  hexb:bc
  32^0x19.d668.9c08.5ae1.6583.1e93.4ff7.63ae.46a2.a6c1.72b3.f1b6.0a8c.e26f
::
++  testnet-hash
  ^-  hexb:bc
  32^0x933.ea01.ad0e.e984.2097.79ba.aec3.ced9.0fa3.f408.7195.26f8.d77f.4943
::
++  regtest-hash
  ^-  hexb:bc
  32^0xf91.88f1.3cb7.b2c7.1f2a.335e.3a4f.c328.bf5b.eb43.6012.afca.590b.1a11.466e.2206
::
++  network-chain-hashes
  ^-  (map network hexb:bc)
  %-  malt
  ^-  (list (pair network hexb:bc))
  :~  [%main mainnet-hash]
      [%testnet testnet-hash]
      [%regtest regtest-hash]
  ==
::
++  chain-hash-networks
  ^-  (map hexb:bc network)
  %-  malt
  ^-  (list (pair hexb:bc network))
  :~  [mainnet-hash %main]
      [testnet-hash %testnet]
      [regtest-hash %regtest]
  ==
::
++  network-chain-hash
  |=  =network
  ^-  hexb:bc
  ?.  (~(has by network-chain-hashes) network)
    ~|(%unknown-network !!)
  (~(got by network-chain-hashes) network)
::
++  chain-hash-network
  |=  chain-hash=hexb:bc
  ^-  network
  ?.  (~(has by chain-hash-networks) chain-hash)
    ~|(%unknown-network !!)
  (~(got by chain-hash-networks) chain-hash)
::
++  msats-to-sats
  |=  a=msats
  ^-  sats:bc
  (div a 1.000)
::
++  sats-to-msats
  |=  a=sats:bc
  ^-  msats
  (mul a 1.000)
::
++  bech32-encode
  |=  [=network =hexb:bc]
  ^-  (unit cord)
  =+  prefix=(~(get by prefixes:bolt11) network)
  ?~  prefix  ~
  %-  some
  %+  encode-raw:bech32:bolt11  u.prefix
  :-  0v0
  %+  to-atoms:bit:bcu  5
  %+  pad-bits:bolt11   5
  (bytes-to-bits:bolt11 hexb)
::
++  bech32-decode
  |=  =cord
  ^-  hexb:bc
  (from-address:bech32:bolt11 cord)
::
++  fee-by-weight
  |=  [feerate-per-kw=@ud weight=@ud]
  ^-  sats:bc
  (div (mul weight feerate-per-kw) 1.000)
::
++  commitment-number-blinding-factor
  =,  secp256k1:secp:crypto
  |=  [oc=point ac=point]
  ^-  hexb:bc
  %+  drop:byt:bcu  26
  %-  sha256:bcu
  %-  cat:byt:bcu
  :~  33^(compress-point oc)
      33^(compress-point ac)
  ==
::
++  obscure-commitment-number
  |=  [cn=commitment-number oc=point ac=point]
  ^-  @ud
  (mix dat:(commitment-number-blinding-factor oc ac) cn)
::
++  unobscure-commitment-number
  |=  [a=@ oc=point ac=point]
  ^-  commitment-number
  (mix dat:(commitment-number-blinding-factor oc ac) a)
::  +encode-point: DER-encode elliptic curve point
::
++  encode-point
  |=  p=point
  ^-  hexb:bc
  %-  flip:byt:bcu:bc
  %-  en:der
  :-  %seq
  :~  [%int x.p]
      [%int y.p]
  ==
::  +decode-point: DER-decode elliptic curve point
::
++  decode-point
  |=  h=hexb:bc
  ^-  point
  =/  a=spec:asn1:der
    %-  need
    %-  de:der
    (flip:byt:bcu h)
  ?.  ?=([%seq [%int @] [%int @] ~] a)
    !!
  [x=int.i.seq.a y=int.i.t.seq.a]
::  +extract-signature: parse DER-format signature or fail
::
++  extract-signature
  |=  =signature
  ^-  [r=@ s=@]
  (decode-point signature)
::  +ecdsa-verify: verify sig is a valid signature for pubkey
::
++  ecdsa-verify
  =,  secp256k1:secp:crypto
  |=  [hash=@ sig=[r=@ s=@] =pubkey]
  ^-  ?
  ?|  =(pubkey (ecdsa-raw-recover hash [0 r.sig s.sig]))
      =(pubkey (ecdsa-raw-recover hash [1 r.sig s.sig]))
  ==
::  +check-signature: verify that signature of hash is correct for pubkey
::
++  check-signature
  =,  secp256k1:secp:crypto
  |=  [hash=hexb:bc =signature =pubkey]
  ^-  ?
  =+  n=(dec wid.signature)
  =+  byts=(take:byt:bcu n signature)
  =+  sigh=(drop:byt:bcu n signature)
  ?.  =(sigh 1^0x1)  %.n
  %^    ecdsa-verify
      dat.hash
    (extract-signature byts)
  pubkey
::  +validate-config: validate channel config against some constants
::
++  validate-config
  |=  [config=channel-config =funding=sats:bc]
  ^-  ?
  ?&  ?!  (lth funding-sats min-funding-sats:const)
      ?!  (gth funding-sats max-funding-sats:const)
      ?&  (lte 0 initial-msats.config)
          (lte initial-msats.config (sats-to-msats funding-sats))
      ==
      ?!  (lth reserve-sats.config dust-limit-sats.config)
  ==
::  +address-to-script: not completely correct but enough for our purpose
::
++  address-to-script
  |=  =address:bc
  ^-  hexb:bc
  ?+    -.address  !!
      %bech32
    (bech32-decode +.address)
  ==
--
