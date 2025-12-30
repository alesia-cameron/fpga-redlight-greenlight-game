/*
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light

Inputs: clk, reset, [3:0]LFSR_in
Outputs: red, green

Description: This testbench initializes the former to verify shift and feedback
behavior. Clk toggles every 5 time signals, reset is asserted high
initially, forcing LFSR output to known seed, ensuring a deterministic
starting state not zeros. After 20 time units reset is deasserted which
allows lfsr to shift.
*/

//====================Test Bench=============================
module tb_lfsr; 
  logic clk;
  logic reset;
  logic [3:0] out;

  lfsr dut(
    .clk(clk),
    .reset(reset),
    .out(out)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;   
  end

  initial begin
    reset = 1;
    #20;           
    reset = 0;  //release reset

    repeat (20) @(posedge clk);

    $stop;          
  end

  //print on every posedge
  always @(posedge clk) 
  begin
    $display("Time=%0t  LFSR=%b", $time, out);
  end
endmodule
