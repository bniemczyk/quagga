module Guic.Widgets where

import Guic.Base
import Guic.Compiler

isNamed name = do
    att "id" name
    att "name" name

-- commonWidgets = map compile_widget [yesNoDialog, messageBox]

yesNoDialog msg = panelw .- do
    isNamed "yesNoDialog"
    -- [msg] <- reqps$ ["msg"]
    ins$ vlayoutw .- do
        ins$ labelw msg
        ins$ hlayoutw .- do
            ins$ buttonw "No"
            ins$ buttonw "Yes"

messageBox msg = panelw .- do
    isNamed "messageBox"
    -- [msg] <- reqps$ ["msg"]
    ins$ vlayoutw .- do
        ins$ labelw msg
        ins$ buttonw "OK"
