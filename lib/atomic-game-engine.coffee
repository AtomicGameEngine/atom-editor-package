glob = require 'glob'
fs = require 'fs'
spawn = require("child_process").spawn

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

  getAtomicConfig: ->

    configFilename = process.env["HOME"] + "/.atomicgameengine/config.json"

    atomicConfig = null

    try
      atomicConfig = JSON.parse fs.readFileSync configFilename
    catch error

    if not atomicConfig or not atomicConfig.activated
      atomicConfig = null
      console.log "display atomic-cli install and activate info"

    return atomicConfig

  runCLI: (command) ->

    config =  @getAtomicConfig()

    if not config
      return

    command = command || []
    opts = {}
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

      if platform
        @runCLI ["run", "--project", path, platform]
