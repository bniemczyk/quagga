import SPJ.LC.Runtime


fact =
  ((_Y) ((((_SO) (_S)) (((_S) (((_S) (((_C) ((_K) (_SO))) (_IF))) (((_C) (((_C) ((_K) (_C))) (==))) (1)))) (((_C) ((_K) (_K))) (1)))) (((_S) (((_C) ((_K) (_S))) (*))) (((_S) (_B)) (((_C) (((_C) ((_K) (_C))) (-))) (1))))))


pack2 =
  ((((_SO) (_S)) (((_S) (((_C) ((_K) (_B))) (_S))) ((((_SO) (_C)) ((((_SO) (_C)) (((_C) ((_K) (_K))) (_C))) ((_K) (_I)))) (_I)))) ((_K) (_K)))


unpack =
  (_I)


mypair =
  (((pack2) (50)) (2))


mymul =
  ((((_SO) (_S)) ((((_SO) (_C)) (((_C) ((_K) (_K))) (*))) (_I))) ((_K) (_I)))


hundred =
  (((unpack) (mypair)) (mymul))


main =
  ((putStrLn) ((show) (((+) ((fact) (5))) (hundred))))
