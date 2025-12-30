/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset, [3:0]LFSR_in
Outputs: red, green

Description: simple traffic light flips between red and green for random lengths 
of time. Watches a countdown timer, whenever timer reaches zero it switches
light to the other color and grabs a fresh random number from the four bit LFSR. 
Random value gets turned into duration 1-10. Timer reloads with that value. 
While timer counts down, light stays in current color. 
The present state holds whichever color is active, next state decides 
where to go when timer expires. Outputs reflect what the current state is. 
Keeps trafic light changing in unpredictable intervals when countdown finishes
*/

module traffic_light (
    input logic clk,
    input logic reset,
    input logic game_active,
    input logic [15:0] LFSR_in,
    output logic red,
    output logic green
);
    typedef enum logic {red_light, green_light} state;
    state ps, ns;
    
    logic [25:0] second_counter; 
    logic [3:0] duration_timer; //seconds left
    logic [3:0] duration; //duration for this light
    
    parameter SECOND = 26'd50_000_000;
    
    always_ff @(posedge clk) begin
        if(reset) begin
            ps <= red_light;
            duration <= 4'd3;
            duration_timer <= 4'd3;
            second_counter <= 26'd0;
        end 
        else if (game_active) begin
            ps <= ns;
            
            //count seconds
            if (second_counter >= SECOND - 1) begin
                second_counter <= 26'd0;
                if (duration_timer > 0)
                    duration_timer <= duration_timer - 1;
            end else begin
                second_counter <= second_counter + 1;
            end
            
            //timer expires, get new random duration
            if (duration_timer == 0) begin
                duration <= (LFSR_in % 10) + 1;
                duration_timer <= (LFSR_in % 10) + 1;
            end
        end
    end
    
    always_comb begin
        ns = ps;
        if(duration_timer == 0) 
		  begin
            case(ps)
                red_light: ns = green_light;
                green_light: ns = red_light;
            endcase
        end
    end
    
    assign red = (ps == red_light);
    assign green = (ps == green_light);

endmodule //traffic_light.sv
