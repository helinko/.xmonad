import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.IO

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                }
    , terminal = "alacritty -e tmux"
      -- "st -f \"Liberation Mono:size=13\" -e tmux"
    }
    `additionalKeysP`
    [  ("M-<Return>", spawn "alacritty")
    ,  ("M4-l", spawn "alock")
    ,  ("M4-S-l", spawn "/home/risto/lock-and-suspend")
    ]
