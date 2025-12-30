/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset, game_active, 16 bit LFSR_in controlling light duration
Outputs:red and green signals indicating which light active

Description: This testbench simulates traffic_light behavior with controlled LFSR input 
to produce multiple durations. 
Clock toggles every 5 time units. 
reset initializes module, game_active starts counting. 
LFSR_in initially 3, incremented by 7 each time duration_timer reaches 0 and 
duration changes. prev_duration prevents repeated prints for same duration

*/


module tb_traffic_light;
 
    logic clk;
    logic reset;
    logic game_active;
    logic [15:0] LFSR_in;
    logic red, green;

    //instantiate DUT
    traffic_light dut(
        .clk(clk),
        .reset(reset),
        .game_active(game_active),
        .LFSR_in(LFSR_in),
        .red(red),
        .green(green)
    );

    //clock
    always #5 clk = ~clk;

    //simulate changing LFSR
    initial begin
        clk = 0;
        reset = 1;
        game_active = 0;
        LFSR_in = 16'd3; //initial value
        #20 reset = 0;
        game_active = 1;
    end

    //feed new random LFSR value each time duration expires
    logic [3:0] prev_duration;
    initial prev_duration = 0;

    always @(posedge clk) begin
        if(!reset && game_active) begin
            if(dut.duration_timer == 0 && dut.duration != prev_duration) begin
                prev_duration = dut.duration;
                //update LFSR_in w new random value
                LFSR_in <= LFSR_in + 16'd7; //just example increment to change value
                $display("Time=%0t New duration=%0d", $time, dut.duration);
            end
        end
    end

endmodule
