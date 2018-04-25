module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy as Z
import Markdown
import Type exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ navbar model
        , section
            [ class "section" ]
            [ div [ class "container is-fluid is-fullhd" ]
                [ rendered model
                ]
            ]
        ]


navbar : Model -> Html Msg
navbar { index, navOpen } =
    nav [ class "navbar" ]
        [ div [ class "navbar-brand" ]
            [ div [ class "navbar-item" ]
                [ a [ href "https://github.com/ymtszw/elm-slides" ]
                    [ span [ class "fab fa-github" ] []
                    , text "ymtszw/elm-slides"
                    ]
                ]
            , div
                [ class <| "navbar-burger burger" ++ isActive navOpen
                , onClick (ToggleNav (not navOpen))
                ]
                [ span [] [], span [] [], span [] [] ]
            ]
        , div [ class <| "navbar-menu" ++ isActive navOpen ]
            [ div [ class "navbar-start" ]
                [ div [ class "navbar-item has-dropdown is-hoverable" ]
                    [ a [ class "navbar-link" ] [ text "INDEX" ]
                    , div [ class "navbar-dropdown is-boxed" ] <|
                        flip List.map (Dict.keys index) <|
                            \filename ->
                                a [ class "navbar-item", href ("#" ++ filename) ]
                                    [ text (String.dropRight 3 filename) ]
                    ]
                ]
            , div [ class "navbar-end" ]
                [ a [ class "navbar-item", onClick (RequestFullscreen ".reveal .slides") ] [ i [ class "fa fa-2x fa-expand" ] [] ]
                ]
            ]
        ]


isActive : Bool -> String
isActive navOpen =
    if navOpen then
        " is-active"
    else
        ""


rendered : Model -> Html Msg
rendered { current, cursor } =
    case current of
        Just ( filename, contents ) ->
            div [ class "reveal" ]
                [ div [ class "slides", id "slides" ] (List.indexedMap (page cursor) contents)
                , locator (List.length contents) filename cursor
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
