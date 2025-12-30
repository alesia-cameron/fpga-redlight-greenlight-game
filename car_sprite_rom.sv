/* 
EE/CSE 371
Dec 5, 2025
Lab 6 - Red Light, Green Light  

Inputs: sprite_x, sprite_y
Outputs: pixel

Description:
stores car sprite pattern as hardcoded logic, takes in x and y coordinates 
within 30x30 pixel grid, outputs whether specific pixel should be solid or 
transparent. Defines car shape row by row using comb logic that checks 
coordinate ranges. Creates car silhouette. Used by graphics controller to 
draw four racing cars on screen by sampling different positions within 
sprite pattern 


*/

/* Car Sprite ROM 30x30 pixel car combinational logic instead of initial blocks for FPGA synthesis
 */
module car_sprite_rom (
    input logic [4:0] sprite_x, //horizontal pixel position sprite from 0 to 29
    input logic [4:0] sprite_y,  //vertical pixel position sprite from 0 to 29
    output logic pixel //output high for solid pixel, low for transparent
);
    
    //calcu pixel val based on coordinates creates car shape by defining which pixels are solid versus transparent
    always_comb 
	 begin
        pixel = 1'b0; //start with transparent as default for each pixel
        
        //organized by row number from top to bottom, each row defines which columns should be solid
        case (sprite_y)
            //rows 0 through 4 at top are completely transparent creates empty space above car body
            5'd0, 5'd1, 5'd2, 5'd3, 5'd4: pixel = 1'b0;
            
            //row 5 starts forming top of car windshield
            //solid pixels from column 8 to 21
            5'd5: begin
                if (sprite_x >= 5'd8 && sprite_x <= 5'd21) pixel = 1'b1;
            end
            
            //row 6 windshield wider
            //solid from column 7 to 22
            5'd6: begin
                if (sprite_x >= 5'd7 && sprite_x <= 5'd22) pixel = 1'b1;
            end
            
           //row 7 windshield expanding
            //solid from column 6 to 23
            5'd7: begin
                if (sprite_x >= 5'd6 && sprite_x <= 5'd23) pixel = 1'b1;
            end
            
            //rows 8 through 10 form upper car body
            //solid from column 5 to 24
            5'd8, 5'd9, 5'd10: begin
                if (sprite_x >= 5'd5 && sprite_x <= 5'd24) pixel = 1'b1;
            end
            
            //rows 11 through 13 continue car body wider
            //solid from column 4 to 25
            5'd11, 5'd12, 5'd13: begin
                if (sprite_x >= 5'd4 && sprite_x <= 5'd25) pixel = 1'b1;
            end
            
            //row 14 body even wider
             //solid from column 3 to 26
            5'd14: begin
                if (sprite_x >= 5'd3 && sprite_x <= 5'd26) pixel = 1'b1;
            end
            
            //rows 15 through 20 form main body at widest point
            //solid from column 2 to 27
            5'd15, 5'd16, 5'd17, 5'd18, 5'd19, 5'd20: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) pixel = 1'b1;
            end
            
            //row 21 has wheel cutouts at front and back
            //body spans columns 2 to 27
            //but front wheel cuts out columns 5 to 9
            //and rear wheel cuts out columns 20 to 24
            5'd21: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) 
					 begin
                    if ((sprite_x >= 5'd5 && sprite_x <= 5'd9) || 
                         (sprite_x >= 5'd20 && sprite_x <= 5'd24)) begin
                        pixel = 1'b0; //make transparent for wheel
                    end else 
						  begin
                      pixel = 1'b1; //solid body between wheels
                    end
                end
            end
            
            //row 22 wheel cutouts slightly narrower
            //front wheel from columns 6 - 10
            //rear wheel from columns 19 - 23
            5'd22: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) begin
                    if ((sprite_x >= 5'd6 && sprite_x <= 5'd10) || 
                        (sprite_x >= 5'd19 && sprite_x <= 5'd23)) begin
                        pixel = 1'b0;
                    end else 
						  begin
                      pixel = 1'b1;
                    end
                end
            end
            
            //rows 23 and 24 wheel cutouts at narrowest
            //front wheel from columns 7 to 11
            //rear wheel from columns 18 to 22
            5'd23, 5'd24: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) begin
                    if ((sprite_x >= 5'd7 && sprite_x <= 5'd11) || 
                        (sprite_x >= 5'd18 && sprite_x <= 5'd22)) begin
                        pixel = 1'b0;
                    end else 
						  begin
                        pixel = 1'b1;
                    end
                end
            end
            
            //row 25 wheel cutouts start widening again
            //front wheel from columns 6 to 10
            //rear wheel from columns 19 to 23
            5'd25: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) begin
                    if ((sprite_x >= 5'd6 && sprite_x <= 5'd10) || 
                        (sprite_x >= 5'd19 && sprite_x <= 5'd23)) begin
                        pixel = 1'b0;
                    end else begin
                        pixel = 1'b1;
                    end
                end
            end
            
            //row 26 wheel cutouts back to widest
            //front wheel from columns 5 to 9
            //rear wheel from columns 20 to 24
            5'd26: begin
                if (sprite_x >= 5'd2 && sprite_x <= 5'd27) begin
                    if ((sprite_x >= 5'd5 && sprite_x <= 5'd9) || 
                        (sprite_x >= 5'd20 && sprite_x <= 5'd24)) begin
                          pixel = 1'b0;
                    end else 
						  begin
                        pixel = 1'b1;
                    end
                end
            end
            
            //rows 27 through 29 at bottom transparent
            //empty space below car body
            5'd27, 5'd28, 5'd29: pixel = 1'b0;
            
            //default case catches unexpected vals
            //makes pixel transparent for safety
            default: pixel = 1'b0;
        endcase
   end
    
endmodule