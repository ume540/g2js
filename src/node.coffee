
class Node extends Container
  constructor:(@nodeProps) ->
    super()
    @fillColor = "#FF0000"
    @borderColor = "#0000FF"
    @borderWidth = 0.1
    @selected = false
    
    # draw node's body.
    @redrawCtrl

    redrawNode:->
        @clear()
        @addChild(@drawBody)

    drawBody:->
        s = new Shape
        s.graphics.beginFill(@fillColor)
        s.graphics.setStrokeStyle(0.1)
        s.graphics.beginStroke(@borderColor)
        s.graphics.drawRoundRect(-@sz/2, -@sz/2, @sz, @sz, @sz/4)
        s.graphics.endFill()
        return s
