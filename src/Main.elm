module Main exposing (main)

import Dict exposing (Dict)
import Navigation exposing (Location)
import Type exposing (..)
import Router exposing (route)
import View


init : Location -> ( Model, Cmd Msg )
init loc =
    let
        model =
            { index =
                Dict.fromList
                    [ ( "README.md", [] )
                    , ( "delightful_elm.md", [] )
                    ]
            , current = Nothing
            , cursor = 0
            }
    in
        route model loc


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ index } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Loc location ->
            route model location

        ClientRes (Ok (GetMarkdownFile filename contents)) ->
            ( { model
                | index = Dict.insert filename contents index
                , current = Just ( filename, contents )
              }
            , Cmd.none
            )

        ClientRes (Err e) ->
            Debug.log "Http Error" e |> always ( model, Cmd.none )


main : Program Never Model Msg
main =
    Navigation.program Loc
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = View.view
        }
