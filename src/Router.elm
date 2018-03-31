module Router exposing (route)

import Dict
import Navigation exposing (Location)
import Type exposing (Model, Msg(..))
import File
import Ports


route : Model -> Location -> ( Model, Cmd Msg )
route ({ index } as model) { hash } =
    let
        ( filename, cursor ) =
            fileAndCursor hash
    in
        case Dict.get filename index of
            Just ((_ :: _) as contents) ->
                ( { model
                    | current = Just ( filename, contents )
                    , cursor = cursor
                  }
                , Ports.setTitle (String.dropRight 3 filename)
                )

            _ ->
                ( { model | cursor = cursor }, File.getMarkdown filename )


fileAndCursor : String -> ( String, Int )
fileAndCursor hash =
    case hash |> String.dropLeft 1 |> String.split "/" of
        [] ->
            ( "README.md", 0 )

        [ "" ] ->
            ( "README.md", 0 )

        [ filename ] ->
            ( filename, 0 )

        filename :: page :: _ ->
            case String.toInt page of
                Ok cursor ->
                    -- Use 1-based index in hash
                    ( filename, cursor - 1 )

                Err _ ->
                    ( filename, 0 )
