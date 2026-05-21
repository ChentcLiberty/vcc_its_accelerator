module idct2_2d8_core #(
    parameter integer DATA_W    = 16,
    parameter integer MID_W     = 32,
    parameter integer OUT_W     = 64,
    parameter integer ROW_ACC_W = 40,
    parameter integer COL_ACC_W = 72,
    parameter        MEM_FILE   = "idct2_tables.memh"
) (
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       start,
    output wire                       in_ready,
    input  wire [6:0]                 non_zero_cols,
    input  wire [6:0]                 non_zero_rows,
    input  wire signed [DATA_W-1:0]   x_in [0:63],
    input  wire                       out_req,
    output wire                       out_valid,
    output wire                       out_last,
    output wire [6:0]                 out_index_base,
    output reg signed [OUT_W-1:0]     out_data_0,
    output reg signed [OUT_W-1:0]     out_data_1,
    output reg signed [OUT_W-1:0]     out_data_2,
    output reg signed [OUT_W-1:0]     out_data_3,
    output reg                        done,
    output wire                       busy
);

    localparam [3:0] S_IDLE        = 4'd0;
    localparam [3:0] S_PREP_ROW    = 4'd1;
    localparam [3:0] S_START_ROW   = 4'd2;
    localparam [3:0] S_RUN_ROW     = 4'd3;
    localparam [3:0] S_PREP_COL_LO = 4'd4;
    localparam [3:0] S_PREP_COL_HI = 4'd5;
    localparam [3:0] S_START_COL   = 4'd6;
    localparam [3:0] S_RUN_COL     = 4'd7;
    localparam [3:0] S_STREAM_OUT  = 4'd8;

    reg [3:0] state_r;
    reg [2:0] row_idx_r;
    reg [2:0] col_idx_r;
    reg [3:0] out_group_r;
    reg [6:0] non_zero_cols_r;
    reg [6:0] non_zero_rows_r;

    reg signed [DATA_W-1:0] x_in_r [0:63];
    reg signed [MID_W-1:0]  row_x_r [0:63];
    reg signed [MID_W-1:0]  col_x_r [0:63];

    wire mid_clear;
    wire final_clear;

    wire row_in_ready;
    wire row_out_valid;
    wire row_out_last;
    wire [6:0] row_out_index_base;
    wire signed [MID_W-1:0] row_out_data_0;
    wire signed [MID_W-1:0] row_out_data_1;
    wire signed [MID_W-1:0] row_out_data_2;
    wire signed [MID_W-1:0] row_out_data_3;
    wire row_done;

    wire col_in_ready;
    wire col_out_valid;
    wire col_out_last;
    wire [6:0] col_out_index_base;
    wire signed [OUT_W-1:0] col_out_data_0;
    wire signed [OUT_W-1:0] col_out_data_1;
    wire signed [OUT_W-1:0] col_out_data_2;
    wire signed [OUT_W-1:0] col_out_data_3;
    wire col_done;

    wire signed [MID_W-1:0] mid_rd_data_0;
    wire signed [MID_W-1:0] mid_rd_data_1;
    wire signed [MID_W-1:0] mid_rd_data_2;
    wire signed [MID_W-1:0] mid_rd_data_3;

    wire signed [OUT_W-1:0] final_rd_data_0;
    wire signed [OUT_W-1:0] final_rd_data_1;
    wire signed [OUT_W-1:0] final_rd_data_2;
    wire signed [OUT_W-1:0] final_rd_data_3;

    wire [6:0] final_rd_row_idx;
    wire [6:0] final_rd_col_base;
    wire [6:0] mid_rd_minor_base;

    integer idx;

    assign in_ready = (state_r == S_IDLE);
    assign busy = (state_r != S_IDLE);
    assign out_valid = (state_r == S_STREAM_OUT);
    assign out_last = (state_r == S_STREAM_OUT) && (out_group_r == 4'd15);
    assign out_index_base = ({4'd0, out_group_r[3:1]} << 3) + (out_group_r[0] ? 7'd4 : 7'd0);

    assign mid_clear = (state_r == S_IDLE) && start;
    assign final_clear = (state_r == S_IDLE) && start;

    assign mid_rd_minor_base = (state_r == S_PREP_COL_HI) ? 7'd4 : 7'd0;
    assign final_rd_row_idx = {4'd0, out_group_r[3:1]};
    assign final_rd_col_base = out_group_r[0] ? 7'd4 : 7'd0;

    idct2_1d_core #(
        .DATA_W(MID_W),
        .OUT_W(MID_W),
        .ACC_W(ROW_ACC_W),
        .MEM_FILE(MEM_FILE)
    ) u_row_idct (
        .clk(clk),
        .rst_n(rst_n),
        .start(state_r == S_START_ROW),
        .in_ready(row_in_ready),
        .n_tbs(7'd8),
        .non_zero_size(non_zero_cols_r),
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
        .out_req(state_r == S_RUN_ROW),
        .out_valid(row_out_valid),
        .out_last(row_out_last),
        .out_index_base(row_out_index_base),
        .out_data_0(row_out_data_0),
        .out_data_1(row_out_data_1),
        .out_data_2(row_out_data_2),
        .out_data_3(row_out_data_3),
        .done(row_done),
        .busy()
    );

    idct2_1d_core #(
        .DATA_W(MID_W),
        .OUT_W(OUT_W),
        .ACC_W(COL_ACC_W),
        .MEM_FILE(MEM_FILE)
    ) u_col_idct (
        .clk(clk),
        .rst_n(rst_n),
        .start(state_r == S_START_COL),
        .in_ready(col_in_ready),
        .n_tbs(7'd8),
        .non_zero_size(non_zero_rows_r),
        .x_0(col_x_r[0]),
        .x_1(col_x_r[1]),
        .x_2(col_x_r[2]),
        .x_3(col_x_r[3]),
        .x_4(col_x_r[4]),
        .x_5(col_x_r[5]),
        .x_6(col_x_r[6]),
        .x_7(col_x_r[7]),
        .x_8(col_x_r[8]),
        .x_9(col_x_r[9]),
        .x_10(col_x_r[10]),
        .x_11(col_x_r[11]),
        .x_12(col_x_r[12]),
        .x_13(col_x_r[13]),
        .x_14(col_x_r[14]),
        .x_15(col_x_r[15]),
        .x_16(col_x_r[16]),
        .x_17(col_x_r[17]),
        .x_18(col_x_r[18]),
        .x_19(col_x_r[19]),
        .x_20(col_x_r[20]),
        .x_21(col_x_r[21]),
        .x_22(col_x_r[22]),
        .x_23(col_x_r[23]),
        .x_24(col_x_r[24]),
        .x_25(col_x_r[25]),
        .x_26(col_x_r[26]),
        .x_27(col_x_r[27]),
        .x_28(col_x_r[28]),
        .x_29(col_x_r[29]),
        .x_30(col_x_r[30]),
        .x_31(col_x_r[31]),
        .x_32(col_x_r[32]),
        .x_33(col_x_r[33]),
        .x_34(col_x_r[34]),
        .x_35(col_x_r[35]),
        .x_36(col_x_r[36]),
        .x_37(col_x_r[37]),
        .x_38(col_x_r[38]),
        .x_39(col_x_r[39]),
        .x_40(col_x_r[40]),
        .x_41(col_x_r[41]),
        .x_42(col_x_r[42]),
        .x_43(col_x_r[43]),
        .x_44(col_x_r[44]),
        .x_45(col_x_r[45]),
        .x_46(col_x_r[46]),
        .x_47(col_x_r[47]),
        .x_48(col_x_r[48]),
        .x_49(col_x_r[49]),
        .x_50(col_x_r[50]),
        .x_51(col_x_r[51]),
        .x_52(col_x_r[52]),
        .x_53(col_x_r[53]),
        .x_54(col_x_r[54]),
        .x_55(col_x_r[55]),
        .x_56(col_x_r[56]),
        .x_57(col_x_r[57]),
        .x_58(col_x_r[58]),
        .x_59(col_x_r[59]),
        .x_60(col_x_r[60]),
        .x_61(col_x_r[61]),
        .x_62(col_x_r[62]),
        .x_63(col_x_r[63]),
        .out_req(state_r == S_RUN_COL),
        .out_valid(col_out_valid),
        .out_last(col_out_last),
        .out_index_base(col_out_index_base),
        .out_data_0(col_out_data_0),
        .out_data_1(col_out_data_1),
        .out_data_2(col_out_data_2),
        .out_data_3(col_out_data_3),
        .done(col_done),
        .busy()
    );

    its_transpose_buffer #(
        .DATA_W(MID_W),
        .MAX_DIM(64)
    ) u_mid_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .clear(mid_clear),
        .n_rows(7'd8),
        .n_cols(7'd8),
        .wr_valid(row_out_valid),
        .wr_transpose(1'b0),
        .wr_row_idx({4'd0, row_idx_r}),
        .wr_col_base(row_out_index_base),
        .wr_data_0(row_out_data_0),
        .wr_data_1(row_out_data_1),
        .wr_data_2(row_out_data_2),
        .wr_data_3(row_out_data_3),
        .rd_transpose(1'b1),
        .rd_major_idx({4'd0, col_idx_r}),
        .rd_minor_base(mid_rd_minor_base),
        .rd_data_0(mid_rd_data_0),
        .rd_data_1(mid_rd_data_1),
        .rd_data_2(mid_rd_data_2),
        .rd_data_3(mid_rd_data_3)
    );

    its_transpose_buffer #(
        .DATA_W(OUT_W),
        .MAX_DIM(64)
    ) u_final_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .clear(final_clear),
        .n_rows(7'd8),
        .n_cols(7'd8),
        .wr_valid(col_out_valid),
        .wr_transpose(1'b1),
        .wr_row_idx({4'd0, col_idx_r}),
        .wr_col_base(col_out_index_base),
        .wr_data_0(col_out_data_0),
        .wr_data_1(col_out_data_1),
        .wr_data_2(col_out_data_2),
        .wr_data_3(col_out_data_3),
        .rd_transpose(1'b0),
        .rd_major_idx(final_rd_row_idx),
        .rd_minor_base(final_rd_col_base),
        .rd_data_0(final_rd_data_0),
        .rd_data_1(final_rd_data_1),
        .rd_data_2(final_rd_data_2),
        .rd_data_3(final_rd_data_3)
    );

    always @(*) begin
        out_data_0 = final_rd_data_0;
        out_data_1 = final_rd_data_1;
        out_data_2 = final_rd_data_2;
        out_data_3 = final_rd_data_3;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r         <= S_IDLE;
            row_idx_r       <= 3'd0;
            col_idx_r       <= 3'd0;
            out_group_r     <= 4'd0;
            non_zero_cols_r <= 7'd8;
            non_zero_rows_r <= 7'd8;
            done            <= 1'b0;
            for (idx = 0; idx < 64; idx = idx + 1) begin
                x_in_r[idx]  <= {DATA_W{1'b0}};
                row_x_r[idx] <= {MID_W{1'b0}};
                col_x_r[idx] <= {MID_W{1'b0}};
            end
        end else begin
            done <= 1'b0;

            case (state_r)
                S_IDLE: begin
                    row_idx_r <= 3'd0;
                    col_idx_r <= 3'd0;
                    out_group_r <= 4'd0;
                    if (start) begin
                        non_zero_cols_r <= non_zero_cols;
                        non_zero_rows_r <= non_zero_rows;
                        for (idx = 0; idx < 64; idx = idx + 1) begin
                            x_in_r[idx] <= x_in[idx];
                        end
                        state_r <= S_PREP_ROW;
                    end
                end

                S_PREP_ROW: begin
                    for (idx = 0; idx < 64; idx = idx + 1) begin
                        row_x_r[idx] <= {MID_W{1'b0}};
                    end
                    for (idx = 0; idx < 8; idx = idx + 1) begin
                        row_x_r[idx] <= $signed(x_in_r[(row_idx_r * 8) + idx]);
                    end
                    state_r <= S_START_ROW;
                end

                S_START_ROW: begin
                    state_r <= S_RUN_ROW;
                end

                S_RUN_ROW: begin
                    if (row_done) begin
                        if (row_idx_r == 3'd7) begin
                            col_idx_r <= 3'd0;
                            state_r <= S_PREP_COL_LO;
                        end else begin
                            row_idx_r <= row_idx_r + 3'd1;
                            state_r <= S_PREP_ROW;
                        end
                    end
                end

                S_PREP_COL_LO: begin
                    for (idx = 0; idx < 64; idx = idx + 1) begin
                        col_x_r[idx] <= {MID_W{1'b0}};
                    end
                    col_x_r[0] <= mid_rd_data_0;
                    col_x_r[1] <= mid_rd_data_1;
                    col_x_r[2] <= mid_rd_data_2;
                    col_x_r[3] <= mid_rd_data_3;
                    state_r <= S_PREP_COL_HI;
                end

                S_PREP_COL_HI: begin
                    col_x_r[4] <= mid_rd_data_0;
                    col_x_r[5] <= mid_rd_data_1;
                    col_x_r[6] <= mid_rd_data_2;
                    col_x_r[7] <= mid_rd_data_3;
                    state_r <= S_START_COL;
                end

                S_START_COL: begin
                    state_r <= S_RUN_COL;
                end

                S_RUN_COL: begin
                    if (col_done) begin
                        if (col_idx_r == 3'd7) begin
                            out_group_r <= 4'd0;
                            state_r <= S_STREAM_OUT;
                        end else begin
                            col_idx_r <= col_idx_r + 3'd1;
                            state_r <= S_PREP_COL_LO;
                        end
                    end
                end

                S_STREAM_OUT: begin
                    if (out_req) begin
                        if (out_group_r == 4'd15) begin
                            done <= 1'b1;
                            state_r <= S_IDLE;
                        end else begin
                            out_group_r <= out_group_r + 4'd1;
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
