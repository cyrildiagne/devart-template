class mk.sound.Sounds
  
  constructor: () ->
    @loop = {}
    @sfx = {}
    @curr = -1
    @type =  null
    @onCompleteCb = null

  load: (@type, @sfx_files, @loops_files, @onCompleteCb) ->
    @files = @loops_files.concat @sfx_files
    if @sfx[@type] or @files.length is 0
      @onCompleteCb()
    else
      @loop[@type] = {}
      @sfx[@type] = {}
      @curr = 0
      @loadNext()

  loadNext: () ->
    url = @files[@curr]
    args = url.split('/')
    kind = args[args.length-2]
    name = args.last().split('.')[0]
    sound = new Howl
      urls : [ url ]
      loop : kind is 'loops'
      onload : =>
        if kind is 'sfx'
          sound.volume 0.4
        # console.log "#{name} loaded"
        @[kind][@type][name] = sound
        if ++@curr >= @files.length
          @onCompleteCb()
        else @loadNext()
      onloaderror : ->
        console.log "error loading #{url}"