module SPJ.LC.Simplify where

import SPJ.LC.Let
import SPJ.LC.Abslc
import SPJ.LC.Infix
import SPJ.LC.SK
import SPJ.LC.Conditionals
import SPJ.LC.WalkExp
import SPJ.LC.Tuple
import SPJ.LC.Curry

simplifyExp = 
        -- convert all expressions to nothing but applications of a fixed set of combinators
        -- this should run last (and may be skipped while debugging, because it makes the
        -- output hard to understand)
        -- removeAbstractions . 

        -- beta reduction
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
        reduce (ApplicationTerm (AbstractionTerm [(Identifier id)] body) arg) = reduce' id body arg
        reduce e = e
        reduce' id body arg = case body of
            VariableTerm (Identifier id') -> if id' == id then arg else VariableTerm $ Identifier id'
            AbstractionTerm [(Identifier id')] abstraction -> if id' == id
                then AbstractionTerm [(Identifier id')] abstraction
                else AbstractionTerm [(Identifier id')] $ reduce' id abstraction arg
            ApplicationTerm p q -> ApplicationTerm (reduce' id p arg) (reduce' id q arg)
            e -> e

simplifyStmt (Equality id e) = Equality id $ simplifyExp e

simplifyProg (Prog stms) = Prog $ map simplifyStmt stms
