// Module d'Anti-rebond de Bouton
// Filtre les rebonds mécaniques et génère un signal stable

module button_debounce #(
    parameter DEBOUNCE_TIME = 250_000  // 10 ms @ 25 MHz (simulation: 50)
)(
    input wire i_Clk,           // Horloge 25 MHz
    input wire i_Switch_1,      // Signal brut du bouton/switch
    output wire o_LED_1         // LED affiche l'état filtré stable
);

    // Synchronisation double pour éviter la métastabilité
    // Tout signal externe asynchrone doit être synchronisé
    reg r_Sync_1 = 0;
    reg r_Sync_2 = 0;

    always @(posedge i_Clk) begin
        r_Sync_1 <= i_Switch_1;  // Premier étage
        r_Sync_2 <= r_Sync_1;    // Deuxième étage (signal synchronisé)
    end

    // Compteur d'anti-rebond
    // Doit compter jusqu'à DEBOUNCE_TIME (18 bits pour 250_000)
    reg [17:0] r_Debounce_Count = 0;

    // État stable du bouton
    reg r_Switch_State = 0;

    // Logique d'anti-rebond
    always @(posedge i_Clk) begin
        if (r_Sync_2 != r_Switch_State) begin
            // Le signal synchronisé est différent de l'état stable
            // Incrémenter le compteur
            r_Debounce_Count <= r_Debounce_Count + 1;

            // Si le signal reste différent pendant DEBOUNCE_TIME cycles
            // alors c'est une vraie transition, pas un rebond
            if (r_Debounce_Count >= DEBOUNCE_TIME) begin
                r_Switch_State <= r_Sync_2;      // Valider la nouvelle valeur
                r_Debounce_Count <= 0;           // Réinitialiser le compteur
            end
        end else begin
            // Le signal synchronisé = état stable
            // Réinitialiser le compteur (transition annulée ou pas de changement)
            r_Debounce_Count <= 0;
        end
    end

    // Sortie LED = état stable
    assign o_LED_1 = r_Switch_State;

endmodule
