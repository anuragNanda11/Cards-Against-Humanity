

#+var GAME_STATE = {
 #+	gameID: 1,
 #+	player_list: [
 #+		{email:"iain" ,score: 10},
 #+		{email:"player1" ,score: 14},
 #+		{email:"player2" ,score: 9},
 #+		{email:"player3" ,score: 4}
 #+	],
 #+	black_card: {id:10, text:"__________: kid tested, mother-approved."},
 #+	hand: [
 #+		{id:1, text:"Being on fire."},
 #+		{id:2, text:"Racism."},
 #+		{id:3, text:"Old-people smell."},
 #+		{id:4, text:"A micro&shy;penis."},
 #+		{id:5, text:"Women in yo&shy;gurt com&shy;mercials."},
 #+		{id:6, text:"Classit under&shy;tones."},
 #+		{id:7, text:"Not giving a shit about the Third World."},
 #+		{id:8, text:"Inserting a mason jar into my anus."}
 #+	],
 #+	vote_cards: [
 #+		{id:1, text:"Being on fire."},
 #+		{id:2, text:"Racism."},
 #+		{id:3, text:"Old-people smell."},
 #+		{id:4, text:"A micro&shy;penis."},
 #+	],
 #+}
 #+



require 'json'

module GamesHelper
	
	def self.update_state game_id, current_user_id
		game = Game.find game_id
		game_user = GameUser.
			where("game_id= ? AND user_id=?",game_id,current_user_id).first
		round = game.current_round
		gs = Hash.new
		gs['id'] = game.id 
		gs['round_id'] = round.id
		gs['num_players'] = game.player_count
		
		players = game.game_users
		
		b_card = round.game_black_card
		gs['black_card'] = {:id => b_card.id, :text => b_card.text}
		gs['hand'] = complile_card_list game_user.hand
		gs['round_cards'] = complile_card_list round.round_cards
		gs['votes']  = round.get_vote_tally
		
		if round.all_cards_in?
			gs['can_vote'] = true 
		else
			gs['can_vote'] = false
		end

		if game.should_end?
			gs['game_end'] = true
		else
			gs['game_end'] = false
		end

		if game.should_start?
			gs['started'] = true
		else
			gs['started'] = false
		end
			
		if(round.all_votes_in?)
			winner = round.get_winner
			gs['winner'] = winner
			round.update_score winner
		end
		gs['score_board'] = complile_score_board players
		push gs
		
		if round.all_votes_in?
			Round.create(game_id: game.id)
			update_state game_id, current_user_id
		end
	end


	def self.push game_state
		puts "pushing game_state"
		gs_json = game_state.to_json
		puts gs_json
		game = "game_#{game_state['id']}"
		timestamp = Time.now().to_s(:time)	
		Pusher.trigger( game, 'status_update', {
      	game_state: gs_json,
     	timestamp: timestamp
    })

	end

	def self.complile_score_board players
		player_list = []
		players.each do |player|
			player_list << {'username' => player.username,
				'score' => player.score}
		end
		return player_list
	end

	def self.complile_card_list game_cards
		card_list  = []
		game_cards.each do |game_card|
			card_list << {'id' => game_card.id,
				'text' => game_card.card.text}
		end
		return card_list
	end
end
