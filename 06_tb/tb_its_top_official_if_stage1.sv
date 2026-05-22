module tb_its_top_official_if_stage1;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;
    localparam string DCT8_16_FULL_MEM = "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d16_dct8_full_expected.memh";

    reg clk;
    reg rst_n;
    reg [21:0] it_info;
    reg it_info_vld;
    reg signed [15:0] it_data_in;
    reg [11:0] it_data_addr;
    reg it_data_in_vld;
    reg it_data_end;
    wire it_data_in_req;
    wire [39:0] it_data_out;
    wire it_data_out_vld;
    reg  it_data_out_req;
    wire it_done;
    reg  it_done_seen;

    reg core4_start;
    reg [1:0] core4_lfnst_set;
    reg [1:0] core4_lfnst_idx;
    reg signed [15:0] core4_xbar [0:15];
    wire core4_in_ready;
    wire core4_out_valid;
    wire core4_out_last;
    wire [5:0] core4_out_row_base;
    wire signed [OUT_W-1:0] core4_out_data_0;
    wire signed [OUT_W-1:0] core4_out_data_1;
    wire signed [OUT_W-1:0] core4_out_data_2;
    wire signed [OUT_W-1:0] core4_out_data_3;
    wire core4_done;

    reg core8_start;
    reg [6:0] core8_non_zero_cols;
    reg [6:0] core8_non_zero_rows;
    reg signed [15:0] core8_xin [0:63];
    wire core8_in_ready;
    wire core8_out_valid;
    wire core8_out_last;
    wire [6:0] core8_out_index_base;
    wire signed [OUT_W-1:0] core8_out_data_0;
    wire signed [OUT_W-1:0] core8_out_data_1;
    wire signed [OUT_W-1:0] core8_out_data_2;
    wire signed [OUT_W-1:0] core8_out_data_3;
    wire core8_done;

    integer idx;
    integer error_count;
    integer group_idx;
    reg signed [OUT_W-1:0] expected16_full [0:255];

    its_top_official_if_stage1 #(
        .LFNST_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh"),
        .IDCT_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh"),
        .ITS_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .it_info(it_info),
        .it_info_vld(it_info_vld),
        .it_data_in(it_data_in),
        .it_data_addr(it_data_addr),
        .it_data_in_vld(it_data_in_vld),
        .it_data_end(it_data_end),
        .it_data_in_req(it_data_in_req),
        .it_data_out(it_data_out),
        .it_data_out_vld(it_data_out_vld),
        .it_data_out_req(it_data_out_req),
        .it_done(it_done)
    );

    lfnst_idct2_2d4_core #(
        .LFNST_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh"),
        .IDCT_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) ref4 (
        .clk(clk),
        .rst_n(rst_n),
        .start(core4_start),
        .in_ready(core4_in_ready),
        .lfnst_tr_set_idx(core4_lfnst_set),
        .lfnst_idx(core4_lfnst_idx),
        .x_bar_0(core4_xbar[0]),
        .x_bar_1(core4_xbar[1]),
        .x_bar_2(core4_xbar[2]),
        .x_bar_3(core4_xbar[3]),
        .x_bar_4(core4_xbar[4]),
        .x_bar_5(core4_xbar[5]),
        .x_bar_6(core4_xbar[6]),
        .x_bar_7(core4_xbar[7]),
        .x_bar_8(core4_xbar[8]),
        .x_bar_9(core4_xbar[9]),
        .x_bar_10(core4_xbar[10]),
        .x_bar_11(core4_xbar[11]),
        .x_bar_12(core4_xbar[12]),
        .x_bar_13(core4_xbar[13]),
        .x_bar_14(core4_xbar[14]),
        .x_bar_15(core4_xbar[15]),
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

    its_2d8_core #(
        .ROW_TR_TYPE(2),
        .COL_TR_TYPE(2),
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) ref8 (
        .clk(clk),
        .rst_n(rst_n),
        .start(core8_start),
        .in_ready(core8_in_ready),
        .non_zero_cols(core8_non_zero_cols),
        .non_zero_rows(core8_non_zero_rows),
        .x_in(core8_xin),
        .out_req(it_data_out_req),
        .out_valid(core8_out_valid),
        .out_last(core8_out_last),
        .out_index_base(core8_out_index_base),
        .out_data_0(core8_out_data_0),
        .out_data_1(core8_out_data_1),
        .out_data_2(core8_out_data_2),
        .out_data_3(core8_out_data_3),
        .done(core8_done),
        .busy()
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            it_done_seen <= 1'b0;
        end else if (it_done) begin
            it_done_seen <= 1'b1;
        end
    end

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

    function [39:0] pack4x10;
        input signed [63:0] d0;
        input signed [63:0] d1;
        input signed [63:0] d2;
        input signed [63:0] d3;
        begin
            pack4x10[9:0]   = pack_lane10(d0);
            pack4x10[19:10] = pack_lane10(d1);
            pack4x10[29:20] = pack_lane10(d2);
            pack4x10[39:30] = pack_lane10(d3);
        end
    endfunction

    task automatic clear_inputs;
        begin
            it_info = '0;
            it_info_vld = 1'b0;
            it_data_in = '0;
            it_data_addr = '0;
            it_data_in_vld = 1'b0;
            it_data_end = 1'b0;
            core4_start = 1'b0;
            core4_lfnst_set = 2'd0;
            core4_lfnst_idx = 2'd0;
            core8_start = 1'b0;
            core8_non_zero_cols = 7'd8;
            core8_non_zero_rows = 7'd8;
        end
    endtask

    task automatic load_demo_4x4_raster;
        begin
            for (idx = 0; idx < 16; idx = idx + 1) begin
                core4_xbar[idx] = '0;
            end
            for (idx = 0; idx < 16; idx = idx + 1) begin
                core4_xbar[idx] = lfnst_scan_addr_4x4(idx) + 1;
            end
        end
    endtask

    task automatic load_demo_8x8_raster;
        begin
            for (idx = 0; idx < 64; idx = idx + 1) begin
                core8_xin[idx] = idx + 1;
            end
        end
    endtask

    task automatic load_expected_mem;
        begin
            $readmemh(DCT8_16_FULL_MEM, expected16_full);
        end
    endtask

    task automatic send_info(input [21:0] info_v);
        begin
            @(posedge clk);
            it_info <= info_v;
            it_info_vld <= 1'b1;
            @(posedge clk);
            it_info_vld <= 1'b0;
        end
    endtask

    task automatic send_coeff(
        input signed [15:0] value_v,
        input [11:0] addr_v,
        input bit end_v
    );
        begin
            while (it_data_in_req !== 1'b1) begin
                @(posedge clk);
            end
            @(posedge clk);
            it_data_in <= value_v;
            it_data_addr <= addr_v;
            it_data_in_vld <= 1'b1;
            it_data_end <= end_v;
            @(posedge clk);
            it_data_in_vld <= 1'b0;
            it_data_end <= 1'b0;
        end
    endtask

    task automatic compare_top_group(
        input [39:0] exp_pack
    );
        begin
            while (it_data_out_vld !== 1'b1) begin
                @(posedge clk);
            end
            if (it_data_out !== exp_pack) begin
                $display("ERR top packed output got %h exp %h", it_data_out, exp_pack);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case_4x4_lfnst;
        reg [39:0] exp_pack;
        begin
            it_done_seen = 1'b0;
            load_demo_4x4_raster();
            core4_lfnst_set = 2'd0;
            core4_lfnst_idx = 2'd1;

            send_info({2'd1, 2'd0, 2'd0, 2'd0, 7'd4, 7'd4});
            for (idx = 0; idx < 16; idx = idx + 1) begin
                send_coeff(idx + 1, idx[11:0], (idx == 15));
            end

            core4_start <= 1'b1;
            @(posedge clk);
            core4_start <= 1'b0;

            for (group_idx = 0; group_idx < 4; group_idx = group_idx + 1) begin
                while (core4_out_valid !== 1'b1) begin
                    @(posedge clk);
                end
                exp_pack = pack4x10(
                    core4_out_data_0,
                    core4_out_data_1,
                    core4_out_data_2,
                    core4_out_data_3
                );
                compare_top_group(exp_pack);
                @(posedge clk);
            end

            wait (it_done_seen === 1'b1);
            @(posedge clk);
        end
    endtask

    task automatic run_case_8x8_dct8;
        reg [39:0] exp_pack;
        begin
            it_done_seen = 1'b0;
            load_demo_8x8_raster();
            core8_non_zero_cols = 7'd8;
            core8_non_zero_rows = 7'd8;

            send_info({2'd0, 2'd0, 2'd2, 2'd2, 7'd8, 7'd8});
            for (idx = 0; idx < 64; idx = idx + 1) begin
                send_coeff(idx + 1, idx[11:0], (idx == 63));
            end

            core8_start <= 1'b1;
            @(posedge clk);
            core8_start <= 1'b0;

            for (group_idx = 0; group_idx < 16; group_idx = group_idx + 1) begin
                while (core8_out_valid !== 1'b1) begin
                    @(posedge clk);
                end
                exp_pack = pack4x10(
                    core8_out_data_0,
                    core8_out_data_1,
                    core8_out_data_2,
                    core8_out_data_3
                );
                compare_top_group(exp_pack);
                @(posedge clk);
            end

            wait (it_done_seen === 1'b1);
            @(posedge clk);
        end
    endtask

    task automatic run_case_16x16_dct8_with_backpressure;
        reg [39:0] exp_pack;
        integer accepted_groups;
        begin
            it_done_seen = 1'b0;
            send_info({2'd0, 2'd0, 2'd2, 2'd2, 7'd16, 7'd16});
            for (idx = 0; idx < 256; idx = idx + 1) begin
                send_coeff(idx + 1, idx[11:0], (idx == 255));
            end

            accepted_groups = 0;
            while (accepted_groups < 64) begin
                @(posedge clk);
                if (it_data_out_vld === 1'b1) begin
                    exp_pack = pack4x10(
                        expected16_full[accepted_groups * 4 + 0],
                        expected16_full[accepted_groups * 4 + 1],
                        expected16_full[accepted_groups * 4 + 2],
                        expected16_full[accepted_groups * 4 + 3]
                    );
                    if (it_data_out !== exp_pack) begin
                        $display(
                            "ERR 16x16 top packed output group=%0d got %h exp %h",
                            accepted_groups,
                            it_data_out,
                            exp_pack
                        );
                        error_count = error_count + 1;
                    end

                    if (accepted_groups == 8) begin
                        it_data_out_req <= 1'b0;
                        @(posedge clk);
                        if (it_data_out_vld !== 1'b0) begin
                            $display("ERR top output valid asserted while out_req is low");
                            error_count = error_count + 1;
                        end
                        it_data_out_req <= 1'b1;
                    end

                    accepted_groups = accepted_groups + 1;
                end
            end

            wait (it_done_seen === 1'b1);
            @(posedge clk);
        end
    endtask

    task automatic run_case_unsupported_mode;
        integer wait_cycles;
        begin
            it_done_seen = 1'b0;
            send_info({2'd0, 2'd0, 2'd0, 2'd0, 7'd16, 7'd8});
            for (idx = 0; idx < 4; idx = idx + 1) begin
                send_coeff(idx + 1, idx[11:0], (idx == 3));
            end

            wait_cycles = 0;
            while ((it_done_seen !== 1'b1) && (wait_cycles < 16)) begin
                if (it_data_out_vld === 1'b1) begin
                    $display("ERR unsupported mode produced output");
                    error_count = error_count + 1;
                end
                wait_cycles = wait_cycles + 1;
                @(posedge clk);
            end

            if (it_done_seen !== 1'b1) begin
                $display("ERR unsupported mode did not raise done in time");
                error_count = error_count + 1;
            end

            @(posedge clk);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        error_count = 0;
        it_data_out_req = 1'b1;
        clear_inputs();
        load_expected_mem();
        for (idx = 0; idx < 16; idx = idx + 1) begin
            core4_xbar[idx] = '0;
        end
        for (idx = 0; idx < 64; idx = idx + 1) begin
            core8_xin[idx] = '0;
        end

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case_4x4_lfnst();
        run_case_8x8_dct8();
        run_case_16x16_dct8_with_backpressure();
        run_case_unsupported_mode();

        if (error_count != 0) begin
            $display("FAIL tb_its_top_official_if_stage1 errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_top_official_if_stage1");
        $finish;
    end

endmodule
