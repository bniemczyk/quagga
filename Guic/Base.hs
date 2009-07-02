module Guic.Base where

data Attributed a = AttributeAttachment { name :: String, value :: String, innerObject :: a }
	deriving (Eq, Show, Read)

attr key val obj = AttributeAttachment key val obj

data InputType = 
		TextInput 
		| DateInput 
		| OptionInput [String] 
		| MultiOptionInput [String] 
        | PasswordInput
		| VerifiedInput { verification :: String, verification_input :: InputType }
	deriving (Eq, Show, Read)

data Form = Form { form_name :: String, form_isDomainObject :: Bool, form_innerWidget :: Widget }
	deriving (Eq, Show, Read)

data Action =
		CustomAction String
		| SubmitFormAction Form
		| CloseFormAction Form
		| OpenFormAction Form
		| LoadPanelAction Widget
	deriving (Eq, Show, Read)

data GridColumn = GridColumn { gcol_name :: String, gcol_caption :: String }
	deriving (Eq, Show, Read)

data Grid = SimpleGrid [GridColumn]
	deriving (Eq, Show, Read)

type ParamName = String

data Widget =
		EmptyWidget
		| ButtonWidget { btn_caption :: String, btn_onClick :: [Action] }
		| PanelWidget Widget
		| LabelWidget String
        | FormInputWidget { form_input_name :: String, form_input_type :: InputType }
		| FormContainer Form
		| GridContainer Grid
		| HLayoutContainer [Widget]
		| VLayoutContainer [Widget]
		| AttrContainer { attr_widget :: Attributed Widget }
        | CompiledWidget { cwidget :: Widget, cwidget_attrs :: [(String, String)] }
        | ParamWidget { param_list :: [ParamName], param_widget :: Widget }
	deriving (Eq, Show, Read)

buttonw caption = ButtonWidget caption []
panelw = PanelWidget EmptyWidget
labelw lbl = LabelWidget lbl
formw name isDomain = FormContainer $ Form name isDomain EmptyWidget
gridw grid = GridContainer grid
hlayoutw = HLayoutContainer []
vlayoutw = VLayoutContainer []
inputw iname itype = FormInputWidget iname itype
attrw key val ws = AttrContainer $ attr key val ws
paramw pname widget = ParamWidget pname widget

data WidgetBuilder a where
		WidgetBuilder	:: (Widget -> (a, Widget)) -> WidgetBuilder a

instance Monad WidgetBuilder where
		return a = WidgetBuilder $ \w -> (a, w)
		WidgetBuilder wb >>= f = WidgetBuilder $ \w -> 
				let (a, w') = wb w in
				let WidgetBuilder wb'' = f a in wb'' w'

(.-) :: Widget -> WidgetBuilder a -> Widget
w .- (WidgetBuilder wb) = let (a, w') = wb w in w'

ins w = WidgetBuilder $ \w' -> let w'' = insertw w' w in (w'', w'')

att k v = ins$ attrw k v EmptyWidget

-- insertw is the core of our widget building monad
insertw :: Widget -> Widget -> Widget

-- empty widgets can just get discarded
insertw w EmptyWidget = w

insertw EmptyWidget w = w

-- if the second argument is an AttrContainer 'insertw' has special semantics 
-- because attributes will get collapsed out of the tree later, this allows
-- metadata to be attached to objects
insertw w (AttrContainer (AttributeAttachment n v EmptyWidget)) = AttrContainer (AttributeAttachment n v w)

--
insertw (AttrContainer (AttributeAttachment n v w)) w' = AttrContainer $ AttributeAttachment n v $ insertw w w' 

-- 
insertw (PanelWidget EmptyWidget) w = PanelWidget w

-- 
insertw (ButtonWidget cap clck) (LabelWidget lbl) = ButtonWidget lbl clck

--
insertw (HLayoutContainer ws) w = HLayoutContainer $ reverse $ w : ws

--
insertw (VLayoutContainer ws) w = VLayoutContainer $ reverse $ w : ws

--
insertw (FormContainer (Form fname fdomain EmptyWidget)) w = FormContainer $ Form fname fdomain w
