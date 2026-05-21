module tb_its_1d_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 32;

    localparam [1:0] TR_DCT2 = 2'd0;
    localparam [1:0] TR_DST7 = 2'd1;
    localparam [1:0] TR_DCT8 = 2'd2;

    reg clk;
    reg rst_n;
    reg start;
    reg [1:0] tr_type;
    reg [6:0] n_tbs;
    reg [6:0] non_zero_size;
    reg out_req;

    reg signed [DATA_W-1:0] x_vec [0:63];
    reg signed [OUT_W-1:0] expected [0:63];

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

    integer idx;
    integer group_idx;
    integer error_count;
    integer lane_base;
    integer last_group_idx;

    reg signed [OUT_W-1:0] hold_0;
    reg signed [OUT_W-1:0] hold_1;
    reg signed [OUT_W-1:0] hold_2;
    reg signed [OUT_W-1:0] hold_3;

    its_1d_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .in_ready      (in_ready),
        .tr_type       (tr_type),
        .n_tbs         (n_tbs),
        .non_zero_size (non_zero_size),
        .x_0           (x_vec[0]),
        .x_1           (x_vec[1]),
        .x_2           (x_vec[2]),
        .x_3           (x_vec[3]),
        .x_4           (x_vec[4]),
        .x_5           (x_vec[5]),
        .x_6           (x_vec[6]),
        .x_7           (x_vec[7]),
        .x_8           (x_vec[8]),
        .x_9           (x_vec[9]),
        .x_10          (x_vec[10]),
        .x_11          (x_vec[11]),
        .x_12          (x_vec[12]),
        .x_13          (x_vec[13]),
        .x_14          (x_vec[14]),
        .x_15          (x_vec[15]),
        .x_16          (x_vec[16]),
        .x_17          (x_vec[17]),
        .x_18          (x_vec[18]),
        .x_19          (x_vec[19]),
        .x_20          (x_vec[20]),
        .x_21          (x_vec[21]),
        .x_22          (x_vec[22]),
        .x_23          (x_vec[23]),
        .x_24          (x_vec[24]),
        .x_25          (x_vec[25]),
        .x_26          (x_vec[26]),
        .x_27          (x_vec[27]),
        .x_28          (x_vec[28]),
        .x_29          (x_vec[29]),
        .x_30          (x_vec[30]),
        .x_31          (x_vec[31]),
        .x_32          (x_vec[32]),
        .x_33          (x_vec[33]),
        .x_34          (x_vec[34]),
        .x_35          (x_vec[35]),
        .x_36          (x_vec[36]),
        .x_37          (x_vec[37]),
        .x_38          (x_vec[38]),
        .x_39          (x_vec[39]),
        .x_40          (x_vec[40]),
        .x_41          (x_vec[41]),
        .x_42          (x_vec[42]),
        .x_43          (x_vec[43]),
        .x_44          (x_vec[44]),
        .x_45          (x_vec[45]),
        .x_46          (x_vec[46]),
        .x_47          (x_vec[47]),
        .x_48          (x_vec[48]),
        .x_49          (x_vec[49]),
        .x_50          (x_vec[50]),
        .x_51          (x_vec[51]),
        .x_52          (x_vec[52]),
        .x_53          (x_vec[53]),
        .x_54          (x_vec[54]),
        .x_55          (x_vec[55]),
        .x_56          (x_vec[56]),
        .x_57          (x_vec[57]),
        .x_58          (x_vec[58]),
        .x_59          (x_vec[59]),
        .x_60          (x_vec[60]),
        .x_61          (x_vec[61]),
        .x_62          (x_vec[62]),
        .x_63          (x_vec[63]),
        .out_req       (out_req),
        .out_valid     (out_valid),
        .out_last      (out_last),
        .out_index_base(out_index_base),
        .out_data_0    (out_data_0),
        .out_data_1    (out_data_1),
        .out_data_2    (out_data_2),
        .out_data_3    (out_data_3),
        .done          (done),
        .busy          (busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic load_demo_xvec;
        begin
            for (idx = 0; idx < 64; idx = idx + 1) begin
                x_vec[idx] = idx + 1;
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

    task automatic set_expected_case;
        input [1:0] tr_type_cfg;
        input [6:0] size_cfg;
        input [6:0] nz_cfg;
        begin
            clear_expected();
            case ({tr_type_cfg, size_cfg, nz_cfg})
                {TR_DCT2, 7'd8, 7'd4}: begin
                    expected[0] = 32'sd640;
                    expected[1] = 32'sd461;
                    expected[2] = -32'sd285;
                    expected[3] = -32'sd428;
                    expected[4] = 32'sd0;
                    expected[5] = 32'sd226;
                    expected[6] = -32'sd25;
                    expected[7] = -32'sd213;
                end
                {TR_DCT8, 7'd8, 7'd8}: begin
                    expected[0] = 32'sd1710;
                    expected[1] = -32'sd1657;
                    expected[2] = 32'sd713;
                    expected[3] = -32'sd571;
                    expected[4] = 32'sd311;
                    expected[5] = -32'sd240;
                    expected[6] = 32'sd166;
                    expected[7] = -32'sd76;
                end
                {TR_DST7, 7'd8, 7'd8}: begin
                    expected[0] = 32'sd2565;
                    expected[1] = -32'sd298;
                    expected[2] = 32'sd106;
                    expected[3] = -32'sd58;
                    expected[4] = 32'sd22;
                    expected[5] = -32'sd33;
                    expected[6] = 32'sd23;
                    expected[7] = -32'sd13;
                end
                {TR_DCT8, 7'd32, 7'd32}: begin
                    expected[0]  = 32'sd22898;
                    expected[1]  = -32'sd24679;
                    expected[2]  = 32'sd10675;
                    expected[3]  = -32'sd9456;
                    expected[4]  = 32'sd6173;
                    expected[5]  = -32'sd5804;
                    expected[6]  = 32'sd4331;
                    expected[7]  = -32'sd4064;
                    expected[8]  = 32'sd3311;
                    expected[9]  = -32'sd3077;
                    expected[10] = 32'sd2565;
                    expected[11] = -32'sd2488;
                    expected[12] = 32'sd2117;
                    expected[13] = -32'sd1934;
                    expected[14] = 32'sd1795;
                    expected[15] = -32'sd1712;
                    expected[16] = 32'sd1393;
                    expected[17] = -32'sd1347;
                    expected[18] = 32'sd1238;
                    expected[19] = -32'sd1077;
                    expected[20] = 32'sd957;
                    expected[21] = -32'sd885;
                    expected[22] = 32'sd776;
                    expected[23] = -32'sd697;
                    expected[24] = 32'sd606;
                    expected[25] = -32'sd531;
                    expected[26] = 32'sd469;
                    expected[27] = -32'sd397;
                    expected[28] = 32'sd317;
                    expected[29] = -32'sd268;
                    expected[30] = 32'sd143;
                    expected[31] = -32'sd94;
                end
                {TR_DST7, 7'd32, 7'd32}: begin
                    expected[0]  = 32'sd38416;
                    expected[1]  = -32'sd4285;
                    expected[2]  = 32'sd1535;
                    expected[3]  = -32'sd744;
                    expected[4]  = 32'sd427;
                    expected[5]  = -32'sd260;
                    expected[6]  = 32'sd223;
                    expected[7]  = -32'sd170;
                    expected[8]  = 32'sd121;
                    expected[9]  = -32'sd41;
                    expected[10] = 32'sd9;
                    expected[11] = -32'sd46;
                    expected[12] = 32'sd61;
                    expected[13] = -32'sd86;
                    expected[14] = 32'sd53;
                    expected[15] = 32'sd4;
                    expected[16] = -32'sd7;
                    expected[17] = -32'sd27;
                    expected[18] = 32'sd82;
                    expected[19] = -32'sd21;
                    expected[20] = -32'sd33;
                    expected[21] = -32'sd27;
                    expected[22] = 32'sd16;
                    expected[23] = -32'sd37;
                    expected[24] = 32'sd54;
                    expected[25] = -32'sd3;
                    expected[26] = -32'sd7;
                    expected[27] = -32'sd1;
                    expected[28] = 32'sd79;
                    expected[29] = -32'sd4;
                    expected[30] = 32'sd55;
                    expected[31] = 32'sd38;
                end
                default: begin
                    $display("ERROR: missing expected vector tr=%0d size=%0d nz=%0d", tr_type_cfg, size_cfg, nz_cfg);
                    error_count = error_count + 1;
                end
            endcase
        end
    endtask

    task automatic pulse_start;
        begin
            @(posedge clk);
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;
        end
    endtask

    task automatic check_case;
        input [1:0]   tr_type_cfg;
        input [6:0]   size_cfg;
        input [6:0]   nz_cfg;
        input integer stall_group_idx;
        input [255:0] case_name;
        begin
            set_expected_case(tr_type_cfg, size_cfg, nz_cfg);
            wait (in_ready);
            tr_type <= tr_type_cfg;
            n_tbs <= size_cfg;
            non_zero_size <= nz_cfg;
            out_req <= 1'b1;
            pulse_start();

            group_idx = 0;
            last_group_idx = (size_cfg / 4) - 1;

            while (group_idx < (size_cfg / 4)) begin
                @(posedge clk);
                if (out_valid) begin
                    lane_base = group_idx * 4;

                    if (out_index_base !== lane_base[6:0]) begin
                        $display("ERROR %0s: base mismatch got=%0d exp=%0d", case_name, out_index_base, lane_base);
                        error_count = error_count + 1;
                    end
                    if (out_data_0 !== expected[lane_base + 0]) begin
                        $display("ERROR %0s: idx=%0d got=%0d exp=%0d", case_name, lane_base + 0, out_data_0, expected[lane_base + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected[lane_base + 1]) begin
                        $display("ERROR %0s: idx=%0d got=%0d exp=%0d", case_name, lane_base + 1, out_data_1, expected[lane_base + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected[lane_base + 2]) begin
                        $display("ERROR %0s: idx=%0d got=%0d exp=%0d", case_name, lane_base + 2, out_data_2, expected[lane_base + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected[lane_base + 3]) begin
                        $display("ERROR %0s: idx=%0d got=%0d exp=%0d", case_name, lane_base + 3, out_data_3, expected[lane_base + 3]);
                        error_count = error_count + 1;
                    end

                    if ((group_idx == last_group_idx) && !out_last) begin
                        $display("ERROR %0s: missing out_last on final group", case_name);
                        error_count = error_count + 1;
                    end
                    if ((group_idx != last_group_idx) && out_last) begin
                        $display("ERROR %0s: unexpected out_last before final group", case_name);
                        error_count = error_count + 1;
                    end

                    if (stall_group_idx >= 0 && group_idx == stall_group_idx) begin
                        out_req <= 1'b0;
                        @(posedge clk);
                        if (!out_valid) begin
                            $display("ERROR %0s: out_valid dropped while stalled", case_name);
                            error_count = error_count + 1;
                        end
                        hold_0 = out_data_0;
                        hold_1 = out_data_1;
                        hold_2 = out_data_2;
                        hold_3 = out_data_3;
                        @(posedge clk);
                        if (!out_valid) begin
                            $display("ERROR %0s: out_valid dropped on second stalled cycle", case_name);
                            error_count = error_count + 1;
                        end
                        if (out_data_0 !== hold_0 || out_data_1 !== hold_1 ||
                            out_data_2 !== hold_2 || out_data_3 !== hold_3) begin
                            $display("ERROR %0s: outputs changed while stalled", case_name);
                            error_count = error_count + 1;
                        end
                        out_req <= 1'b1;
                    end

                    group_idx = group_idx + 1;
                end
            end

            @(posedge clk);
            if (!done) begin
                $display("ERROR %0s: done not asserted in time", case_name);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        tr_type = TR_DCT2;
        n_tbs = 7'd0;
        non_zero_size = 7'd0;
        out_req = 1'b1;
        error_count = 0;

        load_demo_xvec();

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        check_case(TR_DCT2, 7'd8, 7'd4, -1, "dct2_8_sparse4");
        check_case(TR_DCT8, 7'd8, 7'd8, -1, "dct8_8_full");
        check_case(TR_DST7, 7'd8, 7'd8, 0, "dst7_8_full");
        check_case(TR_DCT8, 7'd32, 7'd32, -1, "dct8_32_full");
        check_case(TR_DST7, 7'd32, 7'd32, -1, "dst7_32_full");

        if (error_count == 0) begin
            $display("PASS tb_its_1d_core");
        end else begin
            $display("FAIL tb_its_1d_core error_count=%0d", error_count);
            $fatal(1);
        end

        $finish;
    end

endmodule
