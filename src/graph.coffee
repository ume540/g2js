# Graph class
# -------------------------------------------------------------------------
#
# graphics data is json format:
# {
#   nodes:[                 <= ノードデータのリスト
#     {
#       id:     0,          <= 必須. ノードを一意に識別する番号.
#       class:  "router",   <= ノードのクラス（種別）を表す文字列. (default:"default")
#       name:   "NODE-00",  <= ノードの名前（ラベル）文字列.(default:"")
#       x:      100.0       <= ノードのx座標.(default:0)
#       y:      200.0       <= ノードのy座標.(default:0)
#                           ↓ ノードには(jsの属性として使用可能な範囲で)好きな名前のプロパティを付加できる.
#       prop00: "active",      プロパティは複数付加できて、その型はなんでも良い.
#       prop01: 1.0,
#       ...
#     },
#     ...
#   ],
#   edges:[
#     {
#       id:     0,          <= 必須. エッジを一意に識別する番号.
#       snode:  0,          <= ソースノードのid.
#       dnode:  1,          <= デスティネーションノードのid.
#       class:  "route",    <= エッジのクラス（種別）を表す文字列. (default:"default")
#       name:   "EDGE-00",  <= エッジの名前（ラベル）文字列.(default:"")
#                           ↓ エッジには(jsの属性として使用可能な範囲で)好きな名前のプロパティを付加できる.
#       prop00: "active",      プロパティは複数付加できて、その型はなんでも良い.
#       prop01: 1.0,
#       ...
#     },
#     ...
#   ]
# }
class graph
  constructor:(@stage)->
    @enableUiControlBox = false
    @nodes = {}
    @edges = {}
    
  clear:->
    # clear all graphics objects.
    @stage.clear
    @nodes = {}
    @edges = {}
  
  set:(gData)->
    if gData.nodes is not null
      for d in gData.nodes
        @nodes[d.id] = @stage.addChild(new Node(d.id, d.x, d.y, 10.0))
        
    if gData.edges in not null
      for d in gData.edges
        @edges[d.id] = @stage.addChild(new Edge(d.id, d.snode, d.dnode))
    
  showUiControlBox:->
    if @enableUiControlBox is true
      if @uiControlBox is null
        # create UiControlBox.
        
      # add UiControlBox to stage.
      @stage.addChild(@uiControlBox)
