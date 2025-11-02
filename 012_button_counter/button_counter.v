// Compteur 0-9 avec Boutons Inc/Dec
// Combine anti-rebond + détection de fronts + compteur + afficheur 7 segments

module button_counter #(
    parameter DEBOUNCE_TIME = 250_000  // 10 ms @ 25 MHz (simulation: 50)
)(
    input wire i_Clk,           // Horloge 25 MHz
    input wire i_Switch_1,      // Bouton increment (+)
    input wire i_Switch_2,      // Bouton decrement (-)
    // Afficheur 7 segments (sortie générique)
    output wire [6:0] o_Segments  // {G,F,E,D,C,B,A} actif bas
);

    // ============================================================
    // Anti-rebond pour Switch_1 (Increment)
    // ============================================================
    reg r_Sync1_1 = 0;
    reg r_Sync1_2 = 0;
    reg [17:0] r_Debounce1_Count = 0;
    reg r_Switch1_State = 0;

    always @(posedge i_Clk) begin
        // Synchronisation
        r_Sync1_1 <= i_Switch_1;
        r_Sync1_2 <= r_Sync1_1;

        // Anti-rebond
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
    // Anti-rebond pour Switch_2 (Decrement)
    // ============================================================
    reg r_Sync2_1 = 0;
    reg r_Sync2_2 = 0;
    reg [17:0] r_Debounce2_Count = 0;
    reg r_Switch2_State = 0;

    always @(posedge i_Clk) begin
        // Synchronisation
        r_Sync2_1 <= i_Switch_2;
        r_Sync2_2 <= r_Sync2_1;

        // Anti-rebond
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
    // Détection de fronts montants
    // ============================================================
    reg r_Switch1_Prev = 0;
    reg r_Switch2_Prev = 0;

    wire w_Inc_Edge = r_Switch1_State && !r_Switch1_Prev;  // Front montant Inc
    wire w_Dec_Edge = r_Switch2_State && !r_Switch2_Prev;  // Front montant Dec

    always @(posedge i_Clk) begin
        r_Switch1_Prev <= r_Switch1_State;
        r_Switch2_Prev <= r_Switch2_State;
    end

    // ============================================================
    // Compteur 0-9
    // ============================================================
    reg [3:0] r_Counter = 0;

    always @(posedge i_Clk) begin
        if (w_Inc_Edge && w_Dec_Edge) begin
            // Les deux en même temps : priorité à l'increment
            if (r_Counter == 9)
                r_Counter <= 0;
            else
                r_Counter <= r_Counter + 1;
        end else if (w_Inc_Edge) begin
            // Increment seul
            if (r_Counter == 9)
                r_Counter <= 0;
            else
                r_Counter <= r_Counter + 1;
        end else if (w_Dec_Edge) begin
            // Decrement seul
            if (r_Counter == 0)
                r_Counter <= 9;
            else
                r_Counter <= r_Counter - 1;
        end
        // Sinon : garde la valeur
    end

    // ============================================================
    // Décodeur 7 segments
    // ============================================================
    reg [6:0] r_Segments;

    always @(*) begin
        case (r_Counter)
            4'd0: r_Segments = 7'b0111111;  // 0
            4'd1: r_Segments = 7'b0000110;  // 1
            4'd2: r_Segments = 7'b1011011;  // 2
            4'd3: r_Segments = 7'b1001111;  // 3
            4'd4: r_Segments = 7'b1100110;  // 4
            4'd5: r_Segments = 7'b1101101;  // 5
            4'd6: r_Segments = 7'b1111101;  // 6
            4'd7: r_Segments = 7'b0000111;  // 7
            4'd8: r_Segments = 7'b1111111;  // 8
            4'd9: r_Segments = 7'b1101111;  // 9
            default: r_Segments = 7'b0000000;  // Éteint
        endcase
    end

    // Assignation de la sortie (actif bas)
    assign o_Segments = ~r_Segments;  // {G,F,E,D,C,B,A}

endmodule
