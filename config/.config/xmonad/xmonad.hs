import Colors
import qualified Data.Map as M
import XMonad
import XMonad.Actions.CopyWindow
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (addEwmhWorkspaceSort, ewmh, ewmhDesktopsManageHook, ewmhDesktopsMaybeManageHook, ewmhFullscreen)
import XMonad.Hooks.InsertPosition
import XMonad.Layout.WindowSwitcherDecoration
import XMonad.Layout.DraggingVisualizer
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
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
import XMonad.Util.WorkspaceCompare (filterOutWs, getSortByIndex)

-- Appearance
myBorderWidth = 2

myNormalBorderColor = primaryContainer colors

myFocusedBorderColor = primary colors

mySpacing = smartSpacingWithEdge 3

myTitleLength = 30

-- Workspaces
myWorkspaces = ["sys", "www", "dev", "man", "vid", "gfx", "wrk:7", "wrk:8", "wrk:9", "arc"]

-- Mod key (Super/Windows key)
myModMask = mod4Mask

-- Presets
myTerminal = "ghostty"
myBrowser = "zen-browser"
myFileManager = "thunar"

myTabTheme =
  def
    { fontName = "xft:JetBrainsMono Nerd Font Mono Bold:size=9"
    , activeColor = primaryContainer colors
    , activeBorderColor = primary colors
    , activeTextColor = onPrimaryContainer colors
    , inactiveColor = surfaceContainerLow colors
    , inactiveBorderColor = outlineVariant colors
    , inactiveTextColor = onSurfaceVariant colors
    , urgentColor = errorContainer colors
    , urgentBorderColor = errorColor colors
    , urgentTextColor = errorColor colors
    , decoHeight = 20
    }

-- Layouts
myLayoutHook =
  avoidStruts $
    smartBorders $
      mySpacing $
        toggleLayouts Full $
          renamed [Replace "Tall"] tall
            ||| renamed [Replace "Tabbed"] (tabbed shrinkText myTabTheme)
            ||| renamed [Replace "Full"] Full
  where
    tall = ResizableTall 1 (3 / 100) (11 / 20) []

-- Scratchpads

isConsole =
  (className =? "ghostty")
    <&&> (stringProperty "WM_WINDOW_ROLE" =? "Scratchpad")

scratchpads =
  [ -- run htop in xterm, find it by title, use default floating window placement
    NS "btop" "dbus-launch ghostty +new-window --title=btop -e btop" (title =? "btop") defaultFloating
  , -- run stardict, find it by class name, place it in the floating window
    -- 1/6 of screen width from the left, 1/6 of screen height
    -- from the top, 2/3 of screen width by 2/3 of screen height
    -- NS
    --   "stardict"
    --   "stardict"
    --   (className =? "Stardict")
    --   (customFloating $ W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)),
    -- run gvim, find by role, don't float
    NS "orgmode" "dbus-launch ghostty +new-window --title=orgmode -e nvim ~/dotfiles/personal/personal/orgfiles/refile.org" (title =? "orgmode") defaultFloating
  , NS "floatterm" "dbus-launch ghostty +new-window --title=floatterm " (title =? "floatterm") defaultFloating
  , NS "discord" "discord" (className =? "discord") defaultFloating
  , NS "equibop" "equibop" (className =? "equibop") defaultFloating
  , NS "calculator" "qalculate-gtk" (className =? "Qalculate-gtk") defaultFloating
  , NS "music" "spotify" (className =? "Spotify") defaultFloating
  ]
  where
    role = stringProperty "WM_WINDOW_ROLE"

-- Window rules
--
-- Spawn a new window in the given workspace and switch to it
doShiftAndGo :: WorkspaceId -> ManageHook
doShiftAndGo ws = doF (W.greedyView ws) <+> doShift ws

