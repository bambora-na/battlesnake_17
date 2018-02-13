#
# Copyright (c) 2017 - Beanstream Internet Commerce, Inc. <http://beanstream.com>
#
# MIT License. Use and abuse as you wish.
#
    # The dummy snake goes left only.

from flask import Blueprint
from flask import jsonify
from flask import request


from snakes.food_helper import move_to_food

snake = Blueprint('hungry_snake', __name__, static_folder='static')


@snake.route('/start', methods=['POST'])
def start():
    response = {
        "color": "#42aaf4",
        "head_url": "http://25.media.tumblr.com/236a431819d45798ad9ec689705eff4b/tumblr_mi390uTjf71qm4heyo2_500.gif",
        "name": "Nacho Libre",
        "taunt": "NACHOOOOOOOO",
        "head_type": "bendr",
        "tail_type": "freckled"
    }
    return jsonify(response)


@snake.route('/move', methods=['POST'])
def move():
    data = request.get_json()
    response = {
        "move": move_to_food(data),
        "taunt": "I like to wear stretchy pants"
    }
    return jsonify(response)