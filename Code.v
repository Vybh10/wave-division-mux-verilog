//MUX
`timescale 1ns/1ps
module wdm_mux1bit (
    input ch0, ch1, ch2, ch3,
    input [1:0] sel,
    output reg wdm_out
);
    always @(*) begin
        case (sel)
            2'b00: wdm_out = ch0;
            2'b01: wdm_out = ch1;
            2'b10: wdm_out = ch2;
            2'b11: wdm_out = ch3;
            default: wdm_out = 0;
        endcase
    end
endmodule

//demux

`timescale 1ns/1ps
module wdm_demux1bit (
    input wdm_in,
    input [1:0] sel,
    output reg ch0, ch1, ch2, ch3
);
    always @(*) begin
        ch0 = 0; ch1 = 0; ch2 = 0; ch3 = 0;
        case (sel)
            2'b00: ch0 = wdm_in;
            2'b01: ch1 = wdm_in;
            2'b10: ch2 = wdm_in;
            2'b11: ch3 = wdm_in;
        endcase
    end
endmodule

//testbench 

`timescale 1ns/1ps
module wdm_tb;
    reg clk;
    reg [1:0] sel;
    wire rx0, rx1, rx2, rx3;

    wdm_top uut (
        .clk(clk),
        .sel(sel),
        .rx0(rx0),
        .rx1(rx1),
        .rx2(rx2),
        .rx3(rx3)
    );
  initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        sel = 2'b00; #50000;
        sel = 2'b01; #50000;
        sel = 2'b10; #50000;
        sel = 2'b11; #50000;
        $finish;
    end
endmodule

//top level glue file that connects all your modules together
//top.v idu


`timescale 1ns/1ps
module wdm_top (
    input clk,
    input [1:0] sel,
    output rx0, rx1, rx2, rx3
);
    wire optical_bus;
    wire ch0, ch1, ch2, ch3;
 clk_divider #(.DIV(200)) cd0 (.clk(clk), .clk_out(ch0));
    clk_divider #(.DIV(100)) cd1 (.clk(clk), .clk_out(ch1));
    clk_divider #(.DIV(50)) cd2 (.clk(clk), .clk_out(ch2));
    clk_divider #(.DIV(25)) cd3 (.clk(clk), .clk_out(ch3));

    wdm_mux1bit mux_inst (
        .ch0(ch0), .ch1(ch1), .ch2(ch2), .ch3(ch3),
        .sel(sel),
        .wdm_out(optical_bus)
    );
 wdm_demux1bit demux_inst (
        .wdm_in(optical_bus),
        .sel(sel),
        .ch0(rx0), .ch1(rx1), .ch2(rx2), .ch3(rx3)
    );
endmodule

//clock divider

`timescale 1ns/1ps
module clk_divider #(parameter DIV = 200)(
    input clk,
    output reg clk_out = 0
);
    integer counter = 0;

    always @(posedge clk) begin
        if (counter >= DIV - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
