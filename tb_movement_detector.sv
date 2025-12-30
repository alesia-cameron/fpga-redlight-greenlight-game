/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset, [3:0]LFSR_in
Outputs: red, green

Description: testbench for movement_detector module verifies detection of position changes
*/



module tb_movement_detector();
    
    //control signals
    logic clk;
    logic reset;
    
    //position inputs
    logic [9:0] current_x;
    logic [8:0] current_y;
    
    //output 
    logic moved;
    
    movement_detector dut (
        .clk(clk),
        .reset(reset),
        .current_x(current_x),
        .current_y(current_y),
        .moved(moved)
    );
    
    always #10 clk = ~clk;
    
    //test 
    initial begin
        clk = 0;
        reset = 1;
        current_x = 10'd0;
        current_y = 9'd0;
        
        //reset
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);
        
        $display("test 1: no movement");
         //position stays same so moved should be low
        @(posedge clk);
        assert(moved == 0) else $error("should not detect movement");
        
        $display("test 2: x movement");
        //change x position then check next cycle
        @(posedge clk);
        current_x = 10'd50;
        @(posedge clk);
        assert(moved == 1) else $error("should detect x movement");
        
        
		  $display("test 3: y movement");
        //change y position then check next cycle
        @(posedge clk);
        current_y = 9'd100;
        @(posedge clk);
        assert(moved == 1) else $error("should detect y movement");
        
        $display("test 4: both axes movement");
        //change both positions then check next cycle
        @(posedge clk);
        current_x = 10'd75;
        current_y = 9'd150;
        @(posedge clk);
        assert(moved == 1) else $error("should detect both axes movement");
        
        $display("test 5: stop moving");
        //keep position constant
        
		  repeat(3) @(posedge clk);
        assert(moved == 0) else $error("should not detect movement when stopped");
        
        $display("all tests pass");
        $stop;
    end
    
endmodule