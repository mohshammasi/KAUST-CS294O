`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2021 10:42:50 PM
// Design Name: 
// Module Name: game_logic
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


module game_logic(input clk, rst,
                  input left_btn, right_btn, up_btn,
                  output reg [10:0] yoshi_x,
                  output reg [9:0] yoshi_y);
    
    // Platforms ranges parameters
    // pl is used as abbreviation for platform
    // Platform 1 -> Lower center of the screen
    parameter pl1_yrange1 = 10'd609;
    // platform 4 -> Higher center of the screen
    parameter pl4_yrange1 = 9'd249;
    // Shared between platforms 1 and 4
    parameter pl1and4_xrange1 = 9'd273;
    parameter pl1and4_xrange2 = 10'd1008;
    
    
    // Platform 2 -> Mid left of the screen
    parameter pl2_xrange1 = 6'd32;
    parameter pl2_xrange2 = 10'd511;
    // Platform 3 -> Mid right of the screen
    parameter pl3_xrange1 = 10'd768;
    parameter pl3_xrange2 = 11'd1247;
    // Shared between platforms 2 and 3
    parameter pl2and3_yrange1 = 9'd429;
    
    // Collision Checking for yoshi with platforms
    reg above_pl1_y = 1'b0; // above platform 1
    reg above_pl4_y = 1'b0; // above platform 4
    reg in_pl1and4_xrange = 1'b0; // shared between platforms 1 and 4
    reg in_pl2_xrange = 1'b0; // within platform 2 x range
    reg in_pl3_xrange = 1'b0; // within platform 3 x range
    reg above_pl2and3_y = 1'b0; // shared between platforms 2 and 3
    always@(posedge clk)
    begin
        // Platform 1 -> Lower center of the screen collision checking, 
        // 32 is Yoshi's width, 42 is height
        above_pl1_y <= (yoshi_y + 10'd42 <= pl1_yrange1);
        // Platform 4 -> Higher center of the screen collision checking
        above_pl4_y <= (yoshi_y + 10'd42 <= pl4_yrange1);
        // In x range, shared between platforms 1 and 4
        in_pl1and4_xrange <= ((pl1and4_xrange1-9'd32) <= yoshi_x) & (yoshi_x <= pl1and4_xrange2);
        
        // Platform 2 -> Low left of the screen collision checking
        in_pl2_xrange <= ((pl2_xrange1) <= yoshi_x) & (yoshi_x <= pl2_xrange2);
        // Platform 3 -> Low right of the screen collision checking
        in_pl3_xrange <= ((pl3_xrange1-9'd32) <= yoshi_x) & (yoshi_x <= pl3_xrange2);
        // Above y, shared between platforms 2 and 3 
        above_pl2and3_y <= (yoshi_y + 10'd42 <= pl2and3_yrange1);
    end
    
    
    // Signed jumping velocity, gravity constant, and negative limit 
    reg signed [10:0] pos_y; // need a signed pos y signal for calculations
    reg signed [10:0] jmp_velocity = 11'd0;
    reg signed [10:0] negative_limit = -11'd30;
    reg signed [10:0] gravity = 11'd1;
    reg jumping;
    always@(posedge clk)
    begin
        if (rst)
        begin
            yoshi_x <= 11'd640;
            pos_y <= 11'd756;
        end
        else
        begin    
            // Move left when the left button is pressed
            if (left_btn)
            begin
                if (yoshi_x >= 11'd36) // Don't hit left border
                    yoshi_x <= yoshi_x - 11'd4;
            end
            
            // Move right when the right button is pressed
            if (right_btn)
            begin
                if (yoshi_x + 11'd32 <= 11'd1243) // Don't hit the right border
                    yoshi_x <= yoshi_x + 11'd4;
            end
            
            // If gravity pulls us lower than the floor/platform, set to floor/platform y
            // If the character is on the floor/platform then we are not jumping
            // We set the velocity to 0 while grounded because we want to keep the gravity
            // effect natural when the character walks off a platform i.e. gravity will start
            // from 0 until the character hits the ground.
            if (in_pl1and4_xrange & above_pl4_y) // in x range, above y
            begin
                // Make sure Yoshi stays on the platform
                if ((pos_y + 11'd42 - jmp_velocity) >= pl4_yrange1)
                begin
                    // platform 4 ground y coordinate
                    pos_y <= 11'd207; // 207 + 42 = 249
                    
                    // reset velocity to 0 when Yoshi is grounded so
                    // that when he walk off the platform the gravity 
                    // effect starts feels natural
                    jmp_velocity <= 11'd0;
                end
                else
                    pos_y <= pos_y - jmp_velocity; // apply gravity effect
            end
            else if (in_pl3_xrange & above_pl2and3_y) // platform 3
            begin
                if ((pos_y + 11'd42 - jmp_velocity) >= pl2and3_yrange1)
                begin
                    pos_y <= 11'd387;
                    jmp_velocity <= 11'd0;  
                end
                else
                    pos_y <= pos_y - jmp_velocity; // apply gravity effect
            end
            else if (in_pl2_xrange & above_pl2and3_y) // platform 2
            begin
                if ((pos_y + 11'd42 - jmp_velocity) >= pl2and3_yrange1)
                begin
                    pos_y <= 11'd387;
                    jmp_velocity <= 11'd0;  
                end
                else
                    pos_y <= pos_y - jmp_velocity; // apply gravity effect
            end
            else if (in_pl1and4_xrange & above_pl1_y) // platform 1
            begin
                if ((pos_y + 11'd42 - jmp_velocity) >= pl1_yrange1)
                begin
                    pos_y <= 11'd567;
                    jmp_velocity <= 11'd0;  
                end
                else
                    pos_y <= pos_y - jmp_velocity; // apply gravity effect
            end
            // 768 is ground y coord, 42 is height
            else if ((pos_y + 11'd42 - jmp_velocity) >= 11'd768)
            begin
                pos_y <= 11'd726; // 726 + 42 = 768, on the ground
                jmp_velocity <= 11'd0;
            end
            else
                pos_y <= pos_y - jmp_velocity; // apply gravity effect
                jmp_velocity <= jmp_velocity - gravity; // update velocity constantly
            
            // Limit the velocity negative value, avoids nasty errors
            if (jmp_velocity <= negative_limit)
                jmp_velocity <= 11'd0;
            
            // only jump if we are not jumping already
            if (up_btn & !jumping)
            begin
                jmp_velocity <= 11'd19;
                jumping = 1'b1; // set jumping flag
            end        
            
            if (pos_y - jmp_velocity <= 11'd31) // dont jump through the ceiling
            begin
                pos_y <= 11'd32;
                jmp_velocity <= 11'd0;
            end
            
            if (pos_y == 11'd726) // on floor
            begin
                jumping <= 1'b0;
            end
            else if (pos_y == 11'd567) // on platform 1
            begin
                jumping <= 1'b0;
            end
            else if (pos_y == 11'd387) // on platform 2 or 3
            begin
                jumping <= 1'b0;
            end
            else if (pos_y == 11'd207) // on platform 4
            begin
                jumping <= 1'b0;
            end

            yoshi_y <= $unsigned(pos_y); // assign unsigned to output signal
        end
    end
endmodule 