module tb_its_2d8_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 64;
    localparam int TR_DCT8 = 2;

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
        .ROW_TR_TYPE(TR_DCT8),
        .COL_TR_TYPE(TR_DCT8),
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
            expected[0]  = 64'sd5505250;
            expected[1]  = -64'sd2278955;
            expected[2]  = 64'sd1237755;
            expected[3]  = -64'sd834385;
            expected[4]  = 64'sd513285;
            expected[5]  = -64'sd341240;
            expected[6]  = 64'sd286330;
            expected[7]  = -64'sd105260;
            expected[8]  = -64'sd5981010;
            expected[9]  = 64'sd2069455;
            expected[10] = -64'sd1204031;
            expected[11] = 64'sd772957;
            expected[12] = -64'sd492737;
            expected[13] = 64'sd313344;
            expected[14] = -64'sd278074;
            expected[15] = 64'sd95812;
            expected[16] = 64'sd2519210;
            expected[17] = -64'sd902163;
            expected[18] = 64'sd517699;
            expected[19] = -64'sd335593;
            expected[20] = 64'sd212413;
            expected[21] = -64'sd136288;
            expected[22] = 64'sd119602;
            expected[23] = -64'sd41748;
            expected[24] = -64'sd2050670;
            expected[25] = 64'sd715361;
            expected[26] = -64'sd414833;
            expected[27] = 64'sd266931;
            expected[28] = -64'sd169871;
            expected[29] = 64'sd108256;
            expected[30] = -64'sd95814;
            expected[31] = 64'sd33116;
            expected[32] = 64'sd1104470;
            expected[33] = -64'sd392301;
            expected[34] = 64'sd225853;
            expected[35] = -64'sd146071;
            expected[36] = 64'sd92611;
            expected[37] = -64'sd59296;
            expected[38] = 64'sd52174;
            expected[39] = -64'sd18156;
            expected[40] = -64'sd863930;
            expected[41] = 64'sd300247;
            expected[42] = -64'sd174375;
            expected[43] = 64'sd112085;
            expected[44] = -64'sd71385;
            expected[45] = 64'sd45448;
            expected[46] = -64'sd40274;
            expected[47] = 64'sd13900;
            expected[48] = 64'sd586910;
            expected[49] = -64'sd209957;
            expected[50] = 64'sd120533;
            expected[51] = -64'sd78111;
            expected[52] = 64'sd49451;
            expected[53] = -64'sd31720;
            expected[54] = 64'sd27846;
            expected[55] = -64'sd9716;
            expected[56] = -64'sd274170;
            expected[57] = 64'sd94951;
            expected[58] = -64'sd55223;
            expected[59] = 64'sd35461;
            expected[60] = -64'sd22601;
            expected[61] = 64'sd14376;
            expected[62] = -64'sd12754;
            expected[63] = 64'sd4396;
        end
    endtask

    task automatic set_expected_sparse4;
        begin
            clear_expected();
            expected[0]  = 64'sd1409920;
            expected[1]  = 64'sd513120;
            expected[2]  = -64'sd317072;
            expected[3]  = -64'sd334528;
            expected[4]  = 64'sd105712;
            expected[5]  = 64'sd256064;
            expected[6]  = -64'sd42384;
            expected[7]  = -64'sd220816;
            expected[8]  = 64'sd95500;
            expected[9]  = 64'sd14560;
            expected[10] = -64'sd52744;
            expected[11] = -64'sd40446;
            expected[12] = 64'sd11624;
            expected[13] = 64'sd26468;
            expected[14] = -64'sd6778;
            expected[15] = -64'sd25572;
            expected[16] = -64'sd963634;
            expected[17] = -64'sd381968;
            expected[18] = 64'sd168300;
            expected[19] = 64'sd201101;
            expected[20] = -64'sd65340;
            expected[21] = -64'sd160886;
            expected[22] = 64'sd22919;
            expected[23] = 64'sd134486;
            expected[24] = -64'sd702336;
            expected[25] = -64'sd273392;
            expected[26] = 64'sd130408;
            expected[27] = 64'sd150976;
            expected[28] = -64'sd48728;
            expected[29] = -64'sd119520;
            expected[30] = 64'sd17672;
            expected[31] = 64'sd100648;
            expected[32] = 64'sd198014;
            expected[33] = 64'sd76528;
            expected[34] = -64'sd37620;
            expected[35] = -64'sd43051;
            expected[36] = 64'sd13860;
            expected[37] = 64'sd33946;
            expected[38] = -64'sd5089;
            expected[39] = -64'sd28666;
            expected[40] = 64'sd444728;
            expected[41] = 64'sd170976;
            expected[42] = -64'sd85888;
            expected[43] = -64'sd97484;
            expected[44] = 64'sd31328;
            expected[45] = 64'sd76648;
            expected[46] = -64'sd11604;
            expected[47] = -64'sd64856;
            expected[48] = -64'sd123178;
            expected[49] = -64'sd48736;
            expected[50] = 64'sd21652;
            expected[51] = 64'sd25785;
            expected[52] = -64'sd8372;
            expected[53] = -64'sd20606;
            expected[54] = 64'sd2947;
            expected[55] = 64'sd17238;
            expected[56] = -64'sd440322;
            expected[57] = -64'sd170864;
            expected[58] = 64'sd82588;
            expected[59] = 64'sd95125;
            expected[60] = -64'sd30668;
            expected[61] = -64'sd75174;
            expected[62] = 64'sd11183;
            expected[63] = 64'sd63382;
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
            $display("FAIL tb_its_2d8_core errors=%0d", error_count);
            $fatal;
        end

        $display("PASS tb_its_2d8_core");
        $finish;
    end

endmodule
