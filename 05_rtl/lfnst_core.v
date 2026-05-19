`timescale 1ns/1ps

module lfnst_core #(
    parameter integer DATA_W = 16,
    parameter integer COEFF_W = 9,
    parameter integer ACC_W = 32,
    parameter integer ROM_ROWS_PER_SCENARIO = 48,
    parameter integer ROM_COLS = 16,
    parameter integer ROM_SCENARIOS = 16,
    parameter        MEM_FILE = "lfnst_tables.memh"
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    output wire                    in_ready,
    input  wire [6:0]              tu_width,
    input  wire [6:0]              tu_height,
    input  wire [1:0]              lfnst_tr_set_idx,
    input  wire [1:0]              lfnst_idx,
    input  wire signed [DATA_W-1:0] x_bar_0,
    input  wire signed [DATA_W-1:0] x_bar_1,
    input  wire signed [DATA_W-1:0] x_bar_2,
    input  wire signed [DATA_W-1:0] x_bar_3,
    input  wire signed [DATA_W-1:0] x_bar_4,
    input  wire signed [DATA_W-1:0] x_bar_5,
    input  wire signed [DATA_W-1:0] x_bar_6,
    input  wire signed [DATA_W-1:0] x_bar_7,
    input  wire signed [DATA_W-1:0] x_bar_8,
    input  wire signed [DATA_W-1:0] x_bar_9,
    input  wire signed [DATA_W-1:0] x_bar_10,
    input  wire signed [DATA_W-1:0] x_bar_11,
    input  wire signed [DATA_W-1:0] x_bar_12,
    input  wire signed [DATA_W-1:0] x_bar_13,
    input  wire signed [DATA_W-1:0] x_bar_14,
    input  wire signed [DATA_W-1:0] x_bar_15,
    input  wire                    out_req,
    output wire                    out_valid,
    output wire                    out_last,
    output wire [5:0]              out_row_base,
    output reg  signed [DATA_W-1:0] out_data_0,
    output reg  signed [DATA_W-1:0] out_data_1,
    output reg  signed [DATA_W-1:0] out_data_2,
    output reg  signed [DATA_W-1:0] out_data_3,
    output reg                     done,
    output wire                    busy
);

    localparam integer ROM_WORDS = ROM_SCENARIOS * ROM_ROWS_PER_SCENARIO * ROM_COLS;

    reg signed [COEFF_W-1:0] coeff_rom [0:ROM_WORDS-1];

    reg                      busy_r;
    reg                      out_valid_r;
    reg [5:0]                row_base_r;
    reg [5:0]                ntrs_r;
    reg [4:0]                non_zero_size_r;
    reg [3:0]                scenario_sel_r;

    reg signed [DATA_W-1:0] x_bar_r [0:15];

    reg signed [ACC_W-1:0] acc_0;
    reg signed [ACC_W-1:0] acc_1;
    reg signed [ACC_W-1:0] acc_2;
    reg signed [ACC_W-1:0] acc_3;

    integer lane_idx;
    integer col_idx;
    integer row_idx;
    integer rom_idx;

    initial begin
        $readmemh(MEM_FILE, coeff_rom);
    end

    function [5:0] calc_ntrs;
        input [6:0] width;
        input [6:0] height;
        begin
            calc_ntrs = ((width >= 7'd8) && (height >= 7'd8)) ? 6'd48 : 6'd16;
        end
    endfunction

    function [4:0] calc_non_zero_size;
        input [6:0] width;
        input [6:0] height;
        begin
            if (((width == 7'd4) && (height == 7'd4)) ||
                ((width == 7'd8) && (height == 7'd8))) begin
                calc_non_zero_size = 5'd8;
            end else begin
                calc_non_zero_size = 5'd16;
            end
        end
    endfunction

    function [3:0] calc_scenario_sel;
        input [6:0] width;
        input [6:0] height;
        input [1:0] set_idx;
        input [1:0] core_idx;
        reg [3:0] base;
        begin
            base = ((width >= 7'd8) && (height >= 7'd8)) ? 4'd8 : 4'd0;
            calc_scenario_sel = base + {set_idx, 1'b0} + core_idx - 1'b1;
        end
    endfunction

    function signed [DATA_W-1:0] clip_result;
        input signed [ACC_W-1:0] value;
        reg signed [ACC_W-1:0] shifted;
        begin
            shifted = (value + 32'sd64) >>> 7;
            if (shifted > 32'sd32767) begin
                clip_result = 16'sd32767;
            end else if (shifted < -32'sd32768) begin
                clip_result = -16'sd32768;
            end else begin
                clip_result = shifted[DATA_W-1:0];
            end
        end
    endfunction

    assign in_ready = ~busy_r;
    assign out_valid = out_valid_r;
    assign out_row_base = row_base_r;
    assign out_last = out_valid_r && busy_r && (row_base_r == (ntrs_r - 6'd4));
    assign busy = busy_r;

    always @(*) begin
        acc_0 = {ACC_W{1'b0}};
        acc_1 = {ACC_W{1'b0}};
        acc_2 = {ACC_W{1'b0}};
        acc_3 = {ACC_W{1'b0}};

        if (busy_r) begin
            for (lane_idx = 0; lane_idx < 4; lane_idx = lane_idx + 1) begin
                row_idx = row_base_r + lane_idx;
                for (col_idx = 0; col_idx < ROM_COLS; col_idx = col_idx + 1) begin
                    if (col_idx < non_zero_size_r) begin
                        rom_idx = (scenario_sel_r * ROM_ROWS_PER_SCENARIO * ROM_COLS) +
                                  (row_idx * ROM_COLS) + col_idx;
                        case (lane_idx)
                            0: acc_0 = acc_0 + coeff_rom[rom_idx] * x_bar_r[col_idx];
                            1: acc_1 = acc_1 + coeff_rom[rom_idx] * x_bar_r[col_idx];
                            2: acc_2 = acc_2 + coeff_rom[rom_idx] * x_bar_r[col_idx];
                            3: acc_3 = acc_3 + coeff_rom[rom_idx] * x_bar_r[col_idx];
                            default: ;
                        endcase
                    end
                end
            end
        end
    end

    always @(*) begin
        out_data_0 = clip_result(acc_0);
        out_data_1 = clip_result(acc_1);
        out_data_2 = clip_result(acc_2);
        out_data_3 = clip_result(acc_3);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy_r          <= 1'b0;
            out_valid_r     <= 1'b0;
            row_base_r      <= 6'd0;
            ntrs_r          <= 6'd0;
            non_zero_size_r <= 5'd0;
            scenario_sel_r  <= 4'd0;
            done            <= 1'b0;
            for (row_idx = 0; row_idx < 16; row_idx = row_idx + 1) begin
                x_bar_r[row_idx] <= {DATA_W{1'b0}};
            end
        end else begin
            done <= 1'b0;

            if (!busy_r) begin
                if (start && (lfnst_idx != 2'd0)) begin
                    busy_r          <= 1'b1;
                    out_valid_r     <= 1'b0;
                    row_base_r      <= 6'd0;
                    ntrs_r          <= calc_ntrs(tu_width, tu_height);
                    non_zero_size_r <= calc_non_zero_size(tu_width, tu_height);
                    scenario_sel_r  <= calc_scenario_sel(tu_width, tu_height, lfnst_tr_set_idx, lfnst_idx);

                    x_bar_r[0]  <= x_bar_0;
                    x_bar_r[1]  <= x_bar_1;
                    x_bar_r[2]  <= x_bar_2;
                    x_bar_r[3]  <= x_bar_3;
                    x_bar_r[4]  <= x_bar_4;
                    x_bar_r[5]  <= x_bar_5;
                    x_bar_r[6]  <= x_bar_6;
                    x_bar_r[7]  <= x_bar_7;
                    x_bar_r[8]  <= x_bar_8;
                    x_bar_r[9]  <= x_bar_9;
                    x_bar_r[10] <= x_bar_10;
                    x_bar_r[11] <= x_bar_11;
                    x_bar_r[12] <= x_bar_12;
                    x_bar_r[13] <= x_bar_13;
                    x_bar_r[14] <= x_bar_14;
                    x_bar_r[15] <= x_bar_15;
                end
            end else begin
                if (!out_valid_r) begin
                    out_valid_r <= 1'b1;
                end else if (out_req) begin
                    if (row_base_r == (ntrs_r - 6'd4)) begin
                        busy_r      <= 1'b0;
                        out_valid_r <= 1'b0;
                        row_base_r  <= 6'd0;
                        done        <= 1'b1;
                    end else begin
                        row_base_r <= row_base_r + 6'd4;
                    end
                end
            end
        end
    end

endmodule
