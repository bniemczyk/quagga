module Guic.Compiler where

import Guic.Base

type Attributes = [(String, String)]

data CWidget where
        CButton     :: String -> [Action] -> Attributes -> CWidget
        CPanel      :: CWidget -> Attributes -> CWidget
        CLabel      :: String -> Attributes -> CWidget
        CForm       :: Form -> Attributes -> CWidget
        CGrid       :: Grid -> Attributes -> CWidget
        CVLayout    :: [CWidget] -> Attributes -> CWidget
        CHLayout    :: [CWidget] -> Attributes -> CWidget
    deriving (Eq, Show, Read)
    
compile_widget  :: Widget -> CWidget
compile_widget w =
        let CompiledWidget widget attrs = compile_widget' w in
        case widget of
            ButtonWidget caption onClick -> CButton caption onClick attrs
            PanelWidget w -> CPanel (compile_widget w) attrs
            LabelWidget str -> CLabel str attrs
            FormContainer frm -> CForm frm attrs
            GridContainer grd -> CGrid grd attrs
            HLayoutContainer ws -> CHLayout (map compile_widget ws) attrs
            VLayoutContainer ws -> CVLayout (map compile_widget ws) attrs
    where
        compile_widget' :: Widget -> Widget

        compile_widget' (CompiledWidget a b) = CompiledWidget a b

        compile_widget' (HLayoutContainer ws) = CompiledWidget 
            (HLayoutContainer $ map compile_widget' ws)
            []

        compile_widget' (VLayoutContainer ws) = CompiledWidget
            (VLayoutContainer $ map compile_widget' ws)
            []

        compile_widget' (AttrContainer (AttributeAttachment name value innerObject)) = 
            let CompiledWidget w atts = compile_widget' innerObject in
            CompiledWidget w ((name,value) : atts)
        
        compile_widget' w = CompiledWidget w []
