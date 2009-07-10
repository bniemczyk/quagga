module SPJ.LC.SK where

import SPJ.LC.Abslc
import SPJ.LC.WalkExp

removeAbstractions :: Exp -> Exp
removeAbstractions exp = (walkExp removeAbstractions') exp
    where
        removeAbstractions' (AbstractionTerm id body) = case body of
            ApplicationTerm e1 e2 -> s id e1 e2
            VariableTerm v -> if v == id 
                then i
                else k $ VariableTerm v
            ConstantStringTerm s -> k $ ConstantStringTerm s
            ConstantIntTerm i -> k $ ConstantIntTerm i

        removeAbstractions' exp = exp

        s id e1 e2 = ApplicationTerm 
            (ApplicationTerm (VariableTerm $ Identifier "_S") $ removeAbstractions $ AbstractionTerm id e1) 
            (removeAbstractions $ AbstractionTerm id e2)

        i = VariableTerm $ Identifier "_I"

        k c = ApplicationTerm (VariableTerm $ Identifier "_K") c
