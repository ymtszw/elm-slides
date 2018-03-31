module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy as Z
import Markdown
import Type exposing (Model, Msg(..))


view : Model -> Html Msg
view ({ index } as model) =
    section [ class "section" ]
        [ div [ class "container is-fluid is-fullhd" ]
            [ div [ class "columns" ]
                [ aside [ class "menu column is-2" ]
                    [ p [ class "menu-label" ] [ text "INDEX" ]
                    , ul [ class "menu-list" ] <|
                        List.map
                            (\filename ->
                                li []
                                    [ a [ href ("#" ++ filename) ]
                                        [ text (String.dropRight 3 filename) ]
                                    ]
                            )
                            (Dict.keys index)
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
        Just ( filename, contents ) ->
            div [ class "reveal" ]
                [ locator (List.length contents) filename cursor
                , div [ class "slides" ] (List.indexedMap (page cursor) contents)
                ]

        Nothing ->
            div [ class "reveal" ] [ text "Loading..." ]


locator : Int -> String -> Int -> Html Msg
locator max filename cursor =
    nav
        [ class "pagination is-centered"
        , attribute "role" "navigation"
        , attribute "aria-label" "pagination"
        ]
        [ locatorButton (cursor <= 0)
            filename
            cursor
            [ class "pagination-previous" ]
            [ i [ class "fa fa-chevron-left" ] [] ]
        , span [ class "pagination-list" ]
            -- Use 1-based index in view
            [ text (toString (cursor + 1))
            , text "/"
            , text (toString max)
            ]
        , locatorButton (cursor >= max - 1)
            filename
            (cursor + 2)
            [ class "pagination-next" ]
            [ i [ class "fa fa-chevron-right" ] [] ]
        ]


locatorButton : Bool -> String -> Int -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
locatorButton disabled_ filename toCursor others children =
    if disabled_ then
        span (attribute "disabled" "disabled" :: others) children
    else
        a (href ("#" ++ filename ++ "/" ++ toString toCursor) :: others) children


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
