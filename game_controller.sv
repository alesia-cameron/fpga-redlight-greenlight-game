/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: 
clk, reset, start_key, red_light, player_moved, 
player_x, ai1_x, ai2_x, ai3_x

Outputs: 
game_active, player_score, ai1_score, ai2_score, ai3_score, 
round_num, show_final_scores, show_start_screen, player_lost, player_blink

Description: Module runs main game logic, controls the flow through different 
game phases title screen, three racing rounds, final winner screen. 
During gameplay, it watches four racers to see who crosses finish line first 
and awards points. It catches player if they move during red lighs and 
disqualifies them from that round, keeps track of scores and rounds 
and decides when game over
*/

module game_controller (
    input logic clk,             
    input logic reset,               
    input logic start_key,              
    input logic red_light,  //current traffic light state from traffic_light module
    input logic player_moved,  // high when player press movement keys
    input logic [9:0] player_x, // horizontal position of player car 
    input logic [9:0] ai1_x,    // horizontal position of AI opponent 1
    input logic [9:0] ai2_x,    // horizontal position of AI opponent 2
    input logic [9:0] ai3_x,    // horizontal position of AI opponent 3
    output logic game_active,   // tells car_manager when to allow movement
    output logic [3:0] player_score,  // how many rounds player won 0 to 3
    output logic [3:0] ai1_score,     // how many rounds AI 1 won
    output logic [3:0] ai2_score,     // how many rounds AI 2 won
    output logic [3:0] ai3_score,     // how many rounds AI 3 won
    output logic [1:0] round_num,   // current round number 1, 2, or 3
    output logic show_final_scores, // high when game over to display winner
    output logic show_start_screen, // high when showing title screen
    output logic player_lost,       // high when player disqualified
    output logic player_blink       // controls flashing effect disqualified player
);
    //state machine for possible game phases uses 3 bits to encode 7 different states
    typedef enum logic [2:0] 
	 {
        start_screen,     //initial state when FPGA powers on, game title
        idle,             //waiting between rounds for player to press button
        reset_positions,  //brief transition state
        playing,          //gameplay, cars moving 
        round_end,        //pause after round finishes to show who won
        wait_next_round,  //increment round counter
        game_over         //final state showing winner 
    } state_t;
    
    state_t ps, ns;
    
    //finish_line defines x coordinate where cars complete race
    //set to 580 pixels near right side of 640px screen
    parameter finish_line = 10'd580;
    
    //game play  3 rounds before declaring winner
    parameter total_rounds = 2'd3;
    
    //delay_counter increments every clock cycle to measure time
    //used for pauses between rounds/transitions, 27 bits counting up to 134 million cycles
    logic [26:0] delay_counter;
    
    //round_delay, 100 million cycles at 50MHz = 2 seconds, gives players time to see who won before next round
    parameter round_delay = 27'd100_000_000;
    
    //reset_delay creates pause when cars return to start
    //2.5 million cycles equals 0.05 seconds prevents false finish line detection 
    parameter reset_delay = 27'd2_500_000;
    
    //round_winner_recorded prevents multiple cars from getting points in same round
    //once high, no more finish line checks happen this round
    logic round_winner_recorded;
	 
    //player_disqualified remembers if player moved during red light
    //once set high player cannot win current round even if crosses finish
    //reset to low at start of each new round
    logic player_disqualified;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            // reset button forces game to beginning clears scores and returns to title screen
            ps <= start_screen;
            player_score <= 4'd0;
            ai1_score <= 4'd0;
            ai2_score <= 4'd0;
            ai3_score <= 4'd0;
            round_num <= 2'd1;   //rounds 1, 2, 3 for display
            delay_counter <= 27'd0;
            round_winner_recorded <= 1'b0;
            player_disqualified <= 1'b0;
        end 
		  else 
		  begin
            //ns calc by combinational logic below
            ps <= ns;

            case (ps)
                start_screen: 
					 begin
                    //title screen waiting for player
                    //reset counters so everything clear when game starts
                    delay_counter <= 27'd0;
                    round_winner_recorded <= 1'b0;
                    player_disqualified <= 1'b0;
                end
                
                idle: begin
                    //between rounds reset for fresh start
                    //delay_counter cleared so round_end timing works correctly
                    delay_counter <= 27'd0;
                    round_winner_recorded <= 1'b0;
                    player_disqualified <= 1'b0;
                 end
                
                reset_positions: begin
                    //cars go back to starting line, increment counter until reaches reset_delay threshold
                    //transition to playing state happens
                    delay_counter <= delay_counter + 1;
                end
                
                playing: begin
                    // main game state where racing happens
                    // keep delay_counter at zero during gameplay
                    delay_counter <= 27'd0;
                    
                    //check every cycle if player moving during red light
                    //red_light high means stop player_moved high = bad 
                    //only set disqualified flag once 
                    if (red_light && player_moved && !player_disqualified) begin
                        player_disqualified <= 1'b1;
                    end
                    
                    //once winner recorded no more checks until next round
                    if (!round_winner_recorded) begin
                        //player gets checked first 
                        //can only win if not disqualified from moving on red
                        if (player_x >= finish_line && !player_disqualified) 
								begin
                            player_score <= player_score + 4'd1;  //add 1 point for winning
                            round_winner_recorded <= 1'b1; //lock in winner
                        end
                        //AI opponents checked 
                        //whoever crosses first gets point
                        else if (ai1_x >= finish_line) 
								begin
                            ai1_score <= ai1_score + 4'd1;
                            round_winner_recorded <= 1'b1;
                        end
                        else if (ai2_x >= finish_line) begin
                            ai2_score <= ai2_score + 4'd1;
                            round_winner_recorded <= 1'b1;
                        end
                        else if (ai3_x >= finish_line) begin
                            ai3_score <= ai3_score + 4'd1;
                            round_winner_recorded <= 1'b1;
                        end
                     end
                end
                
                round_end: begin
                    //counting up to 2 sec pause, shows round winner before continue
                    delay_counter <= delay_counter + 1;
                end
                
                wait_next_round: begin
                    //transition state between rounds, increments round number 
                    if (round_num < total_rounds)
                        round_num <= round_num + 1;
                    //reset flags for clean slate in next round
                    delay_counter <= 27'd0;
                    round_winner_recorded <= 1'b0;
                    player_disqualified <= 1'b0;
                end
                
                game_over: 
					 begin
                    //final state after all rounds complete
                    //stays here forever showing winner until  reset
                end
            endcase
        end
    end
    
    always_comb begin
        //default behavior stay in same state
        ns = ps;
        
        case (ps)
            start_screen: begin
                //wait player to press start button !start_key means pressed
                //moves to idle state which waits for round start
                if (!start_key)
                    ns = idle;
             end
            
            idle: begin
                //wait player to start next round, key1 !start_key
                //reset_positions cars return to start
                if (!start_key)
                    ns = reset_positions;
            end
            
            reset_positions: begin
                //waiting for cars to finish sliding back
                //delay_counter incrementing in sequential block above
                //once reaches threshold, safe to start racing
                if (delay_counter >= reset_delay)
                    ns = playing;
            end
            
            playing: 
				begin
                //stay playing state, round_winner_recorded gets set in sequential block
                //when set high, transition to results
                if (round_winner_recorded)
                    ns = round_end;
            end
            
            round_end: begin
                //2 second delay showing results
                //after delay check if game over or more rounds
                if (delay_counter >= round_delay) begin
                    if (round_num >= total_rounds)
                        ns = game_over; //finished all 3 rounds
                    else
                        ns = wait_next_round;  //more rounds left
                end
            end
            
            wait_next_round: 
				begin
                //quick pass through state
                // returns to idle, player presses button key1 for next round
                //gives moment for round_num to increment 
                ns = idle;
            end
            
            game_over: begin
                // stuck here forever showing final winner
                // only way out is hardware reset button
                // keeps displaying scores until player done
            end
        endcase
    end
    
    //output assignments connect internal state to external signals
    //drive other modules  car_manager and vga_draw_controller
    
    //game_active high during actual gameplay and position reset
    //tells car_manager when movement allowed and positions should update
    //low during idle and results screens to freeze cars
    assign game_active = (ps == reset_positions) || (ps == playing);
    
    //show_final_scores goes high only in game_over state
    //triggers vga_draw_controller display winner screen
    //shows cumulative scores across 3 rounds
    assign show_final_scores = (ps == game_over);
    
    //show_start_screen high at title screen, low when game begins
    //vga_draw_controller uses show game name &instructions
    assign show_start_screen = (ps == start_screen);
    
    //player_lost directly mirrors disqualification status, vga_draw_controller can show message when player caught running red
    //stays high rest of round even after crossing finish
    assign player_lost = player_disqualified;
    
    //player_blink creates flashing effect disqualified player
    //player_disqualified must be true, delay_counter < 25M limits blink to first 0.5 seconds after disqualification
    //and (delay_counter / 12.5M) % 2 creates alternating pattern
    //dividing by 12.5M converts cycles to 0.25s chunks
    //modulo 2 gives 0,1,0,1 pattern creating on/off toggle
    //equals 0 means visible, equals 1 means hidden
    //result is car flashes twice (on/off and on/off) over 0.5 s when disqualified
    assign player_blink = player_disqualified && (delay_counter < 27'd25_000_000) && 
                          (((delay_counter / 27'd12_500_000) % 2) == 0);

endmodule //end game_controller
