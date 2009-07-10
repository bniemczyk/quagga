module SPJ.LC.Infix where

import SPJ.LC.Abslc
import SPJ.LC.WalkExp

transformInfixOps :: Exp -> Exp
transformInfixOps exp = walkExp transformInfixOps' exp
    where
        transformInfixOps' exp = case exp of
            InfixTerm e1 (InfixToken tkn) e2 ->
			    let e1' = transformInfixOps e1 in
			    let e2' = transformInfixOps e2 in
                ApplicationTerm (ApplicationTerm (VariableTerm $ Identifier tkn) e1') e2'
            exp -> exp
