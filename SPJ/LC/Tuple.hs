module SPJ.LC.Tuple (packTuples, unpackTuples) where

import SPJ.LC.WalkExp
import SPJ.LC.Abslc

packTuples :: Exp -> Exp
packTuples e = walkExp packTuples' e
    where
        packTuples' (TupleTerm terms) = pack terms
        packTuples' e = e
        pack es = AbstractionTerm [unp] $ foldl ApplicationTerm (VariableTerm unp) es

unpackTuples :: Exp -> Exp
unpackTuples e = walkExp unpackTuples' e
    where
        unpackTuples' (LetUntupleTerm (UntupleTerm items) e1 e2) = 
            let innerApp = unpack items e2 in
            ApplicationTerm e1 innerApp
        unpackTuples' e = e
        unpack [(UntupleVar id)] e = AbstractionTerm [id] e
        unpack ((UntupleVar id) : rest) e = AbstractionTerm [id] (unpack rest e)

unp = Identifier "_unpack"
