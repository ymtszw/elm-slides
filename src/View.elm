module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy as Z
import Markdown
import Type exposing (..)


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
                    , p [ class "menu-label" ] [ text "SOURCE" ]
                    , ul [ class "menu-list" ]
                        [ li []
                            [ a [ href "https://github.com/ymtszw/elm-slides" ]
                                [ i [ class "fab fa-github" ] []
                                , text "ymtszw/elm-slides"
                                ]
                            ]
                        ]
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
