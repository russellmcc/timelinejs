<!DOCTYPE html>
<html>
<head>
    <link href='main.css' rel='stylesheet' type='text/css'/>
    <link href="http://fonts.googleapis.com/css?family=Ubuntu+Mono|Ubuntu+Condensed|Ubuntu" rel="stylesheet" type="text/css"/> 
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/jquery-migrate-1.1.1.min.js"></script>
    <script src="https://www.russellmcc.com/timelinejs/master/timeline.min.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no"></meta>
    <meta charset="UTF-8">
</head>
<body>
<a href="https://github.com/russellmcc/timelinejs"><img style="position: absolute; top: 0; left: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_left_gray_6d6d6d.png" alt="Fork me on GitHub"></a>
<div id="container">

# Time­Line.js
### multitouch timelines for javascript

<div id="timeline-intro" style="height:200px;"></div>
<script type="text/javascript">
  var p = [];
  var n = 35;
  for(var i = 0; i < n; ++i) {
      var h = 0.5 + 0.3 * Math.sin(i/n * Math.PI) * Math.cos(i * Math.PI);
      p.push([i/n, h]);
  }
  $('#timeline-intro').timeline({
     points: p
  });
</script>

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

## API Basics

include timeline.js

    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/jquery-migrate-1.1.1.min.js"></script>
    <script src="https://www.russellmcc.com/timelinejs/master/timeline.min.js"></script>

create a div with a height

    <div id="timeline" style="height:200px;"></div>

initialize the timeline

    $("#timeline").timeline();

it looks like this:

<div id="timeline" style="height:200px;"></div>
<script type="text/javascript">
   $("#timeline").timeline();
</script>

## Initial­ization Options

pass in an object to the initialization to set the options

    $("#timeline").timeline({
       fgColor: 'chartreuse',
       ptColor: 'violet',
       dragColor: 'aqua',
       ptRadius: 30,
       points: [[.25, .5], [.5,.75], [.75,.5]]
    });

<div id="timeline2" style="height:200px;"></div>
<script type="text/javascript">
   $("#timeline2").timeline({
       fgColor: 'chartreuse',
       ptColor: 'violet',
       dragColor: 'aqua',
       ptRadius: 30,
       points: [[.25, .5], [.5,.75], [.75,.5]]
    });
</script>


###available options

* `fgColor`: The line color in hex. default: `'#CFF09E'`
* `ptColor`: The point color in hex. default: `'#3B8686'`
* `dragColor`: The color of dragging points in hex. default: `'#79BD9A'`
* `minRegion`: the length of the screen at the maximum zoom level.
 default: `0.000003`
* `ptRadius`: the drawn radius of the points. default: `10`
* `tapTimeout`: the number of milliseconds before a tap is counted as a drag
 default: `300`
* `tapRadius`: the number of pixels a tap can move before it's counted as a
 drag. default: `10`
* `points` : the initial points as an array of two-element arrays.
* `visibleRegion` : the initial visible region as a two-element array.

## Resizing

resize like this:

    $("#timeline").timeline({points:[[.5,.5]]});       
    $("#timeline").timeline('resize', 200, 200)

<div id="timeline3" style="margin:auto; height:200px; background:'#222';"></div>
<script type="text/javascript">
   $("#timeline3").timeline({points:[[.5,.5]]});
   $("#timeline3").timeline('resize', 200, 200)
</script>

## Setting points


just get the timeline object and call `setPoints`.  Don't do this during a drag.

    $("#timeline").timeline({points:[[.5,.5]]});       
    $("#timeline").timeline().setPoints([[.25,.25], [.75,.75]])

<div id="timeline4" style="height:200px; background:'#222';"></div>
<script type="text/javascript">
   $("#timeline4").timeline();
   $("#timeline4").timeline().setPoints([[.25,.25], [.75,.75]])
</script>

## Getting points

    $("#timeline").timeline({points:[[.5,.5]]});
    var updatePoints = function(){
        var points = $("#timeline").timeline().getPoints();
        var str = "<dl>";
        for(var i = 0; i < points.length; ++i) {
            str += "<dt>" + points[i][0].toFixed(2) + "</dt>";
            str += "<dd>" + points[i][1].toFixed(2) + "</dd>";
        }
        str += "<dl>";
        $("#points").html(str);
    }
    $("#timeline").bind('change', updatePoints);
    updatePoints();

<div id="points"></div>
<div id="timeline5" style="height:200px; background:'#222';"></div>
<script type="text/javascript">
    $("#timeline5").timeline({points:[[.5,.5]]});
    var updatePoints = function(){
        var points = $("#timeline5").timeline().getPoints();
        var str = "<dl>";
        for(var i = 0; i < points.length; ++i) {
            str += "<dt>" + points[i][0].toFixed(2) + "</dt>";
            str += "<dd>" + points[i][1].toFixed(2) + "</dd>";
        }
        str += "<dl>";
        $("#points").html(str);
    }
    $("#timeline5").bind('change', updatePoints);
    updatePoints();
</script>

</div>
</body>
