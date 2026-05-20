module lfnst_idct2_2d4_core #(
    parameter integer DATA_W         = 16,
    parameter integer MID_W          = 32,
    parameter integer OUT_W          = 64,
    parameter integer ROW_ACC_W      = 72,
    parameter        LFNST_MEM_FILE  = "lfnst_tables.memh",
    parameter        IDCT_MEM_FILE   = "idct2_tables.memh"
) (
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       start,
    output wire                       in_ready,
    input  wire [1:0]                 lfnst_tr_set_idx,
    input  wire [1:0]                 lfnst_idx,
    input  wire signed [DATA_W-1:0]   x_bar_0,
    input  wire signed [DATA_W-1:0]   x_bar_1,
    input  wire signed [DATA_W-1:0]   x_bar_2,
    input  wire signed [DATA_W-1:0]   x_bar_3,
    input  wire signed [DATA_W-1:0]   x_bar_4,
    input  wire signed [DATA_W-1:0]   x_bar_5,
    input  wire signed [DATA_W-1:0]   x_bar_6,
    input  wire signed [DATA_W-1:0]   x_bar_7,
    input  wire signed [DATA_W-1:0]   x_bar_8,
    input  wire signed [DATA_W-1:0]   x_bar_9,
    input  wire signed [DATA_W-1:0]   x_bar_10,
    input  wire signed [DATA_W-1:0]   x_bar_11,
    input  wire signed [DATA_W-1:0]   x_bar_12,
    input  wire signed [DATA_W-1:0]   x_bar_13,
    input  wire signed [DATA_W-1:0]   x_bar_14,
    input  wire signed [DATA_W-1:0]   x_bar_15,
    input  wire                       out_req,
    output wire                       out_valid,
    output wire                       out_last,
    output wire [5:0]                 out_row_base,
    output reg signed [OUT_W-1:0]     out_data_0,
    output reg signed [OUT_W-1:0]     out_data_1,
    output reg signed [OUT_W-1:0]     out_data_2,
    output reg signed [OUT_W-1:0]     out_data_3,
    output reg                        done,
    output wire                       busy
);

    localparam [3:0] S_IDLE           = 4'd0;
    localparam [3:0] S_START_COL      = 4'd1;
    localparam [3:0] S_RUN_COL        = 4'd2;
    localparam [3:0] S_PREP_ROW       = 4'd3;
    localparam [3:0] S_START_ROW      = 4'd4;
    localparam [3:0] S_RUN_ROW        = 4'd5;
    localparam [3:0] S_STREAM_OUT     = 4'd6;

    reg [3:0] state_r;
    reg [1:0] lfnst_tr_set_idx_r;
    reg [1:0] lfnst_idx_r;
    reg [1:0] row_idx_r;
    reg [5:0] out_row_base_r;

    reg signed [DATA_W-1:0] x_bar_in_r [0:15];
    reg signed [MID_W-1:0]  col_block_r [0:15];
    reg signed [MID_W-1:0]  row_x_r [0:63];
    reg signed [OUT_W-1:0]  final_block_r [0:15];

    wire col_chain_in_ready;
    wire col_chain_out_valid;
    wire col_chain_out_last;
    wire [5:0] col_chain_out_row_base;
    wire signed [MID_W-1:0] col_chain_out_data_0;
    wire signed [MID_W-1:0] col_chain_out_data_1;
    wire signed [MID_W-1:0] col_chain_out_data_2;
    wire signed [MID_W-1:0] col_chain_out_data_3;
    wire col_chain_done;

    wire row_idct_in_ready;
    wire row_idct_out_valid;
    wire row_idct_out_last;
    wire [6:0] row_idct_out_index_base;
    wire signed [OUT_W-1:0] row_idct_out_data_0;
    wire signed [OUT_W-1:0] row_idct_out_data_1;
    wire signed [OUT_W-1:0] row_idct_out_data_2;
    wire signed [OUT_W-1:0] row_idct_out_data_3;
    wire row_idct_done;

    wire col_chain_start   = (state_r == S_START_COL);
    wire col_chain_out_req = (state_r == S_RUN_COL);
    wire row_idct_start    = (state_r == S_START_ROW);
    wire row_idct_out_req  = (state_r == S_RUN_ROW);

    integer idx;

    assign in_ready = (state_r == S_IDLE);
    assign out_valid = (state_r == S_STREAM_OUT);
    assign out_row_base = out_row_base_r;
    assign out_last = (state_r == S_STREAM_OUT) && (out_row_base_r == 6'd12);
    assign busy = (state_r != S_IDLE);

    lfnst_idct2_col4_core #(
        .DATA_W(DATA_W),
        .IDCT_OUT_W(MID_W),
        .LFNST_MEM_FILE(LFNST_MEM_FILE),
        .IDCT_MEM_FILE(IDCT_MEM_FILE)
    ) u_col_chain (
        .clk(clk),
        .rst_n(rst_n),
        .start(col_chain_start),
        .in_ready(col_chain_in_ready),
        .lfnst_tr_set_idx(lfnst_tr_set_idx_r),
        .lfnst_idx(lfnst_idx_r),
        .x_bar_0(x_bar_in_r[0]),
        .x_bar_1(x_bar_in_r[1]),
        .x_bar_2(x_bar_in_r[2]),
        .x_bar_3(x_bar_in_r[3]),
        .x_bar_4(x_bar_in_r[4]),
        .x_bar_5(x_bar_in_r[5]),
        .x_bar_6(x_bar_in_r[6]),
        .x_bar_7(x_bar_in_r[7]),
        .x_bar_8(x_bar_in_r[8]),
        .x_bar_9(x_bar_in_r[9]),
        .x_bar_10(x_bar_in_r[10]),
        .x_bar_11(x_bar_in_r[11]),
        .x_bar_12(x_bar_in_r[12]),
        .x_bar_13(x_bar_in_r[13]),
        .x_bar_14(x_bar_in_r[14]),
        .x_bar_15(x_bar_in_r[15]),
        .out_req(col_chain_out_req),
        .out_valid(col_chain_out_valid),
        .out_last(col_chain_out_last),
        .out_row_base(col_chain_out_row_base),
        .out_data_0(col_chain_out_data_0),
        .out_data_1(col_chain_out_data_1),
        .out_data_2(col_chain_out_data_2),
        .out_data_3(col_chain_out_data_3),
        .done(col_chain_done),
        .busy()
    );

    idct2_1d_core #(
        .DATA_W(MID_W),
        .OUT_W(OUT_W),
        .ACC_W(ROW_ACC_W),
        .MEM_FILE(IDCT_MEM_FILE)
    ) u_row_idct (
        .clk(clk),
        .rst_n(rst_n),
        .start(row_idct_start),
        .in_ready(row_idct_in_ready),
        .n_tbs(7'd4),
        .non_zero_size(7'd4),
        .x_0(row_x_r[0]),
        .x_1(row_x_r[1]),
        .x_2(row_x_r[2]),
        .x_3(row_x_r[3]),
        .x_4(row_x_r[4]),
        .x_5(row_x_r[5]),
        .x_6(row_x_r[6]),
        .x_7(row_x_r[7]),
        .x_8(row_x_r[8]),
        .x_9(row_x_r[9]),
        .x_10(row_x_r[10]),
        .x_11(row_x_r[11]),
        .x_12(row_x_r[12]),
        .x_13(row_x_r[13]),
        .x_14(row_x_r[14]),
        .x_15(row_x_r[15]),
        .x_16(row_x_r[16]),
        .x_17(row_x_r[17]),
        .x_18(row_x_r[18]),
        .x_19(row_x_r[19]),
        .x_20(row_x_r[20]),
        .x_21(row_x_r[21]),
        .x_22(row_x_r[22]),
        .x_23(row_x_r[23]),
        .x_24(row_x_r[24]),
        .x_25(row_x_r[25]),
        .x_26(row_x_r[26]),
        .x_27(row_x_r[27]),
        .x_28(row_x_r[28]),
        .x_29(row_x_r[29]),
        .x_30(row_x_r[30]),
        .x_31(row_x_r[31]),
        .x_32(row_x_r[32]),
        .x_33(row_x_r[33]),
        .x_34(row_x_r[34]),
        .x_35(row_x_r[35]),
        .x_36(row_x_r[36]),
        .x_37(row_x_r[37]),
        .x_38(row_x_r[38]),
        .x_39(row_x_r[39]),
        .x_40(row_x_r[40]),
        .x_41(row_x_r[41]),
        .x_42(row_x_r[42]),
        .x_43(row_x_r[43]),
        .x_44(row_x_r[44]),
        .x_45(row_x_r[45]),
        .x_46(row_x_r[46]),
        .x_47(row_x_r[47]),
        .x_48(row_x_r[48]),
        .x_49(row_x_r[49]),
        .x_50(row_x_r[50]),
        .x_51(row_x_r[51]),
        .x_52(row_x_r[52]),
        .x_53(row_x_r[53]),
        .x_54(row_x_r[54]),
        .x_55(row_x_r[55]),
        .x_56(row_x_r[56]),
        .x_57(row_x_r[57]),
        .x_58(row_x_r[58]),
        .x_59(row_x_r[59]),
        .x_60(row_x_r[60]),
        .x_61(row_x_r[61]),
        .x_62(row_x_r[62]),
        .x_63(row_x_r[63]),
        .out_req(row_idct_out_req),
        .out_valid(row_idct_out_valid),
        .out_last(row_idct_out_last),
        .out_index_base(row_idct_out_index_base),
        .out_data_0(row_idct_out_data_0),
        .out_data_1(row_idct_out_data_1),
        .out_data_2(row_idct_out_data_2),
        .out_data_3(row_idct_out_data_3),
        .done(row_idct_done),
        .busy()
    );

    always @(*) begin
        out_data_0 = final_block_r[out_row_base_r + 0];
        out_data_1 = final_block_r[out_row_base_r + 1];
        out_data_2 = final_block_r[out_row_base_r + 2];
        out_data_3 = final_block_r[out_row_base_r + 3];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r            <= S_IDLE;
            lfnst_tr_set_idx_r <= 2'd0;
            lfnst_idx_r        <= 2'd0;
            row_idx_r          <= 2'd0;
            out_row_base_r     <= 6'd0;
            done               <= 1'b0;
            for (idx = 0; idx < 16; idx = idx + 1) begin
                x_bar_in_r[idx]   <= {DATA_W{1'b0}};
                col_block_r[idx]  <= {MID_W{1'b0}};
                final_block_r[idx] <= {OUT_W{1'b0}};
            end
            for (idx = 0; idx < 64; idx = idx + 1) begin
                row_x_r[idx] <= {MID_W{1'b0}};
            end
        end else begin
            done <= 1'b0;

            case (state_r)
                S_IDLE: begin
                    out_row_base_r <= 6'd0;
                    if (start) begin
                        lfnst_tr_set_idx_r <= lfnst_tr_set_idx;
                        lfnst_idx_r        <= lfnst_idx;
                        x_bar_in_r[0]  <= x_bar_0;
                        x_bar_in_r[1]  <= x_bar_1;
                        x_bar_in_r[2]  <= x_bar_2;
                        x_bar_in_r[3]  <= x_bar_3;
                        x_bar_in_r[4]  <= x_bar_4;
                        x_bar_in_r[5]  <= x_bar_5;
                        x_bar_in_r[6]  <= x_bar_6;
                        x_bar_in_r[7]  <= x_bar_7;
                        x_bar_in_r[8]  <= x_bar_8;
                        x_bar_in_r[9]  <= x_bar_9;
                        x_bar_in_r[10] <= x_bar_10;
                        x_bar_in_r[11] <= x_bar_11;
                        x_bar_in_r[12] <= x_bar_12;
                        x_bar_in_r[13] <= x_bar_13;
                        x_bar_in_r[14] <= x_bar_14;
                        x_bar_in_r[15] <= x_bar_15;
                        state_r <= S_START_COL;
                    end
                end

                S_START_COL: begin
                    state_r <= S_RUN_COL;
                end

                S_RUN_COL: begin
                    if (col_chain_out_valid) begin
                        col_block_r[col_chain_out_row_base + 0] <= col_chain_out_data_0;
                        col_block_r[col_chain_out_row_base + 1] <= col_chain_out_data_1;
                        col_block_r[col_chain_out_row_base + 2] <= col_chain_out_data_2;
                        col_block_r[col_chain_out_row_base + 3] <= col_chain_out_data_3;
                    end
                    if (col_chain_done) begin
                        row_idx_r <= 2'd0;
                        state_r <= S_PREP_ROW;
                    end
                end

                S_PREP_ROW: begin
                    for (idx = 0; idx < 64; idx = idx + 1) begin
                        row_x_r[idx] <= {MID_W{1'b0}};
                    end
                    row_x_r[0] <= col_block_r[{row_idx_r, 2'b00} + 0];
                    row_x_r[1] <= col_block_r[{row_idx_r, 2'b00} + 1];
                    row_x_r[2] <= col_block_r[{row_idx_r, 2'b00} + 2];
                    row_x_r[3] <= col_block_r[{row_idx_r, 2'b00} + 3];
                    state_r <= S_START_ROW;
                end

                S_START_ROW: begin
                    state_r <= S_RUN_ROW;
                end

                S_RUN_ROW: begin
                    if (row_idct_out_valid) begin
                        final_block_r[{row_idx_r, 2'b00} + 0] <= row_idct_out_data_0;
                        final_block_r[{row_idx_r, 2'b00} + 1] <= row_idct_out_data_1;
                        final_block_r[{row_idx_r, 2'b00} + 2] <= row_idct_out_data_2;
                        final_block_r[{row_idx_r, 2'b00} + 3] <= row_idct_out_data_3;
                    end
                    if (row_idct_done) begin
                        if (row_idx_r == 2'd3) begin
                            out_row_base_r <= 6'd0;
                            state_r <= S_STREAM_OUT;
                        end else begin
                            row_idx_r <= row_idx_r + 2'd1;
                            state_r <= S_PREP_ROW;
                        end
                    end
                end

                S_STREAM_OUT: begin
                    if (out_req) begin
                        if (out_row_base_r == 6'd12) begin
                            out_row_base_r <= 6'd0;
                            done <= 1'b1;
                            state_r <= S_IDLE;
                        end else begin
                            out_row_base_r <= out_row_base_r + 6'd4;
                        end
                    end
                end

                default: begin
                    state_r <= S_IDLE;
                end
            endcase
        end
    end

endmodule
