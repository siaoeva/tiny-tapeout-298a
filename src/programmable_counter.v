`default_nettype none

module programmable_counter (
    input  wire       clk,       
    input  wire       rst_n,     // async active-low reset
    input  wire       en,        
    input  wire       load,      // synchronous parallel load
    input  wire       up_down,   // 1 = up, 0 = down
    input  wire [7:0] data_in,   // 8-bit parallel load input
    input  wire       oe,        // output enable
    output wire [7:0] data_out   // tri-state counter output
);

    reg [7:0] counter;

    always @(posedge clk or negedge rst_n) begin // on rising edge clock or falling edge reset (active low)
        if (!rst_n) begin
            counter <= 8'h00; // set to 0 on reset 
        end
        else if (load) begin
            counter <= data_in; // if there's a load then set counter to input
        end
        else if (en) begin
            if (up_down)
                counter <= counter + 8'h01;
            else
                counter <= counter - 8'h01;
        end
    end

    assign data_out = (oe) ? counter : 8'bz;    // oe = 0 -> Z, oe = 1 -> drive the current counter value

endmodule
