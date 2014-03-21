class mk.Assets
  
  constructor: () ->
    @symbols = {}
    @curr = -1
    @type =  null
    @onCompleteCb = null

  load: (@type, @files, @onCompleteCb) ->
    @symbols[@type] = {}
    if @files.length is 0
      @onCompleteCb()
    else
      @curr = 0
      @loadNext()

  loadNext: () ->

    paper.project.importSVG @files[@curr], (item) =>

      sym = new paper.Symbol item
      name = @files[@curr].split('/').last()
      @symbols[@type][name] = sym
      
      console.log "#{name} loaded"

      if ++@curr >= @files.length
        @onCompleteCb()
      else @loadNext()