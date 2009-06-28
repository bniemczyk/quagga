module Guic.Extjs (compile_extjs) where

import Text.PrettyPrint
import Util (join)
import Guic.Compiler
import Guic.Base

indent = nest 1
mybraces doc = lbrace $+$ indent doc $+$ rbrace 
mybrackets doc = lbrack $+$ indent doc $+$ rbrack

sq txt = "'" ++ txt ++ "'"
rmsq txt = reverse $ tail $ reverse $ tail txt

compile_extjs_all ws = 
    let docs = map compile_extjs ws in
    concatDocs "\n\n" docs

compile_extjs :: CWidget -> Doc

compile_extjs (CButton caption actions attrs) = 
    newWidget "Ext.Button" [] (("text", text $ sq caption) : docAttrs attrs)

compile_extjs (CPanel innerW attrs) = 
    newWidget "Ext.Panel" [] $ docAttrs attrs ++ [("items", mkItems [innerW])]

compile_extjs (CLabel lbl _) = mybraces $ text $ "html: '<span>" ++ lbl ++ "</span>'"

compile_extjs (CVLayout ws attrs) =
        newWidget "Ext.Panel" [] allattrs
    where
        allattrs = docAttrs attrs ++ [("layout", text "'anchor'"), ("items", mkItems ws)]

compile_extjs (CHLayout ws attrs) =
        newWidget "Ext.Panel" [] allattrs
    where
        allattrs = docAttrs attrs ++ [("layout", text "'column'"), ("items", mkItems ws)]

docAttrs attrs = [(a, text $ sq b) | (a, b) <- attrs]

newWidget :: String -> [String] -> [(String, Doc)] -> Doc
newWidget wtype wparams wconfigopts =
        vwrap $ 
        (text $ "new " ++ wtype) 
        <> (parens (
            (text $ join "," wparams)
            <> ( mybraces $ 
                (concatDocs "," configOpts))))
    where
        configOpts = map configOpt wconfigopts
        configOpt (a,b) = (text a) <> (text ":") <+> b
        vwrap doc = case lookup "id" wconfigopts of
            Nothing -> doc
            Just id -> text "var" <+> text (rmsq (show id)) <+> text "=" <+> ( doc <> text ";")

mkItems :: [CWidget] -> Doc
mkItems ws = 
        let wsdocs = map compile_extjs ws in
        mybrackets $ concatDocs "," wsdocs

concatDocs :: String -> [Doc] -> Doc
concatDocs seperator items = foldl ($$) empty (punctuate (text seperator) items)
