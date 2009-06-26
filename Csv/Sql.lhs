\documentclass{article}
%include polycode.fmt
\begin{document}

> module Csv.Sql (csv_to_sql, parse_csv_file, parse_csv) where

> import Util
> import Parser

Parsing is handled by a very simple recursive descent parser defined as

> csvqs = do
>     q <- (one '\'' <|> one '"')
>     s <- many $ esc_char <|> (noneOf [q]) <|> (one q >> one q)
>     one q
>     return s

> field delim = do
>     s <- (csvqs <|> (many $ noneOf $ delim : "\r\n"))
>     return s

> row delim =
>     do
>         first <- field delim
>         rest <- many $ one delim >> field delim
>         eol
>         return $ first : rest

> csv_table delim =
>     do
>         headers <- row delim
>         values <- many $ row delim
>         many eol
>         eof

Append an extra row to the front of the list so that
even if there is no data, the create table statement can be
generated

>         return $ [zip headers headers] ++ [ zip headers x | x <- values ]

> parse_csv_file :: String -> Char -> Maybe [[(String, String)]]
> parse_csv_file fname delim = parseResult $ parse (csv_table delim) (contentsOf fname)

> create_table_sql :: String -> String -> [[(String, String)]] -> String
> create_table_sql table quote_char (rec:_) = "create table " ++ table ++ " (\n\t" ++ columns_def ++ "\n);\n\n"
>     where
>         columns = map (\x -> quote_char ++ x ++ quote_char) $ keys rec
>         columns_def = join ",\n\t" $ map (\x -> x ++ " VARCHAR(255)") columns

> row_sql :: String -> String -> [(String, String)] -> String
> row_sql table quote_char input = "insert into " ++ table ++ " (" ++ (join "," columns) ++ ") values (" ++ (join "," values) ++ ")"
>     where
>         (columns_noquote, nqvalues) = unzip input
>         columns = map (\x -> quote_char ++ x ++ quote_char) columns_noquote
>         values = [ "'" ++ x ++ "'" | x <- map escape_squotes nqvalues ]
>         escape_squotes ('\'':xs) = "''" ++ (escape_squotes xs)
>         escape_squotes [] = []
>         escape_squotes (c:xs) = [c] ++ escape_squotes xs

> (<--) :: ([a] -> a) -> ([b] -> a) -> ([[b]] -> a)
> g <-- f = g . (map f)

> csv_to_sql tbl csv delim quote_char = create_table_sql tbl quote_char parsed_csv ++ 

Only generate row sql for the tail of the csv table, because we appended an extra row earlier to allow
csv files with no data

>                                                (join ";\n" <-- row_sql tbl quote_char) (tail parsed_csv) ++ 
>                                                if length parsed_csv > 1 then ";\n" else ""
>     where 
>         Just parsed_csv = parse_csv csv delim

> parse_csv csv delim = parseResult $ parse (csv_table delim) csv

\end{document}
