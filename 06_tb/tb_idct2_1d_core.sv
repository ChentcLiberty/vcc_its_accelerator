module tb_idct2_1d_core;

    localparam int DATA_W = 16;
    localparam int OUT_W  = 32;

    localparam int CASE_4  = 0;
    localparam int CASE_8  = 1;
    localparam int CASE_16 = 2;
    localparam int CASE_32 = 3;
    localparam int CASE_64 = 4;

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] n_tbs;
    reg [6:0] non_zero_size;
    reg out_req;

    reg signed [DATA_W-1:0] x_vec [0:63];

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

    reg signed [OUT_W-1:0] expected_4 [0:3];
    reg signed [OUT_W-1:0] expected_8 [0:7];
    reg signed [OUT_W-1:0] expected_16 [0:15];
    reg signed [OUT_W-1:0] expected_32 [0:31];
    reg signed [OUT_W-1:0] expected_64 [0:63];

    integer idx;
    integer group_idx;
    integer error_count;
    integer stall_base;

    reg signed [OUT_W-1:0] hold_0;
    reg signed [OUT_W-1:0] hold_1;
    reg signed [OUT_W-1:0] hold_2;
    reg signed [OUT_W-1:0] hold_3;

    idct2_1d_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .in_ready      (in_ready),
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

    task automatic init_expected_vectors;
        begin
            expected_4[0] = 32'sd640;
            expected_4[1] = -32'sd285;
            expected_4[2] = 32'sd0;
            expected_4[3] = -32'sd25;

            expected_8[0] = 32'sd2304;
            expected_8[1] = -32'sd1166;
            expected_8[2] = 32'sd0;
            expected_8[3] = -32'sd118;
            expected_8[4] = 32'sd0;
            expected_8[5] = -32'sd34;
            expected_8[6] = 32'sd0;
            expected_8[7] = -32'sd12;

            expected_16[0]  = 32'sd2304;
            expected_16[1]  = 32'sd1574;
            expected_16[2]  = -32'sd1166;
            expected_16[3]  = -32'sd1574;
            expected_16[4]  = 32'sd0;
            expected_16[5]  = 32'sd731;
            expected_16[6]  = -32'sd118;
            expected_16[7]  = -32'sd657;
            expected_16[8]  = 32'sd0;
            expected_16[9]  = 32'sd476;
            expected_16[10] = -32'sd34;
            expected_16[11] = -32'sd458;
            expected_16[12] = 32'sd0;
            expected_16[13] = 32'sd401;
            expected_16[14] = -32'sd12;
            expected_16[15] = -32'sd381;

            expected_32[0]  = 32'sd2304;
            expected_32[1]  = 32'sd2799;
            expected_32[2]  = 32'sd1574;
            expected_32[3]  = 32'sd76;
            expected_32[4]  = -32'sd1166;
            expected_32[5]  = -32'sd1753;
            expected_32[6]  = -32'sd1574;
            expected_32[7]  = -32'sd868;
            expected_32[8]  = 32'sd0;
            expected_32[9]  = 32'sd603;
            expected_32[10] = 32'sd731;
            expected_32[11] = 32'sd400;
            expected_32[12] = -32'sd118;
            expected_32[13] = -32'sd541;
            expected_32[14] = -32'sd657;
            expected_32[15] = -32'sd428;
            expected_32[16] = 32'sd0;
            expected_32[17] = 32'sd361;
            expected_32[18] = 32'sd476;
            expected_32[19] = 32'sd306;
            expected_32[20] = -32'sd34;
            expected_32[21] = -32'sd345;
            expected_32[22] = -32'sd458;
            expected_32[23] = -32'sd300;
            expected_32[24] = 32'sd0;
            expected_32[25] = 32'sd285;
            expected_32[26] = 32'sd401;
            expected_32[27] = 32'sd272;
            expected_32[28] = -32'sd12;
            expected_32[29] = -32'sd281;
            expected_32[30] = -32'sd381;
            expected_32[31] = -32'sd276;

            expected_64[0]  = 32'sd8704;
            expected_64[1]  = 32'sd10505;
            expected_64[2]  = 32'sd5820;
            expected_64[3]  = 32'sd51;
            expected_64[4]  = -32'sd4689;
            expected_64[5]  = -32'sd6874;
            expected_64[6]  = -32'sd6123;
            expected_64[7]  = -32'sd3323;
            expected_64[8]  = 32'sd0;
            expected_64[9]  = 32'sd2286;
            expected_64[10] = 32'sd2714;
            expected_64[11] = 32'sd1443;
            expected_64[12] = -32'sd513;
            expected_64[13] = -32'sd2064;
            expected_64[14] = -32'sd2423;
            expected_64[15] = -32'sd1503;
            expected_64[16] = 32'sd0;
            expected_64[17] = 32'sd1263;
            expected_64[18] = 32'sd1630;
            expected_64[19] = 32'sd1024;
            expected_64[20] = -32'sd187;
            expected_64[21] = -32'sd1185;
            expected_64[22] = -32'sd1497;
            expected_64[23] = -32'sd1002;
            expected_64[24] = 32'sd0;
            expected_64[25] = 32'sd917;
            expected_64[26] = 32'sd1220;
            expected_64[27] = 32'sd770;
            expected_64[28] = -32'sd73;
            expected_64[29] = -32'sd882;
            expected_64[30] = -32'sd1189;
            expected_64[31] = -32'sd751;
            expected_64[32] = 32'sd0;
            expected_64[33] = 32'sd706;
            expected_64[34] = 32'sd983;
            expected_64[35] = 32'sd642;
            expected_64[36] = -32'sd51;
            expected_64[37] = -32'sd737;
            expected_64[38] = -32'sd982;
            expected_64[39] = -32'sd652;
            expected_64[40] = 32'sd0;
            expected_64[41] = 32'sd622;
            expected_64[42] = 32'sd853;
            expected_64[43] = 32'sd569;
            expected_64[44] = -32'sd15;
            expected_64[45] = -32'sd630;
            expected_64[46] = -32'sd836;
            expected_64[47] = -32'sd610;
            expected_64[48] = 32'sd0;
            expected_64[49] = 32'sd577;
            expected_64[50] = 32'sd805;
            expected_64[51] = 32'sd549;
            expected_64[52] = 32'sd3;
            expected_64[53] = -32'sd556;
            expected_64[54] = -32'sd790;
            expected_64[55] = -32'sd541;
            expected_64[56] = 32'sd0;
            expected_64[57] = 32'sd513;
            expected_64[58] = 32'sd753;
            expected_64[59] = 32'sd538;
            expected_64[60] = -32'sd31;
            expected_64[61] = -32'sd542;
            expected_64[62] = -32'sd746;
            expected_64[63] = -32'sd535;
        end
    endtask

    task automatic check_group(input integer case_id, input integer base_idx);
        begin
            case (case_id)
                CASE_4: begin
                    if (out_data_0 !== expected_4[base_idx + 0]) begin
                        $display("ERR4 idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected_4[base_idx + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected_4[base_idx + 1]) begin
                        $display("ERR4 idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected_4[base_idx + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected_4[base_idx + 2]) begin
                        $display("ERR4 idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected_4[base_idx + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected_4[base_idx + 3]) begin
                        $display("ERR4 idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected_4[base_idx + 3]);
                        error_count = error_count + 1;
                    end
                end
                CASE_8: begin
                    if (out_data_0 !== expected_8[base_idx + 0]) begin
                        $display("ERR8 idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected_8[base_idx + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected_8[base_idx + 1]) begin
                        $display("ERR8 idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected_8[base_idx + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected_8[base_idx + 2]) begin
                        $display("ERR8 idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected_8[base_idx + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected_8[base_idx + 3]) begin
                        $display("ERR8 idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected_8[base_idx + 3]);
                        error_count = error_count + 1;
                    end
                end
                CASE_16: begin
                    if (out_data_0 !== expected_16[base_idx + 0]) begin
                        $display("ERR16 idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected_16[base_idx + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected_16[base_idx + 1]) begin
                        $display("ERR16 idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected_16[base_idx + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected_16[base_idx + 2]) begin
                        $display("ERR16 idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected_16[base_idx + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected_16[base_idx + 3]) begin
                        $display("ERR16 idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected_16[base_idx + 3]);
                        error_count = error_count + 1;
                    end
                end
                CASE_32: begin
                    if (out_data_0 !== expected_32[base_idx + 0]) begin
                        $display("ERR32 idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected_32[base_idx + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected_32[base_idx + 1]) begin
                        $display("ERR32 idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected_32[base_idx + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected_32[base_idx + 2]) begin
                        $display("ERR32 idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected_32[base_idx + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected_32[base_idx + 3]) begin
                        $display("ERR32 idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected_32[base_idx + 3]);
                        error_count = error_count + 1;
                    end
                end
                CASE_64: begin
                    if (out_data_0 !== expected_64[base_idx + 0]) begin
                        $display("ERR64 idx %0d got %0d exp %0d", base_idx + 0, out_data_0, expected_64[base_idx + 0]);
                        error_count = error_count + 1;
                    end
                    if (out_data_1 !== expected_64[base_idx + 1]) begin
                        $display("ERR64 idx %0d got %0d exp %0d", base_idx + 1, out_data_1, expected_64[base_idx + 1]);
                        error_count = error_count + 1;
                    end
                    if (out_data_2 !== expected_64[base_idx + 2]) begin
                        $display("ERR64 idx %0d got %0d exp %0d", base_idx + 2, out_data_2, expected_64[base_idx + 2]);
                        error_count = error_count + 1;
                    end
                    if (out_data_3 !== expected_64[base_idx + 3]) begin
                        $display("ERR64 idx %0d got %0d exp %0d", base_idx + 3, out_data_3, expected_64[base_idx + 3]);
                        error_count = error_count + 1;
                    end
                end
                default: begin
                    $display("ERR unknown case id %0d", case_id);
                    error_count = error_count + 1;
                end
            endcase
        end
    endtask

    task automatic run_case(
        input integer case_id,
        input [6:0] size_i,
        input [6:0] nz_i,
        input integer group_count
    );
        begin
            if (in_ready !== 1'b1) begin
                $display("ERR start while in_ready low for size %0d", size_i);
                error_count = error_count + 1;
            end

            @(posedge clk);
            n_tbs         <= size_i;
            non_zero_size <= nz_i;
            start         <= 1'b1;

            @(posedge clk);
            start <= 1'b0;

            for (group_idx = 0; group_idx < group_count; group_idx = group_idx + 1) begin
                while (out_valid !== 1'b1) begin
                    @(posedge clk);
                end

                if (group_idx == 1) begin
                    hold_0 = out_data_0;
                    hold_1 = out_data_1;
                    hold_2 = out_data_2;
                    hold_3 = out_data_3;
                    stall_base = out_index_base;
                    out_req = 1'b0;
                    @(posedge clk);
                    if (out_valid !== 1'b1) begin
                        $display("ERR hold out_valid dropped during stall, size %0d", size_i);
                        error_count = error_count + 1;
                    end
                    if (out_index_base !== stall_base) begin
                        $display("ERR hold index changed during stall, size %0d got %0d exp %0d", size_i, out_index_base, stall_base);
                        error_count = error_count + 1;
                    end
                    if ((out_data_0 !== hold_0) || (out_data_1 !== hold_1) ||
                        (out_data_2 !== hold_2) || (out_data_3 !== hold_3)) begin
                        $display("ERR hold data changed during stall, size %0d", size_i);
                        error_count = error_count + 1;
                    end
                    out_req = 1'b1;
                end

                if (out_index_base !== (group_idx * 4)) begin
                    $display("ERR size %0d group %0d out_index_base got %0d exp %0d",
                             size_i, group_idx, out_index_base, group_idx * 4);
                    error_count = error_count + 1;
                end

                if ((group_idx == (group_count - 1)) && (out_last !== 1'b1)) begin
                    $display("ERR size %0d last-group out_last not asserted", size_i);
                    error_count = error_count + 1;
                end
                if ((group_idx != (group_count - 1)) && (out_last !== 1'b0)) begin
                    $display("ERR size %0d non-last out_last asserted at group %0d", size_i, group_idx);
                    error_count = error_count + 1;
                end

                check_group(case_id, group_idx * 4);
                @(posedge clk);
            end

            wait(done === 1'b1);
            @(posedge clk);
            if (busy !== 1'b0) begin
                $display("ERR size %0d busy not cleared after done", size_i);
                error_count = error_count + 1;
            end
            if (in_ready !== 1'b1) begin
                $display("ERR size %0d in_ready not restored after done", size_i);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        init_expected_vectors();
        load_demo_xvec();

        start         = 1'b0;
        n_tbs         = 7'd0;
        non_zero_size = 7'd0;
        out_req       = 1'b1;
        rst_n         = 1'b0;
        error_count   = 0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case(CASE_4,  7'd4,  7'd4,  1);
        run_case(CASE_8,  7'd8,  7'd8,  2);
        run_case(CASE_16, 7'd16, 7'd8,  4);
        run_case(CASE_32, 7'd32, 7'd8,  8);
        run_case(CASE_64, 7'd64, 7'd16, 16);

        if (error_count != 0) begin
            $display("FAIL tb_idct2_1d_core errors=%0d", error_count);
            $fatal(1, "tb_idct2_1d_core failed");
        end

        $display("PASS tb_idct2_1d_core");
        $finish;
    end

endmodule
