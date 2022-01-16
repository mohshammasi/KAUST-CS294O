`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 10:36:43 AM
// Design Name: 
// Module Name: vga_out
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_out(input clk, rst,
               input [3:0] red_v, green_v, blue_v,
               output [3:0] pix_r, pix_g, pix_b,
               output reg within, 
               output hsync, vsync,
               output reg [10:0] curr_x,
               output reg [9:0] curr_y);

    reg [10:0] hcount;
    reg [9:0] vcount;
    
    always@(posedge clk)
    begin
        if (rst)
        begin
            hcount <= 11'b0;
            vcount <= 10'b0;
        end
        else
        begin
            if (hcount == 11'd1679)
            begin
                hcount <= 11'b0;  
            
                if (vcount == 10'd827)
                    vcount <= 10'b0; 
                else
                    vcount <= vcount + 1'b1;
            end 
            else
                hcount <= hcount + 1'b1;
        end 
    end
    
    // When hcount is between 0 and 135 we assign 0 to hsync, otherwise we assign 1
    assign hsync = (11'd0 <= hcount) & (hcount <= 11'd135) ? 0 : 1; 
    assign vsync = (10'd0 <= vcount) & (vcount <= 10'd2) ? 1 : 0;
    
    // Set the pixel signals to be the input from drawcon when we are within the display area
    wire within_h, within_v;
    assign within_h = (11'd336 <= hcount) & (hcount <= 11'd1615);
    assign within_v = (10'd27 <= vcount) & (vcount <= 10'd826);
    assign pix_r = (within_h & within_v) ? red_v : 4'd0;
    assign pix_g = (within_h & within_v) ? green_v : 4'd0;
    assign pix_b = (within_h & within_v) ? blue_v : 4'd0;
    
    always@(posedge clk)
    begin
        if (rst)
        begin
            curr_x <= 11'b0;
            curr_y <= 10'b0;
        end
        else
        begin
            if (within_h & within_v)
            begin
                // Signal goes to drawcon to tell if we are within the screen
                within <= 1'b1;
                    
                if (curr_x == 11'd1279)
                begin
                    curr_x <= 11'b0;
                
                    if (curr_y == 10'd799)
                        curr_y <= 10'b0;
                    else
                        curr_y <= curr_y + 1'b1;
                end
                else
                    curr_x <= curr_x + 1'b1;
            end
            else
                within <= 1'b0;
        end
   end
endmodule
