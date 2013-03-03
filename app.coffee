require [], ->
  class EditLine
    constructor: (@canvas) ->
      @points = [[0,0],[1,1]]
      @sortedPoints = @points
      @visibleRegion = [0,1]
      @bgColor = '#0b486b'
      @fgColor = '#CFF09E'
      @ptColor = '#3B8686'
      @dragColor = '#79BD9A'
      @ptRadius = 10
      @$ = $ @canvas
      @ctx = @canvas.getContext '2d'
      @resize(@canvas.width, @canvas.height)
      @dragging = {}

      @startPos = {}
      @startTime = {}
      
      # these determine whether events are considered
      # taps or drags.  If the touch/click was shorter
      # than the tapTimeout and was within the tap radius
      # then it's a tap.
      @tapTimeout = 300 # in milliseconds
      @tapRadius = 10 # in pixels

      @$.bind 'mousedown', (e) => @startDrag 'mouse', e

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

    startDrag: (tag, e, e2) ->
      i = @getIndexUnder @eventToPoint e
      if i?
        e2?.preventDefault()
        @dragging[tag] = i
        @points[i].dragging = tag
        @redraw()
      @startPos[tag] = @eventToPoint e
      @startTime[tag] = e.timeStamp ? e2?.timeStamp
        
    moveDrag: (tag, e, e2) ->
      if @dragging[tag]?
        e2?.preventDefault()
        @points[@dragging[tag]] = @screenToWorld @eventToPoint e
        @points[@dragging[tag]].dragging = tag
        @updateSorted()
        @redraw()

    wasTap: (tag, e, e2) ->
      p = @eventToPoint e
      t = e.timeStamp ? e2.timeStamp
      (@pointsWithin p, @startPos[tag], @tapRadius) and
      (t - @startTime[tag] < @tapTimeout)
      
    endDrag: (tag, e, e2) ->
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
        if @pointsWithin w, pt, @ptRadius
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
      
    resize: (w, h) ->
      @w = w
      @h = h
      r = window.devicePixelRatio ? 1
      @canvas.width = r*w
      @canvas.height = r*h
      @$.css 'width', w
      @$.css 'height', h

      @ctx.setTransform r,0,0,r,0,0

      @redraw()

    drawPoint: (p) ->
      @ctx.fillStyle = if p.dragging? then @dragColor else @ptColor
      sp = @worldToScreen p
      @ctx.beginPath()
      @ctx.arc sp[0], sp[1], @ptRadius, 0, 2 * Math.PI
      @ctx.fill()
      
    redraw: ->
      @ctx.fillStyle = @bgColor
      @ctx.fillRect 0, 0, @w, @h
      @ctx.strokeStyle = @fgColor
      @ctx.fillStyle = @ptColor
      @drawPoint p for p in @points
      @ctx.beginPath()
      firstPoint = @worldToScreen @sortedPoints[0]
      @ctx.moveTo(firstPoint[0], firstPoint[1])
      for p in @sortedPoints[1...]
        sp = @worldToScreen p
        @ctx.lineTo(sp[0], sp[1])
      @ctx.stroke()

  h = ($ '#lines').height()
  e = new EditLine ($ '#lines')[0]
  ($ @).resize -> e.resize $(@).width(), h
  e.resize ($ @).width(), h