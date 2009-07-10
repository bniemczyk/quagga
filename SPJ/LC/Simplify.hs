module SPJ.LC.Simplify where

import SPJ.LC.Let
import SPJ.LC.Abslc
import SPJ.LC.Infix
import SPJ.LC.SK
import SPJ.LC.Conditionals
import SPJ.LC.WalkExp

simplifyExp = 
        removeAbstractions . 
        transformInfixOps . 
        transformLets . 
        transformConditionals . 
        (walkExp removeParens)
    where
        removeParens (PExp e) = e
        removeParens e = e

simplifyStmt (Equality id e) = Equality id $ simplifyExp e

simplifyProg (Prog stms) = Prog $ map simplifyStmt stms
