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

    wire [63:0] characters;
    wire [63:0] masks;
    wire [7:0] result;

    wire aclk;
    wire aresetn;

    wire controller_tvalid;
    wire [7:0] controller_tdata;

    wire comparator_tvalid;
    wire [7:0] comparator_tdata;

    wire encoder_tvalid;
    wire [7:0] encoder_tdata;

    assign sclk = clk;
    assign cs = uio_in[0];
    assign mosi = ui_in;
    assign miso = uo_out;
    assign uio_oe = 8'b00000000;
    assign uio_out = 8'b00000000;
    
    assign aclk = clk;
    assign aresetn = rst_n;

    spi_controller spi_controller(
        .rst_n(rst_n),

        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso),

        .characters(characters),
        .masks(masks),
        .result(result),

        .m_axis_tvalid(controller_tvalid),
        .m_axis_tdata(controller_tdata)
    );

    comparator comparator(
        .aclk(aclk),
        .aresetn(aresetn),

        .s_axis_tvalid(controller_tvalid),
        .s_axis_tdata(controller_tdata),

        .characters(characters),

        .m_axis_tvalid(comparator_tvalid),
        .m_axis_tdata(comparator_tdata)
    );

    encoder encoder(
        .aclk(aclk),
        .aresetn(aresetn),

        .s_axis_tvalid(comparator_tvalid),
        .s_axis_tdata(comparator_tdata),

        .masks(masks),

        .m_axis_tvalid(encoder_tvalid),
        .m_axis_tdata(encoder_tdata)
    );

    test_algo algo(
        .aclk(aclk),
        .aresetn(aresetn),
        
        .s_axis_tvalid(encoder_tvalid),
        .s_axis_tdata(encoder_tdata),

        .result(result)
    );
endmodule
