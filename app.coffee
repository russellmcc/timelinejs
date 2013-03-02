require [], ->
  class EditLine
    constructor: (@canvas) ->
      @points = []
      @bg = '#0b486b'
      @fg = '#CFF09E'
      @ctx = @canvas.getContext '2d'
      @resize(@canvas.width, @canvas.height)

    resize: (w, h) ->
      @w = w
      @h = h
      r = window.devicePixelRatio ? 1
      @canvas.width = r*w
      @canvas.height = r*h
      ($ @canvas).css 'width', w
      ($ @canvas).css 'height', h

      @ctx.setTransform r,0,0,r,0,0

      @redraw()

    
    redraw: ->
      @ctx.fillStyle = @bg
      @ctx.fillRect 0, 0, @w, @h
      @ctx.strokeStyle = @fg
      @ctx.beginPath()
      @ctx.moveTo(0,0)
      @ctx.arc @w/2,
               @h/2,
               Math.min(@w, @h)/4,
               0, 2*Math.PI
      @ctx.stroke()

  e = new EditLine ($ '#lines')[0]
  h = e.canvas.height
  ($ window).resize -> e.resize $(@).width(), h
  e.resize $(@).width(), h