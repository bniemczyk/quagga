module EasyComb where

class EasyComb a where
        seq_combine     :: a -> a -> a
        initialize      :: a
        build           :: a -> EasyCombBuilder a ()
        runBuild        :: EasyCombBuilder a b -> a

        build a = EasyCombBuilder $ \a -> ((), a)
        runBuild cb = 
            let EasyCombBuilder f = cb in
            let (a, c) = f initialize in
            c

data EasyCombBuilder ct a where
        EasyCombBuilder     :: EasyComb ct => (ct -> (a, ct)) -> EasyCombBuilder ct a
        EasyCombIgnore      :: a -> EasyCombBuilder ct a

instance EasyComb ct => Monad (EasyCombBuilder ct) where
        return a = EasyCombIgnore a
        EasyCombBuilder cb >>= f = EasyCombBuilder $ \ct ->
                let (a, ct') = cb ct in
                case f a of
                    EasyCombBuilder cb' ->
                        let (a', ct'') = cb' ct' in
                        (a', ct' `seq_combine` ct'')
                    EasyCombIgnore a' -> (a', ct')
