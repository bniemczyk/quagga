-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module Quagga.LC.Parlc where
import Quagga.LC.Abslc
import Quagga.LC.Lexlc
import Quagga.LC.ErrM
}

%name pProgram Program

-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype { Token }

%token 
 ';' { PT _ (TS ";") }
 ',' { PT _ (TS ",") }
 '=' { PT _ (TS "=") }
 '{' { PT _ (TS "{") }
 '}' { PT _ (TS "}") }
 '(' { PT _ (TS "(") }
 ')' { PT _ (TS ")") }
 '.' { PT _ (TS ".") }
 'else' { PT _ (TS "else") }
 'false' { PT _ (TS "false") }
 'if' { PT _ (TS "if") }
 'in' { PT _ (TS "in") }
 'lambda' { PT _ (TS "lambda") }
 'let' { PT _ (TS "let") }
 'letrec' { PT _ (TS "letrec") }
 'then' { PT _ (TS "then") }
 'true' { PT _ (TS "true") }

L_quoted { PT _ (TL $$) }
L_integ  { PT _ (TI $$) }
L_InfixToken { PT _ (T_InfixToken $$) }
L_Identifier { PT _ (T_Identifier $$) }
L_err    { _ }


%%

String  :: { String }  : L_quoted { $1 }
Integer :: { Integer } : L_integ  { (read $1) :: Integer }
InfixToken    :: { InfixToken} : L_InfixToken { InfixToken ($1)}
Identifier    :: { Identifier} : L_Identifier { Identifier ($1)}

Program :: { Program }
Program : ListStm { Prog (reverse $1) } 


ListStm :: { [Stm] }
ListStm : {- empty -} { [] } 
  | ListStm Stm ';' { flip (:) $1 $2 }


ListExp :: { [Exp] }
ListExp : {- empty -} { [] } 
  | Exp { (:[]) $1 }
  | Exp ',' ListExp { (:) $1 $3 }


ListUntupleItem :: { [UntupleItem] }
ListUntupleItem : {- empty -} { [] } 
  | UntupleItem { (:[]) $1 }
  | UntupleItem ',' ListUntupleItem { (:) $1 $3 }


ListIdentifier :: { [Identifier] }
ListIdentifier : {- empty -} { [] } 
  | ListIdentifier Identifier { flip (:) $1 $2 }


Stm :: { Stm }
Stm : Identifier '=' Exp { Equality $1 $3 } 


UntupleItem :: { UntupleItem }
UntupleItem : Identifier { UntupleVar $1 } 
  | Untuple { UntupleTuple $1 }


Untuple :: { Untuple }
Untuple : '{' ListUntupleItem '}' { UntupleTerm $2 } 


Exp5 :: { Exp }
Exp5 : '(' Exp ')' { PExp $2 } 
  | '{' ListExp '}' { TupleTerm $2 }
  | String { ConstantStringTerm $1 }
  | Integer { ConstantIntTerm $1 }
  | 'true' { ConstantTrue }
  | 'false' { ConstantFalse }
  | Identifier { VariableTerm $1 }
  | '(' Exp ')' { $2 }


Exp4 :: { Exp }
Exp4 : Exp Exp5 { ApplicationTerm $1 $2 } 
  | Exp5 { $1 }


Exp1 :: { Exp }
Exp1 : 'lambda' ListIdentifier '.' Exp { AbstractionTerm (reverse $2) $4 } 
  | 'let' Identifier '=' Exp 'in' Exp { LetTerm $2 $4 $6 }
  | 'let' Untuple '=' Exp 'in' Exp { LetUntupleTerm $2 $4 $6 }
  | 'letrec' Identifier '=' Exp 'in' Exp { LetrecTerm $2 $4 $6 }
  | Exp2 { $1 }


Exp2 :: { Exp }
Exp2 : 'if' Exp 'then' Exp 'else' Exp { ConditionalTerm $2 $4 $6 } 
  | Exp3 { $1 }


Exp3 :: { Exp }
Exp3 : Exp InfixToken Exp { InfixTerm $1 $2 $3 } 
  | Exp4 { $1 }


Exp :: { Exp }
Exp : Exp1 { $1 } 



{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map prToken (take 4 ts))

myLexer = tokens
}

