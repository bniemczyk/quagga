module Quagga.LC.Graph where

import Quagga.LC.Abslc

uniqRef :: a -> IORef [IORef a] -> IO (IORef a)
uniqRef val env =
    do
        urenv <- readIORef env
        as <- mapM readIORef env
