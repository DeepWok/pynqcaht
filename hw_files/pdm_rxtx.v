module pdm_rxtx (
    // Global signals
    input wire CLK_I,
    input wire RST_I,

    // Control signals
    input wire START_TRANSACTION_I,
    input wire STOP_TRANSACTION_I,
    input wire RNW_I,

    // Tx FIFO Control signals
    input wire TX_FIFO_RST_I,
    input wire [15:0] TX_FIFO_D_I,
    input wire TX_FIFO_WR_EN_I,

    // Rx FIFO Control signals
    input wire RX_FIFO_RST_I,
    output wire [31:0] RX_FIFO_D_O,
    input wire RX_FIFO_RD_EN_I,

    // Tx FIFO Flags
    output wire TX_FIFO_EMPTY_O,
    output wire TX_FIFO_FULL_O,

    // Rx FIFO Flags
    output wire RX_FIFO_EMPTY_O,
    output wire RX_FIFO_FULL_O,

    output wire PDM_M_CLK_O,
    input wire [31:0] PDM_M_DATA_I, // actually PCM
    output wire PDM_LRSEL_O,

    output wire PWM_AUDIO_O,
    output wire PWM_AUDIO_T,
    input wire PWM_AUDIO_I,

    // Extra flag
    input wire mic_data_valid_i
);

// State encoding
parameter [1:0] sIdle = 2'b00,
                sCheckRnw = 2'b01,
                sRead = 2'b10,
                sWrite = 2'b11;

// Signal declarations
reg [1:0] CState, NState;
reg StartTransaction, StopTransaction;
reg RxEn, TxEn;
reg Rnw;
wire [31:0] RxFifoDataIn; // THIS IS DA INPUT WIRE
wire RxFifoWrEn;
wire [31:0] TxFifoDataOut;
wire TxFifoRdEn;
wire RxFifoRdEn;
reg RxFifoRdEn_dly;
wire TxFifoWrEn;
reg TxFifoWrEn_dly;
wire TxFifoEmpty;

assign RxFifoDataIn = PDM_M_DATA_I;

// Deserializer instantiation
//pdm_des #(
//    .C_NR_OF_BITS(16),
//    .C_SYS_CLK_FREQ_MHZ(100),
//    .C_PDM_FREQ_MHZ(3)
//) Inst_Deserializer (
//    .clk_i(CLK_I),
//    .rst_i(RST_I),
//    .en_i(RxEn),
//    .done_o(RxFifoWrEn),
//    .data_o(RxFifoDataIn),
//    .pdm_m_clk_o(PDM_M_CLK_O),
//    .pdm_m_data_i(PDM_M_DATA_I),
//    .pdm_lrsel_o(PDM_LRSEL_O)
//);

// Serializer instantiation
pdm_ser #(
    .C_NR_OF_BITS(32),
    .C_SYS_CLK_FREQ_MHZ(100),
    .C_PDM_FREQ_MHZ(3)
) Inst_Serializer (
    .clk_i(CLK_I),
    .rst_i(RST_I),
    .en_i(TxEn),
    .done_o(TxFifoRdEn),
    .data_i(TxFifoDataOut),
    .pwm_audio_o(PWM_AUDIO_O),
    .pwm_audio_t(PWM_AUDIO_T),
    .pwm_audio_i(PWM_AUDIO_I)
);

// FIFO instantiation for Tx
fifo_generator_0 Inst_PdmTxFifo (
    .clk(CLK_I),
    .srst(TX_FIFO_RST_I),
    .din(TX_FIFO_D_I),
    .wr_en(TxFifoWrEn),
    .rd_en(TxFifoRdEn),
    .dout(TxFifoDataOut),
    .full(TX_FIFO_FULL_O),
    .empty(TxFifoEmpty)
);

assign TX_FIFO_EMPTY_O = TxFifoEmpty;

// FIFO instantiation for Rx
fifo_generator_0 Inst_PdmRxFifo (
    .clk(CLK_I),
    .srst(RX_FIFO_RST_I),
    .din(RxFifoDataIn),
    .wr_en(mic_data_valid_i),
    .rd_en(RxFifoRdEn),
    .dout(RX_FIFO_D_O),
    .full(RX_FIFO_FULL_O),
    .empty(RX_FIFO_EMPTY_O)
);

// Register all inputs of the FSM
always @(posedge CLK_I) begin
    StartTransaction <= START_TRANSACTION_I;
    StopTransaction <= STOP_TRANSACTION_I;
    Rnw <= RNW_I;
end

// Register and generate pulse out of rd/wr enables
always @(posedge CLK_I) begin
    RxFifoRdEn_dly <= RX_FIFO_RD_EN_I;
    TxFifoWrEn_dly <= TX_FIFO_WR_EN_I;
end

assign RxFifoRdEn = RX_FIFO_RD_EN_I & ~RxFifoRdEn_dly;
assign TxFifoWrEn = TX_FIFO_WR_EN_I & ~TxFifoWrEn_dly;

// Main FSM, register states, next state decode
always @(posedge CLK_I) begin
    if (RST_I == 1'b1) begin
        CState <= sIdle;
    end else begin
        CState <= NState;
    end
end

always @(*) begin
    NState = CState;
    case (CState)
        sIdle: if (StartTransaction == 1'b1) NState = sCheckRnw;
        sCheckRnw: if (Rnw == 1'b1) NState = sRead; else NState = sWrite;
        sWrite: if (TxFifoEmpty == 1'b1) NState = sIdle;
        sRead: if (StopTransaction == 1'b1) NState = sIdle;
        default: NState = sIdle;
    endcase
end

// Assert transmit enable
always @(posedge CLK_I) begin
    if (CState == sWrite) begin
        TxEn <= 1'b1;
    end else begin
        TxEn <= 1'b0;
    end
end

// Assert receive enable
always @(posedge CLK_I) begin
    if (CState == sRead) begin
        RxEn <= 1'b1;
    end else begin
        RxEn <= 1'b0;
    end
end

endmodule
