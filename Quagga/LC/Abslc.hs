module Quagga.LC.Abslc where

-- Haskell module generated by the BNF converter

newtype InfixToken = InfixToken String deriving (Eq,Ord,Show)
newtype Identifier = Identifier String deriving (Eq,Ord,Show)
data Program =
   Prog [Stm]
  deriving (Eq,Ord,Show)

data Stm =
   Equality Identifier Exp
  deriving (Eq,Ord,Show)

data UntupleItem =
   UntupleVar Identifier
 | UntupleTuple Untuple
  deriving (Eq,Ord,Show)

data Untuple =
   UntupleTerm [UntupleItem]
  deriving (Eq,Ord,Show)

data Exp =
   PExp Exp
 | TupleTerm [Exp]
 | ConstantStringTerm String
 | ConstantIntTerm Integer
 | ConstantTrue
 | ConstantFalse
 | VariableTerm Identifier
 | ArityTerm
 | ApplicationTerm Exp Exp
 | AbstractionTerm [Identifier] Exp
 | LetTerm Identifier Exp Exp
 | LetUntupleTerm Untuple Exp Exp
 | LetrecTerm Identifier Exp Exp
 | ConditionalTerm Exp Exp Exp
 | InfixTerm Exp InfixToken Exp
  deriving (Eq,Ord,Show)

