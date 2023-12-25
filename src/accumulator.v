`timescale 1ns/1ps
`default_nettype none

module accumulator
    #(
        parameter QUEUE_SIZE=8,
        parameter TDATA_WIDTH=8,
        parameter ID_WIDTH=32
    )
    (
        (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
        (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXIS M_AXIS0 M_AXIS1, ASSOCIATED_RESET aresetn" *)
        input wire aclk, //! AXI clock

        (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
        input wire aresetn, //! AXI reset

        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *)
        //! @virtualbus S_AXIS @dir input Input stream
        input wire s_axis_tvalid,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)
        input wire [TDATA_WIDTH - 1 : 0] s_axis_tdata,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *)
        input wire s_axis_tlast,
        //! @end

        output reg [ID_WIDTH * QUEUE_SIZE - 1 : 0] ids
    );
    localparam QUEUE_SIZE_BITS = TDATA_WIDTH * QUEUE_SIZE;
    localparam QUEUE_ID_SIZE_BITS = ID_WIDTH * QUEUE_SIZE;
    reg [ID_WIDTH - 1 : 0] id;
    reg [TDATA_WIDTH * QUEUE_SIZE - 1 : 0] values;
    reg [QUEUE_SIZE - 1 : 0] valid;
    wire [QUEUE_SIZE - 1 : 0] match;
    genvar i;
    genvar j;

     always @ (posedge aclk) begin
        if (!aresetn) begin
            id <= {ID_WIDTH{1'b0}};
            ids <= {QUEUE_ID_SIZE_BITS{1'b1}};
            values <= {QUEUE_SIZE_BITS{1'b1}};
            valid <= {QUEUE_SIZE{1'b0}};
        end
    end

    always @ (posedge aclk) begin
        if (aresetn && s_axis_tvalid) begin
            id <= id + 1;
        end
    end

    generate
        for (i = 0; i != QUEUE_SIZE; i = i + 1) begin
            assign match[i] = s_axis_tdata < values[(i + 1) * TDATA_WIDTH - 1 -: TDATA_WIDTH];
        end

        for (i = 0; i != QUEUE_SIZE; i = i + 1) begin
            always @ (posedge aclk) begin
                if (aresetn && s_axis_tvalid && !s_axis_tlast && match[i]) begin
                    if (i == 0) begin
                        values[TDATA_WIDTH - 1 : 0] <= s_axis_tdata;
                        ids[ID_WIDTH - 1 : 0] <= id;
                        valid[0] <= 1'b1;
                    end else if (match[i - 1 : 0]) begin
                        values[(i + 1) * TDATA_WIDTH - 1 -: TDATA_WIDTH] <= values[i * TDATA_WIDTH - 1 -: TDATA_WIDTH];
                        ids[(i + 1) * ID_WIDTH - 1 -: ID_WIDTH] <= ids[i * ID_WIDTH - 1 -: ID_WIDTH];
                        valid[i] <= valid[i - 1];
                    end else begin
                        values[(i + 1) * TDATA_WIDTH - 1 -: TDATA_WIDTH] <= s_axis_tdata;
                        ids[(i + 1) * ID_WIDTH - 1 -: ID_WIDTH] <= id;
                        valid[i] <= 1'b1;
                    end
                end
            end
        end
    endgenerate
endmodule