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
