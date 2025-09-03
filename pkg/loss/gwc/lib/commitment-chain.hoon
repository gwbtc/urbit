::  commitment-chain.hoon
::
/-  *bolt
::
|_  commits=(list commitment)
::
++  add-commitment
  |=  c=commitment
  ^-  (list commitment)
  (snoc commits c)
::
++  advance
  ^-  (list commitment)
  (tail commits)
::
++  latest
  ^-  (unit commitment)
  ?~  commits  ~
  `(rear commits)
::
++  oldest-unrevoked
  ^-  (unit commitment)
  ?~  commits  ~
  `(head commits)
::
++  has-unacked-commitment
  ^-  ?
  ?~  commits  %.n
  !=((head commits) (rear commits))
--
