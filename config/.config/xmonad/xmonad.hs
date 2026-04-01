import Colors
import Colors (ColorScheme (surfaceDim))
import qualified Data.Map as M
import XMonad
import XMonad.Actions.DwmPromote
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.MouseResize
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import qualified XMonad.Hooks.StatusBar.PP as Hacks
import XMonad.Layout.AutoMaster
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.WindowArranger
import XMonad.ManageHook
import XMonad.StackSet as W
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeysP)
import qualified XMonad.Util.Hacks as Hacks
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce

-- Appearance
myBorderWidth = 2

myNormalBorderColor = primaryContainer colors

myFocusedBorderColor = primary colors

-- Gaps (matching dwm: 3px all around)
mySpacing = spacingWithEdge 3

-- Workspaces
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

-- myWorkspaces = ["", "󰊯", "", "", "󰙯", "󱇤", "", "󱘶", "󰧮"]
-- myWorkspaces = [ "\xf489"  , "\xf268"  , "\xe749" , "\xf198" , "\xf120" , "\xf1bc" , "\xf03d" , "\xf1fc" , "\xf11b" ]

-- myWorkspaces = ["\xf489", "\xf02af", "\xe749", "\xf198", "\xf067f", "\xfb64", "\xf167", "\xf1f6", "\xf86e"]

-- Mod key (Super/Windows key)
myModMask = mod4Mask

-- Terminal
myTerminal = "ghostty"

-- Layouts
myLayoutHook =
    avoidStruts $
        smartBorders $
            toggleLayouts Full $
                renamed [Replace "Tall"] (mySpacing tall)
                    ||| renamed [Replace "Wide"] (mySpacing (Mirror tall))
                    ||| renamed [Replace "Spiral"] (mySpacing (spiral (6 / 7)))
  where
    tall = ResizableTall 1 (3 / 100) (11 / 20) []

-- Scratchpads

scratchpads =
    [ -- run htop in xterm, find it by title, use default floating window placement
      NS "htop" "xterm -e htop" (title =? "htop") defaultFloating
    , -- run stardict, find it by class name, place it in the floating window
      -- 1/6 of screen width from the left, 1/6 of screen height
      -- from the top, 2/3 of screen width by 2/3 of screen height
      -- NS
      --   "stardict"
      --   "stardict"
      --   (className =? "Stardict")
      --   (customFloating $ W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)),
      -- run gvim, find by role, don't float
      NS "notes" "ghostty -e nvim -c 'cd ~/personal/orgfiles'  -c 'Oil'" (title =? "nvim") (customFloating $ W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3))
    , NS "discord" "discord" (className =? "discord") defaultFloating
    , NS "calculator" "galculator" (className =? "Galculator") defaultFloating
    , NS
        "ghostty"
        "ghostty -e sh -c 'printf \"\\033]0;Floatterm\\007\";fish'"
        (title =? "Floatterm")
        defaultFloating
    ]
  where
    role = stringProperty "WM_WINDOW_ROLE"

-- Window rules (matching dwm config)
myManageHook =
    composeAll
        [ className =? "zen" --> doShift "2"
        , className =? "firefox" --> doShift "3"
        , className =? "Slack" --> doShift "4"
        , className =? "kdenlive" --> doShift "8"
        , className =? "Spotify" --> doShift "0"
        , className =? "Thunar" --> doShift "4"
        , className =? "mpv" --> doShift "5"
        , className =? "com.mitchellh.ghostty" --> doShift "3"
        , className =? "Galculator" --> doCenterFloat
        , className =? "pwvucontrol" --> doCenterFloat
        , className =? "vicinae" --> doFloat <+> doRaise <+> doFocus
        , className =? "flameshot" --> doFloat <+> doRaise
        , className =? "discord" --> doRectFloat (W.RationalRect 0.10 0.10 0.5 0.5)
        , title =? "Floatterm" --> doRectFloat (W.RationalRect 0.10 0.10 0.5 0.5)
        ]

