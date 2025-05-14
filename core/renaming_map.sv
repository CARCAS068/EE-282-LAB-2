

module renaming_map import ariane_pkg::*; #(
    parameter int unsigned ARCH_REG_WIDTH = 5,
    parameter int unsigned PHYS_REG_WIDTH = 6
)(
    // Clock and reset signals
    input logic clk_i,
    input logic rst_ni,

    // Indicator that there is a new instruction to rename
    input logic fetch_entry_ready_i,

    // Input decoded instruction entry from the ID stage
    input issue_struct_t issue_n,

    // Output instruction entry with registers renamed
    output issue_struct_t issue_q,

    // Destination register of the committing instruction
    input logic [PHYS_REG_WIDTH-1:0] waddr_i,
    
    // Indicator signal that there is a new committing instruction
    input logic we_gp_i
);

    // 32 architectural registers and 64 physical registers
    localparam ARCH_NUM_REGS = 2**ARCH_REG_WIDTH;
    localparam PHYS_NUM_REGS = 2**PHYS_REG_WIDTH;

   // logic [PHYS_REG_WIDTH-1:0] rs1;
    //logic [PHYS_REG_WIDTH-1:0] rs2;
    //logic [PHYS_REG_WIDTH-1:0] rd;

    


    // TODO: ADD STRUCTURES TO EXECUTE REGISTER RENAMING

    // Maps architectural registers to physical registers
    logic [PHYS_REG_WIDTH-1:0] rename_table [ARCH_NUM_REGS-1:0];

    // Deallocation list of physical registers
    logic [PHYS_NUM_REGS-1:0] deallocate_list ;
    // Free list of physical registers (bitmask or queue)
    logic [PHYS_NUM_REGS-1:0] free_list;
    // 
    logic [PHYS_REG_WIDTH-1:0] new_pr;

    issue_struct_t issue_q_r;

    assign issue_q = issue_q_r;
    //logic its_free;

    //free_list free_list_i (
        //.free_list(free_list),
        //.new_free_list(free_list),
        //.new_pr(new_pr)
    //);


    always_comb begin
        new_pr = '0;
        // Find a free physical register
        for (int i = 1; i < PHYS_NUM_REGS; ++i) begin
            if (!free_list[i]) begin
                new_pr = i[PHYS_REG_WIDTH-1:0];
                free_list[i] = 1'b1;
                break;
            end
        end
    end

    // Positive clock edge used for renaming new instructions
    always @(posedge clk_i, negedge rst_ni) begin
        // Processor reset: revert renaming state to reset conditions    
        if (~rst_ni) begin

            // TODO: ADD LOGIC TO RESET RENAMING STATE
            free_list <= 64'h0000000000000000; // All physical registers free
            //deallocate_list <=  {PHYS_NUM_REGS{1'b0}}; // All physical registers free
            //rename_table <= {ARCH_NUM_REGS{1'b0}}; // All architectural registers free
            // Zero rename_table (unpacked array)
            for (int i = 0; i < ARCH_NUM_REGS; i++) begin
                rename_table[i] <= '0;
            end

            // Zero deallocate_list (array of packed vectors)
            deallocate_list <= '0;
            

  
            issue_q_r <= '0;
    
        // New incoming valid instruction to rename   
        end else if (fetch_entry_ready_i && issue_n.valid) begin
            // Get values of registers in new instruction

            // Set outgoing instruction to incoming instruction without
            // renaming by default. Keep this line since all fields of the 
            // incoming issue_struct_t should carry over to the output
            // except for the register values, which you may rename below
            issue_q_r <= issue_n;

            // TODO: ADD LOGIC TO RENAME OUTGOING INSTRUCTION
            // The registers of the outgoing instruction issue_q can be set like so:
            // issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0] = your new rs1 register value;
            // issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0] = your new rs2 register value;
            // issue_q.sbe.rd[PHYS_REG_WIDTH-1:0] = your new rd register value;
            if (!rename_table[issue_n.sbe.rs1]) begin
                issue_q_r.sbe.rs1[PHYS_REG_WIDTH-1:0] = rename_table[0];
            end else begin
                issue_q_r.sbe.rs1[PHYS_REG_WIDTH-1:0] = rename_table[issue_n.sbe.rs1];
            end
            if (!rename_table[issue_n.sbe.rs2]) begin
                issue_q_r.sbe.rs2[PHYS_REG_WIDTH-1:0] = rename_table[0];
            end else begin
                issue_q_r.sbe.rs2[PHYS_REG_WIDTH-1:0] = rename_table[issue_n.sbe.rs2];;
            end
            
            if(issue_n.sbe.rd != 0) begin
                
                rename_table[issue_n.sbe.rd] <= new_pr;
                issue_q_r.sbe.rd <= rename_table[issue_n.sbe.rd];
                deallocate_list[issue_n.sbe.rd] <= 1'b1; 
  
            end else begin
                issue_q_r.sbe.rd <= rename_table[issue_n.sbe.rd];
            end
           
        // If there is no new instruction this clock cycle, simply pass on the
        // incoming instruction without renaming
        end else begin
            issue_q_r <= issue_n;
        end
    end
    

    // Negative clock edge used for physical register deallocation 
    always @(negedge clk_i) begin
        if (rst_ni) begin
            // If there is a new committing instruction and its prd is not pr0,
            // execute register deallocation logic to reuse physical registers
            if (we_gp_i && waddr_i != 0) begin
        
                // TODO: IMPLEMENT REGISTER DEALLOCATION LOGIC  
                deallocate_list[waddr_i] <= 1'b0;
                //rename_table[waddr_i] <= 1'b0;
                free_list[waddr_i] <= 1'b0; 


            end
        end
    end
endmodule



            end
        end
    end
endmodule

