`timescale 1ns/1ps
`default_nettype none

module levenshtein
    #(
        parameter BITVECTOR_WIDTH=8,    //! Size of the bit vectors
        parameter DISTANCE_WIDTH=8      //! Size of a distance integer
    )
    (
        (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
        (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXIS, ASSOCIATED_RESET aresetn" *)
        input wire aclk,     //! AXI clock

        (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
        input wire aresetn,  //! AXI reset

        input wire [DISTANCE_WIDTH - 1 : 0] word_size,   //! Length of the search word
        input wire [BITVECTOR_WIDTH - 1 : 0] mask,       //! Mask of where the right most column is

        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *)
        //! @virtualbus S_AXIS @dir input Output stream
        input wire s_axis_tvalid,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)
        input wire [BITVECTOR_WIDTH - 1 : 0] s_axis_tdata,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TUSER" *)
        input wire s_axis_tuser,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *)
        input wire s_axis_tlast,
        //! @end

        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
        //! @virtualbus M_AXIS @dir output Output stream
        output reg m_axis_tvalid,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
        output wire [DISTANCE_WIDTH - 1 : 0] m_axis_tdata,
        (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
        output reg m_axis_tlast
        //! @end
    );

    reg [DISTANCE_WIDTH - 1 : 0] d_reg;    //! Storage register for distance
    wire [DISTANCE_WIDTH - 1 : 0] d_prev;  //! Distance from previous cycle

    reg [BITVECTOR_WIDTH - 1 : 0] hp_reg;   //! Storage register for hozitonal positive
    reg [BITVECTOR_WIDTH - 1 : 0] hn_reg;   //! Storage register for horizontal negative
    wire [BITVECTOR_WIDTH - 1 : 0] hp;      //! Horizontal positive, a 1 indicates that the cell is 1 larger than the cell in the previous column
    wire [BITVECTOR_WIDTH - 1 : 0] hn;      //! Horizontal negative, a 1 indicates that the cell is 1 smaller than the cell in the previous column
    wire [BITVECTOR_WIDTH - 1 : 0] hp_prev; //! Horizontal positive for previous column
    wire [BITVECTOR_WIDTH - 1 : 0] hn_prev; //! Horizontal negative for previous column

    wire [BITVECTOR_WIDTH - 1 : 0] vp; //! Vertical positive, a 1 indicates that the cell is 1 larger than the cell in the previous row
    wire [BITVECTOR_WIDTH - 1 : 0] vn; //! Vertical negative, a 1 indicates that the cell is 1 smaller than the cell in the previous row

    wire [BITVECTOR_WIDTH - 1 : 0] d0; //! Diagonal zero, a 1 indicates that the cell is identical to the cell in the previous column in the previous row
    wire [BITVECTOR_WIDTH - 1 : 0] pm; //! Pattern match, a 1 indicates that the current letter is found at that location of the search word

    wire increment; // Indicates if the distance needs to be incremented
    wire decrement; // Indicates if the distance needs to be decremented

    integer i;
    genvar j;

    assign hp_prev = hp_reg;
    assign hn_prev = hn_reg;
    assign d_prev = d_reg;
    assign pm = s_axis_tdata;

    assign m_axis_tdata = d_reg;

    // d0[j] = (((pm[j] & hp[j - 1]) + hp[j - 1]) ^ hp[j - 1]) | pm[j] | hn[j - 1]
    assign d0 = (((pm & hp_prev) + hp_prev) ^ hp_prev) | pm | hn_prev;

    // vp[j] = hn[j - 1] | ~(d0[j] | hp[j - 1])
    assign vp = hn_prev | ~(d0 | hp_prev);

    // vn[j] = d0[j] & hp[j - 1]
    assign vn = d0 & hp_prev;

    // hp[j] = (vn[j] << 1) | ~(d0[j] | (vp[j] << 1))
    assign hp = (vn << 1) | ~(d0 | (vp << 1) | 1'b1);

    // hn[j] = (d0[j] >> 1) & vp[j]
    assign hn = d0 & ((vp << 1) | 1'b1);

    assign increment = (vp & mask) != {BITVECTOR_WIDTH{1'b0}};
    assign decrement = (vn & mask) != {BITVECTOR_WIDTH{1'b0}};

    always @ (posedge aclk) begin
        m_axis_tlast <= s_axis_tlast;
        
        if (s_axis_tvalid) begin
            //$display("mask=%b increment=%b decrement=%b aresetn=%b s_axis_tvalid=%b s_axis_tuser=%b d_prev=%d hp_prev=%b hn_prev=%b | pm=%b vp=%b vn=%b hp=%b hn=%b d0=%b", mask, increment, decrement, aresetn, s_axis_tvalid, s_axis_tuser, d_prev, hp_prev, hn_prev, pm, vp, vn, hp, hn, d0);
        end

        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end

        if (!aresetn || (s_axis_tvalid && s_axis_tuser)) begin
            // Next transfer is first character of new word
            // d[0] = word_size
            d_reg <= word_size;

            // hp[0] = 111111
            for (i = 0; i != BITVECTOR_WIDTH; i = i + 1) begin
                hp_reg[i] <= i < word_size ? 1'b1 : 1'b0; // This can probably be written in a more optimal better
            end

            // hn[0] = 000000
            hn_reg <= {BITVECTOR_WIDTH{1'b0}};
        end

        if (aresetn && s_axis_tvalid) begin
            if (s_axis_tuser) begin
                m_axis_tvalid <= 1'b1;
            end else begin
                if (increment && !decrement) begin
                    d_reg <= d_prev + 1;
                end else if (!increment && decrement) begin
                    d_reg <= d_prev - 1;
                end

                hp_reg <= hp;
                hn_reg <= hn;
            end
        end

        if (aresetn && (!s_axis_tvalid || !s_axis_tuser)) begin
            m_axis_tvalid <= 1'b0;
        end
    end
endmodule
