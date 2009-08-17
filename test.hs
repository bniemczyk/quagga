import Quagga.LC.Runtime


trip =
  (\a ->
   (\b ->
    (\c ->
     (\_arity ->
      (((_arity) (3)) (\_unpack ->
                       ((((_unpack) (a)) (b)) (c))))))))


hundred =
  (((((trip) (2)) (40)) (20)) (\_arity ->
                               (\_unpack ->
                                ((_unpack) (\x ->
                                            (\y ->
                                             (\z ->
                                              (((+) (((*) (x)) (y))) (z)))))))))


nil =
  (\_arity ->
   (((_arity) (0)) (\_unpack ->
                    (_unpack))))


cons =
  (\e ->
   (\lst ->
    (\_arity ->
     (((_arity) (2)) (\_unpack ->
                      (((_unpack) (e)) (lst)))))))


head =
  (\lst ->
   ((lst) (\_arity ->
           (\_unpack ->
            ((_unpack) (\h ->
                        (\t ->
                         (h))))))))


tail =
  (\lst ->
   ((lst) (\_arity ->
           (\_unpack ->
            ((_unpack) (\h ->
                        (\t ->
                         (t))))))))


map =
  (\f ->
   (\lst ->
    ((((_IF) (((==) (lst)) (nil))) (nil)) ((lst) (\_arity ->
                                                  (\_unpack ->
                                                   ((_unpack) (\h ->
                                                               (\t ->
                                                                (((cons) ((f) (h))) (((map) (f)) (t))))))))))))


or =
  (\a ->
   (\b ->
    ((((_IF) (a)) (True)) (b))))


naturals =
  ((\nats ->
    ((nats) (1))) ((_Y) (\nats ->
                         (\n ->
                          (((cons) (n)) ((nats) (((+) (n)) (1))))))))


evens =
  (((map) (\n ->
           (((*) (n)) (2)))) (naturals))


take =
  ((\tak ->
    (tak)) ((_Y) (\tak ->
                  (\n ->
                   (\lst ->
                    ((((_IF) (((==) (n)) (1))) (((cons) ((head) (lst))) (nil))) (((cons) ((head) (lst))) (((tak) (((-) (n)) (1))) ((tail) (lst))))))))))


len =
  ((\len_ ->
    (len_)) ((_Y) (\len_ ->
                   (\lst ->
                    ((((_IF) (((==) (lst)) (\_arity ->
                                            (((_arity) (0)) (\_unpack ->
                                                             (_unpack)))))) (0)) (((+) (1)) ((len_) ((tail) (lst)))))))))


foldr =
  ((\zw ->
    (zw)) ((_Y) (\zw ->
                 (\f ->
                  (\init ->
                   (\lst ->
                    ((((_IF) (((==) (lst)) (nil))) (init)) (((f) ((head) (lst))) ((((zw) (f)) (init)) ((tail) (lst)))))))))))


foldl =
  ((\fl ->
    (fl)) ((_Y) (\fl ->
                 (\f ->
                  (\init ->
                   (\lst ->
                    ((((_IF) (((==) (lst)) (nil))) (init)) ((lst) (\_arity ->
                                                                   (\_unpack ->
                                                                    ((_unpack) (\h ->
                                                                                (\t ->
                                                                                 ((((fl) (f)) (((f) (init)) (h))) (t)))))))))))))))


sum =
  (((foldl) (\x ->
             (\y ->
              (((+) (x)) (y))))) (0))


product =
  (((foldl) (\x ->
             (\y ->
              (((*) (x)) (y))))) (1))


fact =
  (\n ->
   ((product) (((take) (n)) (naturals))))


fastfact =
  ((\f ->
    (f)) ((_Y) (\f ->
                (\n ->
                 ((((_IF) (((==) (n)) (1))) (1)) (((*) (n)) ((f) (((-) (n)) (1)))))))))


main =
  ((\_arity ->
    (((_arity) (2)) (\_unpack ->
                     (((_unpack) (3)) (4))))) (\_arity ->
                                               (\_unpack ->
                                                ((_unpack) (\a ->
                                                            (\b ->
                                                             (((+) (a)) (b))))))))
