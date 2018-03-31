module Type exposing (Msg(..), Success(..), Model)

import Dict exposing (Dict)
import Http
import Navigation exposing (Location)


type Msg
    = NoOp
    | Loc Location
    | GoTo String
    | ToggleNav Bool
    | ClientRes (Result Http.Error Success)


type Success
    = GetMarkdownFile String (List String)


type alias Model =
    { index : Dict String (List String)
    , current : Maybe ( String, List String )
    , cursor : Int
    , navOpen : Bool
    }
