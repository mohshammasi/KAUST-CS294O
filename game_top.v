`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 07:05:44 PM
// Design Name: 
// Module Name: game_top
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


module game_top(input clk, rst,
                input left_btn, right_btn, up_btn, // character control
                input enemy1, enemy2, enemy3, enemy4, // enemy switches
                output a, b, c, d, e, f, g, // seven segments display
                output [7:0] an, // anode's for multi-digit seven segments
                output [3:0] pix_r, pix_g, pix_b, // pixel RGB output
                output led_b, led_g, led_r, // RGB LED
                output hsync, vsync); // control signals for display
               
               
    wire pixclk; // IP block generates an 83.46MHz clock
    wire posclk; // IP block generates a 6MHz clock
    wire displayclk; // IP block generates a 95 MHz clock
    clock_div clock_dividers (.clk_out1(pixclk), .clk_out2(posclk), .clk_out3(displayclk), .clk_in1(clk));
    
    // We require a 60hz clock for the position logic,using a counter we further divide the 6MHz to 60Hz
    wire [15:0] constant = 16'd49999;
    reg [15:0] clk_count = 16'd0;
    always@(posedge posclk)
    begin
        if (rst)
            clk_count <= 16'd0;
        else if (clk_count == constant)
            clk_count <= 16'd0;
        else
            clk_count <= clk_count + 1'b1;
    end
    
    reg sixtyhz_clk;
    always@(posedge posclk)
    begin
        if (rst)
            sixtyhz_clk <= 1'b0;
        else if (clk_count == constant)
            sixtyhz_clk <= ~sixtyhz_clk;
        else
            sixtyhz_clk <= sixtyhz_clk;
    end
    
    // vga_out module instantiation
    wire [10:0] curr_x;
    wire [9:0] curr_y;
    wire within; // within display area or not
    vga_out vga1 (.clk(pixclk),
                 .rst(rst),
                 .red_v(draw_r),
                 .green_v(draw_g),
                 .blue_v(draw_b),
                 // Outputs
                 .within(within),
                 .pix_r(pix_r), 
                 .pix_g(pix_g), 
                 .pix_b(pix_b), 
                 .hsync(hsync), 
                 .vsync(vsync),
                 .curr_x(curr_x),
                 .curr_y(curr_y)
    );
    
    // game_logic module instantiation
    wire [10:0] yoshi_x;
    wire [9:0] yoshi_y;
    game_logic logic1 (.clk(sixtyhz_clk),
                      .rst(rst), 
                      .left_btn(left_btn),
                      .right_btn(right_btn),
                      .up_btn(up_btn),
                      // Outputs
                      .yoshi_x(yoshi_x),
                      .yoshi_y(yoshi_y)
    ); 
    
    // ghosts_logic module instantiation
    wire [10:0] ghost1_x, ghost2_x, ghost3_x, ghost4_x;
    wire [9:0] ghost1_y, ghost2_y, ghost3_y, ghost4_y;
    wire got_hit1, got_hit2, got_hit3, got_hit4;
    ghosts_logic logic2 (.clk(sixtyhz_clk),
                         .rst(rst),
                         .ghost1(enemy1),
                         .ghost2(enemy2),
                         .ghost3(enemy3),
                         .ghost4(enemy4),
                         .yoshi_x(yoshi_x),
                         .yoshi_y(yoshi_y),
                         // Outputs
                         // RGB Leds
                         .led_b(led_b),
                         .led_g(led_g),
                         .led_r(led_r),
                         // Inflicting damage signals
                         .got_hit1(got_hit1),
                         .got_hit2(got_hit2),
                         .got_hit3(got_hit3),
                         .got_hit4(got_hit4),
                         // ghosts positions x,y
                         .ghost1_x(ghost1_x),
                         .ghost2_x(ghost2_x),
                         .ghost3_x(ghost3_x),
                         .ghost4_x(ghost4_x),
                         .ghost1_y(ghost1_y),
                         .ghost2_y(ghost2_y),
                         .ghost3_y(ghost3_y),
                         .ghost4_y(ghost4_y)
    );
    
    // eggs_logic module instantiation
    wire [10:0] egg_x;
    wire [9:0] egg_y;
    wire [3:0] score_dig1, score_dig2, score_dig3, score_dig4;
    eggs_logic logic3 (.clk(sixtyhz_clk),
                       .rst(rst), 
                       .yoshi_x(yoshi_x),
                       .yoshi_y(yoshi_y),
                       // Ouputs
                       .egg_x(egg_x),
                       .egg_y(egg_y),
                       .score_dig1(score_dig1),
                       .score_dig2(score_dig2),
                       .score_dig3(score_dig3),
                       .score_dig4(score_dig4)
    );
    
    // Drawcon instantiation
    wire [3:0] draw_r, draw_g, draw_b;
    reg game_over = 1'b0;
    drawcon draw1 (.clk(pixclk),
                   .game_over(game_over),
                   .within(within),
                   .left_btn(left_btn),
                   .right_btn(right_btn),
                   // Character related signals     
                   .yoshi_x(yoshi_x),
                   .yoshi_y(yoshi_y),
                   // Ghosts related signals
                   // switches
                   .ghost1(enemy1),
                   .ghost2(enemy2),
                   .ghost3(enemy3),
                   .ghost4(enemy4),
                   // x, y coordinates
                   .ghost1_x(ghost1_x),
                   .ghost2_x(ghost2_x),
                   .ghost3_x(ghost3_x),
                   .ghost4_x(ghost4_x),
                   .ghost1_y(ghost1_y),
                   .ghost2_y(ghost2_y),
                   .ghost3_y(ghost3_y),
                   .ghost4_y(ghost4_y),
                   // Eggs related signals
                   .egg_x(egg_x),
                   .egg_y(egg_y),
                   // Current drawing pixel position signals
                   .draw_x(curr_x),
                   .draw_y(curr_y),
                   // Outputs
                   .r(draw_r),
                   .g(draw_g),
                   .b(draw_b)
    );
    
    
    // seven segments display module instantiation
    wire digits_clk;
    multidigit seginterface (.clk(displayclk),
                             .rst(rst), 
                             // Score digits
                             .dig0(score_dig1), 
                             .dig1(score_dig2), 
                             .dig2(score_dig3), 
                             .dig3(score_dig4), 
                             // Health digits
                             .dig4(hp_dig1), 
                             .dig5(hp_dig2), 
                             .dig6(hp_dig3), 
                             .dig7(hp_dig4), 
                             // Outputs
                             .div_clk(digits_clk), 
                             .a(a), 
                             .b(b), 
                             .c(c), 
                             .d(d), 
                             .e(e), 
                             .f(f), 
                             .g(g), 
                             .an(an)
    );
    
    // Our health points digits, we start with 3 health points
    // hp_dig2-4 are defined for the sake of completeness, not used
    reg [3:0] hp_dig1 = 4'd3;
    reg [3:0] hp_dig2 = 4'd0;
    reg [3:0] hp_dig3 = 4'd0;
    reg [3:0] hp_dig4 = 4'd0;
        
    // Based on the "got_hit" signal from the ghosts_logic module decrement health
    // Signal GAME OVER when health is decremented to 0
    always @ (posedge digits_clk)
    begin
        // Hit signal for each ghost 1-4
        if (got_hit1)
        begin
            if (hp_dig1 == 4'd0)
                game_over <= 1'b1;
            else
                hp_dig1 <= hp_dig1 - 1'b1;
        end
            
        if (got_hit2)
        begin
            if (hp_dig1 == 4'd0)
                game_over <= 1'b1;
            else
                hp_dig1 <= hp_dig1 - 1'b1;
        end 
        
        if (got_hit3)
        begin
            if (hp_dig1 == 4'd0)
                game_over <= 1'b1;
            else
                hp_dig1 <= hp_dig1 - 1'b1;
        end
        
        if (got_hit4)
        begin
            if (hp_dig1 == 4'd0)
                game_over <= 1'b1;
            else
                hp_dig1 <= hp_dig1 - 1'b1;
        end
    end
endmodule