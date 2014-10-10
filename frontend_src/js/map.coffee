class Map

  constructor: ()->
    console.log('Map create')
    @dict_map =
      0: ''
      1: 'wall'
      3: 'grass'
      4: 'water'

  render_map: (map) ->
    div = $('<div/>', {
      id: 'box',
      text: 'I am box'
    })
    window.ttt = map
    for x in [0..map.length-1]
      for y in [0..map[x].length-1]
        $('<div/>', {
          id: 'box',
          'class': "box #{@dict_map[map[x][y]]}",
          'data-x': x,
          'data-y': y
        }).appendTo 'body'

      $('<div/>', {
        id: 'nbox',
        'style': 'clear: both;'
      }).appendTo 'body'