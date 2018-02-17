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
    , terminal = "st -f \"DejaVu Sans Mono:size=12\" -e tmux"
    
    }
    `additionalKeysP`
    [  ("M-<Return>", spawn "st -f \"DejaVu Sans Mono:size=12\"")
    ,  ("M4-l", spawn "alock -b shade:blur=85")
--    , ("M-x f", spawn "firefox")
    ]
