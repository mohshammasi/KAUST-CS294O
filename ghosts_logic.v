`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2021 05:35:43 PM
// Design Name: 
// Module Name: ghosts_logic
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


module ghosts_logic(input clk, rst,
                    input ghost1, ghost2, ghost3, ghost4,
                    input [10:0] yoshi_x,
                    input [9:0] yoshi_y,
                    output reg led_b, led_g, led_r,
                    output reg got_hit1, got_hit2, got_hit3, got_hit4,
                    output reg [10:0] ghost1_x, ghost2_x, ghost3_x, ghost4_x,
                    output reg [9:0] ghost1_y, ghost2_y, ghost3_y, ghost4_y);
                                    
    parameter YOSHI_SIZE = 6'd32;
    // Ghosts parameters: size, and speed in the x and y directions
    parameter GHOSTS_SIZE = 6'd32;
    // Ghost 1
    parameter GHOST1_X_SPEED = 11'd1;
    parameter GHOST1_Y_SPEED = 10'd1;
    // Ghost 2
    parameter GHOST2_X_SPEED = 11'd2;
    parameter GHOST2_Y_SPEED = 10'd2;
    // Ghost 3
    parameter GHOST3_X_SPEED = 11'd3;
    parameter GHOST3_Y_SPEED = 10'd3;
    // Ghost 4
    parameter GHOST4_X_SPEED = 11'd4;
    parameter GHOST4_Y_SPEED = 10'd4;
    
    // Checks if there is any overlap between the character and a ghost to apply damage
    // YOSHI_SIZE is the width=32 to be a bit more specific
    assign overlap1 = ((yoshi_x <= ghost1_x + GHOSTS_SIZE) &
                       (yoshi_x + YOSHI_SIZE >= ghost1_x) &
                       (yoshi_y <= ghost1_y + GHOSTS_SIZE) &
                       (yoshi_y + YOSHI_SIZE >= ghost1_y)
    );
    
    assign overlap2 = ((yoshi_x <= ghost2_x + GHOSTS_SIZE) &
                       (yoshi_x + YOSHI_SIZE >= ghost2_x) &
                       (yoshi_y <= ghost2_y + GHOSTS_SIZE) &
                       (yoshi_y + YOSHI_SIZE >= ghost2_y)
    );
    
    assign overlap3 = ((yoshi_x <= ghost3_x + GHOSTS_SIZE) &
                       (yoshi_x + YOSHI_SIZE >= ghost3_x) &
                       (yoshi_y <= ghost3_y + GHOSTS_SIZE) &
                       (yoshi_y + YOSHI_SIZE >= ghost3_y)
    );
    
    assign overlap4 = ((yoshi_x <= ghost4_x + GHOSTS_SIZE) &
                       (yoshi_x + YOSHI_SIZE >= ghost4_x) &
                       (yoshi_y <= ghost4_y + GHOSTS_SIZE) &
                       (yoshi_y + YOSHI_SIZE >= ghost4_y)
    );
    
    
    // Signals used to check if any of the ghosts is close to the character
    // these are used to light up the RGB Leds to red if a ghost is near
    parameter CLOSE_DISTANCE = 8'd150;
    reg ghost1_x_close, ghost1_y_close;
    reg ghost2_x_close, ghost2_y_close;
    reg ghost3_x_close, ghost3_y_close;
    reg ghost4_x_close, ghost4_y_close;
    assign ghost1_close = (ghost1_x_close & ghost1_y_close);
    assign ghost2_close = (ghost2_x_close & ghost2_y_close);
    assign ghost3_close = (ghost3_x_close & ghost3_y_close);
    assign ghost4_close = (ghost4_x_close & ghost4_y_close);
    
    always @ *
    begin
        if (ghost1_close)
        begin
            led_b = 1'b0;
            led_g = 1'b0;
            led_r = 1'b1;
        end
        
        if (ghost2_close)
        begin
            led_b = 1'b0;
            led_g = 1'b0;
            led_r = 1'b1;
        end
        
        if (ghost3_close)
        begin
            led_b = 1'b0;
            led_g = 1'b0;
            led_r = 1'b1;
        end
        
        if (ghost4_close)
        begin
            led_b = 1'b0;
            led_g = 1'b0;
            led_r = 1'b1;
        end
        
        if (!ghost1_close & !ghost2_close & !ghost3_close & !ghost4_close)
        begin
            led_b = 1'b1;
            led_g = 1'b0;
            led_r = 1'b0;
        end
    end
    
    always @ (posedge clk)
    begin
        if (rst)
        begin
            // Ghost 1
            if (ghost1)
            begin
                ghost1_x <= 11'd12;
                ghost1_y <= 10'd12;
            end
            
            // Ghost 2
            if (ghost2)
            begin
                ghost2_x <= 11'd1250;
                ghost2_y <= 10'd12;
            end
            
            // Ghost 3
            if (ghost3)
            begin
                ghost3_x <= 11'd12;
                ghost3_y <= 10'd760;
            end
            
            // Ghost 4
            if (ghost4)
            begin
                ghost4_x <= 11'd1250;
                ghost4_y <= 10'd760;
            end
        end
        else
        begin
            // Ghost 1
            if (ghost1)
            begin
                if (ghost1_x < yoshi_x)
                begin
                    ghost1_x <= ghost1_x + GHOST1_X_SPEED; // move right
                    
                    // Distance check for RGB Leds!
                    if (yoshi_x - ghost1_x <= CLOSE_DISTANCE)
                        ghost1_x_close <= 1'b1;
                    else
                        ghost1_x_close <= 1'b0;
                end
                else if (ghost1_x > yoshi_x)
                begin
                    ghost1_x <= ghost1_x - GHOST1_X_SPEED; // move left
                    
                    // Distance check for RGB Leds!
                    if (ghost1_x - yoshi_x <= CLOSE_DISTANCE)
                        ghost1_x_close <= 1'b1;
                    else
                        ghost1_x_close <= 1'b0;
                end
                    
                if (ghost1_y < yoshi_y)
                begin
                    ghost1_y <= ghost1_y + GHOST1_Y_SPEED; // move down
                    
                    // Distance check for RGB Leds!
                    if (yoshi_y - ghost1_y <= CLOSE_DISTANCE)
                        ghost1_y_close <= 1'b1;
                    else
                        ghost1_y_close <= 1'b0;
                end
                else if (ghost1_y > yoshi_y)
                begin
                    ghost1_y <= ghost1_y - GHOST1_Y_SPEED; // move up
                    
                    // Distance check for RGB Leds!
                    if (ghost1_y - yoshi_y <= CLOSE_DISTANCE)
                        ghost1_y_close <= 1'b1;
                    else
                        ghost1_y_close <= 1'b0;
                end        
                    
                // If the ghost touches the character set signal for hit
                if (overlap1)
                    got_hit1 <= 1'b1;
                else
                    got_hit1 <= 1'b0;
            end
            
            // Ghost 2
            if (ghost2)
            begin
                if (ghost2_x < yoshi_x)
                begin
                    ghost2_x <= ghost2_x + GHOST2_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_x - ghost2_x <= CLOSE_DISTANCE)
                        ghost2_x_close <= 1'b1;
                    else
                        ghost2_x_close <= 1'b0;
                end
                else if (ghost2_x > yoshi_x)
                begin
                    ghost2_x <= ghost2_x - GHOST2_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost2_x - yoshi_x <= CLOSE_DISTANCE)
                        ghost2_x_close <= 1'b1;
                    else
                        ghost2_x_close <= 1'b0;
                end
                    
                if (ghost2_y < yoshi_y)
                begin
                    ghost2_y <= ghost2_y + GHOST2_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_y - ghost2_y <= CLOSE_DISTANCE)
                        ghost2_y_close <= 1'b1;
                    else
                        ghost2_y_close <= 1'b0;
                end
                else if (ghost2_y > yoshi_y)
                begin
                    ghost2_y <= ghost2_y - GHOST2_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost2_y - yoshi_y <= CLOSE_DISTANCE)
                        ghost2_y_close <= 1'b1;
                    else
                        ghost2_y_close <= 1'b0;
                end
                    
                // If the ghost touches the character set signal for hit
                if (overlap2)
                    got_hit2 <= 1'b1;
                else
                    got_hit2 <= 1'b0;
            end
            
            // Ghost 3
            if (ghost3)
            begin
                if (ghost3_x < yoshi_x)
                begin
                    ghost3_x <= ghost3_x + GHOST3_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_x - ghost3_x <= CLOSE_DISTANCE)
                        ghost3_x_close <= 1'b1;
                    else
                        ghost3_x_close <= 1'b0;
                end
                else if (ghost3_x > yoshi_x)
                begin
                    ghost3_x <= ghost3_x - GHOST3_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost3_x - yoshi_x <= CLOSE_DISTANCE)
                        ghost3_x_close <= 1'b1;
                    else
                        ghost3_x_close <= 1'b0;
                end
                    
                if (ghost3_y < yoshi_y)
                begin
                    ghost3_y <= ghost3_y + GHOST3_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_y - ghost3_y <= CLOSE_DISTANCE)
                        ghost3_y_close <= 1'b1;
                    else
                        ghost3_y_close <= 1'b0;
                end
                else if (ghost3_y > yoshi_y)
                begin
                    ghost3_y <= ghost3_y - GHOST3_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost3_y - yoshi_y <= CLOSE_DISTANCE)
                        ghost3_y_close <= 1'b1;
                    else
                        ghost3_y_close <= 1'b0;
                end
                    
                // If the ghost touches the character set signal for hit
                if (overlap3)
                    got_hit3 <= 1'b1;
                else
                    got_hit3 <= 1'b0;
            end
            
            // Ghost 4
            if (ghost4)
            begin
                if (ghost4_x < yoshi_x)
                begin
                    ghost4_x <= ghost4_x + GHOST4_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_x - ghost4_x <= CLOSE_DISTANCE)
                        ghost4_x_close <= 1'b1;
                    else
                        ghost4_x_close <= 1'b0;
                end
                else if (ghost4_x > yoshi_x)
                begin
                    ghost4_x <= ghost4_x - GHOST4_X_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost4_x - yoshi_x <= CLOSE_DISTANCE)
                        ghost4_x_close <= 1'b1;
                    else
                        ghost4_x_close <= 1'b0;
                end
                    
                if (ghost4_y < yoshi_y)
                begin
                    ghost4_y <= ghost4_y + GHOST4_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (yoshi_y - ghost4_y <= CLOSE_DISTANCE)
                        ghost4_y_close <= 1'b1;
                    else
                        ghost4_y_close <= 1'b0;
                end
                else if (ghost4_y > yoshi_y)
                begin
                    ghost4_y <= ghost4_y - GHOST4_Y_SPEED;
                    
                    // Distance check for RGB Leds!
                    if (ghost4_y - yoshi_y <= CLOSE_DISTANCE)
                        ghost4_y_close <= 1'b1;
                    else
                        ghost4_y_close <= 1'b0;
                end
                    
                // If the ghost touches the character set signal for hit
                if (overlap4)
                    got_hit4 <= 1'b1;
                else
                    got_hit4 <= 1'b0;
            end
        end
    end   
endmodule
