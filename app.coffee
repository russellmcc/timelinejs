require ['cs!timeline'], (EditLine)->

  h = ($ '#lines').height()
  e = new EditLine ($ '#lines')[0]
  ($ @).resize -> e.resize $(@).width(), h
  e.resize ($ @).width(), h