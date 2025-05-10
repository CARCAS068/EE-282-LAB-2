// Renaming map module
// While you are free to structure your implementation however you
// like, you are advised to only add code to the TODO sections
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

    // Free list of physical registers (bitmask or queue)
    logic [PHYS_NUM_REGS-1:0] free_list;

    logic [PHYS_REG_WIDTH-1:0] new_pr;

    issue_struct_t issue_q_r;

    assign issue_q = issue_q_r;



    // Positive clock edge used for renaming new instructions
    always @(posedge clk_i, negedge rst_ni) begin
        // Processor reset: revert renaming state to reset conditions    
        if (~rst_ni) begin

            // TODO: ADD LOGIC TO RESET RENAMING STATE

            // Reset: map x0 → p0, clear others
            for (int i = 0; i < ARCH_NUM_REGS; ++i)
                rename_table[i] = (i == 0) ? '0 : '0;

            // Initialize free list: pr0 in use, rest free
            free_list = '1;
            free_list[0] = 1'b0;

            issue_q_r = '0;
    
        // New incoming valid instruction to rename   
        end else if (fetch_entry_ready_i && issue_n.valid) begin
            // Get values of registers in new instruction


            // Set outgoing instruction to incoming instruction without
            // renaming by default. Keep this line since all fields of the 
            // incoming issue_struct_t should carry over to the output
            // except for the register values, which you may rename below
            issue_q_r = issue_n;

            // TODO: ADD LOGIC TO RENAME OUTGOING INSTRUCTION
            // The registers of the outgoing instruction issue_q can be set like so:
            // issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0] = your new rs1 register value;
            // issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0] = your new rs2 register value;
            // issue_q.sbe.rd[PHYS_REG_WIDTH-1:0] = your new rd register value;
             // Rename rs1
            if (issue_n.sbe.rs1 == 0)
                issue_q_r.sbe.rs1 = '0;
            else
                issue_q_r.sbe.rs1 = rename_table[issue_n.sbe.rs1];

            // Rename rs2
            if (issue_n.sbe.rs2 == 0)
                issue_q_r.sbe.rs2 = '0;
            else
                issue_q_r.sbe.rs2 = rename_table[issue_n.sbe.rs2];
            // Rename rd
            if (issue_n.sbe.rd == 0) begin
                issue_q_r.sbe.rd = '0;
            end else begin
                // Allocate a new physical register
                new_pr = '0;
                // Find a free physical register
                for (int i = 1; i < PHYS_NUM_REGS; ++i) begin
                    if (free_list[i]) begin
                        new_pr = i[PHYS_REG_WIDTH-1:0];
                        free_list[i] = 1'b0;
                        break;
                    end
                end
                issue_q_r.sbe.rd = new_pr;
                rename_table[issue_n.sbe.rd] = new_pr;
            end

           
        // If there is no new instruction this clock cycle, simply pass on the
        // incoming instruction without renaming
        end else begin
            issue_q_r = issue_n;
        end
    end
    

    // Negative clock edge used for physical register deallocation 
    always @(negedge clk_i) begin
        if (rst_ni) begin
            // If there is a new committing instruction and its prd is not pr0,
            // execute register deallocation logic to reuse physical registers
            if (we_gp_i && waddr_i != 0) begin
        
                // TODO: IMPLEMENT REGISTER DEALLOCATION LOGIC    
                free_list[waddr_i]= 1'b1; 


            end
        end
    end
endmodule

