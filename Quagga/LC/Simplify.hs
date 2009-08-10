module Quagga.LC.Simplify where

import Quagga.LC.Let
import Quagga.LC.Abslc
import Quagga.LC.Infix
import Quagga.LC.SK
import Quagga.LC.Conditionals
import Quagga.LC.WalkExp
import Quagga.LC.Tuple
import Quagga.LC.Curry
import Quagga.LC.ByteCode

simplifyExp = walkExp . iterative $
        -- convert all expressions to nothing but applications of a fixed set of combinators
        -- this should run last (and may be skipped while debugging, because it makes the
        -- output hard to understand)
        removeAbstractions . 

        -- beta reduction, but only reductions that are safe and don't stop
        -- us from being fully lazy
        (iterative . walkExp $ reduce) .

        -- infix operations changed to prefix function applications
        transformInfixOps . 

        -- remove lets
        transformLets . 

        -- turn if then else into code using the _IF combinator
        transformConditionals . 

        -- translates { foo, bar } into simple lambda calculus
        packTuples . unpackTuples .

        -- change all multi-variable functions into curried single-var functions
        curryExps .

        -- after it's been parsed, the parenthesis are useless
        (walkExp $ removeParens)
    where
        removeParens (PExp e) = e
        removeParens e = e
        reduce 
            (ApplicationTerm 
                (ApplicationTerm 
                    (VariableTerm (Identifier id)) 
                    (ConstantIntTerm i1)) 
                (ConstantIntTerm i2)) = case id of
                    "*" -> ConstantIntTerm $ i1 * i2
                    "/" -> ConstantIntTerm $ i1 `div` i2
                    "+" -> ConstantIntTerm $ i1 + i2
                    "-" -> ConstantIntTerm $ i1 - i2
                    id -> ApplicationTerm 
                        (ApplicationTerm (VariableTerm $ Identifier id) (ConstantIntTerm i1)) 
                        (ConstantIntTerm i2)
        reduce e = e

simplifyStmt (Equality id e) = Equality id $ simplifyExp e

simplifyProg (Prog stms) = Prog $ map simplifyStmt stms

builtins = ["_Y", "_S", "_I", "_K", "*", "/", "+", "-", "==", "_IF", "_B", "_C", "_SO"]

getStandaloneMain :: Program -> Exp
getStandaloneMain (Prog stmts) = walkExp replaceVars $ findexp "main"
    where
        findexp expName = case filter (\(Equality (Identifier id) _) -> id == expName) stmts of
            [(Equality _ e)] -> walkExp replaceVars e
            [] -> error $ "Could not find function " ++ expName
            _ -> error $ "multiple definitions of function " ++ expName
        replaceVars (VariableTerm (Identifier id)) = case [ b | b <- builtins, b == id ] of
            [primitive] -> VariableTerm (Identifier id)
            [] -> findexp id
        replaceVars nonvar = nonvar
