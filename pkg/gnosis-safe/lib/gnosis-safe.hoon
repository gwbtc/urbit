/+  *ethereum
=,  abi
|%
++  data-names
  =<  data-name
    |%
    ++  data-name
      $%  [%| name=@t]
          [%& name=@t names=data-name-list]
      ==
    ++  data-name-list  $@(~ [i=data-name t=data-name-list])
    --
++  named-data
  =<  named-data
  |%
  ++  named-data
    $%  [name=@t $<(%tuple data)]
        [name=@t %tuple p=named-data-list]
    ==
  ++  named-data-list  $@(~ [i=named-data t=named-data-list])
  --
++  add-names
  |=  [names=(list data-names) data=(list data)]
  ^-  (list named-data)
  |-
  ?~  data  ~
  ?>  ?=(^ names)
  ?.  ?=([%tuple *] i.data)
    ?>  ?=(%| -.i.names)
    :-  [name.i.names i.data]
    $(data t.data, names t.names)
  :_  $(data t.data, names t.names)
  ?>  ?=(%& -.i.names)
  :*  name.i.names
      %tuple
      $(data p.i.data, names names.i.names)
  ==
--