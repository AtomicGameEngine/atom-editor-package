glob = require 'glob'
fs = require 'fs'
spawn = require("child_process").spawn
osenv = require 'osenv'
open = require 'open'

{CompositeDisposable} = require 'atom'

module.exports = AtomicGameEngine =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atomic-game-engine:openEditor': => @openEditor()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atomic-game-engine:run': => @run()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  displayNoProjectsDialog: ->
    atom.confirm
      message:"No Atomic Project"
      detailedMessage:"There are no Atomic projects in the treeview"
      buttons:
        Ok: ->


  getAtomicConfig: ->

    configFilename = osenv.home() + "/.atomicgameengine/config.json"

    atomicConfig = null

    try
      atomicConfig = JSON.parse fs.readFileSync configFilename
    catch error

    if not atomicConfig or not atomicConfig.activated
      atomicConfig = null

    if not atomicConfig
      atom.confirm
        message:"atomic-cli package required"
        detailedMessage:"atomic-cli package must be installed and activated"
        buttons:
          "Get Instructions": -> open("https://www.npmjs.com/package/atomic-cli")
          Cancel: ->

    return atomicConfig

  runCLI: (command) ->

    config =  @getAtomicConfig()

    if not config
      return

    command = command || []
    opts = {}
    if process.platform is 'darwin'
      opts.detached = true
    opts.cwd = path
    opts.stdio = ["ignore", "ignore", "ignore"]

    command.unshift config.cliScript

    child = spawn config.nodePath, command, opts

    child.unref()

  getAtomicProjectPath: ->

    paths = atom.project.getPaths()

    for path in paths
      files = glob.sync path + "/*.atomic"
      if files.length
        return path

    @displayNoProjectsDialog()

    return null

  openEditor: ->

    path = @getAtomicProjectPath()

    if path
      @runCLI ["edit", path]

  run: ->

    path = @getAtomicProjectPath()

    if path

      platform = null

      if process.platform is 'darwin'
        platform = "mac"
      else
        platform = "windows"

      if platform
        @runCLI ["run", "--project", path, platform]
