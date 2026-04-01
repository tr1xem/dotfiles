import Colors
import Data.Maybe
import System.Environment (lookupEnv)
import Xmobar

config :: String -> Config
config station =
    defaultConfig
        { font = "JetBrainsMono Nerd Font Mono Bold 9"
        , additionalFonts = ["JetBrainsMono Nerd Font Mono 15", "JetBrainsMono Nerd Font Mono 16", "JetBrainsMono Nerd Font Mono 11"]
        , bgColor = surfaceDim colors
        , fgColor = onPrimaryContainer colors
        , position = TopSize C 100 26
        , -- , alpha = 200
          border = BottomB
        , borderColor = inversePrimary colors
        , borderWidth = 1
        , lowerOnStart = True
        , overrideRedirect = True
        , sepChar = "%"
        , alignSep = "}{"
        , template =
            "%XMonadLog% }{ \
            \%multicoretemp% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%cpu% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%memory% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%wlp0s20f3wi% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%bluetooth% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%battery% <fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%date% <fc="
                <> secondaryContainer colors
                <> ">│</fc> %"
                <> station
                <> "%<fc="
                <> secondaryContainer colors
                <> ">│</fc> \
                   \%_XMONAD_TRAYPAD%"
        , commands =
            [ Run XMonadLog
            , Run $
                WeatherX
                    station
                    [ ("clear", "🌣")
                    , ("sunny", "🌣")
                    , ("mostly clear", "🌤")
                    , ("mostly sunny", "🌤")
                    , ("partly sunny", "⛅")
                    , ("fair", "🌑")
                    , ("cloudy", "☁")
                    , ("overcast", "☁")
                    , ("partly cloudy", "⛅")
                    , ("mostly cloudy", "🌧")
                    , ("considerable cloudiness", "⛈")
                    ]
                    [ "-t"
                    , "<fc=" <> primary colors <> "><skyConditionS> <tempC>°</fc>"
                    ]
                    18000
            , Run $
                XPropertyLog
                    "_XMONAD_TRAYPAD"
            , Run $
                MultiCoreTemp
                    [ "-L"
                    , "60"
                    , "-H"
                    , "85"
                    , "-l"
                    , primary colors
                    , "-n"
                    , primary colors
                    , "-h"
                    , colorRed colors
                    , "-t"
                    , "<fc=" <> primary colors <> "><fn=2>\xef2a\&</fn> <avg>°C</fc>"
                    ]
                    10
            , Run $
                Cpu
                    [ "-t"
                    , "<fc=" <> primary colors <> "><fn=1>\xf035b\& </fn></fc><total>%"
                    , "-L"
                    , "30"
                    , "-H"
                    , "70"
                    , "-l"
                    , primary colors
                    , "-n"
                    , primary colors
                    , "-h"
                    , colorRed colors
                    ]
                    10
            , Run $
                Memory
                    [ "-t"
                    , "<fc=" <> primary colors <> "><fn=1>\xe266\&</fn></fc> <usedratio>%"
                    , "-L"
                    , "29"
                    , "-H"
                    , "70"
                    , "-l"
                    , primary colors
                    , "-n"
                    , primary colors
                    , "-h"
                    , colorRed colors
                    ]
                    10
            , Run $
                Wireless
                    "wlp0s20f3"
                    [ "-t"
                    , "<fc=" <> primary colors <> "><fn=1>\xf05a9\&</fn></fc><fc=" <> primary colors <> "> <ssid> <quality>%</fc>"
                    ]
                    10
            , Run $
                Com
                    "/bin/bash"
                    [ "/home/saumya/.config/xmobar/scripts/bluetooth.sh"
                    , primary colors
                    , colorGreen colors
                    ]
                    "bluetooth"
                    5
            , Run $
                Battery
                    [ "-t"
                    , "<acstatus>"
                    , "-L"
                    , "20"
                    , "-H"
                    , "80"
                    , "-l"
                    , colorRed colors
                    , "-n"
                    , colorGreen colors
                    , "-h"
                    , colorGreen colors
                    , "--"
                    , "-o"
                    , "<fn=3>\xf007f\&</fn> <left>% (<timeleft>)"
                    , "-O"
                    , "<fn=3>\xf0084\&</fn> <left>%"
                    , "-i"
                    , "<fn=3>\xf17e2\&</fn> <left>%"
                    ]
                    50
            , Run $ Date ("<fc=" <> primary colors <> ">%I:%M \x2022\& %a,%-d %b</fc>") "date" 10
            ]
        }

main :: IO ()
main = do
    weatherStation <- lookupEnv "weather_station"
    let station = Data.Maybe.fromMaybe "LIPB" weatherStation
    let config' = config station
    xmobar config'
