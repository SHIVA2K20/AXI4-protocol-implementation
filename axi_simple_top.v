`timescale 1ns / 1ps
module axi_master_slave (
    input wire         ACLK,
    input wire         ARESETn,
    // Write Address
    input wire [31:0]  AWADDR,
    input wire         AWVALID,
    output wire        AWREADY,
    // Write Data
    input wire [31:0]  WDATA,
    input wire         WVALID,
    output wire        WREADY,
    // Write Response
    output reg  [1:0]  BRESP,
    output reg         BVALID,
    input wire         BREADY,
    // Read Address
    input wire [31:0]  ARADDR,
    input wire         ARVALID,
    output wire        ARREADY,
    // Read Data
    output reg [31:0]  RDATA,
    output reg [1:0]   RRESP,
    output reg         RVALID,
    input wire         RREADY
);

reg awready_r, wready_r, arready_r;
assign AWREADY = awready_r;
assign WREADY  = wready_r;
assign ARREADY = arready_r;

// Simple 256 x 32-bit memory
reg [31:0] mem [0:255];

always @(posedge ACLK) begin
    if (!ARESETn) begin
        awready_r <= 0;
        wready_r <= 0;
        arready_r <= 0;
        BVALID <= 0;
        RVALID <= 0;
        BRESP <= 2'b00;
        RRESP <= 2'b00;
        RDATA <= 32'd0;
    end else begin
        // Write Address Handshake
        if (AWVALID && !AWREADY) begin
            awready_r <= 1;
        end else begin
            awready_r <= 0;
        end

        // Write Data Handshake
        if (WVALID && !WREADY) begin
            wready_r <= 1;
        end else begin
            wready_r <= 0;
        end

        // Perform memory write when both address and data are accepted
        if (AWVALID && WVALID && awready_r && wready_r) begin
            mem[AWADDR[9:2]] <= WDATA;  // Using word addressable memory
            BVALID <= 1;
            BRESP <= 2'b00;
        end

        // Clear write response
        if (BVALID && BREADY) begin
            BVALID <= 0;
        end

        // Read Address Handshake
        if (ARVALID && !ARREADY) begin
            arready_r <= 1;
        end else begin
            arready_r <= 0;
        end

        // Perform memory read
        if (ARVALID && ARREADY) begin
            RDATA <= mem[ARADDR[9:2]];
            RRESP <= 2'b00;
            RVALID <= 1;
        end

        // Clear read response
        if (RVALID && RREADY) begin
            RVALID <= 0;
        end
    end
end

endmodule