myManageHook :: ManageHook
myManageHook =
  manageSpecific
    <+> manageDocks
    <+> namedScratchpadManageHook scratchpads
    <+> manageSpawn
  where
    manageSpecific =
      composeOne
        [ -- Basic window rules
          isDialog -?> doCenterFloat
        , isPiP -?> doRectFloat (W.RationalRect 0.25 0.25 0.5 0.5)
        , isNotification -?> doRaise
        , isInProperty "_NET_WM_STATE" "_NET_WM_STATE_MODAL" -?> doCenterFloat
        , isRole =? "pop-up" -?> doCenterFloat
        , isBrowserDialog -?> doCenterFloat
        , isRole =? gtkFile -?> doCenterFloat
        , isInProperty
            "_NET_WM_WINDOW_TYPE"
            "_NET_WM_WINDOW_TYPE_SPLASH"
            -?> doCenterFloat
        , isFullscreen -?> doFullFloat
        , className
            =? "com.mitchellh.ghostty"
            <&&> title
            =? "orgmode"
            -?> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
        , title =? "floatterm" -?> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
        , className
            =? "com.mitchellh.ghostty"
            <&&> title
            =? "btop"
            -?> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
        , className
            =? "Spotify"
            -?> doRectFloat (W.RationalRect 0.15 0.15 0.7 0.7)
        , -- App specific rules
          className =? "zen" -?> doShiftAndGo (myWorkspaces !! 1)
        , className =? "firefox" -?> doShiftAndGo (myWorkspaces !! 2)
        , className =? "Slack" -?> doShiftAndGo (myWorkspaces !! 3)
        , className =? "kdenlive" -?> doShiftAndGo (myWorkspaces !! 5)
        , className =? "Gimp" -?> doShiftAndGo (myWorkspaces !! 5)
        , className =? "Thunar" -?> doShiftAndGo (myWorkspaces !! 3)
        , className =? "mpv" -?> doShiftAndGo (myWorkspaces !! 4)
        , className =? "steam_app_default" -?> doShiftAndGo (myWorkspaces !! 9)
        , className =? "com.mitchellh.ghostty" -?> doShiftAndGo (myWorkspaces !! 2)
        , className =? "Galculator" -?> doCenterFloat
        , className =? "pwvucontrol" -?> doCenterFloat
        , className =? "Xarchiver" -?> doCenterFloat
        , appName =? "vicinae" -?> doCenterFloat <+> doRaise <+> doFocus
        , className =? "flameshot" -?> doFloat <+> doRaise
        , className =? "discord" -?> doRectFloat (W.RationalRect 0.25 0.25 0.5 0.5)
        , className =? "equibop" -?> doRectFloat (W.RationalRect 0.25 0.25 0.5 0.5)
        , className =? "Screenkey" -?> doFloat
        , className =? "stalonetray" -?> doIgnore
        , className =? "Qalculate-gtk" -?> doCenterFloat
        , className =? "Alienware Command Centre - Dell G15 5530" -?> doCenterFloat
        , transience
        ]
    isBrowserDialog = isDialog <&&> className =? "zen"
    gtkFile = "GtkFileChooserDialog"
    isRole = stringProperty "WM_WINDOW_ROLE"
    isPiP = title =? "Picture-in-Picture"

-- Key bindings

swapDownNoMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
swapDownNoMaster s =
  case W.stack (W.workspace (W.current s)) of
    Nothing -> s
    Just st ->
      if null (W.up st)
        then s -- focused is master: don't swap
        else case W.down st of
          [] -> s -- bottom slave: don't wrap into master
          _ -> W.swapDown s

swapUpNoMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
swapUpNoMaster s =
  case W.stack (W.workspace (W.current s)) of
    Nothing -> s
    Just st ->
      if null (W.up st)
        then s -- focused is master: don't swap
        else case W.up st of
          [_] -> s -- top slave (directly above is master): don't swap into master
          (_ : _ : _) -> W.swapUp s
          [] -> s
