// Module : multiplexer
// Description : Multiplexeur 4→1 avec sélection par 2 switches
// Auteur : Exercice Nandland Go Board
// Date : 2025-11-01

module multiplexer (
    // Entrées : 2 switches pour la sélection
    input wire i_Switch_1,  // sel[0] - bit de poids faible
    input wire i_Switch_2,  // sel[1] - bit de poids fort

    // Sorties : LEDs pour visualisation
    output wire o_LED_1,    // Sortie du multiplexeur
    output wire o_LED_2,    // Écho sel[0]
    output wire o_LED_3,    // Écho sel[1]
    output wire o_LED_4     // Inverse de la sortie (pour visualisation)
);

    // Signal de sélection (2 bits)
    wire [1:0] w_Select;
    assign w_Select = {i_Switch_2, i_Switch_1};

    // 4 entrées de données câblées (pattern 4'b1010)
    // data[0] = 0, data[1] = 1, data[2] = 0, data[3] = 1
    wire [3:0] w_Data;
    assign w_Data = 4'b1010;

    // Multiplexeur 4→1 avec case statement
    reg r_Mux_Out;

    always @(*) begin
        case (w_Select)
            2'b00:   r_Mux_Out = w_Data[0];  // Sélection entrée 0
            2'b01:   r_Mux_Out = w_Data[1];  // Sélection entrée 1
            2'b10:   r_Mux_Out = w_Data[2];  // Sélection entrée 2
            2'b11:   r_Mux_Out = w_Data[3];  // Sélection entrée 3
            default: r_Mux_Out = 1'b0;       // Par défaut (jamais atteint)
        endcase
    end

    // Assignations des sorties
    assign o_LED_1 = r_Mux_Out;          // Sortie du mux
    assign o_LED_2 = i_Switch_1;         // Écho sel[0]
    assign o_LED_3 = i_Switch_2;         // Écho sel[1]
    assign o_LED_4 = ~r_Mux_Out;         // Inverse pour visualisation

endmodule
