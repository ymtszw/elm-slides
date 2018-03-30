module Main exposing (main)

import Dict exposing (Dict)
import Regex
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy as Z
import Http exposing (getString, send)
import Markdown


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
    = GetMarkdownFile String (List String) -- Filename, Contents


type alias Model =
    { index : Dict String (List String)
    , current : Maybe ( String, List String )
    , cursor : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { index = Dict.empty
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
                Just contents ->
                    ( { model
                        | current = Just ( filename, contents )
                        , cursor = 0
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, getMarkdownFile filename )

        CursorTo int ->
            ( { model | cursor = int }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    section [ class "section" ]
        [ div [ class "container is-fluid is-fullhd" ]
            [ div [ class "columns" ]
                [ aside [ class "menu column is-2" ]
                    [ p [ class "menu-label" ] [ text "INDEX" ]
                    , ul [ class "menu-list" ] <|
                        List.map
                            (\filename ->
                                li []
                                    [ a [ onClick (OpenFile filename) ]
                                        [ text (String.dropRight 3 filename) ]
                                    ]
                            )
                            slideList
                    ]
                , div [ class "column is-10" ] [ rendered model ]
                ]
            ]
        ]


rendered : Model -> Html Msg
rendered { current, cursor } =
    case current of
        Just ( _, contents ) ->
            div [ class "reveal" ]
                [ locator (List.length contents) cursor
                , div [ class "slides" ] (List.indexedMap (page cursor) contents)
                ]

        Nothing ->
            div [ class "reveal" ] [ text "Loading..." ]


locator : Int -> Int -> Html Msg
locator max cursor =
    nav
        [ class "pagination is-centered"
        , attribute "role" "navigation"
        , attribute "aria-label" "pagination"
        ]
        [ button (withDisabled (cursor <= 0) [ class "pagination-previous", onClick (CursorTo (cursor - 1)) ])
            [ i [ class "fa fa-chevron-left" ] [] ]
        , span [ class "pagination-list" ]
            [ text (toString (cursor + 1))
            , text "/"
            , text (toString max)
            ]
        , button (withDisabled (cursor >= max - 1) [ class "pagination-next", onClick (CursorTo (cursor + 1)) ])
            [ i [ class "fa fa-chevron-right" ] [] ]
        ]


withDisabled : Bool -> List (Html.Attribute msg) -> List (Html.Attribute msg)
withDisabled disabled_ others =
    if disabled_ then
        attribute "disabled" "disabled" :: others
    else
        others


page : Int -> Int -> String -> Html Msg
page cursor index content =
    let
        contents =
            if cursor - 2 <= index && index <= cursor + 2 then
                [ Z.lazy2 Markdown.toHtml [ class "content" ] content ]
            else
                []
    in
        if cursor == index then
            div [ class "slide is-active" ] contents
        else if index < cursor then
            div [ class "slide is-overlay is-left-deck" ] contents
        else
            div [ class "slide is-overlay is-right-deck" ] contents


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
