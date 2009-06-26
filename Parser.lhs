\documentclass{article}
%include lhs2TeX.fmt
\begin{document}

this is a comment

> module Parser where
 
> import Text.Regex.Posix
> import Util

> data Parser from to = Parser (from -> (ParseResult to from))
> data ParseResult to from = ParseFail | ParseSuccess (to, from)
 
> parseResult (ParseSuccess (x, _)) = Just x
> parseResult ParseFail = Nothing

> parse (Parser p) = p

> instance Monad (Parser from) where
>     return x = Parser $ \stream -> ParseSuccess (x, stream)
>     fail _ = Parser $ \_ -> ParseFail
>     p >>= f = Parser $ \stream -> case (parse p stream) of
>         ParseFail -> ParseFail
>         ParseSuccess (x, xs) -> parse (f x) xs

> p <|> p2 = Parser $ \stream -> case (parse p stream) of
>     ParseSuccess (x,xs) -> ParseSuccess (x,xs)
>     ParseFail -> parse p2 stream

> item = Parser $ \stream -> case stream of
>     (x:xs) -> ParseSuccess (x, xs)
>     [] -> ParseFail

> eof = Parser $ \stream -> case stream of
>     [] -> ParseSuccess ( '\0', [] )
>     otherwise -> ParseFail

> dont_consume p = Parser $ \stream -> case (parse p stream) of
>     ParseSuccess (t, _) -> ParseSuccess (t, stream)
>     _ -> ParseFail

> try_parse p = Parser $ \stream -> case (parse p stream) of
>   ParseSuccess (t, new_stream) -> ParseSuccess (Just t, new_stream)
>   _ -> ParseSuccess (Nothing, stream)

> noneOf x = do
>     i <- item
>     if (contains i x)
>         then fail "noneOf failed"
>         else return i

> oneOf x = do
>     i <- item
>     if (contains i x)
>         then return i
>         else fail "oneOf failed"

> word = do
>     many $ noneOf " \r\t\n"

> quoted_list open_q close_q = do
>     one open_q
>     lst <- many (esc_char <|> (noneOf [close_q]))
>     one close_q
>     return lst

> dqstring = quoted_list '"' '"'
> sqstring = quoted_list '\'' '\''

> quoted_string = dqstring <|> sqstring

> whitespace = many $ oneOf " \r\n\t"

> many p = Parser $ \stream -> case (parse p stream) of
>     ParseFail -> ParseSuccess ([], stream)
>     ParseSuccess (x, xs) -> case (parse (many p) xs) of
>         ParseFail -> ParseSuccess ([x], xs) -- this should never get evaluated
>         ParseSuccess (y, ys) -> ParseSuccess (x : y, ys)

> many1 p = do
>     items <- many p
>     if length items > 0
>         then return items
>         else fail "many1 failed"

> one c = Parser $ \stream -> case stream of
>     (x:xs) -> if x == c then ParseSuccess(x,xs) else ParseFail
>     _ -> ParseFail

> char c = one c

> esc_char = do
>     char '\\'
>     i <- item
>     case i of
>         'n' -> return '\n'
>         'r' -> return '\r'
>         other -> return other

> eol = do
>     one '\r' <|> return '\r'
>     one '\n'

> multi_token [] = return []
> multi_token (t:ts) = do
>     c <- one t
>     rest <- multi_token ts
>     return $ c : rest

> number = rgx_parser "-?[0-9]+([.][0-9]+)?"
> integer = rgx_parser "[0-9]+"

> rgx_parser rgx = Parser $ \stream -> case (stream =~ rgx :: (String, String, String)) of
>     (_, [], _) -> ParseFail
>     ([], match, rest) -> ParseSuccess (match, rest)
>     _ -> ParseFail

\end{document}
