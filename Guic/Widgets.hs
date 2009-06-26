module Guic.Widgets where

import Guic.Base

yesNoDialog :: String -> Widget
yesNoDialog msg = panelw .- do
    att "YesNoDialog" "True"
    ins$ vlayoutw .- do
        ins$ labelw msg
        ins$ hlayoutw .- do
            ins$ buttonw "No"
            ins$ buttonw "Yes"

messageBox msg = panelw .- do
    att "MessageBox" "True"
    ins$ vlayoutw .- do
        ins$ labelw msg
        ins$ buttonw "OK"
