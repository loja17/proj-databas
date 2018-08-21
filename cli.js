/**
 * Use internetbankens swish-application and list accounts
 */
"use strict";

const internetbanken = require("./src/internetbanken.js");

/**
 * Main function.
 * @returns void
 */
(function() {
    const readline = require("readline");
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    console.log("Välkommen till internetbanken! Här kan du se dina konton och använda swish.");
    rl.setPrompt("Internetbanken: ");
    rl.prompt();

    rl.on("close", process.exit);
    rl.on("line", async (line, lineArray) => {
        line = line.trim();
        lineArray = line.split(" ");
        line = lineArray[0];

        switch (line) {
            case "quit":
            case "exit":
                process.exit();
                break;
            case "help":
            case "menu":
                showMenu();
                rl.prompt();
                break;
            case "swish":
                swish(internetbanken, lineArray);
                //rl.prompt();
                break;
            case "konton":
                accounts(internetbanken, lineArray);
                //rl.prompt();
                break;
            default:
                console.info(`Okänt kommando, skriv 'menu' för att se tillgängliga kommandon.\n`);
                rl.prompt();
        }
    });
})();


/**
 * Show the menu on that can be done.
 *
 * @returns {void}
 */
function showMenu() {
    console.info(
        ` Du kan välja att göra följande: \n`
        + `  help, menu                                         - visa denna menyn.\n`
        + `  swish <användar-id> <pin> <från kontonummer> \n`
        + `  <summa> <till kontonummer>                         - swisha pengar.\n`
        + `  konton <användar-id> <pin>                         - lista dina bankkonton.\n`
        + `  exit, quit, ctrl-d                                 - avsluta programmet.`
    );
}


/**
 * Swish money.
 *
 * @returns {void}
 */
async function swish(internetbanken, lineArray) {
    await internetbanken.create(`swishMoney(${lineArray[1]}, ${lineArray[2]}, 
        '${lineArray[3]}', ${lineArray[4]}, '${lineArray[5]}' )`);

    console.info(`Du har nu swishat ${lineArray[4]} kronor till konto ${lineArray[5]}! `);
}


/**
 * Show accounts of accountHolder.
 *
 * @returns {void}
 */
async function accounts(internetbanken, lineArray) {
    let str = await internetbanken.showTableAccounts(`showAccountsByIdPin
        (${lineArray[1]}, ${lineArray[2]})`);

    console.info(`Mina konton:`);
    console.info(str);
}