-- Key bindings (matching dwm as closely as possible)
myKeys =
    -- Launch applications
    [ ("M-<Return>", spawn myTerminal)
    , ("M-<Space>", spawn "vicinae toggle")
    , ("M-v", spawn "vicinae vicinae://extensions/vicinae/clipboard/history")
    , ("M-.", spawn "vicinae vicinae://extensions/vicinae/core/search-emojis")
    , ("M-r", spawn "dmenu_run")
    , ("M-<End>", spawn "betterlockscreen -l")
    , ("C-<Print>", spawn "maim -s | xclip -selection clipboard -t image/png")
    , ("M-<Print>", spawn "record.sh")
    , -- Window management
      ("M-q", kill)
    , ("M-j", windows W.focusDown)
    , ("M-k", windows W.focusUp)
    , ("M-<Tab>", windows W.focusDown)
    , -- Master area
      ("M-l", sendMessage Expand)
    , ("M-h", sendMessage Shrink)
    , ("M-i", sendMessage (IncMasterN 1))
    , ("M-p", sendMessage (IncMasterN (-1)))
    , -- ("M-n", sendMessage $ JumpToLayout "Tall"),
      ("M-f", dwmpromote)
    , -- Floating
      ("M-S-f", withFocused toggleFloat)
    , -- Gaps (z to increase, x to decrease, a to toggle)
      ("M-z", incWindowSpacing 3)
    , ("M-x", decWindowSpacing 3)
    , ("M-a", toggleWindowSpacingEnabled >> toggleScreenSpacingEnabled)
    , ("M-S-a", setWindowSpacing (Border 3 3 3 3) >> setScreenSpacing (Border 3 3 3 3))
    , -- Quit/Restart
      ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
    , ("M-S-v", spawn "pwvucontrol")
    , -- Keychords for tag navigation (Mod+Space then number)
      --   ("M-<Space> 1", windows $ W.greedyView "1")
      -- , ("M-<Space> 2", windows $ W.greedyView "2")
      -- , ("M-<Space> 3", windows $ W.greedyView "3")
      -- , ("M-<Space> 4", windows $ W.greedyView "4")
      -- , ("M-<Space> 5", windows $ W.greedyView "5")
      -- , ("M-<Space> 6", windows $ W.greedyView "6")
      -- , ("M-<Space> 7", windows $ W.greedyView "7")
      -- , ("M-<Space> 8", windows $ W.greedyView "8")
      -- , ("M-<Space> 9", windows $ W.greedyView "9")
      ("M-b", spawn "zen-browser")
    , ("M-d", namedScratchpadAction scratchpads "discord")
    , ("M-m", spawn "spotify")
    , ("M-w", spawn "~/.local/bin/wallpaper.sh")
    , ("M-t", spawn "thunar")
    , ("M-y", spawn "curd")
    , ("M-S-t", spawn " maim -s /tmp/screenshot.png && tesseract /tmp/screenshot.png stdout | xclip -selection clipboard")
    , ("M-e", spawn "~/.local/bin/nspawn menu")
    , ("<Print>", spawn "flameshot gui")
    , -- Volume controls
      ("<XF86AudioRaiseVolume>", spawn "control.sh vol-up")
    , ("<XF86AudioLowerVolume>", spawn "control.sh vol-down")
    , ("<XF86AudioMute>", spawn "control.sh vol-mute")
    , ("<XF86MonBrightnessUp>", spawn "control.sh br-up")
    , ("<XF86MonBrightnessDown>", spawn "control.sh br-down")
    , ("<XF86AudioNext>", spawn "playerctl next")
    , ("<XF86AudioPrev>", spawn "playerctl previous")
    , ("<XF86AudioPlay>", spawn "playerctl play-pause")
    , ("<XF86AudioPause>", spawn "playerctl play-pause")
    , ("<XF86Calculator>", namedScratchpadAction scratchpads "calculator")
    , ("M-s n", namedScratchpadAction scratchpads "notes")
    , ("M-s g", namedScratchpadAction scratchpads "ghostty")
    ,
        ( "M1-<Return>"
        , do
            sendMessage ToggleStruts -- hide/show xmobar
            sendMessage (Toggle "Full") -- toggle fullscreen layout
        )
    ]
        ++
        -- Standard TAGKEYS behavior (Mod+# to view, Mod+Shift+# to move)
        [ (mask ++ "M-" ++ [key], windows $ action tag)
        | (tag, key) <- zip myWorkspaces "1234567890"
        , (action, mask) <- [(W.greedyView, ""), (W.shift, "S-")]
        ]

-- Helper function for toggling float
toggleFloat w =
    windows
        ( \s ->
            if M.member w (W.floating s)
                then W.sink w s
                else W.float w (W.RationalRect 0.10 0.10 0.5 0.5) s
        )

-- XMobar PP (Pretty Printer) configuration
myXmobarPP :: PP
myXmobarPP =
    def
        { ppSep = xmobarColor (outline colors) "" " │ "
        , ppTitleSanitize = xmobarStrip
        , ppCurrent = xmobarColor (primary colors) ""
        , ppHidden = xmobarColor (inversePrimary colors) ""
        , ppHiddenNoWindows = xmobarColor (outline colors) ""
        , ppUrgent = xmobarColor (colorRed colors) (colorYellow colors)
        , ppOrder = \[ws, l, _, wins] -> [ws, wins]
        , ppExtras = [logTitles formatFocused formatUnfocused]
        }
  where
    formatFocused = wrap (xmobarColor (primary colors) "" "[") (xmobarColor (primary colors) "" "]") . xmobarColor (onPrimaryContainer colors) "" . ppWindow
    formatUnfocused = wrap (xmobarColor (outline colors) "" "[") (xmobarColor (outline colors) "" "]") . xmobarColor (outline colors) "" . ppWindow
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

-- Main configuration
myConfig =
    def
        { modMask = myModMask
        , terminal = myTerminal
        , XMonad.workspaces = myWorkspaces
        , borderWidth = myBorderWidth
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , layoutHook = mouseResize $ windowArrange myLayoutHook
        , manageHook = myManageHook <+> manageDocks <+> namedScratchpadManageHook scratchpads
        , handleEventHook =
            handleEventHook def
                <> Hacks.fixSteamFlicker
                <> Hacks.trayerPaddingXmobarEventHook
                <> Hacks.trayerAboveXmobarEventHook
        , startupHook = do
            spawnOnce "xsetroot -cursor_name left_ptr"
            spawnOnce "vicinae server --replace"
            spawnOnce "picom"
            spawnOnce "dunst"
            spawnOnce "xset r rate 250 40"
            spawnOnce "setxkbmap -option caps:swapescape"
            spawnOnce "~/.fehbg"
            spawnOnce "xautolock -detectsleep -time 3 -locker '/usr/bin/betterlockscreen'"
            spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1"
            spawnOnce "trayer --edge top --align right --widthtype request --width 200 --height 22 --tint 0x' <> surfaceDim colors <> ' --alpha 0 --transparent true --expand true --margin 4 -l --iconspacing 3"
        }
        `additionalKeysP` myKeys

-- XMobar status bar configuration
myStatusBar = statusBarProp "xmobar ~/.config/xmobar/xmobar.hs" (pure myXmobarPP)

main :: IO ()
main = xmonad . ewmhFullscreen . ewmh . withEasySB myStatusBar (const (0, xK_VoidSymbol)) $ myConfig
