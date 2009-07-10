module SPJ.LC.Runtime where

_Y h = h $ _Y h

_IF pred ontrue onfalse = if pred then ontrue else onfalse

_I x = x

_K c x = c

_S f g x = f x (g x)

_B f g x = f (g x)

_C f g x = f x g

_S' c f g x = c (f x) (g x)
