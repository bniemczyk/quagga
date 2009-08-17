module Quagga.LC.Tuple (packTuples, unpackTuples) where

import Quagga.LC.WalkExp
import Quagga.LC.Abslc

packTuples :: Exp -> Exp
packTuples e = walkExp packTuples' e
    where
        packTuples' (TupleTerm terms) = pack terms
        packTuples' e = e
        pack es = 
            AbstractionTerm [ar] $
                ApplicationTerm
                    (ApplicationTerm 
                        (VariableTerm ar)
                        (ConstantIntTerm (toInteger $ length es)))
                    (AbstractionTerm [unp] $ foldl ApplicationTerm (VariableTerm unp) es)

unpackTuples :: Exp -> Exp
unpackTuples e = walkExp unpackTuples' e
    where
        unpackTuples' (LetUntupleTerm (UntupleTerm items) e1 e2) = 
            let innerApp = unpack items e2 in
            let wrap ia = (AbstractionTerm [ar] (AbstractionTerm [unp] (ApplicationTerm (VariableTerm unp) ia))) in
            ApplicationTerm e1 $ wrap innerApp
        unpackTuples' e = e
        unpack [(UntupleVar id)] e = AbstractionTerm [id] e
        unpack ((UntupleVar id) : rest) e = AbstractionTerm [id] (unpack rest e)

unp = Identifier "_unpack"
ar = Identifier "_arity"
