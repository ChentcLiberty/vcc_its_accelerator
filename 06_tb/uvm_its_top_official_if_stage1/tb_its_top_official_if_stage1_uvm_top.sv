module tb_its_top_official_if_stage1_uvm_top;

    import uvm_pkg::*;
    import its_top_official_if_stage1_uvm_pkg::*;

    logic clk;

    its_top_official_if_stage1_if itf(.clk(clk));

    its_top_official_if_stage1 #(
        .LFNST_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/lfnst_tables.memh"),
        .IDCT_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/idct2_tables.memh"),
        .ITS_MEM_FILE("/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/05_rtl/its_1d_tables.memh")
    ) dut (
        .clk(itf.clk),
        .rst_n(itf.rst_n),
        .it_info(itf.it_info),
        .it_info_vld(itf.it_info_vld),
        .it_data_in(itf.it_data_in),
        .it_data_addr(itf.it_data_addr),
        .it_data_in_vld(itf.it_data_in_vld),
        .it_data_end(itf.it_data_end),
        .it_data_in_req(itf.it_data_in_req),
        .it_data_out(itf.it_data_out),
        .it_data_out_vld(itf.it_data_out_vld),
        .it_data_out_req(itf.it_data_out_req),
        .it_done(itf.it_done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        itf.rst_n = 1'b0;
        repeat (5) @(posedge clk);
        itf.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual its_top_official_if_stage1_if)::set(
            null,
            "*",
            "vif",
            itf
        );
        run_test("its_top_stage1_test");
    end

endmodule
