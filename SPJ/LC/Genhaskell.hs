module SPJ.LC.Genhaskell (genhaskell) where

import Text.PrettyPrint
import SPJ.LC.Abslc
import SPJ.LC.ErrM
type Result = Err Doc

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transIdent :: Ident -> Result
transIdent x = case x of
  Ident str  -> return $ text $ str

transExp :: Exp -> Result
transExp x = case x of
  ConstantStringTerm str  -> return $ text $ show str
  ConstantIntTerm n  -> return $ text $ show n
  VariableTerm id  -> transIdent id
  ApplicationTerm exp0 exp  -> do
    exp0r <- transExp exp0
    exp1r <- transExp exp
    return $ parens $ (parens exp0r) <+> exp1r
  AbstractionTerm id exp  -> do
    expr <- transExp exp
    idr <- transIdent id
    return $ (text "\\") <> idr <+> (text "->") <+> expr

transProgram :: Program -> Result
transProgram x = case x of
  Prog stms  -> do
    stms' <- return $ map transStm stms
    return $ concatDocs "\n\n" (map (\st -> let Ok stm = transStm st in stm) stms)

transStm :: Stm -> Result
transStm x = case x of
  Equality id exp  -> do
    idr <- transIdent id
    expr <- transExp exp
    return $ idr <+> text "=" $+$ (indent expr)

concatDocs :: String -> [Doc] -> Doc
concatDocs seperator items = foldl ($$) empty (punctuate (text seperator) items)

indent = nest 2

genhaskell = transProgram
