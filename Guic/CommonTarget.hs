--- this is required because we superclass EasyComb with CommonTargetWidget
--- so if there are any other instances of EasyComb the behaviour is undefined
{-# LANGUAGE UndecidableInstances #-}

#ifdef ShowWarnings
#warning using undecidable instances ... there cannot be any other instances of EasyComb
#endif

module Guic.CommonTarget where

import Text.PrettyPrint
import EasyComb

class Eq a => CommonTargetValue a where
    value_repr              :: a -> Doc
    get_metadata            :: a -> String -> Maybe b
    add_metadata            :: a -> String -> b -> a

class CommonTargetValue a => CommonTargetWidget a where
    get_inner_widgets       :: (CommonTargetWidget b) => a -> Maybe [b]
    insert_widget           :: a -> a -> a

-- instance CommonTargetWidget a => EasyComb a where
--    seq_combine = insert_widget
--    initialize = fail "fdksl"

class CommonTargetWidget a => ParamTargetWidget a where
    get_params              :: CommonTargetValue b => a -> [b]

find_inner_widgets pred w =
        let front = if pred w then [w] else [] in
        case get_inner_widgets w of
            Nothing -> front
            Just ws -> concat [ find_inner_widgets pred w | w <- ws ]
