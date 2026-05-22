package its_2d16_uvm_common_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class its_2d16_case extends uvm_sequence_item;
        string case_name;
        int unsigned non_zero_cols;
        int unsigned non_zero_rows;
        int signed x_in[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(its_2d16_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(non_zero_cols, UVM_DEFAULT)
            `uvm_field_int(non_zero_rows, UVM_DEFAULT)
            `uvm_field_array_int(x_in, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_2d16_case");
            super.new(name);
            x_in = new[256];
            expected = new[256];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return 64;
        endfunction
    endclass

    class its_2d16_output_sample extends uvm_sequence_item;
        int unsigned base_idx;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(its_2d16_output_sample)
            `uvm_field_int(base_idx, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "its_2d16_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class its_2d16_sequencer extends uvm_sequencer #(its_2d16_case);
        `uvm_component_utils(its_2d16_sequencer)
        function new(string name = "its_2d16_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class its_2d16_driver extends uvm_driver #(its_2d16_case);
        `uvm_component_utils(its_2d16_driver)

        virtual its_2d16_if vif;
        uvm_analysis_port #(its_2d16_case) exp_ap;

        function new(string name = "its_2d16_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_2d16_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_2d16_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.start <= 1'b0;
            vif.non_zero_cols <= '0;
            vif.non_zero_rows <= '0;
            vif.out_req <= 1'b1;
            foreach (vif.x_in[i]) begin
                vif.x_in[i] <= '0;
            end
        endtask

        task run_phase(uvm_phase phase);
            its_2d16_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(its_2d16_case req);
            its_2d16_case exp_case;
            int unsigned consumed_groups;
            bit stalled_once;
            bit done_seen;

            wait (vif.in_ready === 1'b1);
            @(posedge vif.clk);
            vif.non_zero_cols <= req.non_zero_cols[6:0];
            vif.non_zero_rows <= req.non_zero_rows[6:0];
            foreach (vif.x_in[i]) begin
                vif.x_in[i] <= req.x_in[i];
            end
            vif.out_req <= 1'b1;
            vif.start <= 1'b1;

            $cast(exp_case, req.clone());
            exp_ap.write(exp_case);

            @(posedge vif.clk);
            vif.start <= 1'b0;

            consumed_groups = 0;
            stalled_once = 1'b0;
            while (consumed_groups < req.group_count()) begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    consumed_groups++;
                    if (!stalled_once && (req.stall_after_group >= 0) &&
                        (consumed_groups == req.stall_after_group)) begin
                        vif.out_req <= 1'b0;
                        @(posedge vif.clk);
                        vif.out_req <= 1'b1;
                        stalled_once = 1'b1;
                    end
                end
            end

            done_seen = 1'b0;
            repeat (16) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("ITS_2D16_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class its_2d16_monitor extends uvm_component;
        `uvm_component_utils(its_2d16_monitor)

        virtual its_2d16_if vif;
        uvm_analysis_port #(its_2d16_output_sample) ap;

        function new(string name = "its_2d16_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual its_2d16_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "its_2d16_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            its_2d16_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = its_2d16_output_sample::type_id::create("sample");
                    sample.base_idx = vif.out_index_base;
                    sample.out_last = vif.out_last;
                    sample.data[0] = vif.out_data_0;
                    sample.data[1] = vif.out_data_1;
                    sample.data[2] = vif.out_data_2;
                    sample.data[3] = vif.out_data_3;
                    ap.write(sample);
                end
            end
        endtask
    endclass

    class its_2d16_scoreboard extends uvm_component;
        `uvm_component_utils(its_2d16_scoreboard)

        uvm_tlm_analysis_fifo #(its_2d16_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(its_2d16_output_sample) act_fifo;

        function new(string name = "its_2d16_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            its_2d16_case exp_case;
            its_2d16_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("ITS_2D16_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.base_idx != expected_base) begin
                        `uvm_error(
                            "ITS_2D16_SB",
                            $sformatf("case %s base_idx got %0d exp %0d",
                                      exp_case.case_name, act_sample.base_idx, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "ITS_2D16_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "ITS_2D16_SB",
                                $sformatf(
                                    "case %s idx %0d got %0d exp %0d",
                                    exp_case.case_name,
                                    expected_base + lane_idx,
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

    class its_2d16_agent extends uvm_component;
        `uvm_component_utils(its_2d16_agent)

        its_2d16_sequencer seqr;
        its_2d16_driver    drv;
        its_2d16_monitor   mon;

        function new(string name = "its_2d16_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = its_2d16_sequencer::type_id::create("seqr", this);
            drv  = its_2d16_driver::type_id::create("drv", this);
            mon  = its_2d16_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class its_2d16_env extends uvm_component;
        `uvm_component_utils(its_2d16_env)

        its_2d16_agent      agent;
        its_2d16_scoreboard sb;

        function new(string name = "its_2d16_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = its_2d16_agent::type_id::create("agent", this);
            sb    = its_2d16_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class its_2d16_smoke_seq_base extends uvm_sequence #(its_2d16_case);
        `uvm_object_utils(its_2d16_smoke_seq_base)

        function new(string name = "its_2d16_smoke_seq_base");
            super.new(name);
        endfunction

        function its_2d16_case build_case(
            string       case_name,
            int unsigned non_zero_cols,
            int unsigned non_zero_rows,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            its_2d16_case item;

            item = its_2d16_case::type_id::create(case_name);
            item.case_name = case_name;
            item.non_zero_cols = non_zero_cols;
            item.non_zero_rows = non_zero_rows;
            item.stall_after_group = stall_after_group;
            foreach (item.x_in[i]) begin
                item.x_in[i] = i + 1;
                item.expected[i] = exp_vals[i];
            end
            return item;
        endfunction

        task automatic load_expected_mem(
            input string full_mem_path,
            input string sparse_mem_path,
            output int signed exp_full [0:255],
            output int signed exp_sparse [0:255]
        );
            logic signed [63:0] full_mem   [0:255];
            logic signed [63:0] sparse_mem [0:255];

            $readmemh(full_mem_path, full_mem);
            $readmemh(sparse_mem_path, sparse_mem);

            for (int i = 0; i < 256; i++) begin
                exp_full[i] = full_mem[i];
                exp_sparse[i] = sparse_mem[i];
            end
        endtask

        task send_case(its_2d16_case item);
            start_item(item);
            finish_item(item);
        endtask
    endclass

    class its_2d16_uvm_test_base extends uvm_test;
        `uvm_component_utils(its_2d16_uvm_test_base)

        its_2d16_env env;

        function new(string name = "its_2d16_uvm_test_base", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = its_2d16_env::type_id::create("env", this);
        endfunction

        virtual function uvm_sequence_base create_seq();
            return null;
        endfunction

        task run_phase(uvm_phase phase);
            uvm_sequence_base seq;
            phase.raise_objection(this);
            seq = create_seq();
            if (seq == null) begin
                `uvm_fatal("ITS_2D16_TEST", "create_seq returned null")
            end
            seq.start(env.agent.seqr);
            repeat (32) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
