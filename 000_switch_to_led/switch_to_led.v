// Module : switch_to_led
// Description : Connecte directement les 4 switches aux 4 LEDs
// Auteur : Exercice Nandland Go Board
// Date : 2025-11-01

module switch_to_led (
    // Entrées : 4 commutateurs (switches)
    input wire i_Switch_1,
    input wire i_Switch_2,
    input wire i_Switch_3,
    input wire i_Switch_4,

    // Sorties : 4 LEDs
    output wire o_LED_1,
    output wire o_LED_2,
    output wire o_LED_3,
    output wire o_LED_4
);

    // Assignation continue : connexion directe switch → LED
    assign o_LED_1 = i_Switch_1;
    assign o_LED_2 = i_Switch_2;
    assign o_LED_3 = i_Switch_3;
    assign o_LED_4 = i_Switch_4;

endmodule
