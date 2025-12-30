/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: sprite_x, sprite_y
Outputs:  pixel

Description: traffic Light Sprite ROM 40x40 pixel
 */
module traffic_light_sprite_rom (
    input logic [5:0] sprite_x,  // 0-39 (40 pixels wide)
    input logic [5:0] sprite_y,  // 0-39 (40 pixels tall)
    output logic pixel           // 1 = draw, 0 = transparent
);
    
    // Generate traffic light shape combinationally
    always_comb begin
        pixel = 1'b0; // Default transparent
        
        case (sprite_y)
            // Top border
            6'd0, 6'd1: begin
                pixel = 1'b1;
            end
            
            // Upper border sides
            6'd2, 6'd3: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
            end
            
            // Red light circle area (rows 4-15)
            6'd4: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd12 && sprite_x <= 6'd27) pixel = 1'b1;
            end
            
            6'd5: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd10 && sprite_x <= 6'd29) pixel = 1'b1;
            end
            
            6'd6: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd9 && sprite_x <= 6'd30) pixel = 1'b1;
            end
            
            6'd7: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd8 && sprite_x <= 6'd31) pixel = 1'b1;
            end
            
            6'd8, 6'd9, 6'd10, 6'd11: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd7 && sprite_x <= 6'd32) pixel = 1'b1;
            end
            
            6'd12: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd8 && sprite_x <= 6'd31) pixel = 1'b1;
            end
            
            6'd13: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd9 && sprite_x <= 6'd30) pixel = 1'b1;
            end
            
            6'd14: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd10 && sprite_x <= 6'd29) pixel = 1'b1;
            end
            
            6'd15: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd12 && sprite_x <= 6'd27) pixel = 1'b1;
            end
            
            // Middle spacer (rows 16-18)
            6'd16, 6'd17, 6'd18: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
            end
            
            // Green light circle area (rows 19-30)
            6'd19: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd12 && sprite_x <= 6'd27) pixel = 1'b1;
            end
            
            6'd20: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd10 && sprite_x <= 6'd29) pixel = 1'b1;
            end
            
            6'd21: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd9 && sprite_x <= 6'd30) pixel = 1'b1;
            end
            
            6'd22: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd8 && sprite_x <= 6'd31) pixel = 1'b1;
            end
            
            6'd23, 6'd24, 6'd25, 6'd26: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd7 && sprite_x <= 6'd32) pixel = 1'b1;
            end
            
            6'd27: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd8 && sprite_x <= 6'd31) pixel = 1'b1;
            end
            
            6'd28: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd9 && sprite_x <= 6'd30) pixel = 1'b1;
            end
            
            6'd29: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd10 && sprite_x <= 6'd29) pixel = 1'b1;
            end
            
            6'd30: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
                else if (sprite_x >= 6'd12 && sprite_x <= 6'd27) pixel = 1'b1;
            end
            
            // Lower spacer (rows 31-37)
            6'd31, 6'd32, 6'd33, 6'd34, 6'd35, 6'd36, 6'd37: begin
                if (sprite_x <= 6'd1 || sprite_x >= 6'd38) pixel = 1'b1;
            end
            
            // Bottom border
            6'd38, 6'd39: begin
                pixel = 1'b1;
            end
            
            default: pixel = 1'b0;
        endcase
    end
    
endmodule