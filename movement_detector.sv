/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset, current_x, current_y
Outputs: moved

Description: detects when player car position changes between clock cycles. 
Stores previous x and y coordinates in registers then compares against current 
coordinates every cycle. 
Sets moved output high whenever either horizontal or vertical position 
differs from last cycle. Used by game controller to catch player cheating by 
moving during red light
*/

module movement_detector (
    input logic clk,
    input logic reset,
    input logic [9:0] current_x, //current horizontal position of player car
    input logic [8:0] current_y, //current vertical position of player car
    output logic moved //high when position changed from previous cycle
);
    //registers store position from previous clock cycle
    logic [9:0] prev_x;
    logic [8:0] prev_y;
    
    //creates one cycle delay for comparison
    always_ff @(posedge clk) 
	 begin
        if (reset) begin
            //reset clears previous positions to 0
            //prevents false movement detection on startup
            prev_x <= 10'd0;
             prev_y <= 9'd0;
        end else 
		  
		  begin
            //save current positions for next cycle comparison
            //pipeline of position values
            prev_x <= current_x;
            prev_y <= current_y;
        end
    end
    
    //moved goes high if either x or y coordinate changed
    //catches horizontal movement, vertical movement, or diagonal movement
	assign moved = (current_x != prev_x) || (current_y != prev_y);

endmodule
