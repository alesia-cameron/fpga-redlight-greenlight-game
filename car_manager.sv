/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs:
clk, reset, game_active, rand_val, move_up, move_down, move_forward

Outputs:
player_x, player_y, ai1_x, ai1_y, ai2_x, ai2_y, ai3_x, ai3_y

Description:
Manages positions of four racing cars, tracks player car position based on 
SW inputs and updates 3 AI opponent positions using random # generator. 
Player moves faster than AI cars. When new round starts, all cars 
reset to starting line on left of screen. Rate limiting prevents cars 
from moving too fast by only updating positions every few milliseconds. 
AI cars use random values to decide when to move forward/change lanes  


*/

module car_manager (
    input logic clk,                   
    input logic reset,                 
    input logic game_active, //high when racing, low when paused/ between rounds
    input logic [15:0] rand_val, //random # from lfsr
    input logic move_up,    //SW move player up
    input logic move_down,  //SW move player down
    input logic move_forward,  //SW move player forward
    output logic [9:0] player_x,  //horizontal position of player 0 to 640
    output logic [8:0] player_y, //vertical position of player 0 to 480
    output logic [9:0] ai1_x, //horizontal position of 1 AI opponent
    output logic [8:0] ai1_y, //vertical position of 1 AI opponent
    output logic [9:0] ai2_x, //horizontal position of 2 AI opponent
    output logic [8:0] ai2_y, //vertical position of 2 AI opponent
    output logic [9:0] ai3_x, //horizontal position of 3 AI opponent
    output logic [8:0] ai3_y  //vertical position of 3 AI opponent
);
    //starting x coordinate for all cars start line
    parameter player_start_x = 10'd50;
    
    //spread vertically 
    parameter player_start_y = 9'd120;
    parameter ai1_start_y = 9'd220;
    parameter ai2_start_y = 9'd320;
    parameter ai3_start_y = 9'd420;
    
    //counter tracks clock cycles between AI movement 
    //prevents AI from moving every single cycle which would be too fast
    logic [22:0] ai_update_counter;
    
    //AI moves every 0.1 seconds, 5 million cycles times 20ns per cycle equals 0.1 second
    parameter ai_update = 23'd5_000_000;
    
    //separate counter for player movement timing, player faster updates than ai for better control
    logic [21:0] player_update_counter;
    
    //player can move every 0.05 seconds twice as fast as AI, 2.5 million cycles times 20ns per cycle equals 0.05 second
    parameter player_update = 22'd2_500_000;
    
    //stores previous state of movement inputs for edge detection, detect when button first pressed versus held down
    logic move_forward_prev, move_up_prev, move_down_prev;
    logic move_forward_edge, move_up_edge, move_down_edge;
    
    
	 //remembers if game active last cycle to detect transition from inactive to active, new round starting
    logic game_active_prev;
    
    //rate limit prevent cars from moving too fast
    always_ff @(posedge clk) begin
        if (reset) 
		  begin          
            player_x <= player_start_x;
            player_y <= player_start_y;
            ai1_x <= player_start_x;
            ai1_y <= ai1_start_y;
            ai2_x <= player_start_x;
            ai2_y <= ai2_start_y;
            ai3_x <= player_start_x;
            ai3_y <= ai3_start_y;
            ai_update_counter <= 23'd0;
            player_update_counter <= 22'd0;
            move_forward_prev <= 1'b0;
            move_up_prev <= 1'b0;
            move_down_prev <= 1'b0;
            game_active_prev <= 1'b0;
        end 
        else 
		  begin
            //store current game_active for next cycle comparison
            game_active_prev <= game_active;
            
            //when game transitions from inactive to active, reset all positions
            //at start of each new round
            //ensures cars return to start line before racing
            if (game_active && !game_active_prev) 
				begin
                player_x <= player_start_x;
                player_y <= player_start_y;
                ai1_x <= player_start_x;
                ai1_y <= ai1_start_y;
                ai2_x <= player_start_x;
                ai2_y <= ai2_start_y;
                ai3_x <= player_start_x;
                ai3_y <= ai3_start_y;
                player_update_counter <= 22'd0;
                ai_update_counter <= 23'd0;
            end
            else if (game_active) 
				begin
                //game active so process movement 
                
                //save prev input states for edge detection
                //edge detection not currently used but kept for future features
                move_forward_prev <= move_forward;
                move_up_prev <= move_up;
                move_down_prev <= move_down;
                
                //calcu rising edges button just pressed this cycle
                move_forward_edge <= move_forward && !move_forward_prev;
                move_up_edge <= move_up && !move_up_prev;
                move_down_edge <= move_down && !move_down_prev;
                
                //player movement controlled by rate limiting counter
                //only update pos when counter reaches threshold
                if (player_update_counter >= player_update - 1) begin
                    //counter reached limit so reset and allow movement
                    player_update_counter <= 22'd0;
                    
                    //check each direction input and update position accordingly
                    //boundaries prevent car from going off screen edges
                    
                    //forward movement increases x coordinate 
                    //600 limit allows reaching finish line at 580
                    if (move_forward && player_x < 10'd600)
                        player_x <= player_x + 10'd5;  //move 5 pixels right
                    
                    //up decreases y coordinate 
                    //50 min keeps car from going off top edge
                    if (move_up && player_y > 9'd50)
                        player_y <= player_y - 9'd5;   //move 5 pixels up
                    
                    //down movement increases y coordinate 
                    //430 maximum keeps car from going off bottom edge
                    if (move_down && player_y < 9'd430)
                        player_y <= player_y + 9'd5;   //move 5 pixels down
                end else begin
                    //counter not reached limit yet so just increment
                    //no position changes this cycle
                    player_update_counter <= player_update_counter + 1;
                end
                
                //AI cars move based on counter with longer period
                if (ai_update_counter >= ai_update - 1) begin
                    //counter reached limit so reset and update positions
                    ai_update_counter <= 23'd0;
                    
                    //AI car uses different bits from lfsr, random movement patterns
                    
                    //AI car 1 controlled by bits [3:0] of random value
                    //bits [1:0] control forward movement
                    //pattern 11 triggers forward move
                    if (rand_val[1:0] == 2'b11 && ai1_x < 10'd600)
                        ai1_x <= ai1_x + 10'd10;  //AI moves 10 pixels 
                    
                    //bits [3:2] control vertical movement
                    //pattern 01 means move up, 10 means move down
                    if (rand_val[3:2] == 2'b01 && ai1_y > 9'd50)
                        ai1_y <= ai1_y - 9'd5;
                    else if (rand_val[3:2] == 2'b10 && ai1_y < 9'd430)
                        ai1_y <= ai1_y + 9'd5;
                    
                    //AI car 2 controlled by bits [7:4] of random value
                    //same logic as car 1 but different random bits
                    if (rand_val[5:4] == 2'b11 && ai2_x < 10'd600)
                        ai2_x <= ai2_x + 10'd10;
                    if (rand_val[7:6] == 2'b01 && ai2_y > 9'd50)
                        ai2_y <= ai2_y - 9'd5;
                    else if (rand_val[7:6] == 2'b10 && ai2_y < 9'd430)
                        ai2_y <= ai2_y + 9'd5;
                    
                    //AI car 3 controlled by bits [11:8] of random value
                    //independent from other cars due to different bit positions
                    if (rand_val[9:8] == 2'b11 && ai3_x < 10'd600)
                        ai3_x <= ai3_x + 10'd10;
                    if (rand_val[11:10] == 2'b01 && ai3_y > 9'd50)
                        ai3_y <= ai3_y - 9'd5;
                    else if (rand_val[11:10] == 2'b10 && ai3_y < 9'd430)
                        ai3_y <= ai3_y + 9'd5;
                end else begin
                    //counter not reached limit yet so just increment
                    //AI positions stay frozen this cycle
                    ai_update_counter <= ai_update_counter + 1;
                end
            end
        end
    end
endmodule 