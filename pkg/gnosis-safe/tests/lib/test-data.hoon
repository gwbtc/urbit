/+  *test, *eth-trace
/*  test-data  %json  /data/test-data/json
=/  parsed-data
  ?>  ?=([%a *] test-data)
  ?>  ?=(^ p.test-data)
  ((ar:dejs:format trace:dejs) test-data)
=/  reduced-trace  (reduce-traces parsed-data)
:: ~&  parsed-data
:: ~&  reduced-trace
:: ~&  parsed-data+(lent parsed-data)
|%
++  test-foo
  ;:  weld
    %+  expect-eq
      !>  43
      !>  .*(~ [%6 [%1 1] 0 [%1 43]])
  ==
--