// Code your testbench here
// or browse Examples

`timescale 1ns / 1ps

module tb_axi_master_slave;

    // Clock and Reset
    reg ACLK;
    reg ARESETn = 0;

    // Write Address Channel
    reg  [31:0] AWADDR;
    reg         AWVALID;
    wire        AWREADY;

    // Write Data Channel
    reg  [31:0] WDATA;
    reg         WVALID;
    wire        WREADY;

    // Write Response Channel
    wire [1:0]  BRESP;
    wire        BVALID;
    reg         BREADY;

    // Read Address Channel
    reg  [31:0] ARADDR;
    reg         ARVALID;
    wire        ARREADY;

    // Read Data Channel
    wire [31:0] RDATA;
    wire [1:0]  RRESP;
    wire        RVALID;
    reg         RREADY;

    // Clock generation
   always #5 ACLK = ~ACLK;
    // Instantiate DUT
    axi_master_slave dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

    // Write Task
    task axi_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge ACLK);
        AWADDR  <= addr;
        AWVALID <= 1;
        WDATA   <= data;
        WVALID  <= 1;

        wait (AWREADY && WREADY);
        @(posedge ACLK);
        AWVALID <= 0;
        WVALID  <= 0;

        BREADY <= 1;
        wait (BVALID);
        @(posedge ACLK);
        BREADY <= 0;
    end
    endtask

    // Read Task
    task axi_read(input [31:0] addr);
    begin
        @(posedge ACLK);
        ARADDR  <= addr;
        ARVALID <= 1;

        wait (ARREADY);
        @(posedge ACLK);
        ARVALID <= 0;

        RREADY <= 1;
        wait (RVALID);
        @(posedge ACLK);
        $display("Read Data from address 0x%08X = 0x%08X", addr, RDATA);
        RREADY <= 0;
    end
    endtask
  
 
    initial begin
       
      ACLK=0;
     // Dumpfile for waveform
    $dumpfile("axi_master_slave.vcd");  // Output file name
    $dumpvars(0, tb_axi_master_slave);
        // Initialize signals
        AWADDR = 0;
        AWVALID = 0;
        WDATA = 0;
        WVALID = 0;
        BREADY = 0;
        ARADDR = 0;
        ARVALID = 0;
        RREADY = 0;

        // Reset
        ARESETn = 0;
        #20;
        ARESETn = 1;
     
        // Perform Write Transaction
        $display("Starting Write Transaction...");
        axi_write(32'h00000010, 32'hCAFEBABE);

        // Perform Read Transaction
        $display("Starting Read Transaction...");
        axi_read(32'h00000010);

        #20;
        $finish    end
   


endmodule