myKeys =
  [ -- Window management
    ("M-q", kill)
  , ("M-j", windows W.focusDown)
  , ("M-k", windows W.focusUp)
  , ("M-<Tab>", windows W.focusDown)
  , -- Master area
    ("M-l", sendMessage Expand)
  , ("M-h", sendMessage Shrink)
  , ("M-S-j", windows swapDownNoMaster)
  , ("M-S-k", windows swapUpNoMaster)
  , -- Layouts
    ("M-p", promote)
  , ("M-S-p", toggleCopyToAll)
  , ("M-S-f", withFocused toggleFloat)
  , ("M-f", sendMessage (Toggle "Full"))
  , -- Gaps (z to increase, x to decrease, a to toggle)
    ("M-z", incWindowSpacing 3)
  , ("M-x", decWindowSpacing 3)
  , ("M-a", toggleWindowSpacingEnabled >> toggleScreenSpacingEnabled)
  , ("M-S-a", setWindowSpacing (Border 3 3 3 3) >> setScreenSpacing (Border 3 3 3 3))
  , -- Quit/Restart
    ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
  , -- Apps
    ("M-S-v", spawn "pwvucontrol")
  , ("M-C-v", spawn "~/.local/bin/change_output.sh")
  , ("M-b", spawn myBrowser)
  , ("M-t", spawn myFileManager)
  , ("M-y", spawn "curd")
  , ("M-S-t", spawn " maim -s /tmp/screenshot.png && tesseract /tmp/screenshot.png stdout | xclip -selection clipboard")
  , ("M-c", spawn "~/.local/bin/lxc-machines menu")
  , ("<Print>", spawn "dbus-launch flameshot gui")
  , ("M-w", spawn "~/.local/bin/wallpaper.sh")
  , ("M-<Space>", spawn "vicinae toggle")
  , ("<F23>", spawn "vicinae toggle")
  , ("M-v", spawn "vicinae vicinae://launch/clipboard/history")
  , ("M-.", spawn "vicinae vicinae://launch/core/search-emojis")
  , ("M-<Return>", spawn myTerminal)
  , ("M-<End>", spawn "betterlockscreen -l")
  , -- Utils
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
  , ("C-<Print>", spawn "maim -s | xclip -selection clipboard -t image/png")
  , ("M-<Print>", spawn "record.sh toggle")
  , -- Scratchpads
    -- ("M-d", namedScratchpadAction scratchpads "discord")
    ("M-d", namedScratchpadAction scratchpads "equibop")
  , ("M-m", namedScratchpadAction scratchpads "music")
  , ("M-s o", namedScratchpadAction scratchpads "orgmode")
  , ("M-s g", namedScratchpadAction scratchpads "floatterm")
  , ("C-S-<Escape>", namedScratchpadAction scratchpads "btop")
  , ("M-S-.", sendMessage (IncMasterN (-1)))
  , ("M1-t", sendMessage $ JumpToLayout "Tabbed")
  , ("M1-m", sendMessage $ JumpToLayout "Tall")
  , ("M1-b", sendMessage ToggleStruts)
  ,
    ( "M1-<Return>"
    , do
        sendMessage ToggleStruts
        sendMessage (Toggle "Full")
    )
  ]
    ++
    -- Standard TAGKEYS behavior (Mod+# to view, Mod+Shift+# to move)
    [ (mask ++ "M-" ++ [key], windows $ action tag)
    | (tag, key) <- zip myWorkspaces "1234567890"
    , (action, mask) <- [(W.greedyView, ""), (W.shift, "S-")]
    ]
  where
    toggleCopyToAll :: X ()
    toggleCopyToAll = do
      wss <- wsContainingCopies
      if null wss
        then windows copyToAll
        else killAllOtherCopies
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
  filterOutWsPP [scratchpadWorkspaceTag] $
    def
      { ppSep = xmobarColor (outline colors) "" " │ "
      , ppTitleSanitize = xmobarStrip
      , ppCurrent = xmobarColor (primary colors) ""
      , ppHidden = \ws ->
            if ws `elem` init (drop 6 myWorkspaces)
            then ""
            else xmobarColor (inversePrimary colors) "" ws
      , ppHiddenNoWindows = \ws ->
            if ws `elem` init (drop 6 myWorkspaces)
            then ""
            else xmobarColor (outline colors) "" ws
      , ppUrgent = xmobarColor (colorRed colors) (colorYellow colors)
      , ppOrder = \[ws, l, _, wins] -> [ws, wins]
      , ppExtras = [logTitlesPinned]
      }
  where
    formatFocused = wrap (xmobarColor (primary colors) "" "[") (xmobarColor (primary colors) "" "]") . xmobarColor (onPrimaryContainer colors) "" . ppWindow
    formatUnfocused = wrap (xmobarColor (outline colors) "" "[") (xmobarColor (outline colors) "" "]") . xmobarColor (outline colors) "" . ppWindow
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten myTitleLength
    logTitlesPinned :: Logger
    logTitlesPinned = do
        ws <- gets windowset
        let currWs = W.workspace (W.current ws)
            focused = fmap W.focus (W.stack currWs)
            currTag = W.tag currWs
            stackWins Nothing = []
            stackWins (Just s) = W.up s ++ [W.focus s] ++ W.down s
            wins = stackWins (W.stack currWs)
            otherWins = concatMap (\s -> if W.tag s /= currTag then stackWins (W.stack s) else []) (W.workspaces ws)
            isCopied w = w `elem` otherWins
        titles <- mapM (runQuery title) wins
        let ppCop t =
                wrap (xmobarColor (tertiary colors) "" "[") (xmobarColor (tertiary colors) "" "]")
                    . xmobarColor (tertiary colors) ""
                    . ppWindow
                    $ t
            ppFocCop t =
                wrap (xmobarColor (tertiary colors) "" "<") (xmobarColor (tertiary colors) "" ">")
                    . xmobarColor (tertiary colors) ""
                    . ppWindow
                    $ t
            formatOne w t
                | Just w == focused, isCopied w = ppFocCop t
                | Just w == focused = formatFocused t
                | isCopied w = ppCop t
                | otherwise = formatUnfocused t
        return . Just . unwords . Prelude.filter (not . null) $ zipWith formatOne wins titles

-- Main configuration
myConfig =
  ewmhFullscreen $
    def
      { modMask = myModMask
      , terminal = myTerminal
      , XMonad.workspaces = myWorkspaces
      , borderWidth = myBorderWidth
      , normalBorderColor = myNormalBorderColor
      , focusedBorderColor = myFocusedBorderColor
      , layoutHook = mouseResize $ windowArrange myLayoutHook
      , manageHook = myManageHook
      , handleEventHook =
          handleEventHook def
          <> Hacks.trayPaddingXmobarEventHook
              (className =? "stalonetray")
              "_XMONAD_TRAYPAD"
          <> Hacks.trayAbovePanelEventHook
              (className =? "stalonetray")
              (className =? "xmobar")
          <> Hacks.fixSteamFlicker
          <> Hacks.windowedFullscreenFixEventHook
      , startupHook = do
          spawn "xsetroot -cursor_name left_ptr"
          spawn "vicinae server --replace"
          spawnOnce "picom"
          spawnOnce "dunst"
          spawnOnce "udiskie -s -a"
          spawnOnce "~/.fehbg"
          spawnOnce "keepassxc --minimized"
          spawnOnce "lxqt-policykit-agent"
          spawnOnce "xss-lock -- betterlockscreen -l"
          spawnOnce "stalonetray"
          spawnOnce "snixembed --fork"
      }
      `additionalKeysP` myKeys

-- XMobar status bar configuration
myStatusBar = statusBarProp "xmobar ~/.config/xmobar/xmobar.hs" (pure myXmobarPP)

main :: IO ()
main = xmonad . ewmh . withEasySB myStatusBar (const (0, xK_VoidSymbol)) $ myConfig
