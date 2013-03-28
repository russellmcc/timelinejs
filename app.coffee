require ['cs!timeline'], ()->

  h = ($ '.lines').height()
  ($ '.lines').timeline()
  ($ '.lines').timeline 'resize', '100%'