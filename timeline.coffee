#~readme.out~
#
#----
#~options~

$ = jQuery
class TimeLine
  constructor: (@div, options) ->
    @$div = $ @div
    @canvas = document.createElement 'canvas'
    @div.appendChild @canvas

#~options~
# + `fgColor`: The line color in hex. default: `'#CFF09E'`
# + `ptColor`: The point color in hex. default: `'#3B8686'`
# + `dragColor`: The color of dragging points in hex. default: `'#79BD9A'`
# + `minRegion`: the length of the screen at the maximum zoom level.
#  default: `0.000003`
# + `ptRadius`: the drawn radius of the points. default: `10`
# + `tapTimeout`: the number of milliseconds before a tap is counted as a drag
#  default: `300`
# + `tapRadius`: the number of pixels a tap can move before it's counted as a
#  drag. default: `10`
    @o = $.extend({
      fgColor: '#CFF09E'
      ptColor: '#3B8686'
      dragColor: '#79BD9A'
      minRegion: 0.000003
      ptRadius: 10
      tapTimeout: 300 # in milliseconds
      tapRadius: 10 # in pixels
      }, options)
      
    @points = [[0,0],[1,1]]
    @sortedPoints = @points
    @visibleRegion = [0,1]
    @$ = $ @canvas
    @ctx = @canvas.getContext '2d'
    @dragging = {}

    @startPos = {}
    @startTime = {}
    @lastPos = {}
    
    @$.bind 'mousedown', (e) => @startDrag 'mouse', e

    @$.bind 'mousewheel', (e) =>
      e.preventDefault()
      scale = Math.pow(1.001, e.wheelDelta)
      @scale scale, @visibleRegion, (@screenToWorld @eventToPoint e)[0]

    @canvas.ongesturestart = (e) =>
      @gestureRegion= [@visibleRegion[0], @visibleRegion[1]]
      @gestureBase = (@screenToWorld @eventToPoint e)[0]

    @canvas.ongesturechange = (e) =>
      # don't scale if there's a drag active
      return if Object.keys(@dragging).length
      @scale e.scale, @gestureRegion, @gestureBase
      
    ($ window).bind 'mouseup', (e) => @endDrag 'mouse', e

    ($ window).bind 'mousemove', (e) => @moveDrag 'mouse', e

    @canvas.ontouchstart = (e) =>
      for t in e.changedTouches
        @startDrag t.identifier, t, e
    window.ontouchmove = (e) =>
      for t in e.changedTouches
        @moveDrag t.identifier, t, e
    window.ontouchend = (e) =>
      for t in e.changedTouches
        @endDrag t.identifier, t, e

    ($ window).resize => @resize()
    @resize()

    
  startDrag: (tag, e, e2) ->
    i = @getIndexUnder @eventToPoint e
    if i?
      e2?.preventDefault()
      e2?.stopPropagation()
      @dragging[tag] = i
      @points[i].dragging = tag
      @redraw()
    @startPos[tag] = @eventToPoint e
    @lastPos[tag] = @startPos[tag]
    @startTime[tag] = e.timeStamp ? e2?.timeStamp
      
  moveDrag: (tag, e, e2) ->
    if @dragging[tag]?
      e2?.preventDefault()
      e2?.stopPropagation()
      @points[@dragging[tag]] = @screenToWorld @eventToPoint e
      @points[@dragging[tag]].dragging = tag
      @updateSorted()
      @redraw()
    else if @startPos[tag]?
      e2?.preventDefault()
      e2?.stopPropagation()
      p = @eventToPoint e
      @scroll @lastPos[tag][0] - p[0]
      @lastPos[tag] = p
      
  wasTap: (tag, e, e2) ->
    p = @eventToPoint e
    t = e.timeStamp ? e2.timeStamp
    (@pointsWithin p, @startPos[tag], @o.tapRadius) and
    (t - @startTime[tag] < @o.tapTimeout)
    
  endDrag: (tag, e, e2) ->
    return if not @startPos[tag]?
    
    wasTap = @wasTap tag, e, e2
    if @dragging[tag]?
      e2?.preventDefault()
      if wasTap
        @points.splice(@dragging[tag],1)
        @updateSorted()
      else
        delete @points[@dragging[tag]].dragging
      delete @dragging[tag]
      @redraw()
    else
      if wasTap
        e2?.preventDefault()
        @points.push @screenToWorld @eventToPoint e
        @updateSorted()
        @redraw()
    delete @startPos[tag]
    delete @startTime[tag]

  scroll: (dx) ->
    vRange = @visibleRegion[1] - @visibleRegion[0]
    unitsPerPixel = vRange / @w
    @visibleRegion[0] += unitsPerPixel * dx
    @visibleRegion[0] = Math.min(1 - vRange, Math.max(0, @visibleRegion[0]))
    @visibleRegion[1] = @visibleRegion[0] + vRange
    @redraw()

  scale: (scale, origRegion, base) ->
    diff = [ origRegion[0] - base
           , origRegion[1] - base ]
    scale = Math.min(scale, (diff[1] - diff[0])/@o.minRegion)
    scaledRegion = [ diff[0] / scale + base
                   , diff[1] / scale + base]
    @visibleRegion = (Math.min(1,Math.max(0,t)) for t in scaledRegion)
    @redraw()

  updateSorted: ->
    @sortedPoints = @points[0...@points.length]
    @sortedPoints.sort (a, b) -> a[0] - b[0]

  eventToPoint: (e) ->
    offset = @$.offset()
    [e.pageX - offset.left, e.pageY - offset.top]

  # pt is [x,y]
  worldToScreen: (pt) ->
    xRatio = (pt[0] - @visibleRegion[0]) /
             (@visibleRegion[1] - @visibleRegion[0])
    [ xRatio * @w
    , @h - @h * pt[1]
    ]

  screenToWorld: (pt) ->
    xPos = pt[0] / @w * (@visibleRegion[1] - @visibleRegion[0]) +
           @visibleRegion[0]
    for t in [ xPos, (@h - pt[1]) / @h]
      Math.min(1, Math.max(t, 0))

  pointDistanceSq: (p1, p2) ->
    d = [p1[0] - p2[0], p1[1] - p2[1]]
    d[0]*d[0] + d[1]*d[1]

  pointsWithin: (p1, p2, r) ->
    (@pointDistanceSq p1, p2) < r*r
                
  getIndexUnder: (pt) ->
    for i in [0...@points.length]
      w = @worldToScreen @points[i]
      if @pointsWithin w, pt, @o.ptRadius
        return i
    return null

  handleCreateDelete: (pt) ->
    # check if there is a point nearby.  if so, delete it.
    i = @getIndexUnder pt
    if i?
      @points.splice(i, 1)
    else
      @points.push @screenToWorld pt
    @updateSorted()
    @redraw()
    
  resize: (w, h) =>
    @$div.width w if w?
    @$div.height h if h?
    @w = @$div.width()
    @h = @$div.height()
    r = window.devicePixelRatio ? 1
    @canvas.width = r*@w
    @canvas.height = r*@h
    @$.css 'width', @w
    @$.css 'height', @h

    @ctx.setTransform r,0,0,r,0,0

    @redraw()

  drawPoint: (p) ->
    @ctx.fillStyle = if p.dragging? then @o.dragColor else @o.ptColor
    sp = @worldToScreen p
    @ctx.beginPath()
    @ctx.arc sp[0], sp[1], @o.ptRadius, 0, 2 * Math.PI
    @ctx.fill()
    
  redraw: ->
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.strokeStyle = @o.fgColor
    @ctx.fillStyle = @o.ptColor
    @drawPoint p for p in @points
    lastY = @sortedPoints?[@sortedPoints.length-1]?[1] ? 0.5
    firstY = @sortedPoints?[0]?[1] ? 0.5
    @ctx.beginPath()
    first = @worldToScreen [0, firstY]
    @ctx.moveTo first[0], first[1]
    for p in @sortedPoints[0...]
      sp = @worldToScreen p
      @ctx.lineTo sp[0], sp[1]
    last = @worldToScreen [1, lastY]
    @ctx.lineTo last[0], last[1]
    @ctx.stroke()
    
$.fn.timeline = (m) ->
  a = arguments
  ret = @
  found = no

  methods =
    init : (o) ->
      $t = $ @
      if ($t.data 'timeline')?
        ret = ($t.data 'timeline') unless found
        found = yes
      else
        t = new TimeLine @, o if $t.is 'div'
        $t.data 'timeline', t
        ret = t unless found
        found = yes
    resize: (w, h) ->
      t = ($ @).data 'timeline'
      t.resize w, h if t?
          
  @each ->
    if methods[m]
      args = Array.prototype.slice.call a, 1
      methods[m].apply @, args
    else if (typeof m is 'object') or not m?
      methods.init.apply @, a
    else
      $.error "Method #{method} does not exist on jQuery.timeline"
  return ret
  return