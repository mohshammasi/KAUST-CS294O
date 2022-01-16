`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2021 06:06:10 PM
// Design Name: 
// Module Name: eggs_logic
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


module eggs_logic(input clk, rst, 
                  input [10:0] yoshi_x,
                  input [9:0] yoshi_y, 
                  output reg [10:0] egg_x,
                  output reg [9:0] egg_y,
                  output reg [3:0] score_dig1, score_dig2, score_dig3, score_dig4);
                  
    
    // Serial to parallel shift register to keep shifting the random egg x & y positions
    // over time. These x and y indices are used to select the next egg position which only
    // changes when the player consumes the current egg. Hence randomness is achieved by
    // making the next egg position depend on the time (more specifically the clock edge)
    // that the egg was consumed at.
    reg x_index = 1'b0, y_index = 1'b0;
    reg [4:0] rand_egg_x = 5'b00001; // 5 bits just to increase randomness and not align with y 
    reg [3:0] rand_egg_y = 4'b0001; // 4 bits because we have 4 levels of height (y value) floor, pl1, pl2&3, pl4
    
    // Similar logic to anode activation shifting for sevengsegment display
    always @ *
    begin
        x_index = 1'b0;
        y_index = 1'b0;
        if (rand_egg_x == 5'b10000)
            x_index = 1'b1;
            
        if (rand_egg_y == 4'b1000)
            y_index = 1'b1;
    end
    
    // Shift register, shift to the left
    always @ (posedge clk)
    begin
        rand_egg_x[0] <= x_index;
        rand_egg_x[4:1] <= rand_egg_x[3:0];
        
        rand_egg_y[0] <= y_index;
        rand_egg_y[3:1] <= rand_egg_y[2:0];
    end
    
    
    // Parameters for the ground/platform values for the eggs on each level
    parameter ground = 10'd732;
    parameter pl1_ground = 10'd573;
    parameter pl2and3_ground = 10'd393;
    parameter pl4_ground = 10'd213;
    
    reg [10:0] next_egg_x = 11'd240;
    reg [9:0] next_egg_y = 10'd732;
    reg [10:0] x_option1, x_option2, x_option3, x_option4, x_option5;
    always @ *
    begin
        // Case statement to set the y coordinate for the next egg position and set values of the
        // x_option registers to appropriate values that are WITHIN the selected surface x range
        case(rand_egg_y)
            4'b0001: begin // ground
                        next_egg_y = ground;
                        x_option1 = 11'd140;
                        x_option2 = 11'd350;
                        x_option3 = 11'd560;
                        x_option4 = 11'd770;
                        x_option5 = 11'd980;
                     end
            4'b0010: begin // platform 1
                        next_egg_y = pl1_ground;
                        x_option1 = 11'd280;
                        x_option2 = 11'd450;
                        x_option3 = 11'd620;
                        x_option4 = 11'd790;
                        x_option5 = 11'd960;
                     end
            4'b0100: begin // platforms 2 and 3
                        next_egg_y = pl2and3_ground;
                        x_option1 = 11'd80;
                        x_option2 = 11'd420;
                        x_option3 = 11'd785;
                        x_option4 = 11'd971;
                        x_option5 = 11'd1157;
                     end
            4'b1000: begin // platform 4, similar to platform 1
                        next_egg_y = pl4_ground;
                        x_option1 = 11'd280;
                        x_option2 = 11'd450;
                        x_option3 = 11'd620;
                        x_option4 = 11'd790;
                        x_option5 = 11'd960;
                     end
        endcase
        
        // Case statement to set the x for the next egg position. x_option registers values have been
        // assigned coordinate values based on rand_egg_y in the previous case statement
        case(rand_egg_x)
            5'b00001: next_egg_x = x_option1;
            5'b00010: next_egg_x = x_option2;
            5'b00100: next_egg_x = x_option3;
            5'b01000: next_egg_x = x_option4;
            5'b10000: next_egg_x = x_option5;
        endcase
    end
    
    // Overlap check for egg consumption 
    parameter CHARACTER_SIZE = 6'd32; // wdith, to be more specific
    parameter EGG_SIZE = 6'd32; // width, to be more specific
    assign overlap = ((yoshi_x <= egg_x + EGG_SIZE) &
                      (yoshi_x + CHARACTER_SIZE >= egg_x) &
                      (yoshi_y <= egg_y + EGG_SIZE) &
                      (yoshi_y + CHARACTER_SIZE >= egg_y)
    );
    
    // Synchronous block to signal consumption of current egg and fetch next egg position
    // Also increment the score counter
    always @ (posedge clk)
    begin
        if (rst)
        begin
            // Egg position
            egg_x <= 11'd640;
            egg_y <= pl1_ground;
            
            // Score counter
            score_dig1 <= 4'd0;
            score_dig2 <= 4'd0;
            score_dig3 <= 4'd0;
            score_dig4 <= 4'd0;
        end
        else
        begin
            if (overlap)
            begin
                // Change egg position when collected
                egg_x <= next_egg_x;
                egg_y <= next_egg_y;
                
                // Increment score counter, this can possibly be in a separte module
                score_dig1 <= score_dig1 + 1'b1; // increment by 1
                
                // score_dig2 increment if score_dig1 is 9
                if (score_dig1 == 4'd9)
                    score_dig2 <= score_dig2 + 1'b1;
                
                // score_dig3 increment if both score_dig1, score_dig2 are 9
                if (score_dig1 == 4'd9 & score_dig2 == 4'd9)
                    score_dig3 <= score_dig3 + 1'b1;
                
                // score_dig4 increment if all score_dig1-3 are 9
                if (score_dig1 == 4'd9 & score_dig2 == 4'd9 & score_dig3 == 4'd9)
                    score_dig4 <= score_dig4 + 1'b1;
                    
                // Loop back to 0 after reaching 9 for the decimal counters
                if (score_dig1 == 4'd9 & score_dig2 == 4'd9 & score_dig3 == 4'd9 & score_dig4 == 4'd9)
                    score_dig4 <= 4'b0000;
                    
                if (score_dig1 == 4'd9 & score_dig2 == 4'd9 & score_dig3 == 4'd9)
                    score_dig3 <= 4'b0000;
                    
                if (score_dig1 == 4'd9 & score_dig2 == 4'd9)
                    score_dig2 <= 4'b0000;
                    
                if (score_dig1 == 4'd9)
                    score_dig1 <= 4'b0000;
            end
        end
    end
endmodule