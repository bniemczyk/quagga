module SPJ.LC.Genhaskell (genhaskell) where

import Text.PrettyPrint
import SPJ.LC.Abslc
import SPJ.LC.ErrM
type Result = Err Doc

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transIdentifier :: Identifier -> Result
transIdentifier x = case x of
  Identifier str  -> return $ text $ str

transExp :: Exp -> Result
transExp x = do
    expr <- case x of
      PExp exp -> do
        expr <- transExp exp
        return expr
      ConstantStringTerm str  -> return $ text $ show str
      ConstantIntTerm n  -> return $ text $ show n
      VariableTerm id  -> transIdentifier id
      ApplicationTerm exp0 exp  -> do
        exp0r <- transExp exp0
        exp1r <- transExp exp
        return $ exp0r <+> exp1r
      AbstractionTerm id exp  -> do
        expr <- transExp exp
        idr <- transIdentifier id
        return $ (text "\\") <> idr <+> (text "->") $$ expr
      ConditionalTerm pred ontrue onfalse -> do
        pred' <- transExp pred
        ontrue' <- transExp ontrue
        onfalse' <- transExp onfalse
        return $ (text "if") <+> pred' $$ (text "then") <+> ontrue' $$ (text "else") <+> onfalse'
      exp -> failure exp
    return $ parens expr

transProgram :: Program -> Result
transProgram x = case x of
  Prog stms  -> do
    stms' <- return $ map transStm stms
    runtime' <- return $ text "import SPJ.LC.Runtime"
    return $ concatDocs "\n\n" (runtime' : (map (\st -> let Ok stm = transStm st in stm) stms))

transStm :: Stm -> Result
transStm x = case x of
  Equality id exp  -> do
    idr <- transIdentifier id
    expr <- transExp exp
    return $ idr <+> text "=" $+$ (indent expr)

concatDocs :: String -> [Doc] -> Doc
concatDocs seperator items = foldl ($$) empty (punctuate (text seperator) items)

indent = nest 2

genhaskell = transProgram
