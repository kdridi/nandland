// Chronomètre Simple 00-99
// Machine à états avec Start/Stop toggle et Reset

module stopwatch #(
    parameter DEBOUNCE_TIME = 250_000,  // 10 ms @ 25 MHz
    parameter CENTISECOND = 250_000     // 0.01s @ 25 MHz (simulation: 100)
)(
    input wire i_Clk,
    input wire i_Switch_1,      // Start/Stop (toggle)
    input wire i_Switch_2,      // Reset
    // Sorties génériques
    output wire [6:0] o_Segments1,  // Dizaines {G,F,E,D,C,B,A} actif bas
    output wire [6:0] o_Segments2   // Unités {G,F,E,D,C,B,A} actif bas
);

    // ============================================================
    // États de la machine à états
    // ============================================================
    localparam IDLE    = 2'b00;  // Arrêté à 00
    localparam RUNNING = 2'b01;  // Compte
    localparam STOPPED = 2'b10;  // En pause

    reg [1:0] r_State = IDLE;

    // ============================================================
    // Anti-rebond pour Switch_1 (Start/Stop)
    // ============================================================
    reg r_Sync1_1 = 0;
    reg r_Sync1_2 = 0;
    reg [17:0] r_Debounce1_Count = 0;
    reg r_Switch1_State = 0;

    always @(posedge i_Clk) begin
        r_Sync1_1 <= i_Switch_1;
        r_Sync1_2 <= r_Sync1_1;

        if (r_Sync1_2 != r_Switch1_State) begin
            r_Debounce1_Count <= r_Debounce1_Count + 1;
            if (r_Debounce1_Count >= DEBOUNCE_TIME) begin
                r_Switch1_State <= r_Sync1_2;
                r_Debounce1_Count <= 0;
            end
        end else begin
            r_Debounce1_Count <= 0;
        end
    end

    // ============================================================
    // Anti-rebond pour Switch_2 (Reset)
    // ============================================================
    reg r_Sync2_1 = 0;
    reg r_Sync2_2 = 0;
    reg [17:0] r_Debounce2_Count = 0;
    reg r_Switch2_State = 0;

    always @(posedge i_Clk) begin
        r_Sync2_1 <= i_Switch_2;
        r_Sync2_2 <= r_Sync2_1;

        if (r_Sync2_2 != r_Switch2_State) begin
            r_Debounce2_Count <= r_Debounce2_Count + 1;
            if (r_Debounce2_Count >= DEBOUNCE_TIME) begin
                r_Switch2_State <= r_Sync2_2;
                r_Debounce2_Count <= 0;
            end
        end else begin
            r_Debounce2_Count <= 0;
        end
    end

    // ============================================================
    // Détection de fronts
    // ============================================================
    reg r_Switch1_Prev = 0;
    reg r_Switch2_Prev = 0;

    wire w_StartStop_Edge = r_Switch1_State && !r_Switch1_Prev;
    wire w_Reset_Edge = r_Switch2_State && !r_Switch2_Prev;

    always @(posedge i_Clk) begin
        r_Switch1_Prev <= r_Switch1_State;
        r_Switch2_Prev <= r_Switch2_State;
    end

    // ============================================================
    // Diviseur de fréquence : 25 MHz → 100 Hz (0.01s)
    // ============================================================
    reg [17:0] r_Clk_Count = 0;
    reg r_Enable = 0;

    always @(posedge i_Clk) begin
        if (r_Clk_Count == CENTISECOND - 1) begin
            r_Clk_Count <= 0;
            r_Enable <= 1;
        end else begin
            r_Clk_Count <= r_Clk_Count + 1;
            r_Enable <= 0;
        end
    end

    // ============================================================
    // Compteur 0-99 avec machine à états
    // ============================================================
    reg [6:0] r_Counter = 0;

    always @(posedge i_Clk) begin
        if (w_Reset_Edge) begin
            // Reset : retour à IDLE et compteur à 0
            r_State <= IDLE;
            r_Counter <= 0;
        end else begin
            case (r_State)
                IDLE: begin
                    // Attente : Start/Stop démarre
                    if (w_StartStop_Edge)
                        r_State <= RUNNING;
                end

                RUNNING: begin
                    // Comptage actif
                    if (w_StartStop_Edge) begin
                        // Stop : pause
                        r_State <= STOPPED;
                    end else if (r_Enable) begin
                        // Incrémenter
                        if (r_Counter == 99)
                            r_Counter <= 0;  // Wrap
                        else
                            r_Counter <= r_Counter + 1;
                    end
                end

                STOPPED: begin
                    // Pause : garde la valeur
                    if (w_StartStop_Edge)
                        r_State <= RUNNING;  // Resume
                end

                default: begin
                    r_State <= IDLE;
                end
            endcase
        end
    end

    // ============================================================
    // Extraction dizaines et unités
    // ============================================================
    wire [3:0] w_Tens = r_Counter / 10;
    wire [3:0] w_Units = r_Counter % 10;

    // ============================================================
    // Décodeurs 7 segments
    // ============================================================
    reg [6:0] r_Segments_Tens;
    reg [6:0] r_Segments_Units;

    // Décodeur dizaines
    always @(*) begin
        case (w_Tens)
            4'd0: r_Segments_Tens = 7'b0111111;
            4'd1: r_Segments_Tens = 7'b0000110;
            4'd2: r_Segments_Tens = 7'b1011011;
            4'd3: r_Segments_Tens = 7'b1001111;
            4'd4: r_Segments_Tens = 7'b1100110;
            4'd5: r_Segments_Tens = 7'b1101101;
            4'd6: r_Segments_Tens = 7'b1111101;
            4'd7: r_Segments_Tens = 7'b0000111;
            4'd8: r_Segments_Tens = 7'b1111111;
            4'd9: r_Segments_Tens = 7'b1101111;
            default: r_Segments_Tens = 7'b0000000;
        endcase
    end

    // Décodeur unités
    always @(*) begin
        case (w_Units)
            4'd0: r_Segments_Units = 7'b0111111;
            4'd1: r_Segments_Units = 7'b0000110;
            4'd2: r_Segments_Units = 7'b1011011;
            4'd3: r_Segments_Units = 7'b1001111;
            4'd4: r_Segments_Units = 7'b1100110;
            4'd5: r_Segments_Units = 7'b1101101;
            4'd6: r_Segments_Units = 7'b1111101;
            4'd7: r_Segments_Units = 7'b0000111;
            4'd8: r_Segments_Units = 7'b1111111;
            4'd9: r_Segments_Units = 7'b1101111;
            default: r_Segments_Units = 7'b0000000;
        endcase
    end

    // Assignation (actif bas)
    assign o_Segments1 = ~r_Segments_Tens;
    assign o_Segments2 = ~r_Segments_Units;

endmodule
