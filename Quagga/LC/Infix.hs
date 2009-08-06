module Quagga.LC.Infix where

import Quagga.LC.Abslc
import Quagga.LC.WalkExp

transformInfixOps :: Exp -> Exp
transformInfixOps exp = walkExp transformInfixOps' exp
    where
        transformInfixOps' exp = case exp of
            InfixTerm e1 (InfixToken tkn) e2 ->
			    let e1' = transformInfixOps e1 in
			    let e2' = transformInfixOps e2 in
                ApplicationTerm (ApplicationTerm (VariableTerm $ Identifier tkn) e1') e2'
            exp -> exp
