import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.IO
import XMonad.Actions.TopicSpace

browserCmd :: String
browserCmd = "firefox"

myTopics :: [Topic]
myTopics =
  [ "dashboard" -- the first one
  , "flowdock", "wire", "spotify", "web"
  , "emacs", "mordor", "system-management"
  ]
  
myTopicConfig :: TopicConfig
myTopicConfig = def
  { topicDirs = M.fromList $
      [ ("conf", "w/conf")
      , ("dashboard", "Desktop")
      , ("mordor", "w/mordor")
      , ("darcs", "w/dev-haskell/darcs")
      , ("haskell", "w/dev-haskell")
      , ("xmonad", "w/dev-haskell/xmonad")
      , ("tools", "w/tools")
      , ("movie", "Movies")
      , ("talk", "w/talks")
      , ("music", "Music")
      , ("documents", "w/documents")
      , ("pdf", "w/documents")
      ]
  , defaultTopicAction = const $ spawnShell >*> 2
  , defaultTopic = "dashboard"
  , topicActions = M.fromList $
      [ ("flowdock", spawn browserCmd)
      , ("spotify", spawn "spotify")
      , ("dashboard",  spawnShell)
      , ("web",        spawn browserCmd)
      ]
  }

spawnShell :: X ()
spawnShell = currentTopicDir myTopicConfig >>= spawnShellIn

spawnShellIn :: Dir -> X ()
spawnShellIn dir = spawn $ "urxvt '(cd ''" ++ dir ++ "'' && " ++ myShell ++ " )'"

goto :: Topic -> X ()
goto = switchTopic myTopicConfig

promptedGoto :: X ()
promptedGoto = workspacePrompt myXPConfig goto

promptedShift :: X ()
promptedShift = workspacePrompt myXPConfig $ windows . W.shift

-- extend your keybindings
myKeys conf@XConfig{modMask=modm} =
  [ ((modm              , xK_n     ), spawnShell) -- %! Launch terminal
  , ((modm              , xK_a     ), currentTopicAction myTopicConfig)
  , ((modm              , xK_g     ), promptedGoto)
  , ((modm .|. shiftMask, xK_g     ), promptedShift)
  {- more  keys ... -}
  ]
  ++
  [ ((modm, k), switchNthLastFocused myTopicConfig i)
  | (i, k) <- zip [1..] workspaceKeys]
  
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
    [  ("M-e", promptedGoto) -- e is bad for xinerama!
    ,  ("M-S-e", promptedShift)
    ,  ("M-<Return>", spawn "alacritty")
    ,  ("M4-l", spawn "alock")
    ,  ("M4-S-l", spawn "/home/risto/lock-and-suspend")
    ]
