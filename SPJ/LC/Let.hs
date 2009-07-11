module SPJ.LC.Let (transformLets) where

import SPJ.LC.Abslc
import SPJ.LC.WalkExp

transformLets :: Exp -> Exp
transformLets exp = walkExp transformLets' exp
    where
        transformLets' exp = case exp of
            LetTerm id e1 e2 -> ApplicationTerm (AbstractionTerm [id] e2) e1
            LetrecTerm id e1 e2 -> transformLets' $ 
                LetTerm id (ApplicationTerm (VariableTerm $ Identifier "_Y") (AbstractionTerm [id] e1)) e2
            exp -> exp
