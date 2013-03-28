# timeline.js

timeline.js is a multi-touch widget for editing
automation-style timelines. The idea is similar to [duration.cc][1].
View the live demo [here][2].

[1]: http://duration.cc/
[2]: http://russellmcc.com/timelinejs/

## Touch Controls
 + pinch-to-zoom.
 + drag anywhere away from the line to pan
 + drag any number of control points to edit the line
 + tap a control point to delete it
 + tap away from a control point to create a new one.

## Mouse Controls
 + mousewheel up/down to zoom in/out
 + mousewheel left/right to pan
 + click and drag outside the line to pan
 + click and drag a control point to edit the line
 + click a control point to delete it
 + click away from a control point to create a new one.

## API

timeline.js is a jquery plug in.  You must first include jquery,
then include timeline.js.  To create a timeline, use $.timeline() on
a `div` element:

          $('#timeline').timeline();

to access the timeline object, use $.timeline() on an already-created
object, or, alternatively, use $.data('timeline'). To access the point
data, use `.getPoints()`, and to change the points, use `.setPoints()`
`.setPoints()`.  See the live demo for more info.

to resize the timeline, use `$.timeline('resize', width, height)`.

## Creation Options:
to customize your timeline, pass in an options object when you create
the timeline.

          $('#timeline').timeline({fgColor: '#000'});

available options are:
 + `fgColor`: The line color in hex. default: `'#CFF09E'`
 + `ptColor`: The point color in hex. default: `'#3B8686'`
 + `dragColor`: The color of dragging points in hex. default: `'#79BD9A'`
 + `minRegion`: the length of the screen at the maximum zoom level.
  default: `0.000003`
 + `ptRadius`: the drawn radius of the points. default: `10`
 + `tapTimeout`: the number of milliseconds before a tap is counted as a drag
  default: `300`
 + `tapRadius`: the number of pixels a tap can move before it's counted as a
  drag. default: `10`
 + `points` : the initial points as an array of two-element arrays.
 + `visibleRegion` : the initial visible region as a two-element array.

