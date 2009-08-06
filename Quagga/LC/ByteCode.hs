module Quagga.LC.ByteCode (encode, decode) where

import Control.Monad
import Data.Binary
import Quagga.LC.Abslc

instance Binary Exp where
    put (ConstantStringTerm s) = put (1 :: Word8) >> put s
    put (ConstantIntTerm i) = put (2 :: Word8) >> put i
    put (ApplicationTerm e1 e2) = put (3 :: Word8) >> put e1 >> put e2
    put (VariableTerm (Identifier id)) = case id of
            "_Y" -> put' 1
            "_S" -> put' 2
            "_I" -> put' 3
            "_K" -> put' 4
            "*" -> put' 5
            "/" -> put' 6
            "+" -> put' 7
            "-" -> put' 8
            "==" -> put' 9
            "_IF" -> put' 10
            sym -> put' 254 >> put sym
        where put' (n :: Word8) = put (4 :: Word8) >> put n
    put bad = error $ "Cannot create bytecode for: " ++ show bad
    get = do
            tag <- getWord8
            case tag of
                1 -> liftM ConstantStringTerm get
                2 -> liftM ConstantIntTerm get
                3 -> liftM2 ApplicationTerm get get
                4 -> do
                    code :: Word8 <- get
                    case code of
                        1 -> var "_Y"
                        2 -> var "_S"
                        3 -> var "_I"
                        4 -> var "_K"
                        5 -> var "*"
                        6 -> var "/"
                        7 -> var "+"
                        8 -> var "-"
                        9 -> var "=="
                        10 -> var "_IF"
                        254 -> do
                            sym <- get
                            return $ VariableTerm (Identifier sym)
                    where var id = return $ VariableTerm (Identifier id)

instance Binary Stm where
    put (Equality (Identifier id) exp) = do
        put (1 :: Word8)
        put id
        put exp
    get = do
        code :: Word8 <- get
        case code of
            1 -> do
                id <- get
                exp <- get
                return $ Equality (Identifier id) exp

instance Binary Program where
    put (Prog stms) = do
        put (1 :: Word8)
        put stms
    get = do
        code :: Word8 <- get
        case code of
            1 -> do
                stms <- get
                return $ Prog stms
