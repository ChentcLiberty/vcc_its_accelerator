package lfnst_idct2_col4_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class lfnst_idct2_col4_case extends uvm_sequence_item;
        string case_name;
        int unsigned lfnst_tr_set_idx;
        int unsigned lfnst_idx;
        int signed x_bar[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(lfnst_idct2_col4_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(lfnst_tr_set_idx, UVM_DEFAULT)
            `uvm_field_int(lfnst_idx, UVM_DEFAULT)
            `uvm_field_array_int(x_bar, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "lfnst_idct2_col4_case");
            super.new(name);
            x_bar = new[16];
            expected = new[16];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return 4;
        endfunction
    endclass

    class lfnst_idct2_col4_output_sample extends uvm_sequence_item;
        int unsigned row_base;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(lfnst_idct2_col4_output_sample)
            `uvm_field_int(row_base, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "lfnst_idct2_col4_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class lfnst_idct2_col4_sequencer extends uvm_sequencer #(lfnst_idct2_col4_case);
        `uvm_component_utils(lfnst_idct2_col4_sequencer)
        function new(string name = "lfnst_idct2_col4_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class lfnst_idct2_col4_driver extends uvm_driver #(lfnst_idct2_col4_case);
        `uvm_component_utils(lfnst_idct2_col4_driver)

        virtual lfnst_idct2_col4_if vif;
        uvm_analysis_port #(lfnst_idct2_col4_case) exp_ap;

        function new(string name = "lfnst_idct2_col4_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual lfnst_idct2_col4_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "lfnst_idct2_col4_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.start <= 1'b0;
            vif.lfnst_tr_set_idx <= '0;
            vif.lfnst_idx <= '0;
            vif.out_req <= 1'b1;
            foreach (vif.x_bar[i]) begin
                vif.x_bar[i] <= '0;
            end
        endtask

        task run_phase(uvm_phase phase);
            lfnst_idct2_col4_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(lfnst_idct2_col4_case req);
            lfnst_idct2_col4_case exp_case;
            int unsigned consumed_groups;
            bit stalled_once;
            bit done_seen;

            wait (vif.in_ready === 1'b1);
            @(posedge vif.clk);
            vif.lfnst_tr_set_idx <= req.lfnst_tr_set_idx[1:0];
            vif.lfnst_idx <= req.lfnst_idx[1:0];
            foreach (vif.x_bar[i]) begin
                vif.x_bar[i] <= req.x_bar[i];
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
            repeat (6) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("CHAIN_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class lfnst_idct2_col4_monitor extends uvm_component;
        `uvm_component_utils(lfnst_idct2_col4_monitor)

        virtual lfnst_idct2_col4_if vif;
        uvm_analysis_port #(lfnst_idct2_col4_output_sample) ap;

        function new(string name = "lfnst_idct2_col4_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual lfnst_idct2_col4_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "lfnst_idct2_col4_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            lfnst_idct2_col4_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = lfnst_idct2_col4_output_sample::type_id::create("sample");
                    sample.row_base = vif.out_row_base;
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

    class lfnst_idct2_col4_scoreboard extends uvm_component;
        `uvm_component_utils(lfnst_idct2_col4_scoreboard)

        uvm_tlm_analysis_fifo #(lfnst_idct2_col4_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(lfnst_idct2_col4_output_sample) act_fifo;

        function new(string name = "lfnst_idct2_col4_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            lfnst_idct2_col4_case exp_case;
            lfnst_idct2_col4_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("CHAIN_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.row_base != expected_base) begin
                        `uvm_error(
                            "CHAIN_SB",
                            $sformatf("case %s row_base got %0d exp %0d",
                                      exp_case.case_name, act_sample.row_base, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "CHAIN_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "CHAIN_SB",
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

    class lfnst_idct2_col4_agent extends uvm_component;
        `uvm_component_utils(lfnst_idct2_col4_agent)

        lfnst_idct2_col4_sequencer seqr;
        lfnst_idct2_col4_driver    drv;
        lfnst_idct2_col4_monitor   mon;

        function new(string name = "lfnst_idct2_col4_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = lfnst_idct2_col4_sequencer::type_id::create("seqr", this);
            drv  = lfnst_idct2_col4_driver::type_id::create("drv", this);
            mon  = lfnst_idct2_col4_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class lfnst_idct2_col4_env extends uvm_component;
        `uvm_component_utils(lfnst_idct2_col4_env)

        lfnst_idct2_col4_agent      agent;
        lfnst_idct2_col4_scoreboard sb;

        function new(string name = "lfnst_idct2_col4_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = lfnst_idct2_col4_agent::type_id::create("agent", this);
            sb    = lfnst_idct2_col4_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class lfnst_idct2_col4_smoke_seq extends uvm_sequence #(lfnst_idct2_col4_case);
        `uvm_object_utils(lfnst_idct2_col4_smoke_seq)

        function new(string name = "lfnst_idct2_col4_smoke_seq");
            super.new(name);
        endfunction

        function lfnst_idct2_col4_case build_case(
            string       case_name,
            int unsigned lfnst_tr_set_idx,
            int unsigned lfnst_idx,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            lfnst_idct2_col4_case item;
            int signed demo_xbar[16] = '{1, 5, 2, 9, 6, 3, 13, 10, 7, 4, 14, 11, 8, 15, 12, 16};

            item = lfnst_idct2_col4_case::type_id::create(case_name);
            item.case_name = case_name;
            item.lfnst_tr_set_idx = lfnst_tr_set_idx;
            item.lfnst_idx = lfnst_idx;
            item.stall_after_group = stall_after_group;
            foreach (item.x_bar[i]) begin
                item.x_bar[i] = demo_xbar[i];
                item.expected[i] = exp_vals[i];
            end
            return item;
        endfunction

        task send_case(lfnst_idct2_col4_case item);
            start_item(item);
            finish_item(item);
        endtask

        task body();
            int signed exp_bypass[16] = '{
                1792, 2048, 2304, 2560,
                -1140, -1140, -1140, -1140,
                0, 0, 0, 0,
                -100, -100, -100, -100
            };
            int signed exp_lfnst[16] = '{
                448, -384, -704, -576,
                -1248, 855, -365, -108,
                576, -512, 1344, -448,
                149, 75, -750, 249
            };

            send_case(build_case("bypass_case", 0, 0, -1, exp_bypass));
            send_case(build_case("lfnst_enabled_case", 0, 1, 1, exp_lfnst));
        endtask
    endclass

    class lfnst_idct2_col4_uvm_test extends uvm_test;
        `uvm_component_utils(lfnst_idct2_col4_uvm_test)

        lfnst_idct2_col4_env env;

        function new(string name = "lfnst_idct2_col4_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = lfnst_idct2_col4_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            lfnst_idct2_col4_smoke_seq seq;
            phase.raise_objection(this);
            seq = lfnst_idct2_col4_smoke_seq::type_id::create("seq");
            seq.start(env.agent.seqr);
            repeat (20) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
