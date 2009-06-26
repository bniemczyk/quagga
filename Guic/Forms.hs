module Guic.Forms where

import Guic.Base
import Guic.Widgets

formLayout formName formIsDomain = 
    formw formName formIsDomain .- do
        ins$ vlayoutw

formInput inputName inputCaption inputType = ins $
    hlayoutw .- do
        ins$ labelw inputCaption
        ins$ inputw inputName inputType
