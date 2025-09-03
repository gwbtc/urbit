/-  spider, volt
/+  strand, io=strandio
=,  strand=strand:spider
|%
++  poke-volt
  |=  =command:volt
  ?>  =(%add-invoice -.command)
  (poke-our:io %volt %volt-command !>(command))
++  watch-volt
  =/  m  (strand ,~)
  ;<  =bowl:spider  bind:m  get-bowl:io
  (watch-our:io /volt %volt /latest-invoice)
++  take-result
  (take-fact:io /volt)
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
=+  !<(=command:volt arg)
;<  ~  bind:m  watch-volt
;<  ~  bind:m  (poke-volt command)
;<  =cage  bind:m  take-result
?>  =(%volt-update p.cage)
(pure:m q.cage)
