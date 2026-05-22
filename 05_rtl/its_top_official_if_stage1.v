module its_top_official_if_stage1 #(
    parameter integer DATA_W        = 16,
    parameter integer PACK_W        = 10,
    parameter        LFNST_MEM_FILE = "lfnst_tables.memh",
    parameter        IDCT_MEM_FILE  = "idct2_tables.memh",
    parameter        ITS_MEM_FILE   = "its_1d_tables.memh"
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [21:0]              it_info,
    input  wire                     it_info_vld,
    input  wire signed [15:0]       it_data_in,
    input  wire [11:0]              it_data_addr,
    input  wire                     it_data_in_vld,
    input  wire                     it_data_end,
    output wire                     it_data_in_req,
    output reg  [39:0]              it_data_out,
    output wire                     it_data_out_vld,
    input  wire                     it_data_out_req,
    output wire                     it_done
);

    localparam [2:0] MODE_UNSUPPORTED = 3'd0;
    localparam [2:0] MODE_4X4_DCT2    = 3'd1;
    localparam [2:0] MODE_8X8_DCT2    = 3'd2;
    localparam [2:0] MODE_8X8_DST7    = 3'd3;
    localparam [2:0] MODE_8X8_DCT8    = 3'd4;
    localparam [2:0] MODE_16X16_DCT2  = 3'd5;
    localparam [2:0] MODE_16X16_DST7  = 3'd6;
    localparam [2:0] MODE_16X16_DCT8  = 3'd7;

    localparam [1:0] TR_DCT2 = 2'd0;
    localparam [1:0] TR_DST7 = 2'd1;
    localparam [1:0] TR_DCT8 = 2'd2;

    localparam [2:0] S_IDLE         = 3'd0;
    localparam [2:0] S_LOAD         = 3'd1;
    localparam [2:0] S_START        = 3'd2;
    localparam [2:0] S_RUN          = 3'd3;
    localparam [2:0] S_UNSUP_DONE   = 3'd4;

    reg [2:0] state_r;
    reg [2:0] mode_r;
    reg [6:0] tu_width_r;
    reg [6:0] tu_height_r;
    reg [1:0] tr_type_hor_r;
    reg [1:0] tr_type_ver_r;
    reg [1:0] lfnst_tr_set_idx_r;
    reg [1:0] lfnst_idx_r;
    reg signed [DATA_W-1:0] tu_buf_r [0:255];

    wire [6:0] tu_width_w  = it_info[6:0];
    wire [6:0] tu_height_w = it_info[13:7];
    wire [1:0] tr_hor_w    = it_info[15:14];
    wire [1:0] tr_ver_w    = it_info[17:16];
    wire [1:0] lfnst_set_w = it_info[19:18];
    wire [1:0] lfnst_idx_w = it_info[21:20];

    wire load_mode_w;
    wire start_mode_w;
    wire run_mode_w;

    wire start_4x4;
    wire start_8x8_dct2;
    wire start_8x8_dst7;
    wire start_8x8_dct8;
    wire start_16x16_dct2;
    wire start_16x16_dst7;
    wire start_16x16_dct8;

    wire sel_out_valid;
    wire sel_done;
    wire signed [63:0] sel_out_data_0;
    wire signed [63:0] sel_out_data_1;
    wire signed [63:0] sel_out_data_2;
    wire signed [63:0] sel_out_data_3;

    wire signed [DATA_W-1:0] x8_in [0:63];
    wire signed [DATA_W-1:0] x16_in [0:255];

    wire core4_in_ready;
    wire core4_out_valid;
    wire core4_out_last;
    wire [5:0] core4_out_row_base;
    wire signed [63:0] core4_out_data_0;
    wire signed [63:0] core4_out_data_1;
    wire signed [63:0] core4_out_data_2;
    wire signed [63:0] core4_out_data_3;
    wire core4_done;

    wire core8_dct2_in_ready;
    wire core8_dct2_out_valid;
    wire core8_dct2_out_last;
    wire [6:0] core8_dct2_out_index_base;
    wire signed [63:0] core8_dct2_out_data_0;
    wire signed [63:0] core8_dct2_out_data_1;
    wire signed [63:0] core8_dct2_out_data_2;
    wire signed [63:0] core8_dct2_out_data_3;
    wire core8_dct2_done;

    wire core8_dst7_in_ready;
    wire core8_dst7_out_valid;
    wire core8_dst7_out_last;
    wire [6:0] core8_dst7_out_index_base;
    wire signed [63:0] core8_dst7_out_data_0;
    wire signed [63:0] core8_dst7_out_data_1;
    wire signed [63:0] core8_dst7_out_data_2;
    wire signed [63:0] core8_dst7_out_data_3;
    wire core8_dst7_done;

    wire core8_dct8_in_ready;
    wire core8_dct8_out_valid;
    wire core8_dct8_out_last;
    wire [6:0] core8_dct8_out_index_base;
    wire signed [63:0] core8_dct8_out_data_0;
    wire signed [63:0] core8_dct8_out_data_1;
    wire signed [63:0] core8_dct8_out_data_2;
    wire signed [63:0] core8_dct8_out_data_3;
    wire core8_dct8_done;

    wire core16_dct2_in_ready;
    wire core16_dct2_out_valid;
    wire core16_dct2_out_last;
    wire [7:0] core16_dct2_out_index_base;
    wire signed [63:0] core16_dct2_out_data_0;
    wire signed [63:0] core16_dct2_out_data_1;
    wire signed [63:0] core16_dct2_out_data_2;
    wire signed [63:0] core16_dct2_out_data_3;
    wire core16_dct2_done;

    wire core16_dst7_in_ready;
    wire core16_dst7_out_valid;
    wire core16_dst7_out_last;
    wire [7:0] core16_dst7_out_index_base;
    wire signed [63:0] core16_dst7_out_data_0;
    wire signed [63:0] core16_dst7_out_data_1;
    wire signed [63:0] core16_dst7_out_data_2;
    wire signed [63:0] core16_dst7_out_data_3;
    wire core16_dst7_done;

    wire core16_dct8_in_ready;
    wire core16_dct8_out_valid;
    wire core16_dct8_out_last;
    wire [7:0] core16_dct8_out_index_base;
    wire signed [63:0] core16_dct8_out_data_0;
    wire signed [63:0] core16_dct8_out_data_1;
    wire signed [63:0] core16_dct8_out_data_2;
    wire signed [63:0] core16_dct8_out_data_3;
    wire core16_dct8_done;

    integer idx;

    assign load_mode_w = (state_r == S_LOAD);
    assign start_mode_w = (state_r == S_START);
    assign run_mode_w = (state_r == S_RUN);

    assign it_data_in_req = load_mode_w;
    assign it_data_out_vld = sel_out_valid && it_data_out_req;
    assign it_done = (state_r == S_UNSUP_DONE) ? 1'b1 : sel_done;

    assign start_4x4       = start_mode_w && (mode_r == MODE_4X4_DCT2);
    assign start_8x8_dct2  = start_mode_w && (mode_r == MODE_8X8_DCT2);
    assign start_8x8_dst7  = start_mode_w && (mode_r == MODE_8X8_DST7);
    assign start_8x8_dct8  = start_mode_w && (mode_r == MODE_8X8_DCT8);
    assign start_16x16_dct2 = start_mode_w && (mode_r == MODE_16X16_DCT2);
    assign start_16x16_dst7 = start_mode_w && (mode_r == MODE_16X16_DST7);
    assign start_16x16_dct8 = start_mode_w && (mode_r == MODE_16X16_DCT8);

    function [2:0] decode_mode;
        input [6:0] width_i;
        input [6:0] height_i;
        input [1:0] tr_hor_i;
        input [1:0] tr_ver_i;
        input [1:0] lfnst_idx_i;
        begin
            decode_mode = MODE_UNSUPPORTED;
            if ((width_i == 7'd4) && (height_i == 7'd4) &&
                (tr_hor_i == TR_DCT2) && (tr_ver_i == TR_DCT2)) begin
                decode_mode = MODE_4X4_DCT2;
            end else if ((width_i == 7'd8) && (height_i == 7'd8) &&
                         (lfnst_idx_i == 2'd0) && (tr_hor_i == tr_ver_i)) begin
                case (tr_hor_i)
                    TR_DCT2: decode_mode = MODE_8X8_DCT2;
                    TR_DST7: decode_mode = MODE_8X8_DST7;
                    TR_DCT8: decode_mode = MODE_8X8_DCT8;
                    default: decode_mode = MODE_UNSUPPORTED;
                endcase
            end else if ((width_i == 7'd16) && (height_i == 7'd16) &&
                         (lfnst_idx_i == 2'd0) && (tr_hor_i == tr_ver_i)) begin
                case (tr_hor_i)
                    TR_DCT2: decode_mode = MODE_16X16_DCT2;
                    TR_DST7: decode_mode = MODE_16X16_DST7;
                    TR_DCT8: decode_mode = MODE_16X16_DCT8;
                    default: decode_mode = MODE_UNSUPPORTED;
                endcase
            end
        end
    endfunction

    function [8:0] coeff_count;
        input [2:0] mode_i;
        begin
            case (mode_i)
                MODE_4X4_DCT2: coeff_count = 9'd16;
                MODE_8X8_DCT2,
                MODE_8X8_DST7,
                MODE_8X8_DCT8: coeff_count = 9'd64;
                MODE_16X16_DCT2,
                MODE_16X16_DST7,
                MODE_16X16_DCT8: coeff_count = 9'd256;
                default: coeff_count = 9'd0;
            endcase
        end
    endfunction

    function [3:0] lfnst_scan_addr_4x4;
        input [3:0] scan_idx;
        begin
            case (scan_idx)
                4'd0:  lfnst_scan_addr_4x4 = 4'd0;
                4'd1:  lfnst_scan_addr_4x4 = 4'd4;
                4'd2:  lfnst_scan_addr_4x4 = 4'd1;
                4'd3:  lfnst_scan_addr_4x4 = 4'd8;
                4'd4:  lfnst_scan_addr_4x4 = 4'd5;
                4'd5:  lfnst_scan_addr_4x4 = 4'd2;
                4'd6:  lfnst_scan_addr_4x4 = 4'd12;
                4'd7:  lfnst_scan_addr_4x4 = 4'd9;
                4'd8:  lfnst_scan_addr_4x4 = 4'd6;
                4'd9:  lfnst_scan_addr_4x4 = 4'd3;
                4'd10: lfnst_scan_addr_4x4 = 4'd13;
                4'd11: lfnst_scan_addr_4x4 = 4'd10;
                4'd12: lfnst_scan_addr_4x4 = 4'd7;
                4'd13: lfnst_scan_addr_4x4 = 4'd14;
                4'd14: lfnst_scan_addr_4x4 = 4'd11;
                default: lfnst_scan_addr_4x4 = 4'd15;
            endcase
        end
    endfunction

    function [9:0] pack_lane10;
        input signed [63:0] value_i;
        reg signed [63:0] clipped_v;
        begin
            if (value_i > 64'sd511) begin
                clipped_v = 64'sd511;
            end else if (value_i < -64'sd512) begin
                clipped_v = -64'sd512;
            end else begin
                clipped_v = value_i;
            end
            pack_lane10 = clipped_v[9:0];
        end
    endfunction

    genvar g;
    generate
        for (g = 0; g < 64; g = g + 1) begin : GEN_X8
            assign x8_in[g] = tu_buf_r[g];
        end
        for (g = 0; g < 256; g = g + 1) begin : GEN_X16
            assign x16_in[g] = tu_buf_r[g];
        end
    endgenerate

    lfnst_idct2_2d4_core #(
        .LFNST_MEM_FILE(LFNST_MEM_FILE),
        .IDCT_MEM_FILE(IDCT_MEM_FILE)
    ) u_core4 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_4x4),
        .in_ready(core4_in_ready),
        .lfnst_tr_set_idx(lfnst_tr_set_idx_r),
        .lfnst_idx(lfnst_idx_r),
        .x_bar_0(tu_buf_r[lfnst_scan_addr_4x4(4'd0)]),
        .x_bar_1(tu_buf_r[lfnst_scan_addr_4x4(4'd1)]),
        .x_bar_2(tu_buf_r[lfnst_scan_addr_4x4(4'd2)]),
        .x_bar_3(tu_buf_r[lfnst_scan_addr_4x4(4'd3)]),
        .x_bar_4(tu_buf_r[lfnst_scan_addr_4x4(4'd4)]),
        .x_bar_5(tu_buf_r[lfnst_scan_addr_4x4(4'd5)]),
        .x_bar_6(tu_buf_r[lfnst_scan_addr_4x4(4'd6)]),
        .x_bar_7(tu_buf_r[lfnst_scan_addr_4x4(4'd7)]),
        .x_bar_8(tu_buf_r[lfnst_scan_addr_4x4(4'd8)]),
        .x_bar_9(tu_buf_r[lfnst_scan_addr_4x4(4'd9)]),
        .x_bar_10(tu_buf_r[lfnst_scan_addr_4x4(4'd10)]),
        .x_bar_11(tu_buf_r[lfnst_scan_addr_4x4(4'd11)]),
        .x_bar_12(tu_buf_r[lfnst_scan_addr_4x4(4'd12)]),
        .x_bar_13(tu_buf_r[lfnst_scan_addr_4x4(4'd13)]),
        .x_bar_14(tu_buf_r[lfnst_scan_addr_4x4(4'd14)]),
        .x_bar_15(tu_buf_r[lfnst_scan_addr_4x4(4'd15)]),
        .out_req(it_data_out_req),
        .out_valid(core4_out_valid),
        .out_last(core4_out_last),
        .out_row_base(core4_out_row_base),
        .out_data_0(core4_out_data_0),
        .out_data_1(core4_out_data_1),
        .out_data_2(core4_out_data_2),
        .out_data_3(core4_out_data_3),
        .done(core4_done),
        .busy()
    );

    idct2_2d8_core #(
        .MEM_FILE(IDCT_MEM_FILE)
    ) u_core8_dct2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_8x8_dct2),
        .in_ready(core8_dct2_in_ready),
        .non_zero_cols(7'd8),
        .non_zero_rows(7'd8),
        .x_in(x8_in),
        .out_req(it_data_out_req),
        .out_valid(core8_dct2_out_valid),
        .out_last(core8_dct2_out_last),
        .out_index_base(core8_dct2_out_index_base),
        .out_data_0(core8_dct2_out_data_0),
        .out_data_1(core8_dct2_out_data_1),
        .out_data_2(core8_dct2_out_data_2),
        .out_data_3(core8_dct2_out_data_3),
        .done(core8_dct2_done),
        .busy()
    );

    its_2d8_core #(
        .ROW_TR_TYPE(TR_DST7),
        .COL_TR_TYPE(TR_DST7),
        .MEM_FILE(ITS_MEM_FILE)
    ) u_core8_dst7 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_8x8_dst7),
        .in_ready(core8_dst7_in_ready),
        .non_zero_cols(7'd8),
        .non_zero_rows(7'd8),
        .x_in(x8_in),
        .out_req(it_data_out_req),
        .out_valid(core8_dst7_out_valid),
        .out_last(core8_dst7_out_last),
        .out_index_base(core8_dst7_out_index_base),
        .out_data_0(core8_dst7_out_data_0),
        .out_data_1(core8_dst7_out_data_1),
        .out_data_2(core8_dst7_out_data_2),
        .out_data_3(core8_dst7_out_data_3),
        .done(core8_dst7_done),
        .busy()
    );

    its_2d8_core #(
        .ROW_TR_TYPE(TR_DCT8),
        .COL_TR_TYPE(TR_DCT8),
        .MEM_FILE(ITS_MEM_FILE)
    ) u_core8_dct8 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_8x8_dct8),
        .in_ready(core8_dct8_in_ready),
        .non_zero_cols(7'd8),
        .non_zero_rows(7'd8),
        .x_in(x8_in),
        .out_req(it_data_out_req),
        .out_valid(core8_dct8_out_valid),
        .out_last(core8_dct8_out_last),
        .out_index_base(core8_dct8_out_index_base),
        .out_data_0(core8_dct8_out_data_0),
        .out_data_1(core8_dct8_out_data_1),
        .out_data_2(core8_dct8_out_data_2),
        .out_data_3(core8_dct8_out_data_3),
        .done(core8_dct8_done),
        .busy()
    );

    idct2_2d16_core #(
        .MEM_FILE(IDCT_MEM_FILE)
    ) u_core16_dct2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_16x16_dct2),
        .in_ready(core16_dct2_in_ready),
        .non_zero_cols(7'd16),
        .non_zero_rows(7'd16),
        .x_in(x16_in),
        .out_req(it_data_out_req),
        .out_valid(core16_dct2_out_valid),
        .out_last(core16_dct2_out_last),
        .out_index_base(core16_dct2_out_index_base),
        .out_data_0(core16_dct2_out_data_0),
        .out_data_1(core16_dct2_out_data_1),
        .out_data_2(core16_dct2_out_data_2),
        .out_data_3(core16_dct2_out_data_3),
        .done(core16_dct2_done),
        .busy()
    );

    its_2d16_core #(
        .ROW_TR_TYPE(TR_DST7),
        .COL_TR_TYPE(TR_DST7),
        .MEM_FILE(ITS_MEM_FILE)
    ) u_core16_dst7 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_16x16_dst7),
        .in_ready(core16_dst7_in_ready),
        .non_zero_cols(7'd16),
        .non_zero_rows(7'd16),
        .x_in(x16_in),
        .out_req(it_data_out_req),
        .out_valid(core16_dst7_out_valid),
        .out_last(core16_dst7_out_last),
        .out_index_base(core16_dst7_out_index_base),
        .out_data_0(core16_dst7_out_data_0),
        .out_data_1(core16_dst7_out_data_1),
        .out_data_2(core16_dst7_out_data_2),
        .out_data_3(core16_dst7_out_data_3),
        .done(core16_dst7_done),
        .busy()
    );

    its_2d16_core #(
        .ROW_TR_TYPE(TR_DCT8),
        .COL_TR_TYPE(TR_DCT8),
        .MEM_FILE(ITS_MEM_FILE)
    ) u_core16_dct8 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_16x16_dct8),
        .in_ready(core16_dct8_in_ready),
        .non_zero_cols(7'd16),
        .non_zero_rows(7'd16),
        .x_in(x16_in),
        .out_req(it_data_out_req),
        .out_valid(core16_dct8_out_valid),
        .out_last(core16_dct8_out_last),
        .out_index_base(core16_dct8_out_index_base),
        .out_data_0(core16_dct8_out_data_0),
        .out_data_1(core16_dct8_out_data_1),
        .out_data_2(core16_dct8_out_data_2),
        .out_data_3(core16_dct8_out_data_3),
        .done(core16_dct8_done),
        .busy()
    );

    assign sel_out_valid =
        (mode_r == MODE_4X4_DCT2)   ? core4_out_valid :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_out_valid :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_out_valid :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_out_valid :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_out_valid :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_out_valid :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_out_valid :
                                       1'b0;

    assign sel_done =
        (mode_r == MODE_4X4_DCT2)   ? core4_done :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_done :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_done :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_done :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_done :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_done :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_done :
                                       1'b0;

    assign sel_out_data_0 =
        (mode_r == MODE_4X4_DCT2)   ? core4_out_data_0 :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_out_data_0 :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_out_data_0 :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_out_data_0 :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_out_data_0 :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_out_data_0 :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_out_data_0 :
                                       64'sd0;

    assign sel_out_data_1 =
        (mode_r == MODE_4X4_DCT2)   ? core4_out_data_1 :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_out_data_1 :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_out_data_1 :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_out_data_1 :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_out_data_1 :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_out_data_1 :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_out_data_1 :
                                       64'sd0;

    assign sel_out_data_2 =
        (mode_r == MODE_4X4_DCT2)   ? core4_out_data_2 :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_out_data_2 :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_out_data_2 :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_out_data_2 :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_out_data_2 :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_out_data_2 :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_out_data_2 :
                                       64'sd0;

    assign sel_out_data_3 =
        (mode_r == MODE_4X4_DCT2)   ? core4_out_data_3 :
        (mode_r == MODE_8X8_DCT2)   ? core8_dct2_out_data_3 :
        (mode_r == MODE_8X8_DST7)   ? core8_dst7_out_data_3 :
        (mode_r == MODE_8X8_DCT8)   ? core8_dct8_out_data_3 :
        (mode_r == MODE_16X16_DCT2) ? core16_dct2_out_data_3 :
        (mode_r == MODE_16X16_DST7) ? core16_dst7_out_data_3 :
        (mode_r == MODE_16X16_DCT8) ? core16_dct8_out_data_3 :
                                       64'sd0;

    always @(*) begin
        it_data_out[9:0]   = pack_lane10(sel_out_data_0);
        it_data_out[19:10] = pack_lane10(sel_out_data_1);
        it_data_out[29:20] = pack_lane10(sel_out_data_2);
        it_data_out[39:30] = pack_lane10(sel_out_data_3);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r <= S_IDLE;
            mode_r <= MODE_UNSUPPORTED;
            tu_width_r <= 7'd0;
            tu_height_r <= 7'd0;
            tr_type_hor_r <= 2'd0;
            tr_type_ver_r <= 2'd0;
            lfnst_tr_set_idx_r <= 2'd0;
            lfnst_idx_r <= 2'd0;
            for (idx = 0; idx < 256; idx = idx + 1) begin
                tu_buf_r[idx] <= '0;
            end
        end else begin
            case (state_r)
                S_IDLE: begin
                    if (it_info_vld) begin
                        mode_r <= decode_mode(tu_width_w, tu_height_w, tr_hor_w, tr_ver_w, lfnst_idx_w);
                        tu_width_r <= tu_width_w;
                        tu_height_r <= tu_height_w;
                        tr_type_hor_r <= tr_hor_w;
                        tr_type_ver_r <= tr_ver_w;
                        lfnst_tr_set_idx_r <= lfnst_set_w;
                        lfnst_idx_r <= lfnst_idx_w;
                        for (idx = 0; idx < 256; idx = idx + 1) begin
                            tu_buf_r[idx] <= '0;
                        end
                        state_r <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    if (it_data_in_vld && (it_data_addr < coeff_count(mode_r))) begin
                        tu_buf_r[it_data_addr] <= it_data_in;
                    end

                    if (it_data_end) begin
                        if (mode_r == MODE_UNSUPPORTED) begin
                            state_r <= S_UNSUP_DONE;
                        end else begin
                            state_r <= S_START;
                        end
                    end
                end

                S_START: begin
                    state_r <= S_RUN;
                end

                S_RUN: begin
                    if (sel_done) begin
                        state_r <= S_IDLE;
                    end
                end

                S_UNSUP_DONE: begin
                    state_r <= S_IDLE;
                end

                default: begin
                    state_r <= S_IDLE;
                end
            endcase
        end
    end

endmodule
