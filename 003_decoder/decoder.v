// Module : decoder
// Description : Décodeur binaire 2→4 (inverse du multiplexeur)
// Auteur : Exercice Nandland Go Board
// Date : 2025-11-01

module decoder (
    // Entrées : 2 switches pour le code binaire
    input wire i_Switch_1,  // code[0] - bit de poids faible
    input wire i_Switch_2,  // code[1] - bit de poids fort

    // Sorties : 4 LEDs (une seule allumée à la fois)
    output wire o_LED_1,    // Sortie 0 (actif si code=00)
    output wire o_LED_2,    // Sortie 1 (actif si code=01)
    output wire o_LED_3,    // Sortie 2 (actif si code=10)
    output wire o_LED_4     // Sortie 3 (actif si code=11)
);

    // Signal de code binaire (2 bits)
    wire [1:0] w_Code;
    assign w_Code = {i_Switch_2, i_Switch_1};

    // Décodeur 2→4 : active une seule sortie selon le code
    // Méthode 1 : Logique combinatoire directe
    assign o_LED_1 = (w_Code == 2'b00);  // Actif si code=00
    assign o_LED_2 = (w_Code == 2'b01);  // Actif si code=01
    assign o_LED_3 = (w_Code == 2'b10);  // Actif si code=10
    assign o_LED_4 = (w_Code == 2'b11);  // Actif si code=11

    // Alternative avec case statement (commentée)
    /*
    reg [3:0] r_Outputs;

    always @(*) begin
        case (w_Code)
            2'b00:   r_Outputs = 4'b0001;  // Active LED_1
            2'b01:   r_Outputs = 4'b0010;  // Active LED_2
            2'b10:   r_Outputs = 4'b0100;  // Active LED_3
            2'b11:   r_Outputs = 4'b1000;  // Active LED_4
            default: r_Outputs = 4'b0000;  // Toutes OFF
        endcase
    end

    assign {o_LED_4, o_LED_3, o_LED_2, o_LED_1} = r_Outputs;
    */

endmodule
