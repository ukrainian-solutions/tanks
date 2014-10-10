class Boost

  constructor: ()->
    console.log('Boost create')

  add_boost: (boost)->
    y = boost[0][0]
    x = boost[0][1]

    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.addClass(boost[1])

  remove_boost: (boost) ->
    y = boost[0][0]
    x = boost[0][1]

    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.removeClass(boost[1])
