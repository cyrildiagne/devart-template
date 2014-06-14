class mk.sound.Sounds
  
  constructor: () ->
    @sfx = {}
    @keys = []
    @curr = -1
    @type =  null
    @onCompleteCb = null

  load: (@type, @files, @onCompleteCb) ->
    if @sfx[@type]
      @onCompleteCb()
    else
      @sfx[@type] = {}
      @keys.push k for k,v of @files
      if @keys.length is 0
        @onCompleteCb()
        return
      @curr = 0
      @loadNext()

  loadNext: () ->
    name = @keys[@curr]
    file = @files[name]
    url = 'assets/sounds/'+@type+'/sfx/'+file+'.mp3'
    sound = new Howl
      urls : [ url ]
      onload : =>
        # sound.volume 0.6
        # console.log "#{name} loaded"
        @sfx[@type][name] = sound
        if ++@curr >= @keys.length
          @onCompleteCb()
        else @loadNext()
      onloaderror : ->
        console.log "error loading #{url}"