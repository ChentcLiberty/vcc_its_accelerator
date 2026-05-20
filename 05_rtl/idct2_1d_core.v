`timescale 1ns/1ps

module idct2_1d_core #(
    parameter integer DATA_W      = 16,
    parameter integer COEFF_W     = 8,
    parameter integer OUT_W       = 32,
    parameter integer ACC_W       = 40,
    parameter integer MAX_SIZE    = 64,
    parameter integer TABLE_COUNT = 5,
    parameter        MEM_FILE     = "idct2_tables.memh"
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     start,
    output wire                     in_ready,
    input  wire [6:0]               n_tbs,
    input  wire [6:0]               non_zero_size,
    input  wire signed [DATA_W-1:0] x_0,
    input  wire signed [DATA_W-1:0] x_1,
    input  wire signed [DATA_W-1:0] x_2,
    input  wire signed [DATA_W-1:0] x_3,
    input  wire signed [DATA_W-1:0] x_4,
    input  wire signed [DATA_W-1:0] x_5,
    input  wire signed [DATA_W-1:0] x_6,
    input  wire signed [DATA_W-1:0] x_7,
    input  wire signed [DATA_W-1:0] x_8,
    input  wire signed [DATA_W-1:0] x_9,
    input  wire signed [DATA_W-1:0] x_10,
    input  wire signed [DATA_W-1:0] x_11,
    input  wire signed [DATA_W-1:0] x_12,
    input  wire signed [DATA_W-1:0] x_13,
    input  wire signed [DATA_W-1:0] x_14,
    input  wire signed [DATA_W-1:0] x_15,
    input  wire signed [DATA_W-1:0] x_16,
    input  wire signed [DATA_W-1:0] x_17,
    input  wire signed [DATA_W-1:0] x_18,
    input  wire signed [DATA_W-1:0] x_19,
    input  wire signed [DATA_W-1:0] x_20,
    input  wire signed [DATA_W-1:0] x_21,
    input  wire signed [DATA_W-1:0] x_22,
    input  wire signed [DATA_W-1:0] x_23,
    input  wire signed [DATA_W-1:0] x_24,
    input  wire signed [DATA_W-1:0] x_25,
    input  wire signed [DATA_W-1:0] x_26,
    input  wire signed [DATA_W-1:0] x_27,
    input  wire signed [DATA_W-1:0] x_28,
    input  wire signed [DATA_W-1:0] x_29,
    input  wire signed [DATA_W-1:0] x_30,
    input  wire signed [DATA_W-1:0] x_31,
    input  wire signed [DATA_W-1:0] x_32,
    input  wire signed [DATA_W-1:0] x_33,
    input  wire signed [DATA_W-1:0] x_34,
    input  wire signed [DATA_W-1:0] x_35,
    input  wire signed [DATA_W-1:0] x_36,
    input  wire signed [DATA_W-1:0] x_37,
    input  wire signed [DATA_W-1:0] x_38,
    input  wire signed [DATA_W-1:0] x_39,
    input  wire signed [DATA_W-1:0] x_40,
    input  wire signed [DATA_W-1:0] x_41,
    input  wire signed [DATA_W-1:0] x_42,
    input  wire signed [DATA_W-1:0] x_43,
    input  wire signed [DATA_W-1:0] x_44,
    input  wire signed [DATA_W-1:0] x_45,
    input  wire signed [DATA_W-1:0] x_46,
    input  wire signed [DATA_W-1:0] x_47,
    input  wire signed [DATA_W-1:0] x_48,
    input  wire signed [DATA_W-1:0] x_49,
    input  wire signed [DATA_W-1:0] x_50,
    input  wire signed [DATA_W-1:0] x_51,
    input  wire signed [DATA_W-1:0] x_52,
    input  wire signed [DATA_W-1:0] x_53,
    input  wire signed [DATA_W-1:0] x_54,
    input  wire signed [DATA_W-1:0] x_55,
    input  wire signed [DATA_W-1:0] x_56,
    input  wire signed [DATA_W-1:0] x_57,
    input  wire signed [DATA_W-1:0] x_58,
    input  wire signed [DATA_W-1:0] x_59,
    input  wire signed [DATA_W-1:0] x_60,
    input  wire signed [DATA_W-1:0] x_61,
    input  wire signed [DATA_W-1:0] x_62,
    input  wire signed [DATA_W-1:0] x_63,
    input  wire                     out_req,
    output wire                     out_valid,
    output wire                     out_last,
    output wire [6:0]               out_index_base,
    output reg  signed [OUT_W-1:0]  out_data_0,
    output reg  signed [OUT_W-1:0]  out_data_1,
    output reg  signed [OUT_W-1:0]  out_data_2,
    output reg  signed [OUT_W-1:0]  out_data_3,
    output reg                      done,
    output wire                     busy
);

    localparam integer TABLE_WORDS = MAX_SIZE * MAX_SIZE;
    localparam integer ROM_WORDS   = TABLE_COUNT * TABLE_WORDS;

    reg signed [COEFF_W-1:0] coeff_rom [0:ROM_WORDS-1];

    reg                      busy_r;
    reg                      out_valid_r;
    reg [6:0]                size_r;
    reg [6:0]                row_base_r;
    reg [6:0]                non_zero_size_r;
    reg [2:0]                table_sel_r;
    reg signed [DATA_W-1:0]  x_r [0:63];

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

    function is_supported_size;
        input [6:0] size_in;
        begin
            case (size_in)
                7'd4,
                7'd8,
                7'd16,
                7'd32,
                7'd64: is_supported_size = 1'b1;
                default: is_supported_size = 1'b0;
            endcase
        end
    endfunction

    function [2:0] calc_table_sel;
        input [6:0] size_in;
        begin
            case (size_in)
                7'd4:  calc_table_sel = 3'd0;
                7'd8:  calc_table_sel = 3'd1;
                7'd16: calc_table_sel = 3'd2;
                7'd32: calc_table_sel = 3'd3;
                7'd64: calc_table_sel = 3'd4;
                default: calc_table_sel = 3'd0;
            endcase
        end
    endfunction

    function [6:0] clamp_non_zero_size;
        input [6:0] req_size;
        input [6:0] vec_size;
        begin
            if (req_size > vec_size) begin
                clamp_non_zero_size = vec_size;
            end else begin
                clamp_non_zero_size = req_size;
            end
        end
    endfunction

    function signed [OUT_W-1:0] cast_acc;
        input signed [ACC_W-1:0] value;
        begin
            cast_acc = value[OUT_W-1:0];
        end
    endfunction

    assign in_ready = ~busy_r;
    assign out_valid = out_valid_r;
    assign out_index_base = row_base_r;
    assign out_last = out_valid_r && busy_r && (row_base_r == (size_r - 7'd4));
    assign busy = busy_r;

    always @(*) begin
        acc_0 = {ACC_W{1'b0}};
        acc_1 = {ACC_W{1'b0}};
        acc_2 = {ACC_W{1'b0}};
        acc_3 = {ACC_W{1'b0}};

        if (busy_r) begin
            for (lane_idx = 0; lane_idx < 4; lane_idx = lane_idx + 1) begin
                row_idx = row_base_r + lane_idx;
                if (row_idx < size_r) begin
                    for (col_idx = 0; col_idx < MAX_SIZE; col_idx = col_idx + 1) begin
                        if (col_idx < non_zero_size_r) begin
                            rom_idx = (table_sel_r * TABLE_WORDS) + (row_idx * MAX_SIZE) + col_idx;
                            case (lane_idx)
                                0: acc_0 = acc_0 + coeff_rom[rom_idx] * x_r[col_idx];
                                1: acc_1 = acc_1 + coeff_rom[rom_idx] * x_r[col_idx];
                                2: acc_2 = acc_2 + coeff_rom[rom_idx] * x_r[col_idx];
                                3: acc_3 = acc_3 + coeff_rom[rom_idx] * x_r[col_idx];
                                default: ;
                            endcase
                        end
                    end
                end
            end
        end
    end

    always @(*) begin
        out_data_0 = cast_acc(acc_0);
        out_data_1 = cast_acc(acc_1);
        out_data_2 = cast_acc(acc_2);
        out_data_3 = cast_acc(acc_3);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy_r          <= 1'b0;
            out_valid_r     <= 1'b0;
            size_r          <= 7'd0;
            row_base_r      <= 7'd0;
            non_zero_size_r <= 7'd0;
            table_sel_r     <= 3'd0;
            done            <= 1'b0;
            for (row_idx = 0; row_idx < MAX_SIZE; row_idx = row_idx + 1) begin
                x_r[row_idx] <= {DATA_W{1'b0}};
            end
        end else begin
            done <= 1'b0;

            if (!busy_r) begin
                if (start && is_supported_size(n_tbs)) begin
                    busy_r          <= 1'b1;
                    out_valid_r     <= 1'b0;
                    size_r          <= n_tbs;
                    row_base_r      <= 7'd0;
                    non_zero_size_r <= clamp_non_zero_size(non_zero_size, n_tbs);
                    table_sel_r     <= calc_table_sel(n_tbs);

                    x_r[0]  <= x_0;
                    x_r[1]  <= x_1;
                    x_r[2]  <= x_2;
                    x_r[3]  <= x_3;
                    x_r[4]  <= x_4;
                    x_r[5]  <= x_5;
                    x_r[6]  <= x_6;
                    x_r[7]  <= x_7;
                    x_r[8]  <= x_8;
                    x_r[9]  <= x_9;
                    x_r[10] <= x_10;
                    x_r[11] <= x_11;
                    x_r[12] <= x_12;
                    x_r[13] <= x_13;
                    x_r[14] <= x_14;
                    x_r[15] <= x_15;
                    x_r[16] <= x_16;
                    x_r[17] <= x_17;
                    x_r[18] <= x_18;
                    x_r[19] <= x_19;
                    x_r[20] <= x_20;
                    x_r[21] <= x_21;
                    x_r[22] <= x_22;
                    x_r[23] <= x_23;
                    x_r[24] <= x_24;
                    x_r[25] <= x_25;
                    x_r[26] <= x_26;
                    x_r[27] <= x_27;
                    x_r[28] <= x_28;
                    x_r[29] <= x_29;
                    x_r[30] <= x_30;
                    x_r[31] <= x_31;
                    x_r[32] <= x_32;
                    x_r[33] <= x_33;
                    x_r[34] <= x_34;
                    x_r[35] <= x_35;
                    x_r[36] <= x_36;
                    x_r[37] <= x_37;
                    x_r[38] <= x_38;
                    x_r[39] <= x_39;
                    x_r[40] <= x_40;
                    x_r[41] <= x_41;
                    x_r[42] <= x_42;
                    x_r[43] <= x_43;
                    x_r[44] <= x_44;
                    x_r[45] <= x_45;
                    x_r[46] <= x_46;
                    x_r[47] <= x_47;
                    x_r[48] <= x_48;
                    x_r[49] <= x_49;
                    x_r[50] <= x_50;
                    x_r[51] <= x_51;
                    x_r[52] <= x_52;
                    x_r[53] <= x_53;
                    x_r[54] <= x_54;
                    x_r[55] <= x_55;
                    x_r[56] <= x_56;
                    x_r[57] <= x_57;
                    x_r[58] <= x_58;
                    x_r[59] <= x_59;
                    x_r[60] <= x_60;
                    x_r[61] <= x_61;
                    x_r[62] <= x_62;
                    x_r[63] <= x_63;
                end
            end else begin
                if (!out_valid_r) begin
                    out_valid_r <= 1'b1;
                end else if (out_req) begin
                    if (row_base_r == (size_r - 7'd4)) begin
                        busy_r      <= 1'b0;
                        out_valid_r <= 1'b0;
                        size_r      <= 7'd0;
                        row_base_r  <= 7'd0;
                        done        <= 1'b1;
                    end else begin
                        row_base_r <= row_base_r + 7'd4;
                    end
                end
            end
        end
    end

endmodule
