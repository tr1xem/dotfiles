import Data.Map qualified as M
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.InsertPosition
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.Renamed
import XMonad.StackSet qualified as W
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Loggers
import XMonad.Util.SpawnOnce
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.Fullscreen

-- TokyoNight Colors
colorBg = "#1a1b26" -- background
colorFg = "#a9b1d6" -- foreground
colorBlk = "#32344a" -- black
colorRed = "#f7768e" -- red
colorGrn = "#9ece6a" -- green
colorYlw = "#e0af68" -- yellow
colorBlu = "#7aa2f7" -- blue
colorMag = "#ad8ee6" -- magenta
colorCyn = "#0db9d7" -- cyan
colorBrBlk = "#444b6a" -- bright black

-- Appearance
myBorderWidth = 2

myNormalBorderColor = colorBrBlk

myFocusedBorderColor = colorMag

-- Gaps (matching dwm: 3px all around)
mySpacing = spacingWithEdge 3

-- Workspaces
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9" , "0"]
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
  smartBorders $     -- removes borders automatically in fullscreen
    toggleLayouts Full $  -- <-- add this line
        renamed [Replace "Tall"] (mySpacing tall)
        ||| renamed [Replace "Wide"] (mySpacing (Mirror tall))
        ||| renamed [Replace "Spiral"] (mySpacing (spiral (6 / 7)))
  where
    tall = ResizableTall 1 (3 / 100) (11 / 20) []

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
    ]
    <+> insertPosition Below Newer

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
  -- , -- Layout switching
    -- ("M-t", sendMessage $ JumpToLayout "Tall")
  , ("M-f", windows W.shiftMaster)
  , ("M-c", sendMessage $ JumpToLayout "Spiral")
  , ("M-S-<Return>", sendMessage NextLayout)
  , ("M-n", sendMessage NextLayout)
  , -- Floating
    ("M-S-f", withFocused toggleFloat)
  , -- Gaps (z to increase, x to decrease, a to toggle)
    ("M-z", incWindowSpacing 3)
  , ("M-x", decWindowSpacing 3)
  , ("M-a", toggleWindowSpacingEnabled >> toggleScreenSpacingEnabled)
  , ("M-S-a", setWindowSpacing (Border 3 3 3 3) >> setScreenSpacing (Border 3 3 3 3))
  , -- Quit/Restart
    ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
   -- Keychords for tag navigation (Mod+Space then number)
   --   ("M-<Space> 1", windows $ W.greedyView "1")
   -- , ("M-<Space> 2", windows $ W.greedyView "2")
   -- , ("M-<Space> 3", windows $ W.greedyView "3")
   -- , ("M-<Space> 4", windows $ W.greedyView "4")
   -- , ("M-<Space> 5", windows $ W.greedyView "5")
   -- , ("M-<Space> 6", windows $ W.greedyView "6")
   -- , ("M-<Space> 7", windows $ W.greedyView "7")
   -- , ("M-<Space> 8", windows $ W.greedyView "8")
   -- , ("M-<Space> 9", windows $ W.greedyView "9")
  , ("M-S-b", spawn "zen-browser")
  , ("M-d", spawn "discord")
  , ("M-m", spawn "spotify")
  , ("M-t", spawn "thunar")
  , ("M-y", spawn "curd")
  , ("<Print>", spawn "flameshot gui")
  , -- Volume controls
    ("<XF86AudioRaiseVolume>", spawn "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%+")
  , ("<XF86AudioLowerVolume>", spawn "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%-")
  , ("<XF86AudioMute>", spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
  , ("<XF86MonBrightnessUp>", spawn "brightnessctl set '10.0+'")
  , ("<XF86MonBrightnessDown>", spawn "brightnessctl set '10.0-'")
  , ("<XF86AudioNext>", spawn "playerctl next")
  , ("<XF86AudioPrev>", spawn "playerctl previous")
  , ("<XF86AudioPlay>", spawn "playerctl play-pause")
  , ("<XF86AudioPause>", spawn"playerctl play-pause")
  , ("M1-<Return>", do
     sendMessage ToggleStruts        -- hide/show xmobar
     sendMessage (Toggle "Full"))    -- toggle fullscreen layout

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
    { ppSep = xmobarColor colorBrBlk "" " │ "
    , ppTitleSanitize = xmobarStrip
    , ppCurrent = xmobarColor colorCyn ""
    , ppHidden = xmobarColor colorFg ""
    , ppHiddenNoWindows = xmobarColor colorBrBlk ""
    , ppUrgent = xmobarColor colorRed colorYlw
    , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused = wrap (xmobarColor colorCyn "" "[") (xmobarColor colorCyn "" "]") . xmobarColor colorFg "" . ppWindow
    formatUnfocused = wrap (xmobarColor colorBrBlk "" "[") (xmobarColor colorBrBlk "" "]") . xmobarColor colorBrBlk "" . ppWindow
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

-- Main configuration
myConfig =
  def
    { modMask = myModMask
    , terminal = myTerminal
    , workspaces = myWorkspaces
    , borderWidth = myBorderWidth
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , layoutHook = myLayoutHook
    , manageHook = myManageHook <+> manageDocks
    , startupHook = do
        spawnOnce "xsetroot -cursor_name left_ptr"
        spawnOnce "vicinae server --replace"
        spawnOnce "picom"
        spawnOnce "dunst"
        spawnOnce "xset r rate 250 40"
        spawnOnce "setxkbmap -option caps:swapescape"
        spawnOnce "~/.fehbg"
        spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1"

    }
    `additionalKeysP` myKeys

-- XMobar status bar configuration
myStatusBar = statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure myXmobarPP)

main :: IO ()
main = xmonad . ewmhFullscreen . ewmh . withEasySB myStatusBar defToggleStrutsKey $ myConfig
