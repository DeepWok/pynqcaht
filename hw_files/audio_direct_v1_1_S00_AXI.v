`timescale 1 ns / 1 ps

module audio_direct_v1_1_S00_AXI #
(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line

    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH    = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH    = 5
)
(
    // Users to add ports here

    // PDM
    output wire pdm_m_clk_o,
    input wire [31:0] pdm_m_data_i, // actually pcm
    output wire pdm_lrsel_o,

    // PWM
    output wire pwm_audio_o,
    output wire pwm_audio_t,
    input wire pwm_audio_i,
    output wire pwm_sdaudio_o,

    // Extra ports
    input wire mic_data_valid_i,

    // User ports ends
    // Do not modify the ports beyond this line

    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave)
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire  S_AXI_RREADY
);

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]     axi_awaddr;
    reg      axi_awready;
    reg      axi_wready;
    reg [1 : 0]     axi_bresp;
    reg      axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]     axi_araddr;
    reg      axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]     axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg      axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 2;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 6
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_RESET_REG;
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_TRANSFER_CONTROL_REG;
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_FIFO_CONTROL_REG;
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_DATA_IN_REG;
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_DATA_OUT_REG;
    reg [C_S_AXI_DATA_WIDTH-1:0]    PDM_STATUS_REG;
    wire     slv_reg_rden;
    wire     slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out;
    integer     byte_index;
    reg     aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY    = axi_wready;
    assign S_AXI_BRESP    = axi_bresp;
    assign S_AXI_BVALID    = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA    = axi_rdata;
    assign S_AXI_RRESP    = axi_rresp;
    assign S_AXI_RVALID    = axi_rvalid;

    // User logic signals
    wire PDM_RST_I;
    wire START_TRANSACTION_I;
    wire STOP_TRANSACTION_I;
    wire RNW_I;
    wire TX_FIFO_RST_I;
    wire [15:0] TX_FIFO_D_I;
    wire TX_FIFO_WR_EN_I;
    wire [31:0] RX_FIFO_D_O;
    wire RX_FIFO_RD_EN_I;
    wire TX_FIFO_EMPTY_O;
    wire TX_FIFO_FULL_O;
    wire RX_FIFO_RST_I;
    wire RX_FIFO_EMPTY_O;
    wire RX_FIFO_FULL_O;

    // Instantiate the pdm_rxtx module
    pdm_rxtx pdm_rxtx_inst (
        .CLK_I(S_AXI_ACLK),
        .RST_I(PDM_RST_I),
        .START_TRANSACTION_I(START_TRANSACTION_I),
        .STOP_TRANSACTION_I(STOP_TRANSACTION_I),
        .RNW_I(RNW_I),
        .TX_FIFO_RST_I(TX_FIFO_RST_I),
        .TX_FIFO_D_I(TX_FIFO_D_I),
        .TX_FIFO_WR_EN_I(TX_FIFO_WR_EN_I),
        .RX_FIFO_RST_I(RX_FIFO_RST_I),
        .RX_FIFO_D_O(RX_FIFO_D_O),
        .RX_FIFO_RD_EN_I(RX_FIFO_RD_EN_I),
        .TX_FIFO_EMPTY_O(TX_FIFO_EMPTY_O),
        .TX_FIFO_FULL_O(TX_FIFO_FULL_O),
        .RX_FIFO_EMPTY_O(RX_FIFO_EMPTY_O),
        .RX_FIFO_FULL_O(RX_FIFO_FULL_O),
        .PDM_M_CLK_O(pdm_m_clk_o),
        .PDM_M_DATA_I(pdm_m_data_i),
        .PDM_LRSEL_O(pdm_lrsel_o),
        .PWM_AUDIO_O(pwm_audio_o),
        .PWM_AUDIO_T(pwm_audio_t),
        .PWM_AUDIO_I(pwm_audio_i),
        .mic_data_valid_i(mic_data_valid_i)
    );

    // User logic signal assignments
    assign PDM_RST_I = PDM_RESET_REG[0];
    assign START_TRANSACTION_I = PDM_TRANSFER_CONTROL_REG[0];
    assign STOP_TRANSACTION_I = PDM_TRANSFER_CONTROL_REG[1];
    assign RNW_I = PDM_TRANSFER_CONTROL_REG[2];
    assign pwm_sdaudio_o = PDM_TRANSFER_CONTROL_REG[3];
    assign TX_FIFO_WR_EN_I = PDM_FIFO_CONTROL_REG[0];
    assign RX_FIFO_RD_EN_I = PDM_FIFO_CONTROL_REG[1];
    assign TX_FIFO_RST_I = PDM_FIFO_CONTROL_REG[30];
    assign RX_FIFO_RST_I = PDM_FIFO_CONTROL_REG[31];
    assign TX_FIFO_D_I = PDM_DATA_IN_REG[15:0]; // should be 32

    // Implement axi_awready generation
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end
        else
        begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
            begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end
            else
            begin
                axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_awaddr <= 0;
        end
        else
        begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_wready <= 1'b0;
        end
        else
        begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
                axi_wready <= 1'b1;
            end
            else
            begin
                axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            PDM_RESET_REG <= 0;
            PDM_TRANSFER_CONTROL_REG <= 0;
            PDM_FIFO_CONTROL_REG <= 0;
            PDM_DATA_IN_REG <= 0;
        end
        else begin
            if (slv_reg_wren)
            begin
                case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                    3'h0:
                        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                            if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                PDM_RESET_REG[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                            end
                    3'h1:
                        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                            if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                PDM_TRANSFER_CONTROL_REG[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                            end
                    3'h2:
                        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                            if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                PDM_FIFO_CONTROL_REG[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                            end
                    3'h3:
                        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                            if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                                PDM_DATA_IN_REG[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                            end
                    default : begin
                        PDM_RESET_REG <= PDM_RESET_REG;
                        PDM_TRANSFER_CONTROL_REG <= PDM_TRANSFER_CONTROL_REG;
                        PDM_FIFO_CONTROL_REG <= PDM_FIFO_CONTROL_REG;
                        PDM_DATA_IN_REG <= PDM_DATA_IN_REG;
                    end
                endcase
            end
        end
    end

    // Implement write response logic generation
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_bvalid  <= 0;
            axi_bresp   <= 2'b0;
        end
        else
        begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;
            end
            else
            begin
                if (S_AXI_BREADY && axi_bvalid)
                begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end
        else
        begin
            if (~axi_arready && S_AXI_ARVALID)
            begin
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end
            else
            begin
                axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end
        else
        begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;
            end
            else if (axi_rvalid && S_AXI_RREADY)
            begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and read logic generation
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*)
    begin
        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            3'h0   : reg_data_out <= PDM_RESET_REG;
            3'h1   : reg_data_out <= PDM_TRANSFER_CONTROL_REG;
            3'h2   : reg_data_out <= PDM_FIFO_CONTROL_REG;
            3'h3   : reg_data_out <= PDM_DATA_IN_REG;
            3'h4   : reg_data_out <= PDM_DATA_OUT_REG;
            3'h5   : reg_data_out <= PDM_STATUS_REG;
            default : reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            axi_rdata  <= 0;
        end
        else
        begin
            if (slv_reg_rden)
            begin
                axi_rdata <= reg_data_out;
            end
        end
    end

    // Implement PDM_DATA_OUT_REG and PDM_STATUS_REG updates
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 )
        begin
            PDM_DATA_OUT_REG <= 0;
            PDM_STATUS_REG <= 0;
        end
        else
        begin
            PDM_DATA_OUT_REG <= RX_FIFO_D_O;
            PDM_STATUS_REG[0] <= TX_FIFO_EMPTY_O;
            PDM_STATUS_REG[1] <= TX_FIFO_FULL_O;
            PDM_STATUS_REG[15:2] <= 14'b0;
            PDM_STATUS_REG[16] <= RX_FIFO_EMPTY_O;
            PDM_STATUS_REG[17] <= RX_FIFO_FULL_O;
            PDM_STATUS_REG[31:18] <= 14'b0;
        end
    end

endmodule
