/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: clk, reset
Outputs: [15:0] out

Description: small register keeps shifting bits around. 
Every clock it pushes bits forward and mixes in new bit from XOR which
turns sequence into something that looks random. Ooutput is bits after
they shift. Output fed into anything that needs randomness 
*/

module lfsr (
    input logic clk,
    input logic reset,
    output logic [15:0] out
);
    always_ff @(posedge clk) begin
        if (reset)
            out <= 16'hACE1; //seed val
        else
            //16-bit LFSR with taps at positions 16, 15, 13, 4
            out <= {out[14:0], out[15] ^ out[14] ^ out[12] ^ out[3]};
    end
endmodule 



//====================Test Bench=============================
module lfsr_tb; 
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
