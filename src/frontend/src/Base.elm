module Base exposing (ContainerInfo, PodInfo, CommonModel, ContainerStatusInfo, ContainerState (Running, Failed), renderButtonCell, renderBadge, getPodState)

import String.Format exposing (format1, format2)
import Date
import Date.Distance as Distance
import Material
import Material.Grid as Grid
import Material.Chip as Chip
import Material.Button as Button
import Material.Badge as Badge
import Material.Options as Options exposing (css)
import Html exposing (..)

-- MODEL

type alias ContainerInfo = {
        name : String,
        image : String
    }
    
type ContainerState = 
      Running String -- startedAt
    | Failed String String String -- startedAt, reason, message

type alias ContainerStatusInfo = {
        restartCount : Int,
        ready : Bool,
        state : ContainerState
    }

type alias PodInfo =
    { name: String
    , uid: String
    , app: String
    , status: String
    , podIP: String
    , containers : List ContainerInfo
    , containerStatus : ContainerStatusInfo 
    }

type alias CommonModel = {
    podList: List PodInfo,
    now : Maybe Date.Date
}

-- FUNCTIONS


renderButtonCell index model makeMdl msg actionText =
    Grid.cell [ Grid.size Grid.All 4 ] [ 
        Button.render makeMdl [ index ] model.mdl [ Button.raised, Button.colored, Button.ripple, Options.onClick msg ] [ text actionText ]
    ]

renderBadge message badge =
    Chip.button [ ] [ Chip.content [ css "width" "10rem" ] [ text (format2 "{1}: {2}" (message, badge)) ] ]

getPodState pod commonModel =
    case pod.containerStatus.state of
        Running started ->
            format1 "Running since {1}" (case Date.fromString started of
                Ok d ->
                    (case commonModel.now of
                        Just now ->
                            (Distance.inWords now d)
                        Nothing ->
                            started)
                Err _ ->
                    started)
        Failed _ reason message ->
            format2 "Not running. {1}: {2}" (reason, message)

