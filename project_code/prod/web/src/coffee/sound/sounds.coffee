class mk.sound.Sounds
  
  constructor: () ->
    @loops = {}
    @oneshots = {}
    @curr = -1
    @type =  null
    @onCompleteCb = null

  load: (@type, @loops_files, @oneshots_files, @onCompleteCb) ->
    @files = @loops_files.concat @oneshots_files
    if @loops[@type] or @files.length is 0
      @onCompleteCb()
    else
      @loops[@type] = {}
      @oneshots[@type] = {}
      @curr = 0
      @loadNext()

  loadNext: () ->

    url = @files[@curr]
    args = url.split('/')
    kind = args[args.length-2]
    name = args.last().split('.')[0]
    sound = new Howl
      urls : [ url ]
      loop : kind is 'loop'
      onload : =>
        console.log "#{name} loaded"
        # console.log kind
        @[kind+'s'][@type][name] = sound
        if ++@curr >= @files.length
          @onCompleteCb()
        else @loadNext()
      onloaderror : ->
        console.log "error loading #{url}"