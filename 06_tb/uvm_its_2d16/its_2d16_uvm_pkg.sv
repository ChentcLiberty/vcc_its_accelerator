package its_2d16_uvm_pkg;

    import uvm_pkg::*;
    import its_2d16_uvm_common_pkg::*;
    `include "uvm_macros.svh"

    localparam string FULL_MEM =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d16_dct8_full_expected.memh";
    localparam string SPARSE_MEM =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/its_2d16_dct8_sparse_expected.memh";

    class its_2d16_dct8_smoke_seq extends its_2d16_smoke_seq_base;
        `uvm_object_utils(its_2d16_dct8_smoke_seq)

        function new(string name = "its_2d16_dct8_smoke_seq");
            super.new(name);
        endfunction

        task body();
            int signed exp_full [0:255];
            int signed exp_sparse [0:255];

            load_expected_mem(FULL_MEM, SPARSE_MEM, exp_full, exp_sparse);
            send_case(build_case("full16_case", 16, 16, 8, exp_full));
            send_case(build_case("sparse8_case", 8, 8, -1, exp_sparse));
        endtask
    endclass

    class its_2d16_uvm_test extends its_2d16_uvm_test_base;
        `uvm_component_utils(its_2d16_uvm_test)

        function new(string name = "its_2d16_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function uvm_sequence_base create_seq();
            return its_2d16_dct8_smoke_seq::type_id::create("seq");
        endfunction
    endclass

endpackage
