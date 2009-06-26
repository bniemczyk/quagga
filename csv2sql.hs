module Main where

import Util
import Csv.Sql
import System
import System.Console.GetOpt
import Data.Maybe( fromMaybe )

main = do
    input <- return $ contentsOf $ last program_arguments
    delim <- return $ head $ get_option "-d" ","
    table <- return $ get_option "-t" "table"
    qchar <- return $ get_option "-q" ""
    help <- return $ has_option "-h"
    drop <- return $ has_option "--drop"
    if (drop && not help)
        then putStr $ "drop table " ++ table ++ ";\n\n"
        else putStr ""
    if help
        then printHelp
        else putStr $ csv_to_sql table input delim qchar


printHelp :: IO ()
printHelp = do
    putStr "-t <table name> -- set table name (default: table)\n"
    putStr "-d <delimiter> -- the the delimiter (default: ,)\n"
    putStr "-q <quote_char> -- set the quote character for table names (default: none)\n"
    putStr "-h -- show this help\n"
