`timescale 1ns/1ps
`default_nettype none

module comparator
    (
        input wire aclk,
        input wire aresetn,

        //! @virtualbus S_AXIS @dir input
        input wire s_axis_tvalid,
        input wire [7:0] s_axis_tdata,
        //! @end

        input wire [63:0] characters,

        //! @virtualbus M_AXIS @dir output
        output reg m_axis_tvalid,
        output reg [7:0] m_axis_tdata
        //! @end
    );

    integer i;

    always @ (posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tvalid <= s_axis_tvalid;
        end

        for (i = 0; i != 8; i = i + 1) begin
            m_axis_tdata[i] <= s_axis_tdata == characters[i * 8 + 7 -: 8] ? 1'b1 : 1'b0;
        end
    end
endmodule