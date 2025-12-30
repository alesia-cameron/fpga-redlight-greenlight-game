/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: 
clk, reset, game_active, show_final_scores, show_start_screen, red_light, 
green_light, player_lost, player_blink, player_x, player_y, 
ai1_x, ai1_y, ai2_x, ai2_y, ai3_x, ai3_y,
[3:0] player_score,
[3:0] ai1_score, ai2_score, ai3_score, [1:0] round_num, [9:0] x, [8:0] y,
   
Outputs:  [7:0] r, logic [7:0] g, [7:0]  b

Description: Module renders the game graphics in real-time by calculating the RGB
color for each pixel as the VGA scans the screen. Draws three different
screens: title, gameplay with road/cars/traffic light, and game over
with winner. Uses sprite ROMs for car and traffic light shapes, character
ROM for text. No framebuffer - generates all pixels every frame using purely combinational logic.

*/
module vga_draw_controller (

    input logic clk,
    input logic reset,
    //stuff from game telling us what to draw
    input logic game_active,
    input logic show_final_scores,
    input logic show_start_screen,
    input logic red_light,
    input logic green_light,
    input logic player_lost,
    input logic player_blink,
    input logic [9:0]  player_x,
    input logic [8:0] player_y,
    input logic [9:0] ai1_x,
    input logic [8:0] ai1_y,
    input logic [9:0] ai2_x,
    input logic [8:0] ai2_y,
    input logic [9:0] ai3_x,
    input logic [8:0] ai3_y,
    input logic [3:0] player_score,
    input logic [3:0] ai1_score,
    input logic [3:0] ai2_score,
    input logic [3:0] ai3_score,
    input logic [1:0] round_num,
    //video driver tells us which pixel we need to color right now
    input logic [9:0] x,
    input logic [8:0] y,
    //we spit out rgb values for whatever pixel video driver asked about
    output logic [7:0] r,
    output logic [7:0] g,
    output logic [7:0]  b
);

    //next cycle rgb values sit here before getting registered
    logic [7:0] r_next, g_next, b_next;
    
    //stuff for talking to character rom to get text pixels
    logic [7:0] char_pixels;
    logic [7:0] char_code;
    logic [2:0] char_row;
    
    //bunch of variables we need when rendering text
    logic [9:0] char_x, char_y;
    logic [2:0] scaled_row;
    logic [2:0] pixel_col;
    logic char_pixel;
    logic [3:0] winner_score;
    logic [7:0] winner_char1, winner_char2, winner_char3;
    logic [7:0] score_char;
    logic [9:0] start_x;
    logic [9:0]  num_chars;
    
    //character rom gives 8x8 bitmaps for letters
    char_rom text_rom (
        .clk(clk),
        .char_code(char_code),
        .row(char_row),
        .pixels(char_pixels)
    );
    
    //car sprite rom tells us which pixels in car shape are solid
    logic  car_pixel;
    logic [4:0] car_sprite_x, car_sprite_y;
    
    car_sprite_rom car_sprite (
	 
        .sprite_x(car_sprite_x),
        .sprite_y(car_sprite_y),
        .pixel(car_pixel)
    );
    
    //traffic light sprite rom gives us light shape
    logic traffic_pixel;
    logic [5:0] traffic_sprite_x, traffic_sprite_y;
    
    traffic_light_sprite_rom traffic_sprite (
	 
        .sprite_x(traffic_sprite_x),
        .sprite_y(traffic_sprite_y),
        .pixel(traffic_pixel)
    );
   
    //register outputs for timing reasons
    always_ff @(posedge clk) 
	 begin
        if (reset) begin
            r <= 8'h00;
            g <= 8'h00;
            b <= 8'h00;
        end else begin
            r <= r_next;
            g <= g_next;
             b <= b_next;
        end
    end

    //function check if point inside rectangle
    function automatic logic in_rect(
        input logic [9:0] px, py,
        input logic [9:0] rx, ry, rw, rh
    );
        return (px >= rx) && (px < rx + rw) &&
              (py >= ry) && (py < ry + rh);
    endfunction
   
    //massive combinational block decides color for current x y pixel
    //video driver scans left to right top to bottom asking us for colors
    always_comb begin
        //default everything to black
        r_next = 8'h00;
        g_next = 8'h00;
        b_next = 8'h00;
    
	 
        //initialize all our working variables
        char_code = 8'd32; //space character by default
        char_row = 3'd0;
        car_sprite_x = 5'd0;
        car_sprite_y = 5'd0;
        traffic_sprite_x = 6'd0;
        traffic_sprite_y = 6'd0;
        
        char_x = 10'd0;
        char_y = 10'd0;
        scaled_row = 3'd0;
        pixel_col = 3'd0;
        char_pixel = 1'b0;
        winner_score = 4'd0;
        winner_char1 =  8'd32;
        winner_char2 = 8'd32;
        winner_char3 = 8'd32;
        score_char = 8'd48;
        start_x = 10'd0;
        num_chars = 10'd0;
        
        //title screen draws red light green light text plus instructions
        if (show_start_screen)
		  begin
            //red light title text at y 180 to 195
            if (y >= 9'd180 && y < 9'd196) begin
                char_y = 9'd180;
                scaled_row = (y - char_y) >> 1; //divide by 2 to double size
                
                if (x >= 10'd220 && x < 10'd380) 
					 begin
                    char_x = (x - 10'd220) >> 4; //which character in string
                    pixel_col = ((x - 10'd220) >> 1) & 3'b111; //which pixel in character
                    
                    //map char position to actual letter
                    case (char_x)
                        10'd0: char_code = 8'd82;  //r
                        10'd1: char_code = 8'd69;  //e
                        10'd2: char_code = 8'd68;  //d
                        10'd3: char_code = 8'd32;  //space
                        10'd4: char_code = 8'd76;  //l
                        10'd5: char_code = 8'd73;  //i
                        10'd6: char_code = 8'd71;  //g
                        10'd7: char_code = 8'd72;  //h
                        10'd8: char_code = 8'd84;  //t
                        default: char_code = 8'd32;
                    endcase
                    
                    char_row = scaled_row;
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    //color it red if pixel is solid
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'h00;
                        b_next = 8'h00;
                    end
                end
            end
            
            //green light title text at y 210 to 225
            if (y >= 9'd210 && y < 9'd226) begin
                char_y = 9'd210;
                scaled_row = (y - char_y) >> 1;
                
                if (x >= 10'd204 && x < 10'd396) 
					 begin
                    char_x = (x - 10'd204) >> 4;
                      pixel_col = ((x - 10'd204) >> 1) & 3'b111;
                    
                  case (char_x)
                        10'd0: char_code = 8'd71;  //g
                        10'd1: char_code = 8'd82;  //r
                        10'd2: char_code = 8'd69;  //e
                        10'd3: char_code = 8'd69;  //e
                        10'd4: char_code = 8'd78;  //n
                        10'd5: char_code = 8'd32;  //space
                        10'd6: char_code = 8'd76;  //l
                        10'd7: char_code = 8'd73;  //i
                        10'd8: char_code = 8'd71;  //g
                        10'd9: char_code = 8'd72;  //h
                        10'd10: char_code = 8'd84; //t
                        default: char_code = 8'd32;
                    endcase
                    
                    char_row = scaled_row;
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    //color it green if pixel solid
                    if (char_pixel) begin
                        r_next = 8'h00;
                        g_next = 8'hFF;
                        b_next = 8'h00;
                    end
                end
            end
            
            //press key 1 instruction at y 280 to 287
            if (y >= 9'd280 && y < 9'd288) begin
                char_row = y - 9'd280;
                
                if (x >= 10'd244 && x < 10'd332) begin
                    char_x = (x - 10'd244) >> 3; //normal size text
                    pixel_col = (x - 10'd244) & 3'b111;
                    
                    case (char_x)
                        10'd0: char_code = 8'd80;  //p
                        10'd1: char_code = 8'd114; //r
                        10'd2: char_code = 8'd101; //e
                        10'd3: char_code = 8'd115; //s
                        10'd4: char_code = 8'd115; //s
                        10'd5: char_code = 8'd32; //space
                        10'd6: char_code = 8'd75;  //k
                        10'd7: char_code = 8'd69;  //e
                        10'd8: char_code = 8'd89;  //y
                        10'd9: char_code = 8'd32; //space
                        10'd10: char_code = 8'd49; //1
                        
								default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    //white text
                    if (char_pixel) 
						  begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
            
            //to start text at y 300 to 307
            if (y >= 9'd300 && y < 9'd308) begin
                char_row = y - 9'd300;
                
                if (x >= 10'd268 && x < 10'd332) begin
                    char_x = (x - 10'd268) >> 3;
                    pixel_col = (x - 10'd268) & 3'b111;
                    
                    case (char_x)
                        
								10'd0: char_code = 8'd116; //t
                        10'd1: char_code = 8'd111; //o
                        10'd2: char_code = 8'd32; //space
                        10'd3: char_code = 8'd115; //s
                        10'd4: char_code = 8'd116; //t
                        10'd5: char_code = 8'd97;  //a
                        10'd6: char_code = 8'd114; //r
                        10'd7: char_code = 8'd116; //t
                        
								default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
        end
        //game over screen shows winner after all rounds done
        else if (show_final_scores) begin
            //figure out who won by comparing all scores
            winner_score = player_score;
            winner_char1 = 8'd80;  //p
            winner_char2 = 8'd108; //l
            winner_char3 = 8'd97;  //a
            
            if (ai1_score > winner_score) begin
                winner_score = ai1_score;
                winner_char1 = 8'd65; //a
                winner_char2 = 8'd73; //i
                winner_char3 = 8'd49; //1
            end
            if (ai2_score > winner_score) begin
                winner_score = ai2_score;
                winner_char1 = 8'd65; //a
                winner_char2 = 8'd73; //i
                winner_char3 = 8'd50; //2
            end
            if (ai3_score > winner_score) begin
                winner_score = ai3_score;
                winner_char1 = 8'd65; //a
                winner_char2 = 8'd73; //i
                winner_char3 = 8'd51; //3
            end
            
            //turn score number into ascii character
            score_char = 8'd48 + winner_score; //48 is zero in ascii
            
            //game over text at y 140 big letters
            if (y >= 9'd140 && y < 9'd156) begin
                char_y = 9'd140;
                scaled_row = (y - char_y) >> 1;
                
                if (x >= 10'd228 && x < 10'd388) begin
                    char_x = (x - 10'd228) >> 4;
                    pixel_col = ((x - 10'd228) >> 1) & 3'b111;
                    
                    case (char_x)
                        10'd0: char_code = 8'd71;  //g
                        10'd1: char_code = 8'd65;  //a
                        10'd2: char_code = 8'd77;  //m
                        10'd3: char_code = 8'd69;  //e
                        10'd4: char_code = 8'd32;  //space
                        10'd5: char_code = 8'd79;  //o
                        10'd6: char_code = 8'd86;  //v
                        10'd7: char_code = 8'd69;  //e
                        10'd8: char_code = 8'd82;  //r
                       
							  default: char_code = 8'd32;
                    endcase
                    
                    char_row = scaled_row;
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    //yellow text
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'h00;
                    end
                end
            end
            
            //winner colon text at y 200
            if (y >= 9'd200 && y < 9'd208) 
				begin
                char_row = y - 9'd200;
                
                if (x >= 10'd268 && x < 10'd324) begin
                    char_x = (x - 10'd268) >> 3;
                    pixel_col = (x - 10'd268) & 3'b111;
                    
                    case (char_x)
                        10'd0: char_code = 8'd87;  //w
                        10'd1: char_code = 8'd105; //i
                        10'd2: char_code = 8'd110; //n
                        10'd3: char_code = 8'd110; //n
                        10'd4: char_code = 8'd101; //e
                        10'd5: char_code = 8'd114; //r
                        10'd6: char_code = 8'd58;  //colon
                        
								default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    if (char_pixel) 
						  begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
            
            //winner name like player or ai1 at y 230 big size
            if (y >= 9'd230 && y < 9'd246) 
				begin
                char_y = 9'd230;
                scaled_row = (y - char_y) >> 1;
                
                //position depends on player or ai text length
                if (winner_char1 == 8'd80) begin //player
                    start_x = 10'd260;
                    num_chars = 10'd6;
                end else begin //ai1 ai2 or ai3
                    start_x = 10'd292;
                    num_chars = 10'd3;
                end
                
                if (x >= start_x && x < start_x + (num_chars << 4)) begin
                    char_x = (x - start_x) >> 4;
                    pixel_col = ((x - start_x) >> 1) & 3'b111;
                    
                    if (winner_char1 == 8'd80) begin //player
                        case (char_x)
                            10'd0: char_code = 8'd80;  //p
                            10'd1: char_code = 8'd108; //l
                            10'd2: char_code = 8'd97;  //a
                            10'd3: char_code = 8'd121; //y
                            10'd4: char_code = 8'd101; //e
                            10'd5: char_code = 8'd114; //r
                            default: char_code = 8'd32;
                        endcase
                    end else begin //ai
                        case (char_x)
                            10'd0: char_code = winner_char1; //a
                            10'd1: char_code = winner_char2; //i
                            10'd2: char_code = winner_char3; //1 or 2 or 3
                            default: char_code = 8'd32;
                        endcase
                    end
                    
                    char_row = scaled_row;
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    //green winner text
                    if (char_pixel) begin
                         r_next = 8'h00;
                        g_next = 8'hFF;
                        b_next = 8'h00;
                    end
                end
            end
            
            //score colon number pt at y 270
            if (y >= 9'd270 && y < 9'd278) begin
                char_row = y - 9'd270;
                
                if (x >= 10'd260 && x < 10'd348) begin
                    char_x = (x - 10'd260) >> 3;
                    pixel_col = (x - 10'd260) & 3'b111;
                    
                    case (char_x)
                        10'd0: char_code = 8'd83; //s
                        10'd1: char_code = 8'd99;  //c
                        10'd2: char_code = 8'd111; //o
                        10'd3: char_code = 8'd114; //r
                        10'd4: char_code = 8'd101; //e
                        10'd5: char_code = 8'd58;  //colon
                        10'd6: char_code = 8'd32;  //space
                        10'd7: char_code = score_char; //score digit
                        10'd8: char_code = 8'd32;  //space
                        10'd9: char_code = 8'd112; //p
                        10'd10: char_code = 8'd116; //t
                        default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
            
            //press key 0 instruction at y 330
            if (y >= 9'd330 && y < 9'd338) begin
                char_row = y - 9'd330;
                
                if (x >= 10'd244 && x < 10'd332) begin
                    char_x = (x - 10'd244) >> 3;
                    pixel_col = (x - 10'd244) & 3'b111;
                    
                  case (char_x)
                        10'd0: char_code = 8'd80;  //p
                        10'd1: char_code = 8'd114; //r
                        10'd2: char_code = 8'd101; //e
                        10'd3: char_code = 8'd115; //s
                        10'd4: char_code = 8'd115; //s
                        10'd5: char_code = 8'd32;  //space
                        10'd6: char_code = 8'd75;  //k
                        10'd7: char_code = 8'd69;  //e
                        10'd8: char_code = 8'd89;  //y
                        10'd9: char_code = 8'd32;  //space
                        10'd10: char_code = 8'd48; //0
                        default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
            
            //restart text at y 350
            if (y >= 9'd350 && y < 9'd358) 
				begin
                char_row = y - 9'd350;
                
                if (x >= 10'd260 && x < 10'd332) 
					 begin
                    char_x = (x - 10'd260) >> 3;
                    pixel_col = (x - 10'd260) & 3'b111;
                    
                    case (char_x)
                        10'd0: char_code = 8'd116; //t
                        10'd1: char_code = 8'd111; //o
                        10'd2: char_code = 8'd32; //space
                        10'd3: char_code = 8'd114; //r
                        10'd4: char_code = 8'd101; //e
                        10'd5: char_code = 8'd115; //s
                        10'd6: char_code = 8'd116; //t
                        10'd7: char_code = 8'd97;  //a
                         10'd8: char_code = 8'd114;//r
                       
							  default: char_code = 8'd32;
                    endcase
                    
                    char_pixel = char_pixels[7 - pixel_col];
                    
                    if (char_pixel) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
        end
        //actual game screen with racing cars
        else begin
            //gray road surface from y 50 to bottom
            if (y >= 9'd50 && y < 9'd480) begin
                r_next = 8'h60;
                g_next = 8'h60;
                 b_next = 8'h60;
               
                //white dashed lane markers at x 200 and 400
                if (x == 10'd200 || x == 10'd400) begin
                    if (((y - 9'd50) % 9'd40) < 9'd20) begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end
            end
           
            //checkered finish line at x 590
            if (x == 10'd590 && y >= 9'd50 && y < 9'd480)
				begin
                if (((y - 9'd50) / 9'd10) % 2 == 0) 
					 begin
                    r_next = 8'hFF;
                    g_next = 8'h00;
                    b_next = 8'h00;
                end else 
					 begin
                    r_next = 8'hFF;
                    g_next = 8'hFF;
                    b_next = 8'hFF;
                end
            end
           
            //traffic light drawn first so cars can go in front of it
            if (in_rect(x, {1'b0, y}, 10'd580, 10'd10, 10'd40, 10'd40)) begin
                traffic_sprite_x = (x - 10'd580);
                traffic_sprite_y = ({1'b0, y} - 10'd10);
                
                //use sprite rom to know what part of light we on
                if (traffic_pixel) begin
                    //rows 4 to 15 are red circle area
                    if (traffic_sprite_y >= 6'd4 && traffic_sprite_y <= 6'd15) begin
                         if (red_light) begin
                            r_next = 8'hFF; //bright red when lit
                            g_next = 8'h00;
                            b_next = 8'h00;
                        end else begin
                            r_next = 8'h60; //dim red when off
                            g_next = 8'h00;
                            b_next = 8'h00;
                        end
                    end
                    //rows 19 to 30 are green circle area
                    else if (traffic_sprite_y >= 6'd19 && traffic_sprite_y <= 6'd30) begin
                        if (green_light) begin
                            r_next = 8'h00;
                            g_next = 8'hFF; //bright green when lit
                            b_next = 8'h00;
                        end else begin
                            r_next = 8'h00;
                            g_next = 8'h60; //dim green when off
                            b_next = 8'h00;
                         end
                    end
                   
						 //border or spacer parts are white
                    else begin
                        r_next = 8'hFF;
                        g_next = 8'hFF;
                        b_next = 8'hFF;
                    end
                end else begin
                    //dark gray background behind light
                    r_next = 8'h30;
                    g_next = 8'h30;
                    b_next = 8'h30;
                end
            end
           
            //player car using sprite rom for shape
            //hide if lost unless blink signal says show
            if (in_rect(x, {1'b0, y}, player_x, {1'b0, player_y}, 10'd30, 10'd30) && 
                (!player_lost || player_blink)) begin
                car_sprite_x = (x - player_x);
                car_sprite_y = ({1'b0, y} - {1'b0, player_y});
                
                if (car_pixel) 
					 begin
                    if (player_lost) begin
                        r_next = 8'hFF; //red disqualified
                        g_next = 8'h00;
                        b_next = 8'h00;
                    end else begin
                        r_next = 8'h00; //green normally
                        g_next = 8'hFF;
                        b_next = 8'h00;
                    end
                end
            end
           
            //ai car 1 cyan color
            if (in_rect(x, {1'b0, y}, ai1_x, {1'b0, ai1_y}, 10'd30, 10'd30)) begin
                car_sprite_x = (x - ai1_x);
                car_sprite_y = ({1'b0, y} - {1'b0, ai1_y});
                
                if (car_pixel) begin
                    r_next = 8'h00;
                    g_next = 8'hFF;
                    b_next = 8'hFF;
                end
            end
           
            //ai car 2 yellow color
            if (in_rect(x, {1'b0, y}, ai2_x, {1'b0, ai2_y}, 10'd30, 10'd30)) begin
                car_sprite_x = (x - ai2_x);
                car_sprite_y = ({1'b0, y} - {1'b0, ai2_y});
                
					 
                if (car_pixel) 
					 begin
                    r_next = 8'hFF;
                    g_next = 8'hFF;
                    b_next = 8'h00;
                end
            end
           
            //ai car 3 pink 
            if (in_rect(x, {1'b0, y}, ai3_x, {1'b0, ai3_y}, 10'd30, 10'd30)) begin
                car_sprite_x = (x - ai3_x);
                car_sprite_y = ({1'b0, y} - {1'b0, ai3_y});
                
                if (car_pixel) begin
                    r_next = 8'hFF;
                    g_next = 8'h00;
                    b_next = 8'hFF;
                end
            end
        end
    end
   
endmodule 