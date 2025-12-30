/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: CLOCK_50, KEY, SW

Outputs:HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, 
LEDR, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS

Description: top level module connects game components, takes input from buttons 
and switches for controlling player car and resetting game. 
Instantiates random number generator for AI movement, traffic light controller,
car position manager, movement detector for catching red light violation
and game controller for scoring and rounds. 
Display scores on 7seg display and LEDs while showing current round number. 
Drives VGA monitor by connecting video driver and draw controller modules together
Video driver scans screen pixel by pixel while draw controller determines colors based 
on car positions, traffic light state, and game status
*/

module DE1_SoC (
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output [9:0] LEDR,
    output [7:0] VGA_R, VGA_G, VGA_B,
    output VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS
);
   
    //reset key 0, active low 
    logic reset;
    assign reset = ~KEY[0];
   
    //lfsr generates random numbers for ai behavior and traffic light times
    //outputs 16 bit random val every clock cycle
    logic [15:0] rand_val;
    lfsr lfsr_inst (
        .clk(CLOCK_50),
        .reset(reset),
        .out(rand_val)
    );
   
    //traffic light controls when players can move 
    //switches between red and green based on random timing
    //active when game_active signal high
    logic red, green, game_active;
    traffic_light tl (
       .clk(CLOCK_50),
        .reset(reset),
        .game_active(game_active),
        .LFSR_in(rand_val),
         .red(red),
        .green(green)
    );
   
    //display curr traffic light state on top two leds
    //led 9 shows red light led 8 shows green 
    assign LEDR[9] = red;
    assign LEDR[8] = green;
   
    //position coords for all cars
    //x go from 0 to 640 horizontal, y go from 0 to 480 vertical
    logic [9:0] player_x, ai1_x, ai2_x, ai3_x;
    logic [8:0] player_y, ai1_y, ai2_y, ai3_y;
   
    
	 //movement from switches on board
    //switch 0 moves forward, switch 1 up, switch 2 down
    logic move_forward, move_up, move_down;
    assign move_forward = SW[0];
    assign move_up = SW[1];
    assign move_down = SW[2];
   
    //car manager update positions for cars
    //player controlled by switches, ai controlled by random vals
    //resets positions when new round 
    car_manager cars (
         .clk(CLOCK_50),
        .reset(reset),
        .game_active(game_active),
        .rand_val(rand_val),
        .move_up(move_up),
        .move_down(move_down),
        .move_forward(move_forward),
        .player_x(player_x),
        .player_y(player_y),
        .ai1_x(ai1_x),
        .ai1_y(ai1_y),
        .ai2_x(ai2_x),
        .ai2_y(ai2_y),
        .ai3_x(ai3_x),
        .ai3_y(ai3_y)
    );
   
    //movement detector monitor player car position
    //sets moved signal high if position changes between clock cycles
    //to catch player moving during red light
    logic player_moved;
    movement_detector md (
         .clk(CLOCK_50),
        .reset(reset),
        .current_x(player_x),
        .current_y(player_y),
        .moved(player_moved)
    );
   
	//game controller main state machine
    //track scores, manages rounds, checks for winner
    //disqualifies player if move during red light
    logic [3:0] player_score, ai1_score, ai2_score, ai3_score;
    logic [1:0] round_num;
    logic show_final_scores, show_start_screen, player_lost, player_blink;
   
    game_controller gc (
        .clk(CLOCK_50),
        .reset(reset),
        .start_key(KEY[1]),
        .red_light(red),
        .player_moved(player_moved),
        .player_x(player_x),
        .ai1_x(ai1_x),
        .ai2_x(ai2_x),
        .ai3_x(ai3_x),
        .game_active(game_active),
        .player_score(player_score),
        .ai1_score(ai1_score),
        .ai2_score(ai2_score),
        .ai3_score(ai3_score),
        .round_num(round_num),
        .show_final_scores(show_final_scores),
        .show_start_screen(show_start_screen),
         .player_lost(player_lost),
         .player_blink(player_blink)
    );
   
    //display scores on bottom leds 
    //leds 0 through 3 show player score leds 4 through 7 show ai1 score
    assign LEDR[3:0] = player_score;
    assign LEDR[7:4] = ai1_score;
   
     //hex5 displays curr round number at top right
    //show 1, 2, or 3 using seven segm
    assign HEX5 = (round_num == 2'd1) ? 7'b1111001 : //1
       (round_num == 2'd2) ? 7'b0100100 : //2
           (round_num == 2'd3) ? 7'b0110000 : //3
                  7'b1111111; //blank else
   
    //remaining hex show four player scores
    //hex0 shows player ones digit, hex1 shows player tens digit
    //hex2 shows ai1 score, hex3 shows ai2 score, hex4 shows ai3 score
    
    //func converts 4 bit # into 7seg display 
    //bit pattern lights up to form digit shape
    function automatic [6:0] digit_to_7seg(input [3:0] digit);
        case (digit)
            4'd0: digit_to_7seg = 7'b1000000; //0
            4'd1: digit_to_7seg = 7'b1111001; //1
            4'd2: digit_to_7seg = 7'b0100100; //2
            4'd3: digit_to_7seg = 7'b0110000; //3
            4'd4: digit_to_7seg = 7'b0011001; //4
            4'd5: digit_to_7seg = 7'b0010010; //5
            4'd6: digit_to_7seg = 7'b0000010; //6
            4'd7: digit_to_7seg = 7'b1111000; //7
            4'd8: digit_to_7seg = 7'b0000000; //8
            4'd9: digit_to_7seg = 7'b0010000; //9
            
				default: digit_to_7seg = 7'b1111111; //blank for invalid
        endcase
    endfunction
    
    //calc and display scores on hex displays
    //%10 gives 1 digit, divide by 10 gives tens digit
    assign HEX0 = digit_to_7seg(player_score % 10);
    assign HEX1 = digit_to_7seg(player_score / 10);
    assign HEX2 =  digit_to_7seg(ai1_score);
    assign HEX3 = digit_to_7seg(ai2_score);
    assign HEX4 =  digit_to_7seg(ai3_score);
   
    //vga display section renders graphics 
    //video driver scans screen pixel by pixel
    //draw controller determines color for each pixel 
   
    //video driver outputs current position
    //x and y show which pixel currently being drawn
    logic [9:0] x;
    logic [8:0] y;
    
	//draw controller outputs rgb colors for current scan position
    //colors change based on what needs to be drawn at current x,y location
    logic [7:0] r, g, b;
   
	//video driver module scans screen 
    //provides current x,y coordinates to draw controller
    //takes rgb colors from draw controller and sends to vga pins
    video_driver #(
        .WIDTH(640),
        .HEIGHT(480)
    ) vga_driver (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .x(x), //output curr scan position x
        .y(y), //output curr scan position y
        .r(r), //input color for curr pixel
        .g(g),
         .b(b),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_VS(VGA_VS)
    );
   
    //draw controller decides what color each pixel should be
    //checks if current x,y position falls w/in car sprites, traffic light, text
    //outputs rgb color vals for whats drawn
    vga_draw_controller vga_ctrl (
        .clk(CLOCK_50),
        .reset(reset),
        .game_active(game_active),
        .show_final_scores(show_final_scores),
        .show_start_screen(show_start_screen),
        .red_light(red),
        .green_light(green),
        .player_lost(player_lost),
        .player_blink(player_blink),
        .player_x(player_x),
        .player_y(player_y),
        .ai1_x(ai1_x),
        .ai1_y(ai1_y),
        .ai2_x(ai2_x),
        .ai2_y(ai2_y),
        .ai3_x(ai3_x),
        .ai3_y(ai3_y),
        .player_score(player_score),
        .ai1_score(ai1_score),
        .ai2_score(ai2_score),
        .ai3_score(ai3_score),
        .round_num(round_num),
        .x(x), //input curr scan position from video driver
        .y(y),
        .r(r),  //output color for curr pixel
        .g(g),
         .b(b)
    );

endmodule //DE1_SoC
