package its_top_official_if_stage1_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam string EXP_4X4_LFNST_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_4x4_lfnst_expected.txt";
    localparam string EXP_8X8_DCT2_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_8x8_dct2_expected.txt";
    localparam string EXP_8X8_DST7_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_8x8_dst7_expected.txt";
    localparam string EXP_8X8_DCT8_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_8x8_dct8_expected.txt";
    localparam string EXP_8X8_DCT2_SPARSE_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_8x8_dct2_sparse_expected.txt";
    localparam string EXP_8X8_DST7_SPARSE_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_8x8_dst7_sparse_expected.txt";
    localparam string EXP_16X16_DCT2_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_16x16_dct2_expected.txt";
    localparam string EXP_16X16_DST7_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_16x16_dst7_expected.txt";
    localparam string EXP_16X16_DCT8_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_16x16_dct8_expected.txt";
    localparam string EXP_16X16_DCT8_SPARSE_FILE =
        "/mnt/hgfs/wdchenaic/比赛/华为杯/02_题1_VVC_ITS/06_tb/data/official_if_stage1_16x16_dct8_sparse_expected.txt";

    class its_top_stage1_case extends uvm_sequence_item;
        string case_name;
        bit [21:0] info;
        int signed input_values[];
        int unsigned input_addrs[];
        int signed expected[];
        bit expect_output;
        int stall_groups[];
        int done_timeout_cycles;

        `uvm_object_utils_begin(its_top_stage1_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(info, UVM_DEFAULT)
            `uvm_field_array_int(input_values, UVM_DEFAULT)
            `uvm_field_array_int(input_addrs, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(expect_output, UVM_DEFAULT)
            `uvm_field_array_int(stall_groups, UVM_DEFAULT)
            `uvm_field_int(done_timeout_cycles, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_top_stage1_case");
            super.new(name);
            expect_output = 1'b1;
            stall_groups = new[0];
            done_timeout_cycles = 64;
        endfunction

        function int unsigned coeff_count();
            return input_values.size();
        endfunction

        function int unsigned group_count();
            return expected.size() / 4;
        endfunction
    endclass

    class its_top_stage1_output_sample extends uvm_sequence_item;
        int signed data[];

        `uvm_object_utils_begin(its_top_stage1_output_sample)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_top_stage1_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class its_top_stage1_sequencer extends uvm_sequencer #(its_top_stage1_case);
        `uvm_component_utils(its_top_stage1_sequencer)
        function new(string name = "its_top_stage1_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    function automatic int signed signext10(input bit [9:0] raw);
        bit signed [9:0] tmp;
        begin
            tmp = raw;
            return tmp;
        end
    endfunction

    function automatic void load_expected_file(input string path, output int signed values[]);
        int fd;
        int rc;
        int signed value;
        int signed tmp_q[$];

        fd = $fopen(path, "r");
        if (fd == 0) begin
            `uvm_fatal("FILE", $sformatf("Failed to open expected file: %s", path))
        end

        while (!$feof(fd)) begin
            rc = $fscanf(fd, "%d\n", value);
            if (rc == 1) begin
                tmp_q.push_back(value);
            end else if (rc == 0) begin
                void'($fgetc(fd));
            end
        end
        $fclose(fd);

        values = new[tmp_q.size()];
        foreach (tmp_q[i]) begin
            values[i] = tmp_q[i];
        end
    endfunction

    function automatic void fill_dense_input(
        input int count,
        output int signed values[],
        output int unsigned addrs[]
    );
        values = new[count];
        addrs = new[count];
        for (int i = 0; i < count; i++) begin
            values[i] = i + 1;
            addrs[i] = i;
        end
    endfunction

    function automatic void fill_sparse_input(
        input int signed sparse_values[],
        input int unsigned sparse_addrs[],
        output int signed values[],
        output int unsigned addrs[]
    );
        values = new[sparse_values.size()];
        addrs = new[sparse_addrs.size()];
        foreach (sparse_values[i]) begin
            values[i] = sparse_values[i];
            addrs[i] = sparse_addrs[i];
        end
    endfunction

    function automatic its_top_stage1_case build_4x4_lfnst_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_4x4_lfnst");
            c.case_name = "case_4x4_lfnst";
            c.info = {2'd1, 2'd0, 2'd0, 2'd0, 7'd4, 7'd4};
            fill_dense_input(16, c.input_values, c.input_addrs);
            load_expected_file(EXP_4X4_LFNST_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 32;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_8x8_dct8_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_8x8_dct8");
            c.case_name = "case_8x8_dct8";
            c.info = {2'd0, 2'd0, 2'd2, 2'd2, 7'd8, 7'd8};
            fill_dense_input(64, c.input_values, c.input_addrs);
            load_expected_file(EXP_8X8_DCT8_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 64;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_8x8_dct2_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_8x8_dct2");
            c.case_name = "case_8x8_dct2";
            c.info = {2'd0, 2'd0, 2'd0, 2'd0, 7'd8, 7'd8};
            fill_dense_input(64, c.input_values, c.input_addrs);
            load_expected_file(EXP_8X8_DCT2_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 64;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_8x8_dst7_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_8x8_dst7");
            c.case_name = "case_8x8_dst7";
            c.info = {2'd0, 2'd0, 2'd1, 2'd1, 7'd8, 7'd8};
            fill_dense_input(64, c.input_values, c.input_addrs);
            load_expected_file(EXP_8X8_DST7_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 64;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_16x16_dct8_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_16x16_dct8");
            c.case_name = "case_16x16_dct8";
            c.info = {2'd0, 2'd0, 2'd2, 2'd2, 7'd16, 7'd16};
            fill_dense_input(256, c.input_values, c.input_addrs);
            load_expected_file(EXP_16X16_DCT8_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.stall_groups = new[1];
            c.stall_groups[0] = 9;
            c.done_timeout_cycles = 160;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_16x16_dct2_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_16x16_dct2");
            c.case_name = "case_16x16_dct2";
            c.info = {2'd0, 2'd0, 2'd0, 2'd0, 7'd16, 7'd16};
            fill_dense_input(256, c.input_values, c.input_addrs);
            load_expected_file(EXP_16X16_DCT2_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 160;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_16x16_dst7_case();
        its_top_stage1_case c;
        int signed expected[];
        begin
            c = its_top_stage1_case::type_id::create("case_16x16_dst7");
            c.case_name = "case_16x16_dst7";
            c.info = {2'd0, 2'd0, 2'd1, 2'd1, 7'd16, 7'd16};
            fill_dense_input(256, c.input_values, c.input_addrs);
            load_expected_file(EXP_16X16_DST7_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 160;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_unsupported_case();
        its_top_stage1_case c;
        begin
            c = its_top_stage1_case::type_id::create("case_unsupported");
            c.case_name = "case_unsupported";
            c.info = {2'd0, 2'd0, 2'd0, 2'd0, 7'd16, 7'd8};
            fill_dense_input(4, c.input_values, c.input_addrs);
            c.expect_output = 1'b0;
            c.expected = new[0];
            c.done_timeout_cycles = 24;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_8x8_dct2_sparse_case();
        its_top_stage1_case c;
        int signed expected[];
        int signed sparse_values[];
        int unsigned sparse_addrs[];
        begin
            c = its_top_stage1_case::type_id::create("case_8x8_dct2_sparse");
            c.case_name = "case_8x8_dct2_sparse";
            c.info = {2'd0, 2'd0, 2'd0, 2'd0, 7'd8, 7'd8};
            sparse_values = new[8];
            sparse_addrs = new[8];
            sparse_values = '{17, -11, 29, -7, 5, -13, 9, -3};
            sparse_addrs = '{9, 0, 63, 18, 1, 45, 27, 8};
            fill_sparse_input(sparse_values, sparse_addrs, c.input_values, c.input_addrs);
            load_expected_file(EXP_8X8_DCT2_SPARSE_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.done_timeout_cycles = 64;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_8x8_dst7_sparse_case();
        its_top_stage1_case c;
        int signed expected[];
        int signed sparse_values[];
        int unsigned sparse_addrs[];
        begin
            c = its_top_stage1_case::type_id::create("case_8x8_dst7_sparse");
            c.case_name = "case_8x8_dst7_sparse";
            c.info = {2'd0, 2'd0, 2'd1, 2'd1, 7'd8, 7'd8};
            sparse_values = new[8];
            sparse_addrs = new[8];
            sparse_values = '{12, -4, 19, -15, 6, -8, 21, -5};
            sparse_addrs = '{54, 7, 14, 28, 35, 42, 56, 3};
            fill_sparse_input(sparse_values, sparse_addrs, c.input_values, c.input_addrs);
            load_expected_file(EXP_8X8_DST7_SPARSE_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.stall_groups = new[2];
            c.stall_groups[0] = 3;
            c.stall_groups[1] = 9;
            c.done_timeout_cycles = 64;
            return c;
        end
    endfunction

    function automatic its_top_stage1_case build_16x16_dct8_sparse_case();
        its_top_stage1_case c;
        int signed expected[];
        int signed sparse_values[];
        int unsigned sparse_addrs[];
        begin
            c = its_top_stage1_case::type_id::create("case_16x16_dct8_sparse");
            c.case_name = "case_16x16_dct8_sparse";
            c.info = {2'd0, 2'd0, 2'd2, 2'd2, 7'd16, 7'd16};
            sparse_values = new[12];
            sparse_addrs = new[12];
            sparse_values = '{31, -17, 9, -6, 15, -12, 7, -10, 13, -3, 11, -14};
            sparse_addrs = '{255, 0, 18, 35, 68, 85, 119, 136, 171, 188, 204, 221};
            fill_sparse_input(sparse_values, sparse_addrs, c.input_values, c.input_addrs);
            load_expected_file(EXP_16X16_DCT8_SPARSE_FILE, expected);
            c.expected = new[expected.size()];
            foreach (expected[i]) c.expected[i] = expected[i];
            c.stall_groups = new[3];
            c.stall_groups[0] = 4;
            c.stall_groups[1] = 17;
            c.stall_groups[2] = 33;
            c.done_timeout_cycles = 160;
            return c;
        end
    endfunction

    class its_top_stage1_driver extends uvm_driver #(its_top_stage1_case);
        `uvm_component_utils(its_top_stage1_driver)

        virtual its_top_official_if_stage1_if vif;
        uvm_analysis_port #(its_top_stage1_case) exp_ap;

        function new(string name = "its_top_stage1_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_top_official_if_stage1_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_top_stage1_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.it_info <= '0;
            vif.it_info_vld <= 1'b0;
            vif.it_data_in <= '0;
            vif.it_data_addr <= '0;
            vif.it_data_in_vld <= 1'b0;
            vif.it_data_end <= 1'b0;
            vif.it_data_out_req <= 1'b1;
        endtask

        task run_phase(uvm_phase phase);
            its_top_stage1_case req;

            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(its_top_stage1_case req);
            its_top_stage1_case exp_case;
            int unsigned consumed_groups;
            int wait_cycles;
            int stall_idx;
            bit done_seen;

            @(posedge vif.clk);
            vif.it_info <= req.info;
            vif.it_info_vld <= 1'b1;
            @(posedge vif.clk);
            vif.it_info_vld <= 1'b0;

            for (int i = 0; i < req.coeff_count(); i++) begin
                while (vif.it_data_in_req !== 1'b1) begin
                    @(posedge vif.clk);
                end
                @(posedge vif.clk);
                vif.it_data_in <= req.input_values[i];
                vif.it_data_addr <= req.input_addrs[i][11:0];
                vif.it_data_in_vld <= 1'b1;
                vif.it_data_end <= (i == (req.coeff_count() - 1));
                @(posedge vif.clk);
                vif.it_data_in_vld <= 1'b0;
                vif.it_data_end <= 1'b0;
            end

            $cast(exp_case, req.clone());
            exp_ap.write(exp_case);

            if (req.expect_output) begin
                consumed_groups = 0;
                stall_idx = 0;
                while (consumed_groups < req.group_count()) begin
                    @(posedge vif.clk);
                    if (vif.it_data_out_vld && vif.it_data_out_req) begin
                        consumed_groups++;
                        if ((stall_idx < req.stall_groups.size()) &&
                            (consumed_groups == req.stall_groups[stall_idx])) begin
                            vif.it_data_out_req <= 1'b0;
                            @(posedge vif.clk);
                            if (vif.it_data_out_vld !== 1'b0) begin
                                `uvm_error(
                                    "ITS_TOP_DRV",
                                    $sformatf("case %s asserted out_vld while out_req=0",
                                              req.case_name)
                                )
                            end
                            vif.it_data_out_req <= 1'b1;
                            stall_idx++;
                        end
                    end
                end
            end

            done_seen = 1'b0;
            for (wait_cycles = 0; wait_cycles < req.done_timeout_cycles; wait_cycles++) begin
                @(posedge vif.clk);
                if (!req.expect_output && vif.it_data_out_vld) begin
                    `uvm_error(
                        "ITS_TOP_DRV",
                        $sformatf("case %s produced output while unsupported", req.case_name)
                    )
                end
                if (vif.it_done) begin
                    done_seen = 1'b1;
                    break;
                end
            end

            if (!done_seen) begin
                `uvm_error(
                    "ITS_TOP_DRV",
                    $sformatf("case %s did not raise done in time", req.case_name)
                )
            end

            vif.it_data_out_req <= 1'b1;
        endtask
    endclass

    class its_top_stage1_monitor extends uvm_component;
        `uvm_component_utils(its_top_stage1_monitor)

        virtual its_top_official_if_stage1_if vif;
        uvm_analysis_port #(its_top_stage1_output_sample) ap;

        function new(string name = "its_top_stage1_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_top_official_if_stage1_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_top_stage1_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            its_top_stage1_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.it_data_out_vld && vif.it_data_out_req) begin
                    sample = its_top_stage1_output_sample::type_id::create("sample");
                    sample.data[0] = signext10(vif.it_data_out[9:0]);
                    sample.data[1] = signext10(vif.it_data_out[19:10]);
                    sample.data[2] = signext10(vif.it_data_out[29:20]);
                    sample.data[3] = signext10(vif.it_data_out[39:30]);
                    ap.write(sample);
                end
            end
        endtask
    endclass

    class its_top_stage1_scoreboard extends uvm_component;
        `uvm_component_utils(its_top_stage1_scoreboard)

        uvm_tlm_analysis_fifo #(its_top_stage1_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(its_top_stage1_output_sample) act_fifo;

        function new(string name = "its_top_stage1_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_top_stage1_case exp_case;
            its_top_stage1_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned base_idx;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("ITS_TOP_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                if (!exp_case.expect_output) begin
                    continue;
                end

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    base_idx = group_idx * 4;
                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[base_idx + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "ITS_TOP_SB",
                                $sformatf(
                                    "case %s idx %0d got %0d exp %0d",
                                    exp_case.case_name,
                                    base_idx + lane_idx,
                                    act_sample.data[lane_idx],
                                    expected_value
                                )
                            )
                        end
                    end
                end
            end
        endtask
    endclass

    class its_top_stage1_agent extends uvm_component;
        `uvm_component_utils(its_top_stage1_agent)

        its_top_stage1_sequencer seqr;
        its_top_stage1_driver    drv;
        its_top_stage1_monitor   mon;

        function new(string name = "its_top_stage1_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = its_top_stage1_sequencer::type_id::create("seqr", this);
            drv  = its_top_stage1_driver::type_id::create("drv", this);
            mon  = its_top_stage1_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class its_top_stage1_env extends uvm_component;
        `uvm_component_utils(its_top_stage1_env)

        its_top_stage1_agent      agent;
        its_top_stage1_scoreboard sb;

        function new(string name = "its_top_stage1_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = its_top_stage1_agent::type_id::create("agent", this);
            sb    = its_top_stage1_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class its_top_stage1_sequence extends uvm_sequence #(its_top_stage1_case);
        `uvm_object_utils(its_top_stage1_sequence)

        function new(string name = "its_top_stage1_sequence");
            super.new(name);
        endfunction

        task send_case(its_top_stage1_case c);
            start_item(c);
            finish_item(c);
        endtask

        task body();
            send_case(build_4x4_lfnst_case());
            send_case(build_8x8_dct2_case());
            send_case(build_8x8_dst7_case());
            send_case(build_8x8_dct8_case());
            send_case(build_8x8_dct2_sparse_case());
            send_case(build_8x8_dst7_sparse_case());
            send_case(build_16x16_dct2_case());
            send_case(build_16x16_dst7_case());
            send_case(build_16x16_dct8_case());
            send_case(build_16x16_dct8_sparse_case());
            send_case(build_unsupported_case());
        endtask
    endclass

    class its_top_stage1_test extends uvm_test;
        `uvm_component_utils(its_top_stage1_test)

        its_top_stage1_env env;

        function new(string name = "its_top_stage1_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = its_top_stage1_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_top_stage1_sequence seq;
            phase.raise_objection(this);
            seq = its_top_stage1_sequence::type_id::create("seq");
            seq.start(env.agent.seqr);
            #200ns;
            phase.drop_objection(this);
        endtask
    endclass

endpackage
