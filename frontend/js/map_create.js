$(document).ready(function() {
    var map = [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,3,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
           [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]];
    function create_map(map) {
        var div = $('<div/>', {
        id: 'box',
        text: 'I am box'
        });
        for(var x=0; x<map.length; x++) {
            for(var y=0; y<map[x].length; y++){
                if(map[x][y] == 0) {
                    $('<div/>', {
                        id: 'box',
                        'class': 'box',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                    continue;
                }
                if(map[x][y] == 1) {
                    $('<div/>', {
                        id: 'box',
                        'class': 'wall',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                    continue;
                }
                if(map[x][y] == 3){
                    $('<div/>', {
                        id: 'box',
                        'class': 'grass',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                }
                if(map[x][y] == 4){
                    $('<div/>', {
                        id: 'box',
                        'class': 'water',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                }
            }
            $('<div/>', {
                id: 'nbox',
                'style': 'clear: both;'
            }).appendTo('body');
        }
    }

    function start_game() {
        socket.emit('addTank', function(tank_json) {
            console.log('this is tank', tank_json);
            draw_tank(tank_json)
        });
    }

    function draw_tank(tank_json) {
        var y = tank_json['place_on_map'][0];
        var x = tank_json['place_on_map'][1];
        var div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']');
        div.removeClass();
        div.attr('data-id_tank', tank_json['id']);
        div.addClass('tank');
    }

    function move_tank(tank_json) {
        var tank = $('[data-id_tank='+tank_json['id']+']');
        tank.removeClass();
        tank.addClass('box');
        draw_tank(tank_json)
    }

    socket.on('tanks', function(tanks) {
       console.log(tanks[1].place_on_map);
       for (var _i = 0, _len = tanks.length; _i < _len; _i++) {
            var tank = tanks[_i];
            move_tank(tank);
       }
    });

    socket.emit('map', function(map) {
        create_map(map);
    });

    socket.emit('tanks', function(tanks_json) {
       for (var _i = 0, _len = tanks_json.length; _i < _len; _i++) {
            var tank = tanks_json[_i];
            draw_tank(tank);
       }
    });
    $('#start_game').on('click', start_game());



});