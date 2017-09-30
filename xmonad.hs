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
    , terminal = "st -e tmux"
    --    , modMask = mod4Mask     -- Rebind Mod to the Windows key
    }
    `additionalKeysP`
    [ ("M-<Return>", spawn "st")
--    , ("M-x f", spawn "firefox")
    ]


