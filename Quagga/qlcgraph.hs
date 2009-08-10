module Main where

import IO
import System.IO
import System
import Data.IORef

import Quagga.LC.Abslc
import Quagga.LC.ByteCode
import Quagga.LC.Simplify
import Quagga.LC.Graph

run args = do
    prog <- loadBytecodeFiles args
    let exp = getStandaloneMain prog
    (qgenv, graphref) <- qgraphFromExp [] exp
    graph <- readIORef graphref
    graphdot <- return $ dotFromGraph graph
    putStrLn $ show graphdot
    
main = do
    args <- getArgs
    run args
