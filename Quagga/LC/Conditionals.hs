module Quagga.LC.Conditionals where

import Quagga.LC.WalkExp
import Quagga.LC.Abslc

transformConditionals :: Exp -> Exp
transformConditionals exp = walkExp transformConditionals' exp where
    transformConditionals' (ConditionalTerm pred ontrue onfalse) =
        ApplicationTerm (ApplicationTerm (ApplicationTerm (VariableTerm $ Identifier "_IF") pred) ontrue) onfalse
    transformConditionals' e = e
