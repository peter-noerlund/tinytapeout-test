`default_nettype none
`timescale 1ns/1ns

module tt_um_pchri03_top
    (
        input wire clk,                  //! Clock
        input wire rst_n,                //! Reset
        input wire ena,                  //! Enable

        input wire [7:0] ui_in,          //! Input ports

        output wire [7:0] uo_out,        //! Output ports

        input wire [7:0] uio_in,         //! In/Out ports (In)
        output wire [7:0] uio_out,       //! In/Out ports (Out)
        output wire [7:0] uio_oe         //! In/Out ports (Output enable)
    );

    wire sclk;
    wire cs;
    wire [7:0] mosi;
    wire [7:0] miso;

    wire [7:0] word_size;
    wire [7:0] result_mask;
    wire [63:0] characters;
    wire [63:0] masks;
    wire [63:0] result_ids;
    
    wire aclk;
    wire aresetn;

    wire controller_tvalid;
    wire [7:0] controller_tdata;
    wire controller_tuser;

    wire comparator_tvalid;
    wire [7:0] comparator_tdata;
    wire comparator_tuser;
    
    wire levenshtein_tvalid;
    wire [7:0] levenshtein_tdata;

    assign sclk = clk;
    assign cs = uio_in[0];
    assign mosi = ui_in;
    assign miso = uo_out;
    assign uio_oe = 8'b00000000;
    assign uio_out = 8'b00000000;
    
    spi_controller controller(
        .rst_n(rst_n),

        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso),

        .word_size(word_size),
        .result_mask(result_mask),
        .characters(characters),
        .masks(masks),
        .result_ids(result_ids),

        .aclk(aclk),
        .aresetn(aresetn),
        
        .m_axis_tvalid(controller_tvalid),
        .m_axis_tdata(controller_tdata),
        .m_axis_tuser(controller_tuser)
    );

    comparator comparator(
        .aclk(aclk),
        .aresetn(aresetn),

        .characters(characters),
        .masks(masks),

        .s_axis_tvalid(controller_tvalid),
        .s_axis_tdata(controller_tdata),
        .s_axis_tuser(controller_tuser),
        
        .m_axis_tvalid(comparator_tvalid),
        .m_axis_tdata(comparator_tdata),
        .m_axis_tuser(comparator_tuser)
    );

    levenshtein levenshtein(
        .aclk(aclk),
        .aresetn(aresetn),

        .word_size(word_size),
        .mask(result_mask),

        .s_axis_tvalid(comparator_tvalid),
        .s_axis_tdata(comparator_tdata),
        .s_axis_tuser(comparator_tuser),
        .s_axis_tlast(1'b0),

        .m_axis_tvalid(levenshtein_tvalid),
        .m_axis_tdata(levenshtein_tdata)
    );

    accumulator #(.ID_WIDTH(8)) accumulator(
        .aclk(aclk),
        .aresetn(aresetn),

        .s_axis_tvalid(levenshtein_tvalid),
        .s_axis_tdata(levenshtein_tdata),
        .s_axis_tlast(1'b0),

        .ids(result_ids)
    );
endmodule
