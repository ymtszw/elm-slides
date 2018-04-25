module Main exposing (main)

import Dict
import Navigation exposing (Location)
import Keyboard exposing (KeyCode)
import Type exposing (Model, Msg(..), Success(..))
import Router exposing (route)
import Ports
import View


init : Location -> ( Model, Cmd Msg )
init loc =
    let
        model =
            { index =
                Dict.fromList
                    [ ( "README.md", [] )
                    , ( "delightful_elm.md", [] )
                    , ( "screenshot_crawler.md", [] )
                    ]
            , current = Nothing
            , cursor = 0
            , navOpen = False
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

        GoTo hash ->
            ( model, Navigation.newUrl hash )

        ClientRes (Ok (GetMarkdownFile filename contents)) ->
            ( { model
                | index = Dict.insert filename contents index
                , current = Just ( filename, contents )
              }
            , Ports.setTitle (String.dropRight 3 filename)
            )

        ClientRes (Err e) ->
            Debug.log "Http Error" e |> always ( model, Cmd.none )

        ToggleNav navOpen ->
            ( { model | navOpen = navOpen }, Cmd.none )

        RequestFullscreen selector ->
            ( model, Ports.requestFullscreen selector )


subscriptions : Model -> Sub Msg
subscriptions { current, cursor } =
    case current of
        Just ( filename, (_ :: _ :: _) as contents ) ->
            let
                max =
                    List.length contents
            in
                Keyboard.downs (binds filename max cursor)

        _ ->
            Sub.none


binds : String -> Int -> Int -> KeyCode -> Msg
binds filename max cursor =
    let
        gotoBinds =
            if cursor <= 0 then
                [ bindGoTo filename (cursor + 2) forwardKeys ]
            else if cursor >= max - 1 then
                [ bindGoTo filename cursor backwardKeys ]
            else
                [ bindGoTo filename (cursor + 2) forwardKeys
                , bindGoTo filename cursor backwardKeys
                ]
    in
        foldBinds gotoBinds


foldBinds : List (KeyCode -> Maybe Msg) -> KeyCode -> Msg
foldBinds callbacks code =
    case callbacks of
        [] ->
            NoOp

        c :: cs ->
            case c code of
                Just msg ->
                    msg

                Nothing ->
                    foldBinds cs code


bindGoTo : String -> Int -> List KeyCode -> KeyCode -> Maybe Msg
bindGoTo filename toCursor keys code =
    if List.member code keys then
        Just (GoTo ("#" ++ filename ++ "/" ++ toString toCursor))
    else
        Nothing


forwardKeys : List KeyCode
forwardKeys =
    [ 39 -- Down
    , 40 -- Right
    , 74 -- J
    , 76 -- L
    ]


backwardKeys : List KeyCode
backwardKeys =
    [ 37 -- Left
    , 38 -- Up
    , 72 -- H
    , 75 -- K
    ]


main : Program Never Model Msg
main =
    Navigation.program Loc
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = View.view
        }
