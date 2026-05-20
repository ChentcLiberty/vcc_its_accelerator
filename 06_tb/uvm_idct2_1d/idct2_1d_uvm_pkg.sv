package idct2_1d_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class idct2_1d_case extends uvm_sequence_item;
        string case_name;
        int unsigned n_tbs;
        int unsigned non_zero_size;
        int signed x_vec[];
        int signed expected[];
        int stall_after_group;

        `uvm_object_utils_begin(idct2_1d_case)
            `uvm_field_string(case_name, UVM_DEFAULT)
            `uvm_field_int(n_tbs, UVM_DEFAULT)
            `uvm_field_int(non_zero_size, UVM_DEFAULT)
            `uvm_field_array_int(x_vec, UVM_DEFAULT)
            `uvm_field_array_int(expected, UVM_DEFAULT)
            `uvm_field_int(stall_after_group, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "idct2_1d_case");
            super.new(name);
            x_vec = new[64];
            expected = new[0];
            stall_after_group = -1;
        endfunction

        function int unsigned group_count();
            return (n_tbs >> 2);
        endfunction
    endclass

    class idct2_1d_output_sample extends uvm_sequence_item;
        int unsigned base_idx;
        bit          out_last;
        int signed   data[];

        `uvm_object_utils_begin(idct2_1d_output_sample)
            `uvm_field_int(base_idx, UVM_DEFAULT)
            `uvm_field_int(out_last, UVM_DEFAULT)
            `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "idct2_1d_output_sample");
            super.new(name);
            data = new[4];
        endfunction
    endclass

    class idct2_1d_sequencer extends uvm_sequencer #(idct2_1d_case);
        `uvm_component_utils(idct2_1d_sequencer)
        function new(string name = "idct2_1d_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass

    class idct2_1d_driver extends uvm_driver #(idct2_1d_case);
        `uvm_component_utils(idct2_1d_driver)

        virtual idct2_1d_if vif;
        uvm_analysis_port #(idct2_1d_case) exp_ap;

        function new(string name = "idct2_1d_driver", uvm_component parent = null);
            super.new(name, parent);
            exp_ap = new("exp_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual idct2_1d_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "idct2_1d_driver failed to get virtual interface")
            end
        endfunction

        task init_signals();
            vif.start         <= 1'b0;
            vif.n_tbs         <= '0;
            vif.non_zero_size <= '0;
            vif.out_req       <= 1'b1;
            foreach (vif.x_vec[i]) begin
                vif.x_vec[i] <= '0;
            end
        endtask

        task run_phase(uvm_phase phase);
            idct2_1d_case req;
            init_signals();
            wait (vif.rst_n === 1'b1);

            forever begin
                seq_item_port.get_next_item(req);
                drive_case(req);
                seq_item_port.item_done();
            end
        endtask

        task drive_case(idct2_1d_case req);
            idct2_1d_case exp_case;
            int unsigned consumed_groups;
            bit stalled_once;
            bit done_seen;

            wait (vif.in_ready === 1'b1);
            @(posedge vif.clk);
            vif.n_tbs         <= req.n_tbs[6:0];
            vif.non_zero_size <= req.non_zero_size[6:0];
            foreach (vif.x_vec[i]) begin
                vif.x_vec[i] <= req.x_vec[i];
            end
            vif.out_req <= 1'b1;
            vif.start   <= 1'b1;

            $cast(exp_case, req.clone());
            exp_ap.write(exp_case);

            @(posedge vif.clk);
            vif.start <= 1'b0;

            consumed_groups = 0;
            stalled_once    = 1'b0;

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
            repeat (4) begin
                @(posedge vif.clk);
                if (vif.done) begin
                    done_seen = 1'b1;
                    break;
                end
            end
            if (!done_seen) begin
                `uvm_error("IDCT2_DRV", $sformatf("case %s did not raise done in time", req.case_name))
            end
        endtask
    endclass

    class idct2_1d_monitor extends uvm_component;
        `uvm_component_utils(idct2_1d_monitor)

        virtual idct2_1d_if vif;
        uvm_analysis_port #(idct2_1d_output_sample) ap;

        function new(string name = "idct2_1d_monitor", uvm_component parent = null);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual idct2_1d_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal("NOVIF", "idct2_1d_monitor failed to get virtual interface")
            end
        endfunction

        task run_phase(uvm_phase phase);
            idct2_1d_output_sample sample;
            wait (vif.rst_n === 1'b1);
            forever begin
                @(posedge vif.clk);
                if (vif.out_valid && vif.out_req) begin
                    sample = idct2_1d_output_sample::type_id::create("sample");
                    sample.base_idx = vif.out_index_base;
                    sample.out_last = vif.out_last;
                    sample.data[0]  = vif.out_data_0;
                    sample.data[1]  = vif.out_data_1;
                    sample.data[2]  = vif.out_data_2;
                    sample.data[3]  = vif.out_data_3;
                    ap.write(sample);
                end
            end
        endtask
    endclass

    class idct2_1d_scoreboard extends uvm_component;
        `uvm_component_utils(idct2_1d_scoreboard)

        uvm_tlm_analysis_fifo #(idct2_1d_case)          exp_fifo;
        uvm_tlm_analysis_fifo #(idct2_1d_output_sample) act_fifo;

        function new(string name = "idct2_1d_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            exp_fifo = new("exp_fifo", this);
            act_fifo = new("act_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            idct2_1d_case exp_case;
            idct2_1d_output_sample act_sample;
            int unsigned group_idx;
            int unsigned lane_idx;
            int unsigned expected_base;
            int signed expected_value;

            forever begin
                exp_fifo.get(exp_case);
                `uvm_info("IDCT2_SB", $sformatf("Checking case %s", exp_case.case_name), UVM_MEDIUM)

                for (group_idx = 0; group_idx < exp_case.group_count(); group_idx++) begin
                    act_fifo.get(act_sample);
                    expected_base = group_idx * 4;

                    if (act_sample.base_idx != expected_base) begin
                        `uvm_error(
                            "IDCT2_SB",
                            $sformatf("case %s base_idx got %0d exp %0d",
                                      exp_case.case_name, act_sample.base_idx, expected_base)
                        )
                    end

                    if (act_sample.out_last != (group_idx == (exp_case.group_count() - 1))) begin
                        `uvm_error(
                            "IDCT2_SB",
                            $sformatf("case %s out_last mismatch at group %0d",
                                      exp_case.case_name, group_idx)
                        )
                    end

                    for (lane_idx = 0; lane_idx < 4; lane_idx++) begin
                        expected_value = exp_case.expected[expected_base + lane_idx];
                        if (act_sample.data[lane_idx] != expected_value) begin
                            `uvm_error(
                                "IDCT2_SB",
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

    class idct2_1d_agent extends uvm_component;
        `uvm_component_utils(idct2_1d_agent)

        idct2_1d_sequencer seqr;
        idct2_1d_driver    drv;
        idct2_1d_monitor   mon;

        function new(string name = "idct2_1d_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seqr = idct2_1d_sequencer::type_id::create("seqr", this);
            drv  = idct2_1d_driver::type_id::create("drv", this);
            mon  = idct2_1d_monitor::type_id::create("mon", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
    endclass

    class idct2_1d_env extends uvm_component;
        `uvm_component_utils(idct2_1d_env)

        idct2_1d_agent      agent;
        idct2_1d_scoreboard sb;

        function new(string name = "idct2_1d_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = idct2_1d_agent::type_id::create("agent", this);
            sb    = idct2_1d_scoreboard::type_id::create("sb", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.drv.exp_ap.connect(sb.exp_fifo.analysis_export);
            agent.mon.ap.connect(sb.act_fifo.analysis_export);
        endfunction
    endclass

    class idct2_1d_smoke_seq extends uvm_sequence #(idct2_1d_case);
        `uvm_object_utils(idct2_1d_smoke_seq)

        function new(string name = "idct2_1d_smoke_seq");
            super.new(name);
        endfunction

        function idct2_1d_case build_case(
            string       case_name,
            int unsigned n_tbs,
            int unsigned non_zero_size,
            int          stall_after_group,
            int signed   exp_vals[]
        );
            idct2_1d_case item;
            item = idct2_1d_case::type_id::create(case_name);
            item.case_name = case_name;
            item.n_tbs = n_tbs;
            item.non_zero_size = non_zero_size;
            item.stall_after_group = stall_after_group;
            foreach (item.x_vec[i]) begin
                item.x_vec[i] = i + 1;
            end
            item.expected = new[n_tbs];
            foreach (item.expected[i]) begin
                item.expected[i] = exp_vals[i];
            end
            return item;
        endfunction

        task send_case(idct2_1d_case item);
            start_item(item);
            finish_item(item);
        endtask

        task body();
            int signed exp_4[] = '{
                640, -285, 0, -25
            };
            int signed exp_8[] = '{
                2304, -1166, 0, -118, 0, -34, 0, -12
            };
            int signed exp_16[] = '{
                2304, 1574, -1166, -1574, 0, 731, -118, -657,
                0, 476, -34, -458, 0, 401, -12, -381
            };
            int signed exp_32[] = '{
                2304, 2799, 1574, 76, -1166, -1753, -1574, -868,
                0, 603, 731, 400, -118, -541, -657, -428,
                0, 361, 476, 306, -34, -345, -458, -300,
                0, 285, 401, 272, -12, -281, -381, -276
            };
            int signed exp_64[] = '{
                8704, 10505, 5820, 51, -4689, -6874, -6123, -3323,
                0, 2286, 2714, 1443, -513, -2064, -2423, -1503,
                0, 1263, 1630, 1024, -187, -1185, -1497, -1002,
                0, 917, 1220, 770, -73, -882, -1189, -751,
                0, 706, 983, 642, -51, -737, -982, -652,
                0, 622, 853, 569, -15, -630, -836, -610,
                0, 577, 805, 549, 3, -556, -790, -541,
                0, 513, 753, 538, -31, -542, -746, -535
            };

            send_case(build_case("case_4", 4, 4, -1, exp_4));
            send_case(build_case("case_8", 8, 8, 1, exp_8));
            send_case(build_case("case_16", 16, 8, -1, exp_16));
            send_case(build_case("case_32", 32, 8, -1, exp_32));
            send_case(build_case("case_64", 64, 16, -1, exp_64));
        endtask
    endclass

    class idct2_1d_uvm_test extends uvm_test;
        `uvm_component_utils(idct2_1d_uvm_test)

        idct2_1d_env env;

        function new(string name = "idct2_1d_uvm_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = idct2_1d_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            idct2_1d_smoke_seq seq;
            phase.raise_objection(this);
            seq = idct2_1d_smoke_seq::type_id::create("seq");
            seq.start(env.agent.seqr);
            repeat (20) @(posedge env.agent.drv.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass

endpackage
