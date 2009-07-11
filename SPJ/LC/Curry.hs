module SPJ.LC.Curry (curryExps) where

import SPJ.LC.Abslc
import SPJ.LC.WalkExp

curryExps :: Exp -> Exp
curryExps e = walkExp curry' e
    where
        curry' (AbstractionTerm [id] body) = AbstractionTerm [id] body -- do nothing for single arg funcs
        curry' (AbstractionTerm (id1:ids) body) = AbstractionTerm [id1] (curry' $ AbstractionTerm ids body)
        curry' e = e
