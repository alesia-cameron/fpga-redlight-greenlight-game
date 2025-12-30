/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: 
clk
char_code[7:0]  
row[2:0]       

Outputs: 
pixels[7:0] 

Description:
character ROM converts convenient char_code + row interface to ROM address
Character ROM stores 8x8 pixel bitmap for rendering text. 
Address port combines 7 least significant bits of incoming character 
code with 3bit row index forming 10bit address selecting 1 of 1024 bytes 
in memory. ROM preloaded from MIF file, each byte contains 8 bits corresponding 
to 8 horizontal pixels on selected row. 1 lights pixel, 0 leaves pixel dark. 
ROM captures address on rising clock, outputs selected byte next cycle through 
pixels. Layout stores characters contiguously: character code selects block, 
row index selects offset inside block. char_rom holds bitmaps, memory stores 
8 rows per character, each row as 8-bit wide pattern, each bit drives pixel 
on/pixel off. Module uses synchronous read, address loads on rising clock, 
bitmap row appears next cycle
*/


module char_rom (
    input logic clk,
    input logic [7:0] char_code,  // ASCII character code (0-127)
    input logic [2:0] row, //row within character 0-7
    output logic [7:0] pixels   //8 pixels for this row
);
    //Calcu ROM address from char_code and row
    //Address = char_code * 8 + row
    logic [9:0] addr;
    assign addr = {char_code[6:0], row};  //concatenate 7 + 3 = 10 bits
    
    // Instantiate ROM
    char_rom_qrom rom_inst (
        .address(addr),    
        .clock(clk),   
        .q(pixels)  //8bit output
    );
    
endmodule //char_rom

