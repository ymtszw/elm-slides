module Main exposing (main)

import Dict exposing (Dict)
import Regex
import Html
import Http exposing (getString, send)
import Type exposing (..)
import View


init : ( Model, Cmd Msg )
init =
    ( { index =
            Dict.fromList
                [ ( "README.md", [] )
                , ( "delightful_elm.md", [] )
                ]
      , current = Nothing
      , cursor = 0
      }
    , getMarkdownFile "README.md"
    )


getMarkdownFile : String -> Cmd Msg
getMarkdownFile path =
    send (ClientRes << Result.map (GetMarkdownFile path << chopFile))
        (getString path)


chopFile : String -> List String
chopFile raw =
    Regex.split Regex.All separator raw


separator : Regex.Regex
separator =
    Regex.regex "---+\\s+"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ index } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ClientRes (Ok (GetMarkdownFile filename contents)) ->
            ( { model
                | index = Dict.insert filename contents index
                , current = Just ( filename, contents )
                , cursor = 0
              }
            , Cmd.none
            )

        ClientRes (Err e) ->
            Debug.log "Http Error" e |> always ( model, Cmd.none )

        OpenFile filename ->
            case Dict.get filename index of
                Just ((_ :: _) as contents) ->
                    ( { model
                        | current = Just ( filename, contents )
                        , cursor = 0
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, getMarkdownFile filename )

        CursorTo int ->
            ( { model | cursor = int }, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = View.view
        }
