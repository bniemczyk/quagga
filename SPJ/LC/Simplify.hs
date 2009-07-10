module SPJ.LC.Simplify where

import SPJ.LC.Let
import SPJ.LC.Abslc
import SPJ.LC.Infix
import SPJ.LC.SK
import SPJ.LC.Conditionals
import SPJ.LC.WalkExp

simplifyExp = 
        removeAbstractions . 
        (iterative . walkExp $ reduce) .
        transformInfixOps . 
        transformLets . 
        transformConditionals . 
        (iterative . walkExp $ removeParens)
    where
        removeParens (PExp e) = e
        removeParens e = e
        reduce (ApplicationTerm (AbstractionTerm (Identifier id) body) arg) = reduce' id body arg
        reduce e = e
        reduce' id body arg = case body of
            VariableTerm (Identifier id') -> if id' == id then arg else VariableTerm $ Identifier id'
            AbstractionTerm (Identifier id') abstraction -> if id' == id
                then AbstractionTerm (Identifier id') abstraction
                else AbstractionTerm (Identifier id') $ reduce' id abstraction arg
            ApplicationTerm p q -> ApplicationTerm (reduce' id p arg) (reduce' id q arg)
            e -> e

simplifyStmt (Equality id e) = Equality id $ simplifyExp e

simplifyProg (Prog stms) = Prog $ map simplifyStmt stms
