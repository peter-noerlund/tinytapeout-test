`timescale 1ns/1ps
`default_nettype none

module test_algo
    (
        input wire aclk,
        input wire aresetn,

        //! @virtualbus S_AXIS @dir input
        input wire s_axis_tvalid,
        input wire [7:0] s_axis_tdata,
        //! @end

        output reg [7:0] result
    );

    always @ (posedge aclk) begin
        if (!aresetn) begin
            result <= 8'h00;
        end else if (s_axis_tvalid) begin
            result <= result | s_axis_tdata;
        end
    end
endmodule