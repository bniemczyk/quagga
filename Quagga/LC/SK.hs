module Quagga.LC.SK (removeAbstractions) where

import Quagga.LC.Abslc
import Quagga.LC.WalkExp

removeAbstractions :: Exp -> Exp
removeAbstractions exp = optimize $ (walkExp removeAbstractions') exp
    where
        removeAbstractions' (AbstractionTerm (id:[]) body) = case body of
            ApplicationTerm e1 e2 -> s [id] e1 e2
            VariableTerm v -> if v == id 
                then i
                else k $ VariableTerm v
            ConstantStringTerm s -> k $ ConstantStringTerm s
            ConstantIntTerm i -> k $ ConstantIntTerm i
            ConstantTrue -> k $ ConstantTrue
            ConstantFalse -> k $ ConstantFalse
            TupleTerm terms -> k $ TupleTerm $ map removeAbstractions terms
            other -> error $ "do not know how to remove abstractions from " ++ show other

        removeAbstractions' exp = exp

        s id e1 e2 = ApplicationTerm 
            (ApplicationTerm (VariableTerm $ Identifier "_S") $ removeAbstractions $ AbstractionTerm id e1) 
            (removeAbstractions $ AbstractionTerm id e2)

        i = VariableTerm $ Identifier "_I"

        k c = ApplicationTerm (VariableTerm $ Identifier "_K") c

optimize :: Exp -> Exp
optimize = iterative . walkExp $ skk_opt . b_opt . c_opt . s_opt . i_opt

skk_opt (ApplicationTerm
    (ApplicationTerm (VariableTerm (Identifier "_S")) (ApplicationTerm (VariableTerm (Identifier "_K")) p))
    (ApplicationTerm (VariableTerm (Identifier "_K")) q)) =
        ApplicationTerm (VariableTerm (Identifier "_K")) (ApplicationTerm p q)
skk_opt e = e

b_opt (ApplicationTerm
    (ApplicationTerm (VariableTerm (Identifier "_S")) (ApplicationTerm (VariableTerm (Identifier "_K")) p))
    q) =
        ApplicationTerm (ApplicationTerm (VariableTerm (Identifier "_B")) p) q
b_opt (ApplicationTerm (ApplicationTerm (VariableTerm (Identifier "_B")) p) (VariableTerm (Identifier "_I"))) = p
b_opt e = e

c_opt (ApplicationTerm
    (ApplicationTerm (VariableTerm (Identifier "_S")) p)
    (ApplicationTerm (VariableTerm (Identifier "_K")) q)) = 
        ApplicationTerm (ApplicationTerm (VariableTerm (Identifier "_C")) p) q
c_opt e = e

s_opt (ApplicationTerm
    (ApplicationTerm 
        (VariableTerm (Identifier "_S")) 
        (ApplicationTerm (ApplicationTerm (VariableTerm (Identifier "_B")) x) y))
        z) = (ApplicationTerm
                (ApplicationTerm (ApplicationTerm (VariableTerm (Identifier "_SO")) x) y)
                z)
s_opt e = e

i_opt (ApplicationTerm (VariableTerm (Identifier "_I")) x) = x
i_opt e = e
