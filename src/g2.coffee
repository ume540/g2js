# g2.coffee -> g2.js

###
G2.GraphPanel class
-------------------------------------------------------------------------

graphics data is json format:
-----------------------------
{
  nodes:[                 <= ノードデータのリスト
    {
      id:     0,          <= 必須. ノードを一意に識別する番号.
      class:  "router",   <= ノードのクラス（種別）を表す文字列. (default:"default")
      name:   "NODE-00",  <= ノードの名前（ラベル）文字列.(default:"")
      x:      100.0       <= ノードのx座標.(default:0)
      y:      200.0       <= ノードのy座標.(default:0)
                          ↓ ノードには(jsの属性として使用可能な範囲で)好きな名前のプロパティを付加できる.
      prop00: "active",      プロパティは複数付加できて、その型はなんでも良い.
      prop01: 1.0,
      ...
    },
    ...
  ],
  edges:[
    {
      id:     0,          <= 必須. エッジを一意に識別する番号.
      snode:  0,          <= ソースノードのid.
      dnode:  1,          <= デスティネーションノードのid.
      class:  "route",    <= エッジのクラス（種別）を表す文字列. (default:"default")
      name:   "EDGE-00",  <= エッジの名前（ラベル）文字列.(default:"")
                          ↓ エッジには(jsの属性として使用可能な範囲で)好きな名前のプロパティを付加できる.
      prop00: "active",      プロパティは複数付加できて、その型はなんでも良い.
      prop01: 1.0,
      ...
    },
    ...
  ]
}

configuration data is json format:
----------------------------------
{
  "class-name":{
    prop01:10.0,
    ...
  },
  ...
}
###
class GraphPanel
  constructor:(canvas)->
    @stage = new Stage(canvas)
    @enableUiControlBox = false
    @nodes = {}
    @edges = {}
    
  clear:->
    # clear all graphics objects.
    @stage.clear
    @nodes = {}
    @edges = {}
  
  set:(gData)->
    if gData.nodes
      for d in gData.nodes
        @nodes[d.id] = @stage.addChild(new Node(@, d))    
    if gData.edges
      for d in gData.edges
        @edges[d.id] = @stage.addChildAt(new Edge(@, d), 0)
    @stage.update()
    
  showUiControlBox:->
    if @enableUiControlBox is true
      if @uiControlBox
        # create UiControlBox.
        _createUiControlBox()
      # add UiControlBox to stage.
      @stage.addChild(@uiControlBox)

  _createUiCOntrolBox:->
    @uiCOntrolBox = Container
    s = new Shape()
    s.graphics.drawRect(0, 0, 100, 50)
    @uiControlBox.addChild(s)
   
###
G2.Node class
-------------------------------------------------------------------------
###
class Node extends Container
  constructor:(@g2panel, @props) ->
    super()
    @fillColor = "#FF0000"
    @borderColor = "#0000FF"
    @borderWidth = 0.1
    @selected = false
    @x = props.x
    @y = props.y
    @sz = 10.0

    # onClick callback
    @onClick = (e)->
      console.log "onClick fired."
      if @selected
        @selected = false
        @borderWidth = 0.1
      else
        @selected = true
        @borderWidth = 1.0
      @redrawNode()
      @g2panel.stage.update()
    
    @onPress = (e)->
      console.log "onPress fired."
      e.onMouseMove = (e)->
        console.log "onMouseMove fired"
      e.onMouseUp = (e)->
        console.log "onMouseUp fired."
        
    
    # draw node's graphics.
    @redrawNode()

  redrawNode:->
    @removeAllChildren()
    @addChild(@_drawBody())

  _drawBody:->
    s = new Shape()
    s.graphics.beginFill(@fillColor)
    s.graphics.setStrokeStyle(@borderWidth)
    s.graphics.beginStroke(@borderColor)
    s.graphics.drawRoundRect(-@sz/2, -@sz/2, @sz, @sz, @sz/4)
    s.graphics.endFill()
    return s

###
G2.Edge class 
-------------------------------------------------------------------------
###
class Edge extends Container
  constructor:(@g2panel, @props) ->
    super()
    @color = "#000000"
    @width = 0.1
    @selected = false
    
    # onClick callback
    @onClick = (e)->
      if @selected
        @selected = false
        @width = 0.1
      else
        @selected = true
        @width = 1.0
      @redrawEdge()
      @g2panel.stage.update()
    
    # draw edge's graphics
    @redrawEdge()
    
  redrawEdge:->
    @removeAllChildren()
    @addChild(@_drawBody())
    
  _drawBody:->
    snode = @g2panel.nodes[@props.snode]
    dnode = @g2panel.nodes[@props.dnode]
    if snode and dnode
      s = new Shape()
      s.graphics.setStrokeStyle(@width)
      s.graphics.beginStroke(@color)
      s.graphics.moveTo(snode.x, snode.y);
      s.graphics.lineTo(dnode.x, dnode.y);
      s.graphics.endStroke();
      return s
    else
      return null

###
exports to global(window) namespace.
-------------------------------------------------------------------------
###
window.G2 = {}
window.G2.GraphPanel = GraphPanel
