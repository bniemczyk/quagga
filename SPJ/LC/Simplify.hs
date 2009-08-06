module SPJ.LC.Simplify where

import SPJ.LC.Let
import SPJ.LC.Abslc
import SPJ.LC.Infix
import SPJ.LC.SK
import SPJ.LC.Conditionals
import SPJ.LC.WalkExp
import SPJ.LC.Tuple
import SPJ.LC.Curry

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
