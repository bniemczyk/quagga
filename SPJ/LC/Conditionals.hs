module SPJ.LC.Conditionals where

import SPJ.LC.WalkExp
import SPJ.LC.Abslc

transformConditionals :: Exp -> Exp
transformConditionals exp = walkExp transformConditionals' exp where
    transformConditionals' (ConditionalTerm pred ontrue onfalse) =
        ApplicationTerm (ApplicationTerm (ApplicationTerm (VariableTerm $ Identifier "_IF") pred) ontrue) onfalse
    transformConditionals' e = e
