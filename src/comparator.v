`timescale 1ns/1ps
`default_nettype none

module comparator
    (
        input wire aclk,
        input wire aresetn,

        //! @virtualbus S_AXIS @dir input Input stream
        input wire s_axis_tvalid,
        input wire [7:0] s_axis_tdata,
        input wire s_axis_tuser,
        //! @end

        input wire [63:0] characters,
        input wire [63:0] masks,

        //! @virtualbus M_AXIS @dir output Output stream
        output reg m_axis_tvalid,
        output reg [7:0] m_axis_tdata,
        output reg m_axis_tuser
        //! @end
    );

    integer i;

    always @ (posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            m_axis_tvalid <= s_axis_tvalid;
            m_axis_tuser <= s_axis_tuser;
            m_axis_tdata <= 8'b00000000;
            for (i = 0; i != 8; i = i + 1) begin
                if (s_axis_tdata == characters[i * 8 + 7 -: 8]) begin
                    m_axis_tdata <= masks[i * 8 + 7 -: 8];
                end
            end
        end
    end
endmodule
