$(document).ready(function() {

    var my_tank = 0;
    var start = false;
    var stop = true;
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
                        'class': 'box wall',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                    continue;
                }
                if(map[x][y] == 3){
                    $('<div/>', {
                        id: 'box',
                        'class': 'box grass',
                        'data-x': x,
                        'data-y': y
                    }).appendTo('body');
                }
                if(map[x][y] == 4){
                    $('<div/>', {
                        id: 'box',
                        'class': 'box water',
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
            if(tank_json["id"] === undefined) {
              tank_json = {
                "id": tank_json[0],
                "direction": tank_json[1],
                "is_hold": tank_json[2],
                "wait": tank_json[3],
                "bullets": tank_json[4],
                "bullets_max": tank_json[5],
                "health": tank_json[6],
                "place_on_map": tank_json[7]
              };
            }
            console.log('this is tank', tank_json);
            my_tank = tank_json['id'];
            draw_tank(tank_json)
        });
    }
    start_game();

    function draw_tank(tank_json) {
        // return [@id, @direction, @is_hold, @wait, @bullets, @bullets_max, @health, @place_on_map]
        if(tank_json["id"] === undefined) {
          tank_json = {
            "id": tank_json[0],
            "direction": tank_json[1],
            "is_hold": tank_json[2],
            "wait": tank_json[3],
            "bullets": tank_json[4],
            "bullets_max": tank_json[5],
            "health": tank_json[6],
            "place_on_map": tank_json[7]
          };
        }
        var y = tank_json['place_on_map'][0];
        var x = tank_json['place_on_map'][1];
        var div = $('*[data-x='+x.toString()+'][data-y='+ y.toString()+']');
        div.attr('data-id_tank', tank_json['id']);
        div.html(tank_json['health']);
        if(tank_json['id'] == my_tank) {
            div.addClass('my_tank');
        }
        else {
            div.addClass('tank');
        }
        div.addClass(tank_json['direction'])
    }

    function move_tank(tank_json) {
        // toJson: -> [@id
                    // @direction
                    // @is_hold
                    // @wait
                    // @bullets
                    // @bullets_max
                    // @health
                    // @place_on_map
                    // @damage_inflicted
                    // @demage_obtained
                    // @destroyed]
        if(tank_json["id"] === undefined) {
          tank_json = {
            "id": tank_json[0],
            "direction": tank_json[1],
            "is_hold": tank_json[2],
            "wait": tank_json[3],
            "bullets": tank_json[4],
            "bullets_max": tank_json[5],
            "health": tank_json[6],
            "place_on_map": tank_json[7]
          };
        }
        var tank = $('[data-id_tank='+tank_json['id']+']');
        tank.html('');
        if(tank_json['id'] == my_tank) {
            tank.removeClass('my_tank');
        }
        else {
            tank.removeClass('tank');
        }
        tank.removeClass('left');
        tank.removeClass('right');
        tank.removeClass('down');
        tank.removeClass('up');
        tank.addClass('box');
        draw_tank(tank_json)
    }

    $('html').keydown(function(eventObject){
        if (event.keyCode == 37) {
            console.log("Ура нажали left");
            socket.emit('setDirection', 'left', false);
        }
        if (event.keyCode == 38) {
            console.log("Ура нажали up");
            socket.emit('setDirection', 'up', false);
        }
        if (event.keyCode == 39) {
            console.log("Ура нажали right");
            socket.emit('setDirection', 'right', false);
        }
        if (event.keyCode == 40) {
            console.log("Ура нажали down");
            socket.emit('setDirection', 'down', false);
        }
        if (event.keyCode == 81) {
            console.log('Ура нажали го');
            socket.emit('setDirection', 'up', true);
        }
        if (event.keyCode == 87) {
            console.log('Ура нажали stop');
            socket.emit('setDirection', 'up', false);
        }


    });

    socket.on('tanks', function(tanks) {
       // console.log(tanks[1].place_on_map);
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


    $('#start').bind('click', function() {
        if(!start) {
            console.log('start');
            socket.emit('start');
            stop = false
        }
    });

    $('#stop').bind('click', function() {
        if(!stop) {
            console.log('stop');
            socket.emit('stop');
            start = false
        }
    })

});
