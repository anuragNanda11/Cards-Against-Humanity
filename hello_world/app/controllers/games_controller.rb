	#FOR REFRENCE: ATTRIBUTES OF THIS MODEL
	#t.integer  "dealer_id"
    #t.integer  "round_id"
    #t.datetime "created_at", null: false
    #t.datetime "updated_at", null: false
    #t.integer  "user_id"

class GamesController < ApplicationController


#this create should be called with game_cards create.
def create
	@game = Game.new
	@game.save
	render :json => @game
end


def index
	#TODO : this can't be all the games	
 @games = Game.all 
 render	:json => @games
end





end
