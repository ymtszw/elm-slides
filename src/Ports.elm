port module Ports exposing (setTitle, requestFullscreen, exitFullscreen)


port setTitle : String -> Cmd msg


port requestFullscreen : String -> Cmd msg


port exitFullscreen : () -> Cmd msg
