module tb_idct2_1d_uvm_top;

    import uvm_pkg::*;
    import idct2_1d_uvm_pkg::*;

    logic clk;

    idct2_1d_if tb_if(.clk(clk));

    idct2_1d_core #(
        .MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh")
    ) dut (
        .clk           (clk),
        .rst_n         (tb_if.rst_n),
        .start         (tb_if.start),
        .in_ready      (tb_if.in_ready),
        .n_tbs         (tb_if.n_tbs),
        .non_zero_size (tb_if.non_zero_size),
        .x_0           (tb_if.x_vec[0]),
        .x_1           (tb_if.x_vec[1]),
        .x_2           (tb_if.x_vec[2]),
        .x_3           (tb_if.x_vec[3]),
        .x_4           (tb_if.x_vec[4]),
        .x_5           (tb_if.x_vec[5]),
        .x_6           (tb_if.x_vec[6]),
        .x_7           (tb_if.x_vec[7]),
        .x_8           (tb_if.x_vec[8]),
        .x_9           (tb_if.x_vec[9]),
        .x_10          (tb_if.x_vec[10]),
        .x_11          (tb_if.x_vec[11]),
        .x_12          (tb_if.x_vec[12]),
        .x_13          (tb_if.x_vec[13]),
        .x_14          (tb_if.x_vec[14]),
        .x_15          (tb_if.x_vec[15]),
        .x_16          (tb_if.x_vec[16]),
        .x_17          (tb_if.x_vec[17]),
        .x_18          (tb_if.x_vec[18]),
        .x_19          (tb_if.x_vec[19]),
        .x_20          (tb_if.x_vec[20]),
        .x_21          (tb_if.x_vec[21]),
        .x_22          (tb_if.x_vec[22]),
        .x_23          (tb_if.x_vec[23]),
        .x_24          (tb_if.x_vec[24]),
        .x_25          (tb_if.x_vec[25]),
        .x_26          (tb_if.x_vec[26]),
        .x_27          (tb_if.x_vec[27]),
        .x_28          (tb_if.x_vec[28]),
        .x_29          (tb_if.x_vec[29]),
        .x_30          (tb_if.x_vec[30]),
        .x_31          (tb_if.x_vec[31]),
        .x_32          (tb_if.x_vec[32]),
        .x_33          (tb_if.x_vec[33]),
        .x_34          (tb_if.x_vec[34]),
        .x_35          (tb_if.x_vec[35]),
        .x_36          (tb_if.x_vec[36]),
        .x_37          (tb_if.x_vec[37]),
        .x_38          (tb_if.x_vec[38]),
        .x_39          (tb_if.x_vec[39]),
        .x_40          (tb_if.x_vec[40]),
        .x_41          (tb_if.x_vec[41]),
        .x_42          (tb_if.x_vec[42]),
        .x_43          (tb_if.x_vec[43]),
        .x_44          (tb_if.x_vec[44]),
        .x_45          (tb_if.x_vec[45]),
        .x_46          (tb_if.x_vec[46]),
        .x_47          (tb_if.x_vec[47]),
        .x_48          (tb_if.x_vec[48]),
        .x_49          (tb_if.x_vec[49]),
        .x_50          (tb_if.x_vec[50]),
        .x_51          (tb_if.x_vec[51]),
        .x_52          (tb_if.x_vec[52]),
        .x_53          (tb_if.x_vec[53]),
        .x_54          (tb_if.x_vec[54]),
        .x_55          (tb_if.x_vec[55]),
        .x_56          (tb_if.x_vec[56]),
        .x_57          (tb_if.x_vec[57]),
        .x_58          (tb_if.x_vec[58]),
        .x_59          (tb_if.x_vec[59]),
        .x_60          (tb_if.x_vec[60]),
        .x_61          (tb_if.x_vec[61]),
        .x_62          (tb_if.x_vec[62]),
        .x_63          (tb_if.x_vec[63]),
        .out_req       (tb_if.out_req),
        .out_valid     (tb_if.out_valid),
        .out_last      (tb_if.out_last),
        .out_index_base(tb_if.out_index_base),
        .out_data_0    (tb_if.out_data_0),
        .out_data_1    (tb_if.out_data_1),
        .out_data_2    (tb_if.out_data_2),
        .out_data_3    (tb_if.out_data_3),
        .done          (tb_if.done),
        .busy          (tb_if.busy)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        tb_if.rst_n = 1'b0;
        tb_if.start = 1'b0;
        tb_if.n_tbs = '0;
        tb_if.non_zero_size = '0;
        tb_if.out_req = 1'b1;
        foreach (tb_if.x_vec[i]) begin
            tb_if.x_vec[i] = '0;
        end

        repeat (5) @(posedge clk);
        tb_if.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual idct2_1d_if)::set(null, "*", "vif", tb_if);
        run_test("idct2_1d_uvm_test");
    end

endmodule
