$ ->
  start = false
  stop = true
  my_direction = 'up'
  my_go = false
  my_tank = false
  lock = false
  callback = ->
    lock = false
  setTimeout callback, 3000
  create_map = (map) ->
    div = $('<div/>', {
    id: 'box',
    text: 'I am box'
    })
    for x in [0..map.length-1]
      for y in [0..map[x].length]
        if map[x][y] == 0
          $('<div/>', {
            id: 'box',
            'class': 'box',
            'data-x': x,
            'data-y': y
          }).appendTo 'body'
          continue
        if(map[x][y] == 1)
          $('<div/>', {
            id: 'box',
            'class': 'box wall',
            'data-x': x,
            'data-y': y
          }).appendTo('body')
          continue
        if(map[x][y] == 3)
          $('<div/>', {
            id: 'box',
            'class': 'box grass',
            'data-x': x,
            'data-y': y
          }).appendTo 'body'

        if(map[x][y] == 4)
          $('<div/>', {
            id: 'box',
            'class': 'box water',
            'data-x': x,
            'data-y': y
          }).appendTo 'body'
      $('<div/>', {
        id: 'nbox',
        'style': 'clear: both;'
      }).appendTo 'body'

  start_game =  ()->
    socket.emit('addTank', (tank_json) ->
      if tank_json["id"] == undefined
        my_tank = new Tank(tank_json)
        tank_json =
          "id": tank_json[0],
          "direction": tank_json[1],
          "is_hold": tank_json[2],
          "wait": tank_json[3],
          "bullets": tank_json[4],
          "bullets_max": tank_json[5],
          "health": tank_json[6],
          "place_on_map": tank_json[7]

      console.log('this is tank', tank_json);
      draw_tank(tank_json)
      )

  start_game()

  draw_tank = (tank_json) ->
    # return [@id, @direction, @is_hold, @wait, @bullets, @bullets_max, @health, @place_on_map]
    if(tank_json["id"] == undefined)
      tank_json =
        "id": tank_json[0],
        "direction": tank_json[1],
        "is_hold": tank_json[2],
        "wait": tank_json[3],
        "bullets": tank_json[4],
        "bullets_max": tank_json[5],
        "health": tank_json[6],
        "place_on_map": tank_json[7]

    y = tank_json['place_on_map'][0]
    x = tank_json['place_on_map'][1]
    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.attr('data-id_tank', tank_json['id'])
    div.html(tank_json['health'])
    if(tank_json['id'] == my_tank.id)
        div.addClass('my_tank')
    else
        div.addClass('tank')
    div.addClass(tank_json['direction'])

  move_tank = (tank_json) ->
    #// toJson: -> [@id
    #            // @direction
    #            // @is_hold
    #            // @wait
    #            // @bullets
    #            // @bullets_max
    #            // @health
    #            // @place_on_map
    #            // @damage_inflicted
    #            // @demage_obtained
    #            // @destroyed]
    if(tank_json["id"] == undefined)
      tank_json =
        "id": tank_json[0],
        "direction": tank_json[1],
        "is_hold": tank_json[2],
        "wait": tank_json[3],
        "bullets": tank_json[4],
        "bullets_max": tank_json[5],
        "health": tank_json[6],
        "place_on_map": tank_json[7]
    tank = $('[data-id_tank='+tank_json['id']+']')
    tank.html('')
    if tank_json['id'] == my_tank.id
        tank.removeClass('my_tank')
    else
        tank.removeClass('tank')
    tank.removeClass('left')
    tank.removeClass('right')
    tank.removeClass('down')
    tank.removeClass('up')
    tank.addClass('box')
    draw_tank(tank_json)

  show_tabl_tank = (tank_json) ->
    tank = '#t_'+tank_json['id']
    console.log('call show tabl_tank', tank, $(tank))
    if $(tank).length > 0
      console.log('not tank tr')
      div = $('<tr/>', {
        id: tank,
        'class': 'tr_tank',
      }).appendTo '.stats'
      td_id = $('<td/>', {
        id: '_id',
        'class': 'td_tank',
      }).appendTo div
      td_health = $('<td/>', {
        id: 'health',
        'class': 'td_tank',
      }).appendTo div
      td_damage_inflicted = $('<td/>', {
        id: 'damage_inflicted',
        'class': 'td_tank',
      }).appendTo div
      td_demage_obtained = $('<td/>', {
        id: 'demage_obtained',
        'class': 'td_tank',
      }).appendTo div

    else
      console.log 'yes tank tr'
      td_id = $(tank+' #_id')
      td_health = $(tank+' #health')
      td_damage_inflicted = $(tank +' #damage_inflicted')
      td_demage_obtained = $(tank ' #demage_obtained')

    td_id.html(tank_json['id'])
    td_health.html(if tank_json['health'] > 0 then tank_json['health'] else 0)
    td_damage_inflicted.html(if tank_json['damage_inflicted'] > 0 then tank_json['damage_inflicted'] else 0)
    td_demage_obtained.html(if tank_json['demage_obtained'] > 0 then tank_json['demage_obtained']  else 0)


  socket.on('tankDestroy', (tank_id) ->
    tank = $('[data-id_tank='+tank_id+']')
    tank.html('')
    if tank_id == my_tank.id
        tank.removeClass('my_tank')
    else
        tank.removeClass('tank')
    tank.removeClass('left')
    tank.removeClass('right')
    tank.removeClass('down')
    tank.removeClass('up')
    tank.addClass('box')
  )

  add_boost = (boost) ->
    x = boost[0][0]
    y = boost[0][1]

    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.addClass(boost[1])

  remove_boost = (boost) ->
    x = boost[0][0]
    y = boost[0][1]

    div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']')
    div.removeClass(boost[1])

  socket.on('newBoost', (boost) ->
    console.log('boost',boost)
    add_boost(boost)
  )
  socket.on('removeBoost', (boost) ->
    console.log('boost',boost)
    remove_boost(boost)
  )

  $('html').keydown( (eventObject) ->
    now_direct = my_direction
    go = my_go
    if (event.keyCode == 37)
        console.log("Ура нажали left")
        now_direct = 'left'

    if (event.keyCode == 38)
        console.log("Ура нажали up")
        now_direct = 'up'

    if (event.keyCode == 39)
        console.log("Ура нажали right");
        now_direct = 'right'

    if (event.keyCode == 40)
        console.log("Ура нажали down");
        now_direct = 'down'

    if (event.keyCode == 81)
        console.log('Ура нажали го');
        go = false;

    if (event.keyCode == 87)
        console.log('Ура нажали stop')
        go = true

    socket.emit('setDirection', now_direct, go)
    )

  socket.on('tanks', (tanks) ->
  #   // console.log(tanks[1].place_on_map);
    for tank in tanks
      move_tank(tank)
  )

  socket.on('info', (logg) ->
    console.log(logg)
  )

  socket.emit('map', (map) ->
    create_map(map)
  )

  socket.emit('tanks', (tanks_json) ->
    for tank in tanks_json
      draw_tank(tank)
  )


  $('#start').bind('click', () ->
    if not start
      console.log('start')
      socket.emit('start')
      stop = false
  )

  $('#stop').bind('click', () ->
    if not stop
      console.log('stop')
      socket.emit('stop')
      start = false
  )

