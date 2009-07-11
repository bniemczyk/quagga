module SPJ.LC.WalkExp (walkExp, iterative) where

import SPJ.LC.Abslc

walkExp :: (Exp -> Exp) -> Exp -> Exp
walkExp fn exp = 
    let walk = walkExp fn in
    case exp of
        PExp e ->  fn $ PExp (walk e)
        ApplicationTerm e1 e2 -> fn $ ApplicationTerm (walk e1) (walk e2)
        AbstractionTerm id exp -> fn $ AbstractionTerm id (walk exp)
        LetTerm id e1 e2 -> fn $ LetTerm id (walk e1) (walk e2)
        LetrecTerm id e1 e2 -> fn $ LetrecTerm id (walk e1) (walk e2)
        InfixTerm e1 iftkn e2 -> fn $ InfixTerm (walk e1) iftkn (walk e2)
        ConditionalTerm e1 e2 e3 -> fn $ ConditionalTerm (walk e1) (walk e2) (walk e3)
        TupleTerm es -> fn $ TupleTerm (map walk es)
        LetUntupleTerm tup e1 e2 -> fn $ LetUntupleTerm tup (walk e1) (walk e2)
        exp -> fn exp

iterative :: Eq a => (a -> a) -> a -> a
iterative fn a = if a == a' then a' else iterative fn a'
    where a' = fn a
