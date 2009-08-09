module Quagga.LC.Graph where

import System.IO.Unsafe
import Data.IORef
import Control.Monad.List
import Control.Monad.Trans
import Quagga.LC.Abslc
import Quagga.LC.ByteCode
import Data.Binary
import System.IO

uniqRef :: Eq a => [IORef a] -> a -> IO ([IORef a], IORef a)
uniqRef env val =
        do
            vals <- sequence $ map readIORef env
            case filter (\(r,v) -> v == val) (zip env vals) of
                [(r,v)] -> return $ (env, r)
                [] -> do
                    r <- newIORef val
                    return (r : env, r)
                _ -> error "non unique uniqRef"

data QuaggaGraph = 
    QString String
    | QInt Integer
	| QBoolean Bool
    | QBuiltin String
    | QApp { leftQGraph :: IORef QuaggaGraph, rightQGraph :: IORef QuaggaGraph }
    deriving (Eq)

getOp :: IORef QuaggaGraph -> IO (String, [IORef QuaggaGraph])
getOp graph = getOp' graph []
    where
    getOp' graph stack = do
        graph' <- readIORef graph
        case graph' of
            (QApp left right) -> getOp' left (right:stack)
            (QBuiltin name) -> return (name, stack)


-- source graph -> stack
type QuaggaAction = QuaggaGraph -> [IORef QuaggaGraph] -> IO ()

reduceQuaggaGraph :: IORef QuaggaGraph -> IO ()
reduceQuaggaGraph graph =
    do
        graph' <- readIORef graph
        case graph' of
            QApp left right -> do
                (g,s) <- selectRedex graph []
                qgReduce g s
                reduceQuaggaGraph graph
            _ -> return ()

selectRedex :: IORef QuaggaGraph -> [IORef QuaggaGraph] -> IO (QuaggaGraph, [IORef QuaggaGraph])
selectRedex graph stack = 
    do
        graph' <- readIORef graph
        case graph' of
            QApp left right -> selectRedex left (right : graph : stack)
            QBuiltin builtin -> return (graph', graph : stack)

qgReduce :: QuaggaAction

qgReduce (QBuiltin "_Y") (self:h:parent:stack) =
    do
        y' <- newIORef $ QBuiltin "_Y"
        y <- newIORef $ QApp y' h
        let full = QApp h y
        writeIORef parent full

qgReduce (QBuiltin "_I") (self:arg:parent:_) =
    do
        arg' <- readIORef arg
        writeIORef parent arg'

qgReduce (QBuiltin "_K") (self:c:_:_:parent:_) =
    do
        c' <- readIORef c
        writeIORef parent c'

qgReduce (QBuiltin "_S") (self:f:_:g:_:x:parent:stack) =
    do
        left <- newIORef $ QApp f x
        right <- newIORef $ QApp g x
        full <- return $ QApp left right
        writeIORef parent full

qgReduce (QBuiltin "*") (self:a:_:b:parent:_) =
	do
		reduceQuaggaGraph a
		reduceQuaggaGraph b
		QInt a' <- readIORef a
		QInt b' <- readIORef b
		writeIORef parent $ QInt $ a' * b'

qgReduce (QBuiltin "/") (self:a:_:b:parent:_) =
	do
		reduceQuaggaGraph a
		reduceQuaggaGraph b
		QInt a' <- readIORef a
		QInt b' <- readIORef b
		writeIORef parent $ QInt $ a' `div` b'

qgReduce (QBuiltin "+") (self:a:_:b:parent:_) =
	do
		reduceQuaggaGraph a
		reduceQuaggaGraph b
		QInt a' <- readIORef a
		QInt b' <- readIORef b
		writeIORef parent $ QInt $ a' + b'

qgReduce (QBuiltin "-") (self:a:_:b:parent:_) =
	do
		reduceQuaggaGraph a
		reduceQuaggaGraph b
		QInt a' <- readIORef a
		QInt b' <- readIORef b
		writeIORef parent $ QInt $ a' - b'

qgReduce (QBuiltin "==") (self:a:_:b:parent:_) =
	do
		reduceQuaggaGraph a
		reduceQuaggaGraph b
		a' <- readIORef a
		b' <- readIORef b
		writeIORef parent $ QBoolean $ a' == b'

qgReduce (QBuiltin "_IF") (self:pred:_:ontrue:_:onfalse:parent:_) =
	do
		reduceQuaggaGraph pred
		QBoolean b <- readIORef pred
		if b
			then do
				ontrue <- readIORef ontrue
				writeIORef parent ontrue
			else do
				onfalse <- readIORef onfalse
				writeIORef parent onfalse

qgReduce exp stack = error $ "Cannot reduce graph: " ++ show exp

instance Show QuaggaGraph where
    show (QString s) = show s
    show (QInt i) = show i
    show (QBuiltin s) = s
    show app@(QApp _ _) = show' 1 app
        where 
            show' level (QApp left right) =
                let left' = (unsafePerformIO $ readIORef left) in
                let right' = (unsafePerformIO $ readIORef right) in
                let nl = level + 1 in
                show' nl left' ++ " <- @" ++ show level ++ " -> " ++ show' nl right'
            show' _ nonapp = show nonapp

type QuaggaEnv = [IORef QuaggaGraph]

qgraphFromExp :: QuaggaEnv -> Exp -> IO (QuaggaEnv, IORef QuaggaGraph)
qgraphFromExp env exp = case exp of
        ConstantStringTerm s -> uniqRef env $ QString s
        ConstantIntTerm i -> uniqRef env $ QInt i
        VariableTerm (Identifier s) -> uniqRef env $ QBuiltin s
        ApplicationTerm e1 e2 -> do
            (env, r1) <- qgraphFromExp env e1
            (env, r2) <- qgraphFromExp env e2
            uniqRef env $ QApp r1 r2
