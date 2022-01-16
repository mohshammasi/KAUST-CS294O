`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2021 05:10:20 PM
// Design Name: 
// Module Name: drawcon
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


module drawcon(input clk, game_over, within, left_btn, right_btn,
               input ghost1, ghost2, ghost3, ghost4,
               input [10:0] yoshi_x, draw_x, ghost1_x, ghost2_x, ghost3_x, ghost4_x, egg_x,
               input [9:0] yoshi_y, draw_y, ghost1_y, ghost2_y, ghost3_y, ghost4_y, egg_y,
               output reg [3:0] r, g, b);
               
    // Border and background drawing logic, wall sprite image size is 32x32
    parameter WALL_WIDTH = 6'd32; 
    assign left_border = (11'd0 <= draw_x) & (draw_x <= 11'd31) & (10'd32 <= draw_y) & (draw_y <= 10'd767);
    assign right_border = (draw_x >= 11'd1248) & (draw_x <= 11'd1279) & (10'd32 <= draw_y) & (draw_y <= 10'd767);
    assign top_border = (10'd0 <= draw_y) & (draw_y <= 10'd31);
    assign bottom_border = (draw_y >= 10'd768) & (draw_y <= 10'd799);
    
    // Need to use different signals for left and right border because they get drawn
    // in parallel technically hence the need to use different signals
    reg [5:0] topAndBottom_x_os = 6'd0, topAndBottom_y_os = 6'd0; // top&bottom border x,y offset trackers
    reg [5:0] left_x_os = 6'd0, left_y_os = 6'd0; // left border x,y offset trackers
    reg [5:0] right_x_os = 6'd0, right_y_os = 6'd0; // right border x,y offset trackers
    reg [10:0] row_count = 11'd0;
    reg [3:0] bg_r, bg_g, bg_b;
    
    // Wall memory instantiation, stores the wall rgb values
    reg [9:0] wall_mem_addr;
    wire [11:0] wall_rgb;
    wall_mem wall_sprite (.clka(clk),    // input wire clka
                          .addra(wall_mem_addr),  // input wire [9 : 0] addra
                          .douta(wall_rgb)  // output wire [11 : 0] douta
    );
    
    always @ (posedge clk)
    begin
        if (within) // must be within display area
        begin
            // All the border conditions are mutually exclusive to not mess up the
            // sprite memory addressing
            if (top_border | bottom_border)
            begin
                wall_mem_addr <= WALL_WIDTH * topAndBottom_y_os + topAndBottom_x_os;
                
                if (topAndBottom_x_os == 5'd31)
                    topAndBottom_x_os <= 6'd0; // reset offset tracker
                else
                    topAndBottom_x_os <= topAndBottom_x_os + 1'b1; // increment x offset tracker
                    
                // Only increment y when we finished drawing the entire row
                if (row_count == 11'd1279)
                begin
                    row_count = 11'd0;
                    
                    if (topAndBottom_y_os == 5'd31)
                        topAndBottom_y_os <= 6'd0; // reset offset tracker
                    else
                        topAndBottom_y_os <= topAndBottom_y_os + 1'b1;
                end
                else
                    row_count <= row_count + 1'b1; // increment row counter
            end
            else if (left_border)
            begin   
                wall_mem_addr <= WALL_WIDTH * left_y_os + left_x_os;   
                
                if (left_x_os == 5'd31)
                begin
                    left_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (left_y_os == 5'd31)
                        left_y_os <= 6'd0;
                    else
                        left_y_os <= left_y_os + 1'b1; // inc y
                end
                else
                    left_x_os <= left_x_os + 1'b1;
            end
            else if (right_border)
            begin
                wall_mem_addr <= WALL_WIDTH * right_y_os + right_x_os;
                
                if (right_x_os == 5'd31)
                begin
                    right_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (right_y_os == 6'd31)
                        right_y_os <= 6'd0;
                    else
                        right_y_os <= right_y_os + 1'b1; // inc y
                end
                else
                    right_x_os <= right_x_os + 1'b1;
            end
        end
    end
    
    
    // background sprite drawing
    // background memory instantiation, stores the bg rgb values
    parameter BACKGROUND_WIDTH = 8'd160; // background sprite image width
    reg [7:0] bg_x_os = 8'd0, bg_y_os = 8'd0; // x,y offset trackers
    reg [10:0] bg_row_count = 11'd0; // horizontal range row counter, upto 1280
    reg [14:0] bg_mem_addr;
    wire [11:0] bg_rgb;
    background_mem bg_sprite (.clka(clk),    // input wire clka
                              .addra(bg_mem_addr),  // input wire [9 : 0] addra
                              .douta(bg_rgb)  // output wire [11 : 0] douta
    );
    
    always @ (posedge clk)
    begin
        if (within) // must be within display area
        begin
            bg_mem_addr <= BACKGROUND_WIDTH * bg_y_os + bg_x_os;
                
            if (bg_x_os == 8'd159)
                bg_x_os <= 8'd0; // reset offset tracker
            else
                bg_x_os <= bg_x_os + 1'b1; // increment x offset tracker
                
            // Only increment y when we finished drawing the entire row
            if (bg_row_count == 11'd1279)
            begin
                bg_row_count = 11'd0;
                
                if (bg_y_os == 8'd159)
                    bg_y_os <= 8'd0; // reset offset tracker
                else
                    bg_y_os <= bg_y_os + 1'b1;
            end
            else
                bg_row_count <= bg_row_count + 1'b1; // increment row counter
        end
    end
    
    always @ *
    begin
        if (top_border | left_border | right_border | bottom_border)
        begin
            // Set the fetched colours from wall memory
            bg_r = wall_rgb[11:8];
            bg_g = wall_rgb[7:4];
            bg_b = wall_rgb[3:0];
        end
        else // background
        begin
            bg_r = bg_rgb[11:8];
            bg_g = bg_rgb[7:4];
            bg_b = bg_rgb[3:0];
        end
    end
        
    
    // Character/yoshi drawing
    assign character_x = (yoshi_x <= draw_x) & (draw_x <= yoshi_x + 11'd31); // -1 since sprite indexing starts at 0
    assign character_y = (yoshi_y <= draw_y) & (draw_y <= yoshi_y + 10'd41); // -1 since sprite indexing starts at 0
    parameter YOSHI_WIDTH = 6'd32;
    reg [5:0] yoshi_x_os = 6'd0, yoshi_y_os = 6'd0; // x,y offset trackers
    
    // Yoshi right sprite memory
    reg [10:0] yoshi_right_mem_addr;
    wire [11:0] yoshi_right_rgb;
    yoshi_right_mem yoshi_right_sprite (.clka(clk),    // input wire clka
                                       .addra(yoshi_right_mem_addr),  // input wire [10 : 0] addra
                                       .douta(yoshi_right_rgb)  // output wire [11 : 0] douta
    );
    
    // Yoshi left sprite memory
    reg [10:0] yoshi_left_mem_addr;
    wire [11:0] yoshi_left_rgb;
    yoshi_left_mem yoshi_left_sprite (.clka(clk),    // input wire clka
                                      .addra(yoshi_left_mem_addr),  // input wire [10 : 0] addra
                                      .douta(yoshi_left_rgb)  // output wire [11 : 0] douta
    );
    
    // Signal to remember what direction was faced last to know which sprite to draw
    reg last_dir; // 0 means left, 1 means right
    
    always @ (posedge clk)
    begin
        // Update the last facing direction tracking signal
        if (left_btn)
            last_dir <= 1'b0;
        else if (right_btn)
            last_dir <= 1'b1;
            
            
        // yoshi reset trackers whenever we start fetching rgb sprite values
        if (draw_x == yoshi_x & draw_y == yoshi_y)
        begin
            yoshi_x_os <= 6'd0;
            yoshi_y_os <= 6'd0;
        end
        
        // yoshi sprite memory addresing logic
        if (character_x & character_y)
        begin
            if (yoshi_x_os == 5'd31)
            begin
                yoshi_x_os <= 6'd0; // reset x offset tracker
                
                // reset y when done drawing 1 row of sprite
                if (yoshi_y_os == 6'd41) 
                    yoshi_y_os <= 6'd0;
                else
                    yoshi_y_os <= yoshi_y_os + 1'b1; // inc y
            end
            else
                yoshi_x_os <= yoshi_x_os + 1'b1;
                
            if (right_btn) // draw right yoshi
                yoshi_right_mem_addr <= YOSHI_WIDTH * yoshi_y_os + yoshi_x_os;   
            else if (left_btn) // draw left yoshi
                yoshi_left_mem_addr <= YOSHI_WIDTH * yoshi_y_os + yoshi_x_os;
            else // standing, not moving using the buttons
            begin
                if (last_dir == 1'b0) // standing facing left side coz last input was left
                    yoshi_left_mem_addr <= YOSHI_WIDTH * yoshi_y_os + yoshi_x_os;
                else if (last_dir == 1'b1) // standing facing right side coz last input was right
                    yoshi_right_mem_addr <= YOSHI_WIDTH * yoshi_y_os + yoshi_x_os; 
            end
        end
    end
    
    reg [3:0] yoshi_r = 4'd0, yoshi_g = 4'd0, yoshi_b = 4'd0;
    always @ *
    begin
        if (character_x & character_y)
        begin
            if (left_btn)
            begin
                yoshi_r = yoshi_left_rgb[11:8];
                yoshi_g = yoshi_left_rgb[7:4];
                yoshi_b = yoshi_left_rgb[3:0];
            end
            else if (right_btn)
            begin
                yoshi_r = yoshi_right_rgb[11:8];
                yoshi_g = yoshi_right_rgb[7:4];
                yoshi_b = yoshi_right_rgb[3:0];
            end
            else
            begin
                if (last_dir == 1'b0)
                begin
                    yoshi_r = yoshi_left_rgb[11:8];
                    yoshi_g = yoshi_left_rgb[7:4];
                    yoshi_b = yoshi_left_rgb[3:0];
                end
                else if (last_dir == 1'b1)
                begin
                    yoshi_r = yoshi_right_rgb[11:8];
                    yoshi_g = yoshi_right_rgb[7:4];
                    yoshi_b = yoshi_right_rgb[3:0];
                end
            end
        end
        else
        begin
            yoshi_r = 4'd0;
            yoshi_g = 4'd0;
            yoshi_b = 4'd0;
        end
    end
    
    // Enemies/Ghosts drawing
    parameter GHOST_SIZE = 5'd31; // -1, for the sake of sprites, indexing starts at 0
    parameter GHOST_WIDTH = 6'd32; // Sprite image width
    // Ghost 1
    assign draw_ghost1_x = (ghost1_x <= draw_x) & (draw_x <= ghost1_x + GHOST_SIZE);
    assign draw_ghost1_y = (ghost1_y <= draw_y) & (draw_y <= ghost1_y + GHOST_SIZE);
    
    // Ghost 2 
    assign draw_ghost2_x = (ghost2_x <= draw_x) & (draw_x <= ghost2_x + GHOST_SIZE);
    assign draw_ghost2_y = (ghost2_y <= draw_y) & (draw_y <= ghost2_y + GHOST_SIZE);
    
    // Ghost 3
    assign draw_ghost3_x = (ghost3_x <= draw_x) & (draw_x <= ghost3_x + GHOST_SIZE);
    assign draw_ghost3_y = (ghost3_y <= draw_y) & (draw_y <= ghost3_y + GHOST_SIZE);
    
    // Ghost 4 
    assign draw_ghost4_x = (ghost4_x <= draw_x) & (draw_x <= ghost4_x + GHOST_SIZE);
    assign draw_ghost4_y = (ghost4_y <= draw_y) & (draw_y <= ghost4_y + GHOST_SIZE);
    
    
    // Ghost left and right sprite image memory instantiation, address, rgb, and trackers
    reg [5:0] ghost1_x_os = 6'd0, ghost1_y_os = 6'd0; 
    reg [5:0] ghost2_x_os = 6'd0, ghost2_y_os = 6'd0; 
    reg [5:0] ghost3_x_os = 6'd0, ghost3_y_os = 6'd0; 
    reg [5:0] ghost4_x_os = 6'd0, ghost4_y_os = 6'd0; 
    reg [9:0] ghost_right_mem_addr;
    wire [11:0] ghost_right_rgb;
    ghost_right_mem ghost_right_sprite (.clka(clk),    // input wire clka
                                       .addra(ghost_right_mem_addr),  // input wire [9 : 0] addra
                                       .douta(ghost_right_rgb)  // output wire [11 : 0] douta
    );
    
    reg [9:0] ghost_left_mem_addr;
    wire [11:0] ghost_left_rgb;
    ghost_left_mem ghost_left_sprite (.clka(clk),    // input wire clka
                                      .addra(ghost_left_mem_addr),  // input wire [9 : 0] addra
                                      .douta(ghost_left_rgb)  // output wire [11 : 0] douta
    );
    
    // Synchronous block to address the ghost memory to fetch the rgb colours
    always @ (posedge clk)
    begin
        // ghost 1 reset trackers whenever we start fetching rgb sprite values
        if (draw_x == ghost1_x & draw_y == ghost1_y)
        begin
            ghost1_x_os <= 6'd0;
            ghost1_y_os <= 6'd0;
        end
        
        // ghost 2 reset trackers whenever we start fetching rgb sprite values
        if (draw_x == ghost2_x & draw_y == ghost2_y)
        begin
            ghost2_x_os <= 6'd0;
            ghost2_y_os <= 6'd0;
        end
        
        // ghost 3 reset trackers whenever we start fetching rgb sprite values
        if (draw_x == ghost3_x & draw_y == ghost3_y)
        begin
            ghost3_x_os <= 6'd0;
            ghost3_y_os <= 6'd0;
        end
        
        // ghost 4 reset trackers whenever we start fetching rgb sprite values
        if (draw_x == ghost4_x & draw_y == ghost4_y)
        begin
            ghost4_x_os <= 6'd0;
            ghost4_y_os <= 6'd0;
        end
        
        // Ghost 1 sprite memory addresing logic
        if (ghost1)
        begin
            if (draw_ghost1_x & draw_ghost1_y)
            begin

                if (ghost1_x_os == 5'd31)
                begin
                    ghost1_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (ghost1_y_os == 6'd31) 
                        ghost1_y_os <= 6'd0;
                    else
                        ghost1_y_os <= ghost1_y_os + 1'b1; // inc y
                end
                else
                    ghost1_x_os <= ghost1_x_os + 1'b1;
                    
                if (ghost1_x < yoshi_x) // fetch from ghost right mem
                    ghost_right_mem_addr <= GHOST_WIDTH * ghost1_y_os + ghost1_x_os;   
                else if (ghost1_x > yoshi_x) // fetch from ghost left mem
                    ghost_left_mem_addr <= GHOST_WIDTH * ghost1_y_os + ghost1_x_os;  
            end
        end
        
        
        // Ghost 2 sprite memory addressing
        if (ghost2)
        begin
            if (draw_ghost2_x & draw_ghost2_y)
            begin

                if (ghost2_x_os == 5'd31)
                begin
                    ghost2_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (ghost2_y_os == 6'd31) 
                        ghost2_y_os <= 6'd0;
                    else
                        ghost2_y_os <= ghost2_y_os + 1'b1; // inc y
                end
                else
                    ghost2_x_os <= ghost2_x_os + 1'b1;
                    
                if (ghost2_x < yoshi_x)
                    ghost_right_mem_addr <= GHOST_WIDTH * ghost2_y_os + ghost2_x_os;   
                else if (ghost2_x > yoshi_x)
                    ghost_left_mem_addr <= GHOST_WIDTH * ghost2_y_os + ghost2_x_os;  
            end
        end
        
        // Ghost 3 sprite memory addressing
        if (ghost3)
        begin
            if (draw_ghost3_x & draw_ghost3_y)
            begin

                if (ghost3_x_os == 5'd31)
                begin
                    ghost3_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (ghost3_y_os == 6'd31) 
                        ghost3_y_os <= 6'd0;
                    else
                        ghost3_y_os <= ghost3_y_os + 1'b1; // inc y
                end
                else
                    ghost3_x_os <= ghost3_x_os + 1'b1;
                    
                if (ghost3_x < yoshi_x)
                    ghost_right_mem_addr <= GHOST_WIDTH * ghost3_y_os + ghost3_x_os;   
                else if (ghost3_x > yoshi_x)
                    ghost_left_mem_addr <= GHOST_WIDTH * ghost3_y_os + ghost3_x_os;  
            end
        end
        
        // Ghost 4 sprite memory addressing
        if (ghost4)
        begin
            if (draw_ghost4_x & draw_ghost4_y)
            begin

                if (ghost4_x_os == 5'd31)
                begin
                    ghost4_x_os <= 6'd0; // reset x offset tracker
                    
                    // reset y when done drawing a tile
                    if (ghost4_y_os == 6'd31) 
                        ghost4_y_os <= 6'd0;
                    else
                        ghost4_y_os <= ghost4_y_os + 1'b1; // inc y
                end
                else
                    ghost4_x_os <= ghost4_x_os + 1'b1;
                    
                if (ghost4_x < yoshi_x)
                    ghost_right_mem_addr <= GHOST_WIDTH * ghost4_y_os + ghost4_x_os;   
                else if (ghost4_x > yoshi_x)
                    ghost_left_mem_addr <= GHOST_WIDTH * ghost4_y_os + ghost4_x_os;  
            end
        end
    end
    
    reg [3:0] ghost1_r = 4'd0, ghost1_g = 4'd0, ghost1_b = 4'd0; // ghost 1 rgb
    reg [3:0] ghost2_r = 4'd0, ghost2_g = 4'd0, ghost2_b = 4'd0; // ghost 2 rgb
    reg [3:0] ghost3_r = 4'd0, ghost3_g = 4'd0, ghost3_b = 4'd0; // ghost 3 rgb
    reg [3:0] ghost4_r = 4'd0, ghost4_g = 4'd0, ghost4_b = 4'd0; // ghost 4 rgb
    always @ *
    begin
        // If ghost 1 is enabled
        if (ghost1)
        begin
            if (draw_ghost1_x & draw_ghost1_y)
            begin
                if (ghost1_x < yoshi_x)
                begin
                    ghost1_r = ghost_right_rgb[11:8];
                    ghost1_g = ghost_right_rgb[7:4];
                    ghost1_b = ghost_right_rgb[3:0];
                end
                else if (ghost1_x > yoshi_x)
                begin
                    ghost1_r = ghost_left_rgb[11:8];
                    ghost1_g = ghost_left_rgb[7:4];
                    ghost1_b = ghost_left_rgb[3:0];
                end
            end
            else
            begin
                ghost1_r = 4'd0;
                ghost1_g = 4'd0;
                ghost1_b = 4'd0;
            end
        end
        else
        begin
            ghost1_r = 4'd0;
            ghost1_g = 4'd0;
            ghost1_b = 4'd0;
        end
     
        
        // If ghost 2 is enabled
        if (ghost2)
        begin
            if (draw_ghost2_x & draw_ghost2_y)
            begin
                if (ghost2_x < yoshi_x)
                begin
                    ghost2_r = ghost_right_rgb[11:8];
                    ghost2_g = ghost_right_rgb[7:4];
                    ghost2_b = ghost_right_rgb[3:0];
                end
                else if (ghost2_x > yoshi_x)
                begin
                    ghost2_r = ghost_left_rgb[11:8];
                    ghost2_g = ghost_left_rgb[7:4];
                    ghost2_b = ghost_left_rgb[3:0];
                end
            end
            else
            begin
                ghost2_r = 4'd0;
                ghost2_g = 4'd0;
                ghost2_b = 4'd0;
            end
        end
        else
        begin
            ghost2_r = 4'd0;
            ghost2_g = 4'd0;
            ghost2_b = 4'd0;
        end
        
        
        // If ghost 3 is enabled
        if (ghost3)
        begin
            if (draw_ghost3_x & draw_ghost3_y)
            begin
                if (ghost3_x < yoshi_x)
                begin
                    ghost3_r = ghost_right_rgb[11:8];
                    ghost3_g = ghost_right_rgb[7:4];
                    ghost3_b = ghost_right_rgb[3:0];
                end
                else if (ghost3_x > yoshi_x)
                begin
                    ghost3_r = ghost_left_rgb[11:8];
                    ghost3_g = ghost_left_rgb[7:4];
                    ghost3_b = ghost_left_rgb[3:0];
                end
            end
            else
            begin
                ghost3_r = 4'd0;
                ghost3_g = 4'd0;
                ghost3_b = 4'd0;
            end
        end
        else
        begin
            ghost3_r = 4'd0;
            ghost3_g = 4'd0;
            ghost3_b = 4'd0;
        end
        
        
        // If ghost 4 is enabled
        if (ghost4)
        begin
            if (draw_ghost4_x & draw_ghost4_y)
            begin
                if (ghost4_x < yoshi_x)
                begin
                    ghost4_r = ghost_right_rgb[11:8];
                    ghost4_g = ghost_right_rgb[7:4];
                    ghost4_b = ghost_right_rgb[3:0];
                end
                else if (ghost4_x > yoshi_x)
                begin
                    ghost4_r = ghost_left_rgb[11:8];
                    ghost4_g = ghost_left_rgb[7:4];
                    ghost4_b = ghost_left_rgb[3:0];
                end
            end
            else
            begin
                ghost4_r = 4'd0;
                ghost4_g = 4'd0;
                ghost4_b = 4'd0;
            end
        end
        else
        begin
            ghost4_r = 4'd0;
            ghost4_g = 4'd0;
            ghost4_b = 4'd0;
        end
    end // always @ * block end
    
    
    
    // Eggs/Score objects drawing
    parameter EGG_WIDTH = 6'd32; 
    parameter EGG_HEIGHT = 6'd36; 
    
    // -1 pixel because we start indexing for sprites from 0
    assign draw_egg_x = (egg_x <= draw_x) & (draw_x <= egg_x + (EGG_WIDTH-1'b1)); 
    assign draw_egg_y = (egg_y <= draw_y) & (draw_y <= egg_y + (EGG_HEIGHT-1'b1));
    
    // Sprite image memory instantiation, address, rgb,and tracker. sprite is 32x36
    reg [5:0] egg_x_os = 6'd0, egg_y_os = 6'd0; 
    reg [10:0] egg_mem_addr;
    wire [11:0] egg_rgb;
    egg_mem egg_sprite (.clka(clk),    // input wire clka
                        .addra(egg_mem_addr),  // input wire [10 : 0] addra
                        .douta(egg_rgb)  // output wire [11 : 0] douta
    );
    
    
    // Synchronous block to address the egg memory to fetch the rgb colours
    always @ (posedge clk)
    begin
        // reset trackers
        if (draw_x == egg_x & draw_y == egg_y)
        begin
            egg_x_os <= 6'd0;
            egg_y_os <= 6'd0;
        end
        if (draw_egg_x & draw_egg_y)
        begin
            egg_mem_addr <= EGG_WIDTH * egg_y_os + egg_x_os;   
                
            if (egg_x_os == 5'd31)
            begin
                egg_x_os <= 6'd0; // reset x offset tracker
                
                // reset y when done drawing a tile
                if (egg_y_os == 6'd35) // height is 36 pixels
                    egg_y_os <= 6'd0;
                else
                    egg_y_os <= egg_y_os + 1'b1; // inc y
            end
            else
                egg_x_os <= egg_x_os + 1'b1;
        end
    end
    
    reg [3:0] egg_r = 4'd0, egg_g = 4'd0, egg_b = 4'd0;
    always @ *
    begin
        if (draw_egg_x & draw_egg_y)
        begin
            egg_r = egg_rgb[11:8];
            egg_g = egg_rgb[7:4];
            egg_b = egg_rgb[3:0];
        end
        else
        begin
            egg_r = 4'd0;
            egg_g = 4'd0;
            egg_b = 4'd0;
        end
    end
    
    
    // Drawing platforms, using pl as an abbreviation for platform
    // Platform 1 drawing -> lower center of the screen
    parameter pl1_yrange1 = 10'd609;
    parameter pl1_yrange2 = 10'd640;
    assign pl1_y = (pl1_yrange1 <= draw_y) & (draw_y <= pl1_yrange2);
    // Platform 4 drawing -> high center of the screen
    parameter pl4_yrange1 = 9'd249;
    parameter pl4_yrange2 = 9'd280;
    assign pl4_y = (pl4_yrange1 <= draw_y) & (draw_y <= pl4_yrange2);
    // Shared between platforms 1 and 4
    parameter pl1and4_xrange1 = 9'd273;
    parameter pl1and4_xrange2 = 10'd1008;
    assign pl1and4_x = (pl1and4_xrange1 <= draw_x) & (draw_x <= pl1and4_xrange2);
    
    // Platform 2 drawing -> second lowest left of the screen
    parameter pl2_xrange1 = 6'd32;
    parameter pl2_xrange2 = 10'd511;
    assign pl2_x = (pl2_xrange1 <= draw_x) & (draw_x <= pl2_xrange2);
    // Platform 3 drawing -> second lowest right of the screen
    parameter pl3_xrange1 = 10'd768;
    parameter pl3_xrange2 = 11'd1247;
    assign pl3_x = (pl3_xrange1 <= draw_x) & (draw_x <= pl3_xrange2);
    // Shared between platforms 2 and 3
    parameter pl2and3_yrange1 = 9'd429;
    parameter pl2and3_yrange2 = 9'd460;
    assign pl2and3_y = (pl2and3_yrange1 <= draw_y) & (draw_y <= pl2and3_yrange2);
    
    // Sprite image for platforms is 32x32
    parameter PLATFORM_WIDTH = 6'd32;
    // Platforms memory instantiation, stores the platform rgb values
    reg [5:0] centerpl_x_os = 6'd0, centerpl_y_os = 6'd0;
    reg [5:0] leftpl_x_os = 6'd0, leftpl_y_os = 6'd0; 
    reg [5:0] rightpl_x_os = 6'd0, rightpl_y_os = 6'd0; 
    reg [9:0] pl1and4_row_count = 10'd0, pl2_row_count = 10'd0, pl3_row_count = 10'd0;
    reg [9:0] pl_mem_addr;
    wire [11:0] pl_rgb;
    platforms_mem platforms_sprite (.clka(clk),    // input wire clka
                                    .addra(pl_mem_addr),  // input wire [9 : 0] addra
                                    .douta(pl_rgb)  // output wire [11 : 0] douta
    );
    
    // Synchronous block to address the platforms memory
    always @ (posedge clk)
    begin
        if ((pl1and4_x & pl1_y) | (pl1and4_x & pl4_y))
        begin
            pl_mem_addr <= PLATFORM_WIDTH * centerpl_y_os + centerpl_x_os;
            
            if (centerpl_x_os == 5'd31)
                centerpl_x_os <= 6'd0; // reset offset tracker
            else
                centerpl_x_os <= centerpl_x_os + 1'b1; // increment x offset tracker
                
            // Only increment y when we finished drawing the entire row
            if (pl1and4_row_count == 11'd735) // we are drawing 23 sprites consecutively, width of pl is 736 pixels
            begin
                pl1and4_row_count = 11'd0;
                
                if (centerpl_y_os == 5'd31)
                    centerpl_y_os <= 6'd0; // reset offset tracker
                else
                    centerpl_y_os <= centerpl_y_os + 1'b1;
            end
            else
                pl1and4_row_count <= pl1and4_row_count + 1'b1; // increment row counter
        end
        else if (pl2_x & pl2and3_y)
        begin   
            pl_mem_addr <= PLATFORM_WIDTH * leftpl_y_os + leftpl_x_os;   
            
            if (leftpl_x_os == 5'd31)
                leftpl_x_os <= 6'd0; // reset offset tracker
            else
                leftpl_x_os <= leftpl_x_os + 1'b1; // increment x offset tracker
                
            // Only increment y when we finished drawing the entire row
            if (pl2_row_count == 11'd479) // we are drawing 15 sprites consecutively, width of pl2 is 480 pixels
            begin
                pl2_row_count = 11'd0;
                
                if (leftpl_y_os == 5'd31)
                    leftpl_y_os <= 6'd0; // reset offset tracker
                else
                    leftpl_y_os <= leftpl_y_os + 1'b1;
            end
            else
                pl2_row_count <= pl2_row_count + 1'b1; // increment row counter
        end
        else if (pl3_x & pl2and3_y)
        begin
            pl_mem_addr <= WALL_WIDTH * rightpl_y_os + rightpl_x_os;
            
            if (rightpl_x_os == 5'd31)
                rightpl_x_os <= 6'd0; // reset offset tracker
            else
                rightpl_x_os <= rightpl_x_os + 1'b1; // increment x offset tracker
                
            // Only increment y when we finished drawing the entire row
            if (pl3_row_count == 11'd479) // we are drawing 15 sprites consecutively, width of pl3 is 480 pixels
            begin
                pl3_row_count = 11'd0;
                
                if (rightpl_y_os == 5'd31)
                    rightpl_y_os <= 6'd0; // reset offset tracker
                else
                    rightpl_y_os <= rightpl_y_os + 1'b1;
            end
            else
                pl3_row_count <= pl3_row_count + 1'b1; // increment row counter
        end
    end
    
    reg [3:0] pl_r = 4'd0, pl_g = 4'd0, pl_b = 4'd0;
    always @ * 
    begin
        if ((pl1and4_x & pl1_y) | (pl2_x & pl2and3_y) | (pl3_x & pl2and3_y) | (pl1and4_x & pl4_y)) // all platforms rgb
        begin
            pl_r = pl_rgb[11:8];
            pl_g = pl_rgb[7:4];
            pl_b = pl_rgb[3:0];
        end
        else
        begin
            pl_r = 4'b0;
            pl_g = 4'b0;
            pl_b = 4'b0;
        end
    end
    
    // Decide between background and foreground colour
    always @ *
    begin
        // Assign colours to draw for the character/block
        // if-else chain asserts priority
        if (game_over)
        begin
            r = 4'b0011;
            g = 4'b0000;
            b = 4'b0110;
        end
        else if ((ghost1_r != 4'd0) & (ghost1_g != 4'd0) & (ghost1_b != 4'd0)) // ghost 1
        begin
            r = ghost1_r;
            g = ghost1_g;
            b = ghost1_b;
        end
        else if ((ghost2_r != 4'd0) & (ghost2_g != 4'd0) & (ghost2_b != 4'd0)) // ghost 2
        begin
            r = ghost2_r;
            g = ghost2_g;
            b = ghost2_b;
        end
        else if ((ghost3_r != 4'd0) & (ghost3_g != 4'd0) & (ghost3_b != 4'd0)) // ghost 3
        begin
            r = ghost3_r;
            g = ghost3_g;
            b = ghost3_b;
        end
        else if ((ghost4_r != 4'd0) & (ghost4_g != 4'd0) & (ghost4_b != 4'd0)) // ghost 4
        begin
            r = ghost4_r;
            g = ghost4_g;
            b = ghost4_b;
        end
        else if ((yoshi_r != 4'd0) | (yoshi_g != 4'd0) | (yoshi_b != 4'd0)) //  character/block
        begin
            r = yoshi_r;
            g = yoshi_g;
            b = yoshi_b;
        end
        else if ((egg_r != 4'd0) & (egg_g != 4'd0) & (egg_b != 4'd0)) // eggs
        begin
            r = egg_r;
            g = egg_g;
            b = egg_b;
        end
        else if ((pl_r != 4'd0) & (pl_g != 4'd0) & (pl_b != 4'd0)) // platforms
        begin
            r = pl_r;
            g = pl_g;
            b = pl_b;
        end 
        else // background
        begin
            r = bg_r;
            g = bg_g;
            b = bg_b;
        end
    end
endmodule