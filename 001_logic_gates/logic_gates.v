// Module : logic_gates
// Description : Implémente les portes logiques de base (AND, OR, XOR, NOT)
// Auteur : Exercice Nandland Go Board
// Date : 2025-11-01

module logic_gates (
    // Entrées : 2 switches utilisés (A et B)
    input wire i_Switch_1,  // A
    input wire i_Switch_2,  // B

    // Sorties : 4 LEDs pour les différentes portes
    output wire o_LED_1,    // A AND B
    output wire o_LED_2,    // A OR B
    output wire o_LED_3,    // A XOR B
    output wire o_LED_4     // NOT A
);

    // Porte AND : Allumée seulement si A ET B sont à 1
    assign o_LED_1 = i_Switch_1 & i_Switch_2;

    // Porte OR : Allumée si A OU B est à 1
    assign o_LED_2 = i_Switch_1 | i_Switch_2;

    // Porte XOR : Allumée si A et B sont différents
    assign o_LED_3 = i_Switch_1 ^ i_Switch_2;

    // Porte NOT : Inverse l'état de A
    assign o_LED_4 = ~i_Switch_1;

endmodule
