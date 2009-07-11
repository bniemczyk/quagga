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
      ((((_unpack) (b)) (a)) (c))))))


hundred =
  (((((trip) (2)) (40)) (20)) (\x ->
                               (\y ->
                                (\z ->
                                 (((+) (((*) (x)) (y))) (z))))))


main =
  ((putStrLn) ((show) (((+) ((fact) (5))) (hundred))))
