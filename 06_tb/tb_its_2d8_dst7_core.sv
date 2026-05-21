module tb_its_2d8_dst7_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;
    localparam int TR_DST7 = 1;

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] non_zero_cols;
    reg [6:0] non_zero_rows;
    reg out_req;
    reg signed [DATA_W-1:0] x_in [0:63];

    wire in_ready;
    wire out_valid;
    wire out_last;
    wire [6:0] out_index_base;
    wire signed [OUT_W-1:0] out_data_0;
    wire signed [OUT_W-1:0] out_data_1;
    wire signed [OUT_W-1:0] out_data_2;
    wire signed [OUT_W-1:0] out_data_3;
    wire done;
    wire busy;

    reg signed [OUT_W-1:0] expected [0:63];
    reg signed [OUT_W-1:0] hold_0;
    reg signed [OUT_W-1:0] hold_1;
    reg signed [OUT_W-1:0] hold_2;
    reg signed [OUT_W-1:0] hold_3;

    integer idx;
    integer group_idx;
    integer error_count;
    integer base_idx_i;

    its_2d8_core #(
        .ROW_TR_TYPE(TR_DST7),
        .COL_TR_TYPE(TR_DST7),
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_ready(in_ready),
        .non_zero_cols(non_zero_cols),
        .non_zero_rows(non_zero_rows),
        .x_in(x_in),
        .out_req(out_req),
        .out_valid(out_valid),
        .out_last(out_last),
        .out_index_base(out_index_base),
        .out_data_0(out_data_0),
        .out_data_1(out_data_1),
        .out_data_2(out_data_2),
        .out_data_3(out_data_3),
        .done(done),
        .busy(busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic load_demo_matrix;
        begin
            for (idx = 0; idx < 64; idx = idx + 1) begin
                x_in[idx] = idx + 1;
            end
        end
    endtask

    task automatic clear_expected;
        begin
            for (idx = 0; idx < 64; idx = idx + 1) begin
                expected[idx] = 0;
            end
        end
    endtask

    task automatic set_expected_full8;
        begin
            clear_expected();
            expected[0]  = 64'sd9160375;
            expected[1]  = 64'sd2383170;
            expected[2]  = 64'sd1571870;
            expected[3]  = 64'sd925490;
            expected[4]  = 64'sd629090;
            expected[5]  = 64'sd368885;
            expected[6]  = 64'sd362045;
            expected[7]  = 64'sd110865;
            expected[8]  = -64'sd1318885;
            expected[9]  = -64'sd587390;
            expected[10] = -64'sd310866;
            expected[11] = -64'sd213502;
            expected[12] = -64'sd129582;
            expected[13] = -64'sd87599;
            expected[14] = -64'sd71959;
            expected[15] = -64'sd27107;
            expected[16] = 64'sd290415;
            expected[17] = -64'sd8998;
            expected[18] = 64'sd20566;
            expected[19] = 64'sd1562;
            expected[20] = 64'sd6442;
            expected[21] = -64'sd243;
            expected[22] = 64'sd4613;
            expected[23] = -64'sd343;
            expected[24] = -64'sd290795;
            expected[25] = -64'sd155906;
            expected[26] = -64'sd77678;
            expected[27] = -64'sd55746;
            expected[28] = -64'sd32786;
            expected[29] = -64'sd23041;
            expected[30] = -64'sd18009;
            expected[31] = -64'sd7181;
            expected[32] = 64'sd37905;
            expected[33] = -64'sd29146;
            expected[34] = -64'sd6998;
            expected[35] = -64'sd8986;
            expected[36] = -64'sd3626;
            expected[37] = -64'sd3981;
            expected[38] = -64'sd1669;
            expected[39] = -64'sd1321;
            expected[40] = -64'sd153805;
            expected[41] = -64'sd74502;
            expected[42] = -64'sd38330;
            expected[43] = -64'sd26870;
            expected[44] = -64'sd16070;
            expected[45] = -64'sd11063;
            expected[46] = -64'sd8879;
            expected[47] = -64'sd3435;
            expected[48] = 64'sd61465;
            expected[49] = -64'sd3842;
            expected[50] = 64'sd3682;
            expected[51] = -64'sd306;
            expected[52] = 64'sd1054;
            expected[53] = -64'sd325;
            expected[54] = 64'sd819;
            expected[55] = -64'sd161;
            expected[56] = -64'sd58045;
            expected[57] = -64'sd26246;
            expected[58] = -64'sd13818;
            expected[59] = -64'sd9526;
            expected[60] = -64'sd5766;
            expected[61] = -64'sd3911;
            expected[62] = -64'sd3199;
            expected[63] = -64'sd1211;
        end
    endtask

    task automatic set_expected_sparse4;
        begin
            clear_expected();
            expected[0]  = 64'sd448105;
            expected[1]  = 64'sd798712;
            expected[2]  = 64'sd369059;
            expected[3]  = -64'sd65849;
            expected[4]  = 64'sd27287;
            expected[5]  = 64'sd217275;
            expected[6]  = 64'sd73211;
            expected[7]  = -64'sd118242;
            expected[8]  = 64'sd703099;
            expected[9]  = 64'sd1249888;
            expected[10] = 64'sd568961;
            expected[11] = -64'sd114443;
            expected[12] = 64'sd38189;
            expected[13] = 64'sd341025;
            expected[14] = 64'sd112985;
            expected[15] = -64'sd188982;
            expected[16] = 64'sd78818;
            expected[17] = 64'sd130376;
            expected[18] = 64'sd34222;
            expected[19] = -64'sd45346;
            expected[20] = -64'sd9242;
            expected[21] = 64'sd38550;
            expected[22] = 64'sd7150;
            expected[23] = -64'sd31284;
            expected[24] = -64'sd385133;
            expected[25] = -64'sd697592;
            expected[26] = -64'sd350959;
            expected[27] = 64'sd19453;
            expected[28] = -64'sd38899;
            expected[29] = -64'sd186375;
            expected[30] = -64'sd69223;
            expected[31] = 64'sd90090;
            expected[32] = -64'sd105496;
            expected[33] = -64'sd192664;
            expected[34] = -64'sd100928;
            expected[35] = 64'sd56;
            expected[36] = -64'sd12848;
            expected[37] = -64'sd51000;
            expected[38] = -64'sd19856;
            expected[39] = 64'sd23040;
            expected[40] = 64'sd220425;
            expected[41] = 64'sd393000;
            expected[42] = 64'sd181875;
            expected[43] = -64'sd32025;
            expected[44] = 64'sd13575;
            expected[45] = 64'sd106875;
            expected[46] = 64'sd36075;
            expected[47] = -64'sd58050;
            expected[48] = 64'sd19052;
            expected[49] = 64'sd32072;
            expected[50] = 64'sd9964;
            expected[51] = -64'sd9100;
            expected[52] = -64'sd1460;
            expected[53] = 64'sd9300;
            expected[54] = 64'sd2044;
            expected[55] = -64'sd6984;
            expected[56] = -64'sd217404;
            expected[57] = -64'sd390960;
            expected[58] = -64'sd189540;
            expected[59] = 64'sd20412;
            expected[60] = -64'sd18036;
            expected[61] = -64'sd105300;
            expected[62] = -64'sd37476;
            expected[63] = 64'sd53784;
        end
    endtask

    task automatic check_group(input integer base_idx);
        begin
            if (out_data_0 !== expected[base_idx + 0]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected[base_idx + 0]);
                error_count = error_count + 1;
            end
            if (out_data_1 !== expected[base_idx + 1]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected[base_idx + 1]);
                error_count = error_count + 1;
            end
            if (out_data_2 !== expected[base_idx + 2]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected[base_idx + 2]);
                error_count = error_count + 1;
            end
            if (out_data_3 !== expected[base_idx + 3]) begin
                $display("ERR idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected[base_idx + 3]);
                error_count = error_count + 1;
            end
        end
    endtask

    task automatic run_case(
        input [6:0] nz_cols_cfg,
        input [6:0] nz_rows_cfg,
        input integer stall_group_idx
    );
        begin
            wait (in_ready === 1'b1);
            non_zero_cols <= nz_cols_cfg;
            non_zero_rows <= nz_rows_cfg;

            @(posedge clk);
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < 16; group_idx = group_idx + 1) begin
                @(posedge clk);
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                base_idx_i = group_idx * 4;
                if (out_index_base !== base_idx_i[6:0]) begin
                    $display("ERR base got %0d exp %0d", out_index_base, base_idx_i);
                    error_count = error_count + 1;
                end
                if (out_last !== (group_idx == 15)) begin
                    $display("ERR out_last at group %0d", group_idx);
                    error_count = error_count + 1;
                end
                check_group(base_idx_i);

                if (stall_group_idx >= 0 && group_idx == stall_group_idx) begin
                    out_req <= 1'b0;
                    @(posedge clk);
                    if (out_valid !== 1'b1) begin
                        $display("ERR out_valid dropped during stall");
                        error_count = error_count + 1;
                    end
                    hold_0 = out_data_0;
                    hold_1 = out_data_1;
                    hold_2 = out_data_2;
                    hold_3 = out_data_3;
                    @(posedge clk);
                    if (out_valid !== 1'b1 ||
                        out_data_0 !== hold_0 ||
                        out_data_1 !== hold_1 ||
                        out_data_2 !== hold_2 ||
                        out_data_3 !== hold_3) begin
                        $display("ERR out hold mismatch during stall");
                        error_count = error_count + 1;
                    end
                    out_req <= 1'b1;
                end
            end

            wait (done === 1'b1);
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        non_zero_cols = 7'd8;
        non_zero_rows = 7'd8;
        out_req = 1'b1;
        error_count = 0;

        load_demo_matrix();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        set_expected_full8();
        run_case(7'd8, 7'd8, 3);

        set_expected_sparse4();
        run_case(7'd4, 7'd4, -1);

        if (error_count != 0) begin
            $display("FAIL tb_its_2d8_dst7_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_2d8_dst7_core");
        $finish;
    end

endmodule
