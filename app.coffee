require ['cs!timeline'], ()->

  h = ($ '.lines').height()
  ($ '.lines').timeline()
  ($ @).resize ->
    ($ '.lines').timeline 'resize', $(@).width(), h
  ($ '.lines').timeline 'resize', ($ @).width(), h