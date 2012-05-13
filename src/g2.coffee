# g2.coffee - g2.js
return define "g2", ["js/vendor/easeljs-0.4.2.min"], (easel) ->
  class G2Panel
    constructor:(@canvas)->
      @stage = new Stage(canvas)

    hello:->
      alart "hello"
