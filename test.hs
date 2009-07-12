import SPJ.LC.Runtime


fact =
  ((_Y) (\f ->
         (\n ->
          ((((_IF) (((==) (n)) (1))) (1)) (((*) (n)) ((f) (((-) (n)) (1))))))))


trip =
  (\a ->
   (\b ->
    (\c ->
     (\_unpack ->
      ((((_unpack) (a)) (b)) (c))))))


hundred =
  (((((trip) (((*) (2)) (20))) (40)) (20)) (\x ->
                                            (\y ->
                                             (\z ->
                                              (((+) (((*) (x)) (y))) (z))))))


sqr =
  (\n ->
   (((*) (n)) (n)))


twenty_five =
  (((*) (5)) (5))


main =
  ((putStrLn) ((show) (((+) ((fact) ((sqr) (2)))) (hundred))))
