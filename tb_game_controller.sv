/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset, [3:0]LFSR_in
Outputs: red, green

Description: testbench for game_controller module simulates racing game scenarios to verify state machine logic

*/


module tb_game_controller();
    
    //control signals
    logic clk;
    logic reset;
    logic start_key;
    logic red_light;
    logic player_moved;
    //position inputs for all racers
    logic [9:0] player_x;
    logic [9:0] ai1_x;
    logic [9:0] ai2_x;
    logic [9:0] ai3_x;
    //outputs from game controller
    logic game_active;
    logic [3:0] player_score;
    logic [3:0] ai1_score;
    logic [3:0] ai2_score;
    logic [3:0] ai3_score;
    logic [1:0] round_num;
    logic show_final_scores;
    logic show_start_screen;
    logic player_lost;
    logic player_blink;
    
    //instantiate 
    game_controller dut (
        .clk(clk),
        .reset(reset),
        .start_key(start_key),
        .red_light(red_light),
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
    
    //clock generation 
    always #10 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        start_key = 1; //1 means not pressed
        red_light = 0;
        player_moved = 0;
        player_x = 10'd0;
        ai1_x = 10'd0;
        ai2_x = 10'd0;
        ai3_x = 10'd0;
        
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);
        
        $display("Test 1 title screen");
        // should be showing start screen
        @(posedge clk);
        assert(show_start_screen == 1) else $error("Not showing start screen");
        
        //press start button 
        @(posedge clk);
        start_key = 0;
        repeat(5) @(posedge clk);
        start_key = 1;
        repeat(5) @(posedge clk);
        
        $display("Test 2 start round 1");
        //press start again to begin first round
        @(posedge clk);
        start_key = 0;
        repeat(5) @(posedge clk);
        start_key = 1;
        
        //wait for reset 
        repeat(2600000) @(posedge clk); //wait for reset_delay (2.5M + margin)
        
        //playing state
        @(posedge clk);
        assert(game_active == 1) else $error("Game not active");
        assert(round_num == 2'd1) else $error("Wrong round");
        
        $display("Test 3 player wins round 1");
        //player reaching finish line
        @(posedge clk);
        red_light = 0;  //green light
        player_moved = 1;
        player_x = 10'd590; //past finish line
        repeat(10) @(posedge clk);  //give more time for score to register
        
        //check player got point
        assert(player_score == 4'd1) else $error("Player should have point");
        
        //wait for round end delay
        repeat(100100000) @(posedge clk); //wait for full 2 second delay  
        
        $display("Test 4 player disqualified round 2");
        @(posedge clk);
        player_x = 10'd0;
        ai1_x = 10'd0;
        @(posedge clk);
        start_key = 0;
        repeat(5) @(posedge clk);
        start_key = 1;
        repeat(2600000) @(posedge clk);
        
        //player moves during red light
        @(posedge clk);
        red_light = 1;
        player_moved = 1;
        repeat(5) @(posedge clk);
        
        //check disqualification
        assert(player_lost == 1) else $error("Player should be disqualified");
        
        // player crosses finish but shouldn't win
        @(posedge clk);
        player_x = 10'd590;
        repeat(5) @(posedge clk);
        assert(player_score == 4'd1) else $error("Player shouldn't get point bc disqualified");
        
        //AI win
        @(posedge clk);
        ai1_x = 10'd590;
        repeat(5) @(posedge clk);
        assert(ai1_score == 4'd1) else $error("AI1 should win");
        
        repeat(100100000) @(posedge clk);  // wait for round end
        
        $display("Test 5 round 3 game over");
        @(posedge clk);
        player_x = 10'd0;
        ai1_x = 10'd0;
        ai2_x = 10'd0;
        @(posedge clk);
        start_key = 0;
        repeat(5) @(posedge clk);
        start_key = 1;
        repeat(2600000) @(posedge clk);
        
        //AI2 win
        @(posedge clk);
        red_light = 0;
        ai2_x = 10'd590;
        repeat(5) @(posedge clk);
        assert(ai2_score == 4'd1) else $error("AI2 should have point");
        
        repeat(100100000) @(posedge clk);  
        
        //game over screen
        repeat(50) @(posedge clk);
        assert(show_final_scores == 1) else $error("Should show final score");
        assert(round_num == 2'd3) else $error("Should be round 3");
        
        $display("All tests pass");
        $stop;
    end
    
endmodule