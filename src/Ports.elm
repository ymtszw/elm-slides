port module Ports exposing (setTitle, requestFullscreen)


port setTitle : String -> Cmd msg


port requestFullscreen : String -> Cmd msg
