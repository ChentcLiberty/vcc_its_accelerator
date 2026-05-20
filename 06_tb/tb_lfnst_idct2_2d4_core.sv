module tb_lfnst_idct2_2d4_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;

    reg clk;
    reg rst_n;
    reg start;
    reg [1:0] lfnst_tr_set_idx;
    reg [1:0] lfnst_idx;
    reg out_req;
    reg signed [DATA_W-1:0] x_bar [0:15];

    wire in_ready;
    wire out_valid;
    wire out_last;
    wire [5:0] out_row_base;
    wire signed [OUT_W-1:0] out_data_0;
    wire signed [OUT_W-1:0] out_data_1;
    wire signed [OUT_W-1:0] out_data_2;
    wire signed [OUT_W-1:0] out_data_3;
    wire done;
    wire busy;

    integer group_idx;
    integer error_count;

    reg signed [OUT_W-1:0] expected_bypass [0:15];
    reg signed [OUT_W-1:0] expected_lfnst  [0:15];

    lfnst_idct2_2d4_core #(
        .LFNST_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh"),
        .IDCT_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_ready(in_ready),
        .lfnst_tr_set_idx(lfnst_tr_set_idx),
        .lfnst_idx(lfnst_idx),
        .x_bar_0(x_bar[0]),
        .x_bar_1(x_bar[1]),
        .x_bar_2(x_bar[2]),
        .x_bar_3(x_bar[3]),
        .x_bar_4(x_bar[4]),
        .x_bar_5(x_bar[5]),
        .x_bar_6(x_bar[6]),
        .x_bar_7(x_bar[7]),
        .x_bar_8(x_bar[8]),
        .x_bar_9(x_bar[9]),
        .x_bar_10(x_bar[10]),
        .x_bar_11(x_bar[11]),
        .x_bar_12(x_bar[12]),
        .x_bar_13(x_bar[13]),
        .x_bar_14(x_bar[14]),
        .x_bar_15(x_bar[15]),
        .out_req(out_req),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_row_base(out_row_base),
        .out_data_0(out_data_0),
        .out_data_1(out_data_1),
        .out_data_2(out_data_2),
        .out_data_3(out_data_3),
        .done(done),
        .busy(busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic load_demo_xbar;
        begin
            x_bar[0]  = 16'sd1;
            x_bar[1]  = 16'sd5;
            x_bar[2]  = 16'sd2;
            x_bar[3]  = 16'sd9;
            x_bar[4]  = 16'sd6;
            x_bar[5]  = 16'sd3;
            x_bar[6]  = 16'sd13;
            x_bar[7]  = 16'sd10;
            x_bar[8]  = 16'sd7;
            x_bar[9]  = 16'sd4;
            x_bar[10] = 16'sd14;
            x_bar[11] = 16'sd11;
            x_bar[12] = 16'sd8;
            x_bar[13] = 16'sd15;
            x_bar[14] = 16'sd12;
            x_bar[15] = 16'sd16;
        end
    endtask

    task automatic init_expected_blocks;
        begin
            expected_bypass[0]  = 64'sd557056;
            expected_bypass[1]  = -64'sd72960;
            expected_bypass[2]  = 64'sd0;
            expected_bypass[3]  = -64'sd6400;
            expected_bypass[4]  = -64'sd291840;
            expected_bypass[5]  = 64'sd0;
            expected_bypass[6]  = 64'sd0;
            expected_bypass[7]  = 64'sd0;
            expected_bypass[8]  = 64'sd0;
            expected_bypass[9]  = 64'sd0;
            expected_bypass[10] = 64'sd0;
            expected_bypass[11] = 64'sd0;
            expected_bypass[12] = -64'sd25600;
            expected_bypass[13] = 64'sd0;
            expected_bypass[14] = 64'sd0;
            expected_bypass[15] = 64'sd0;

            expected_lfnst[0]  = -64'sd77824;
            expected_lfnst[1]  = 64'sd96512;
            expected_lfnst[2]  = 64'sd61440;
            expected_lfnst[3]  = 64'sd10304;
            expected_lfnst[4]  = -64'sd55424;
            expected_lfnst[5]  = -64'sd50700;
            expected_lfnst[6]  = -64'sd118144;
            expected_lfnst[7]  = -64'sd142300;
            expected_lfnst[8]  = 64'sd61440;
            expected_lfnst[9]  = 64'sd18176;
            expected_lfnst[10] = -64'sd45056;
            expected_lfnst[11] = 64'sd190912;
            expected_lfnst[12] = -64'sd17728;
            expected_lfnst[13] = 64'sd21400;
            expected_lfnst[14] = 64'sd68672;
            expected_lfnst[15] = -64'sd72075;
        end
    endtask

    task automatic check_group_against_block(
        input integer base_idx,
        input reg signed [OUT_W-1:0] expected [0:15]
    );
        begin
            if (out_data_0 !== expected[base_idx + 0]) begin
                $display("ERR row %0d got %0d exp %0d", base_idx + 0, out_data_0, expected[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected[base_idx + 1]) begin
                $display("ERR row %0d got %0d exp %0d", base_idx + 1, out_data_1, expected[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected[base_idx + 2]) begin
                $display("ERR row %0d got %0d exp %0d", base_idx + 2, out_data_2, expected[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected[base_idx + 3]) begin
                $display("ERR row %0d got %0d exp %0d", base_idx + 3, out_data_3, expected[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case(
        input [1:0] case_lfnst_idx,
        input reg signed [OUT_W-1:0] expected [0:15]
    );
        begin
            @(posedge clk);
            lfnst_tr_set_idx <= 2'd0;
            lfnst_idx        <= case_lfnst_idx;
            start            <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 4; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                if (out_row_base !== (group_idx * 4)) begin
                    $display("ERR row_base got %0d exp %0d", out_row_base, group_idx * 4);
                    error_count = error_count + 1;
                end

                check_group_against_block(group_idx * 4, expected);
            end

            wait(done === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        lfnst_tr_set_idx = 2'd0;
        lfnst_idx = 2'd0;
        out_req = 1'b1;
        error_count = 0;
        load_demo_xbar();
        init_expected_blocks();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case(2'd0, expected_bypass);
        run_case(2'd1, expected_lfnst);

        if (error_count != 0) begin
            $display("FAIL tb_lfnst_idct2_2d4_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_lfnst_idct2_2d4_core");
        $finish;
    end

endmodule
