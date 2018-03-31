module Type exposing (..)

import Dict exposing (Dict)
import Http


slideList : List String
slideList =
    [ "README.md"
    , "delightful_elm.md"
    ]


type Msg
    = NoOp
    | ClientRes (Result Http.Error Success)
    | OpenFile String
    | CursorTo Int


type Success
    = GetMarkdownFile String (List String)


type alias Model =
    { index : Dict String (List String)
    , current : Maybe ( String, List String )
    , cursor : Int
    }
