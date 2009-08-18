module Quagga.LC.Graph where

import System.IO.Unsafe
import Data.IORef
import Control.Monad.List
import Control.Monad.Trans
import Quagga.LC.Abslc
import Quagga.LC.ByteCode
import System.IO
import Text.PrettyPrint
import Control.Monad.State

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

-- source graph -> stack
type QuaggaAction = QuaggaGraph -> [IORef QuaggaGraph] -> IO ()

reduceQuaggaGraph :: IORef QuaggaGraph -> IO ()
reduceQuaggaGraph graph =
    do
        graph' <- readIORef graph
        case graph' of
            QApp left right -> do
                (g,s) <- selectRedex graph []
                if enoughArgs (length s) g
                    then do
                        qgReduce g s
                        reduceQuaggaGraph graph
                    else
                        return ()
            _ -> return ()
    where
        enoughArgs count (QBuiltin op) = let Just n = lookup op needed in count >= 1 + (2 * n)
        needed = [
            ("_Y", 2), 
            ("_IF", 3),
            ("_I", 1),
            ("_K", 2),
            ("_S", 3),
            ("_B", 3),
            ("_C", 3),
            ("_SO", 4),
            ("==", 2),
            ("+", 2),
            ("-", 2),
            ("*", 2),
            ("/", 2)
            ]

selectRedex :: IORef QuaggaGraph -> [IORef QuaggaGraph] -> IO (QuaggaGraph, [IORef QuaggaGraph])
selectRedex graph stack = 
    do
        graph' <- readIORef graph
        -- qgDebug $ "selecting redex from graph " ++ show graph'
        case graph' of
            QApp left right -> selectRedex left (right : graph : stack)
            QBuiltin builtin -> return (graph', graph : stack)

qgDebug :: String -> IO ()
qgDebug msg = return () -- putStrLn msg

qgReduce :: QuaggaAction

qgReduce (QBuiltin "_Y") (self:h:parent:stack) =
        qgDebug "Y reduce" >>
        writeIORef parent (QApp h parent)

qgReduce (QBuiltin "_I") (self:arg:parent:_) =
    do
        arg' <- readIORef arg
        qgDebug "I reduce"
        writeIORef parent arg'

qgReduce (QBuiltin "_K") (self:c:_:_:parent:_) =
    do
        c' <- readIORef c
        qgDebug "K reduce"
        writeIORef parent c'

qgReduce (QBuiltin "_S") (self:f:_:g:_:x:parent:_) =
    do
        left <- newIORef $ QApp f x
        right <- newIORef $ QApp g x
        full <- return $ QApp left right
        qgDebug "S reduce"
        writeIORef parent full

qgReduce (QBuiltin "_B") (self:f:_:g:_:x:parent:_) =
    do
        right <- newIORef $ QApp g x
        qgDebug "B reduce"
        writeIORef parent $ QApp f right

qgReduce (QBuiltin "_C") (self:f:_:g:_:x:parent:_) =
    do
        left <- newIORef $ QApp f x
        qgDebug "C reduce"
        writeIORef parent $ QApp left g

qgReduce (QBuiltin "_SO") (self:c:_:f:_:g:_:x:parent:_) =
    do
        gx <- newIORef $ QApp g x
        fx <- newIORef $ QApp f x
        left <- newIORef $ QApp c fx
        qgDebug "SO reduce"
        writeIORef parent $ QApp left gx

qgReduce (QBuiltin "*") (self:a:_:b:parent:_) =
    do
        reduceQuaggaGraph a
        reduceQuaggaGraph b
        QInt a' <- readIORef a
        QInt b' <- readIORef b
        qgDebug "* reduce"
        writeIORef parent $ QInt $ a' * b'

qgReduce (QBuiltin "/") (self:a:_:b:parent:_) =
    do
        reduceQuaggaGraph a
        reduceQuaggaGraph b
        QInt a' <- readIORef a
        QInt b' <- readIORef b
        qgDebug "/ reduce"
        writeIORef parent $ QInt $ a' `div` b'

qgReduce (QBuiltin "+") (self:a:_:b:parent:_) =
    do
        reduceQuaggaGraph a
        reduceQuaggaGraph b
        QInt a' <- readIORef a
        QInt b' <- readIORef b
        qgDebug "+ reduce"
        writeIORef parent $ QInt $ a' + b'

qgReduce (QBuiltin "-") (self:a:_:b:parent:_) =
    do
        reduceQuaggaGraph a
        reduceQuaggaGraph b
        QInt a' <- readIORef a
        QInt b' <- readIORef b
        qgDebug "- reduce"
        writeIORef parent $ QInt $ a' - b'

qgReduce (QBuiltin "==") (self:a:_:b:parent:_) =
    do
        reduceQuaggaGraph a
        reduceQuaggaGraph b
        a' <- readIORef a
        b' <- readIORef b
        qgDebug "== reduce"
        writeIORef parent $ QBoolean $ a' == b'

qgReduce (QBuiltin "_IF") (self:pred:_:ontrue:_:onfalse:parent:_) =
    do
        reduceQuaggaGraph pred
        QBoolean b <- readIORef pred
        qgDebug "IF reduce"
        if b
            then do
                ontrue <- readIORef ontrue
                writeIORef parent ontrue
            else do
                onfalse <- readIORef onfalse
                writeIORef parent onfalse

qgReduce exp stack = error $ "Cannot reduce graph: " ++ show exp ++ ", stack has " ++ show (length stack) ++ " nodes"

instance Show QuaggaGraph where
    show (QString s) = show s
    show (QInt i) = show i
    show (QBuiltin s) = s
    show (QBoolean b) = show b
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

--- everything below is to generate .dot files that can be used to create a visual image of the graph
dotFromGraph :: QuaggaGraph -> Doc
dotFromGraph g = let (id, doc) = evalState (dotFromGraph' g) 0 in (text "digraph Main {" $+$ doc) $$ text "}"

dotFromGraph' :: QuaggaGraph -> State Int (Int, Doc)

dotFromGraph' (QBuiltin name) = mkNode name
dotFromGraph' (QInt i) = mkNode $ show i
dotFromGraph' (QString s) = mkNode $ show s
dotFromGraph' (QApp left right) =
    do
        left' <- return $ unsafePerformIO $ readIORef left
        right' <- return $ unsafePerformIO $ readIORef right
        (lid,ldoc) <- dotFromGraph' left'
        (rid,rdoc) <- dotFromGraph' right'
        (id, doc) <- mkNode "@"
        return $ (id, ldoc $$ rdoc $$ doc $$ connect id lid $$ connect id rid)

connect id1 id2 = text $ show id1 ++ " -> " ++ show id2 ++ ";"

mkNode label = do
    id <- nextNodeId
    return (id, text (show id ++ " [label=\"" ++ label ++ "\"]"))

nextNodeId = do
        nodeId <- get
        put (nodeId + 1)
        return nodeId
