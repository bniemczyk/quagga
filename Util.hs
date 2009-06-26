module Util where

import System
import System.IO.Unsafe

check_all :: (a -> Bool) -> [a] -> Bool
check_all _ [] = True
check_all fn (x:xs) = if (fn x)
    then check_all fn xs
    else False

utf16toutf8 [] = []
utf16toutf8 (x : _ : xs) = x : utf16toutf8 xs

just :: Maybe a -> a
just (Just x) = x

debug :: Show a => String -> a -> a
debug msg x = unsafePerformIO (putStr (msg ++ ": ") >> print (show x ++ "\n") >> return x)

mor :: Maybe a -> Maybe a -> Maybe a
mor x y = case x of
    Just _ -> x
    Nothing -> y

swap :: (a -> b -> c) -> (b -> a -> c)
swap f = \b -> \a -> f a b

dict_replace :: Eq a => a -> b -> [(a,b)] -> [(a,b)]
dict_replace _ _ [] = []
dict_replace k v ((k',v'):rest)
    | k' == k = (k,v) : dict_replace k v rest
    | otherwise = (k',v') : dict_replace k v rest

dict_replace_once :: Eq a => a -> b -> [(a,b)] -> [(a,b)]
dict_replace_once _ _ [] = []
dict_replace_once k v ((k',v'):rest)
    | k' == k = (k,v) : rest
    | otherwise = (k',v') : dict_replace_once k v rest

keys :: [(a, b)] -> [a]
keys = map $ \(k,v) -> k

values :: [(a, b)] -> [b]
values = map $ \(k,v) -> v

uniq :: Eq a => [a] -> [a]
uniq lst = uniq_2 lst []
    where 
        uniq_2 [] _ = []
        uniq_2 (x:xs) seen = if (contains x seen)
                                    then uniq_2 xs seen
                                    else x : uniq_2 xs ( x : seen )

flatten :: [[a]] -> [a]
flatten [] = []
flatten (x:xs) = x ++ flatten xs

split :: Char -> String -> [String]
split _ [] = [""]
split delim (x:xs)
    | x == delim = [] : rest
    | otherwise = [(x : head rest)] ++ (tail rest)
    where rest = split delim xs

sort :: Ord a => [a] -> [a]
sort [] = []
sort (x:xs) = sort [y | y <- xs, y <= x] ++ [x] ++ sort [y | y <- xs, y > x]

map_sort :: (Ord b) => (a -> b) -> [a] -> [b]
map_sort f xs = sort $ map f xs

increment :: Eq a => [(a, Int)] -> a -> [(a, Int)]
increment [] _ = []
increment ((x, i):rest) m 
    | m == x = (x, i+1) : increment rest m
    | otherwise = (x, i) : increment rest m

element 0 (x:xs) = x
element n (x:xs) = element (n-1) xs

join :: String -> [String] -> String
join _ [] = []
join _ [x] = x
join delim (x:xs) = x ++ delim ++ (join delim xs)

unquote :: String -> String
unquote xs = (reverse . chomp_first_q) (reverse (chomp_first_q xs))
    where
        chomp_first_q ('\'':xs) = xs
        chomp_first_q ('"':xs) = xs
        chomp_first_q xs = xs

contains :: (Eq a) => a -> [a] -> Bool
contains _ [] = False
contains i (x:xs)
    | x == i = True
    | otherwise = contains i xs

contains_all :: (Eq a) => [a] -> [a] -> Bool
contains_all [] _ = True
contains_all (x:xs) set = if contains x set then contains_all xs set else False

(??) :: (Eq a) => [a] -> (a -> Bool)
x ?? y = contains y x

mktokens :: String -> [String]
mktokens [] = []
mktokens s = first : rest
    where
        [(first, remains)] = lex s
        rest = mktokens remains

pairs :: [a] -> [(a,a)]
pairs (x:y:tail) = (x,y) : pairs tail
pairs [] = []

trim :: String -> String
trim s = reverse $ trim_front (reverse (trim_front s))
    where 
        trim_front (' ':xs) = trim_front xs
        trim_front xs = xs

map2 :: (a -> b) -> [[a]] -> [[b]]
map2 fn lst = map (\sub -> map fn sub) lst

readConfigs :: String -> [(String, String)]
readConfigs fname = unsafePerformIO (do
    contents <- readFile fname -- String
    lines <- return $ split '\n' contents -- [String]
    tokens <- return $ [ head $ pairs x | x <- map2 trim $ map (split '=') lines] -- [(String, String)]
    return tokens
    )

get_config :: String -> String -> Maybe String
get_config filename opt = lookup opt (readConfigs filename)

contentsOf :: String -> String
contentsOf fname = unsafePerformIO (readFile fname)

program_arguments = unsafePerformIO (getArgs)

_get_option :: String -> String -> [String] -> String
_get_option opt dflt [] = dflt
_get_option opt dflt [x] = dflt
_get_option opt dflt (k:v:rest)
    | opt == k = v
    | head v == '-' = _get_option opt dflt $ v : rest
    | otherwise = _get_option opt dflt rest

has_option opt = contains opt program_arguments
get_option opt dflt = _get_option opt dflt program_arguments
