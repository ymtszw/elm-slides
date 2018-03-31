module File exposing (getMarkdown)

import Regex
import Http exposing (getString, send)
import Type exposing (Msg(..), Success(..))


getMarkdown : String -> Cmd Msg
getMarkdown path =
    send (ClientRes << Result.map (GetMarkdownFile path << chopFile))
        (getString path)


chopFile : String -> List String
chopFile raw =
    Regex.split Regex.All separator raw


separator : Regex.Regex
separator =
    Regex.regex "---+\\s+"
