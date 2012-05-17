# g2.coffee -> g2.js

###
G2.GraphPanel class
-------------------------------------------------------------------------
主にインタラクティブなグラフデータの描画を行うパネル.

パネルは以下の3つのレイヤから構成される。

(1) background layer
(2) visualization layer
(3) floating tools layer


グラフデータは以下のJSONデータとして与える.
-------------------------------------------
{
  nodes:[                 <= ノードデータのリスト
    {
      id:     0,          <= 必須. ノードを一意に識別する番号.
      class:  "router",   <= ノードのクラス（種別）を表す文字列. (default:"default")
      name:   "NODE-00",  <= ノードの名前（ラベル）文字列.(default:"")
      x:      100.0,      <= ノードのx座標.(default:0)
      y:      200.0,      <= ノードのy座標.(default:0)
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
    @enableUiControlBox = false
    @nodes = {}
    @edges = {}
    # StageとLayerの初期化.
    @stage = new Stage(canvas)
    @_initLayer()
    @stage.update()
   
  update:->
    @stage.update()
     
  clear:->
    # clear all graphics objects.
    @nodes = {}
    @edges = {}
    @visLayer.clear()
    @selLayer.clear()
    @toolLayer.clear()
  
  _initLayer:->
    # レイヤーの初期化.
    @bgLayer = new Background(@)
    @visLayer = new SelectorLayer(@)
    @selLayer = new Container()
    @toolLayer = new Container()
    @stage.addChild(@bgLayer, @visLayer, @selLayer, @toolLayer)
    
  selectNodeInRectangle:(rect)->
    #ラバーバンド内に中心が存在するノードを選択する.
    for i, n of @nodes
      if not n.select and rect.hitTest(n.x, n.y)
        n.toggleSelect()
    null

  set:(gData)->
    # 表示するグラフデータの設定.
    # グラフデータフォーマットは、このクラスのヘッダを参照.
    if gData.nodes
      for d in gData.nodes
        @nodes[d.id] = @visLayer.addChild(new Node(@, d))    
    if gData.edges
      for d in gData.edges
        @edges[d.id] = @visLayer.addChildAt(new Edge(@, d), 0)
    @stage.update()
    null
    
  showUiControlBox:->
    # Floating Toolboxの作成、表示.
    if @enableUiControlBox is true
      if @uiControlBox
        # create UiControlBox.
        _createUiControlBox()
      # add UiControlBox to stage.
      @toolLayer.addChild(@uiControlBox)
    null
    
  _createUiControlBox:->
    # Floating Toolboxの作成
    @uiControlBox = Container
    s = new Shape()
    s.graphics.drawRect(0, 0, 100, 50)
    @uiControlBox.addChild(s)
    null

###
G2.BackgroundLayer class
-------------------------------------------------------------------------
###
class Background extends Container
  constructor:(@g2panel, @props) ->
    super()
    @fillColor = Graphics.getRGB(250, 200, 50, 0.1)
    @_createBackground()
    
  _createBackground:->
    # 背景の作成.
    s = new Shape()
    s.graphics.beginFill(@fillColor)
    s.graphics.drawRect(0, 0, 4096, 2048)
    s.graphics.endFill()
    @addChild(s)
    # 領域選択用のラバーバンドの表示と、選択時のアクション選択を行う
    # マウスイベントのハンドリング.
    @onPress = @_onMousePress

  _onMousePress:(e)->
    # 背景でマウスを押した時のハンドラ.
    #   (1) ラバーバンド選択する.
    # 選択ラバーバンドの描画開始.
    console.log "fire bgLayer.onMousePress"
    e.onMouseMove = (e)-> @target._onMouseMove(@, e)
    e.onMouseUp = (e)-> @target._onMouseUp(@, e)
    
  _onMouseMove:(org, e)->
    # マウス移動時のハンドラ.
    console.log "fire bgLayer.onMouseMove"
    # ラバーバンドを再描画する.
    @g2panel.selLayer.redrawRubberBand(org.stageX, org.stageY, e.stageX, e.stageY)
    @g2panel.update()
    
  _onMouseUp:(org, e)->
    console.log "fire bgLayer.onMouseUp"
    rect = @g2panel.selLayer.redrawRubberBand(org.stageX, org.stageY, e.stageX, e.stageY)
    @g2panel.update()
    
    @g2panel.selectNodeInRectangle(rect)
    @g2panel.selLayer.removeAllChildren()
    @g2panel.stage.update()

###
G2.SelectorLayer
-------------------------------------------------------------------------
###
class SelectorLayer extends Container
  constructor:(@g2panel, @props) ->
    super()
    @fillColor = Graphics.getRGB(0, 200, 100, 0.1)
    @borderColor = Graphics.getRGB(0, 100, 50)
    @borderWidth = 0.2
   
  redrawRubberBand:(x1, y1, x2, y2)->
    #ラバーバンドの描画.
    s = new Shape()
    s.graphics.beginFill(@fillColor)
    s.graphics.setStrokeStyle(@borderWidth)
    s.graphics.beginStroke(@borderColor)
    s.graphics.drawRect(x1, y1, x2 - x1, y2 - y1)
    s.graphics.endFill()
    @removeAllChildren()
    @addChild(s)
    return s
    
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
    @sz = 20.0
    @edges = {}
    @onPress = @_onMousePress
    # draw node's graphics.
    @redrawNode()

  redrawNode:->
    @removeAllChildren()
    @addChild(@_drawBody())

  _onMousePress:(e)->
    console.log "fire Node.onMousePress"
    e.pressX = e.stageX
    e.pressY = e.stageY
    e.offsetX = e.stageX - @x
    e.offsetY = e.stageY - @y
    e.onMouseMove = (e)-> @target._onMouseMove(@, e)
    e.onMouseUp = (e)-> @target._onMouseUp(@, e)
    
  _onMouseMove:(org, e)->
    console.log "fire Node.onMouseMove"
    @_onMoveOperation(org, e)
    
  _onMouseUp:(org, e)->
    console.log "fire Node.onMouseUp"
    # マウスがpress時と同じ位置であれば「ノード選択」
    # マウスがpress時から移動していれば「ノード移動」
    if org.pressX is e.stageX and org.pressY is e.stageY
      @_onSelectOperation()
    else
      @_onMoveOperation(org, e)

  _onSelectOperation:->
      @toggleSelect()
      @g2panel.update()
    
  _onMoveOperation:(org, e)->
      # move self node.
      @x = e.stageX - org.offsetX
      @y = e.stageY - org.offsetY
      # move linked edges.
      for i, edge of @edges
        edge.redrawEdge()
      @g2panel.update()
        
  toggleSelect:->
      if @selected
        @selected = false
        @borderWidth = 0.1
      else
        @selected = true
        @borderWidth = 1.0
      @redrawNode()
    
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
      @g2panel.update()
    
    # draw edge's graphics
    @redrawEdge()
    
  redrawEdge:->
    @removeAllChildren()
    @addChild(@_drawBody())
    
  _drawBody:->
    snode = @g2panel.nodes[@props.snode]
    dnode = @g2panel.nodes[@props.dnode]
    if snode and dnode
      # register to node
      snode.edges[@props.id] = @
      dnode.edges[@props.id] = @
      # draw edge graphics.
      s = new Shape()
      s.graphics.setStrokeStyle(@width)
      s.graphics.beginStroke(@color)
      s.graphics.moveTo(snode.x, snode.y);
      s.graphics.lineTo(dnode.x, dnode.y);
      s.graphics.endStroke();
      return s
    else
      console.log "node #{@props.snode} was not found." if not snode
      console.log "node #{@props.dnode} was not found." if not dnode
      return null

###
exports to global(window) namespace.
-------------------------------------------------------------------------
###
window.G2 = {}
window.G2.GraphPanel = GraphPanel
