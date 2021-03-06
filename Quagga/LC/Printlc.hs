{-# OPTIONS -fno-warn-incomplete-patterns #-}
module Quagga.LC.Printlc where

-- pretty-printer generated by the BNF converter

import Quagga.LC.Abslc
import Char

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print InfixToken where
  prt _ (InfixToken i) = doc (showString i)


instance Print Identifier where
  prt _ (Identifier i) = doc (showString i)
  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])



instance Print Program where
  prt i e = case e of
   Prog stms -> prPrec i 0 (concatD [prt 0 stms])


instance Print Stm where
  prt i e = case e of
   Equality identifier exp -> prPrec i 0 (concatD [prt 0 identifier , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print UntupleItem where
  prt i e = case e of
   UntupleVar identifier -> prPrec i 0 (concatD [prt 0 identifier])
   UntupleTuple untuple -> prPrec i 0 (concatD [prt 0 untuple])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Untuple where
  prt i e = case e of
   UntupleTerm untupleitems -> prPrec i 0 (concatD [doc (showString "{") , prt 0 untupleitems , doc (showString "}")])


instance Print Exp where
  prt i e = case e of
   PExp exp -> prPrec i 5 (concatD [doc (showString "(") , prt 0 exp , doc (showString ")")])
   TupleTerm exps -> prPrec i 5 (concatD [doc (showString "{") , prt 0 exps , doc (showString "}")])
   ConstantStringTerm str -> prPrec i 5 (concatD [prt 0 str])
   ConstantIntTerm n -> prPrec i 5 (concatD [prt 0 n])
   ConstantTrue  -> prPrec i 5 (concatD [doc (showString "true")])
   ConstantFalse  -> prPrec i 5 (concatD [doc (showString "false")])
   VariableTerm identifier -> prPrec i 5 (concatD [prt 0 identifier])
   ArityTerm  -> prPrec i 5 (concatD [doc (showString "arity")])
   ApplicationTerm exp0 exp -> prPrec i 4 (concatD [prt 0 exp0 , prt 5 exp])
   AbstractionTerm identifiers exp -> prPrec i 1 (concatD [doc (showString "lambda") , prt 0 identifiers , doc (showString ".") , prt 0 exp])
   LetTerm identifier exp0 exp -> prPrec i 1 (concatD [doc (showString "let") , prt 0 identifier , doc (showString "=") , prt 0 exp0 , doc (showString "in") , prt 0 exp])
   LetUntupleTerm untuple exp0 exp -> prPrec i 1 (concatD [doc (showString "let") , prt 0 untuple , doc (showString "=") , prt 0 exp0 , doc (showString "in") , prt 0 exp])
   LetrecTerm identifier exp0 exp -> prPrec i 1 (concatD [doc (showString "letrec") , prt 0 identifier , doc (showString "=") , prt 0 exp0 , doc (showString "in") , prt 0 exp])
   ConditionalTerm exp0 exp1 exp -> prPrec i 2 (concatD [doc (showString "if") , prt 0 exp0 , doc (showString "then") , prt 0 exp1 , doc (showString "else") , prt 0 exp])
   InfixTerm exp0 infixtoken exp -> prPrec i 3 (concatD [prt 0 exp0 , prt 0 infixtoken , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])


